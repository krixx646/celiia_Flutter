import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../models/celia_chat_message.dart';
import 'supabase_service.dart';

/// One decoded event from the coach stream.
sealed class CeliaStreamEvent {
  const CeliaStreamEvent();
}

/// The server-assigned conversation id, emitted before any content.
class CeliaConversationStarted extends CeliaStreamEvent {
  final String conversationId;
  const CeliaConversationStarted(this.conversationId);
}

class CeliaTextDelta extends CeliaStreamEvent {
  final String delta;
  const CeliaTextDelta(this.delta);
}

/// A tool call was created or changed state.
class CeliaToolUpdate extends CeliaStreamEvent {
  final ChatToolCall call;
  const CeliaToolUpdate(this.call);
}

class CeliaStreamError extends CeliaStreamEvent {
  final String message;
  const CeliaStreamError(this.message);
}

/// Talks to the agentic coach backend (`/api/mobile/chat`).
///
/// The backend replies with a Server-Sent Events stream of JSON parts (the AI
/// SDK UI message protocol) rather than one JSON blob, so text can render token
/// by token and tool activity can be shown as it happens.
class CeliaChatService {
  CeliaChatService({FirebaseAuth? firebaseAuth, http.Client? httpClient})
    : _injectedAuth = firebaseAuth,
      _httpClient = httpClient ?? http.Client();

  final FirebaseAuth? _injectedAuth;

  /// Resolved on use so constructing the service does not require Firebase to
  /// be initialised.
  FirebaseAuth get _firebaseAuth => _injectedAuth ?? FirebaseAuth.instance;
  final http.Client _httpClient;

  @visibleForTesting
  static String Function() backendBaseUrl = () => Env.celiaBackendBaseUrl;

  /// Generous: the backend caps itself at 60s, and a multi-tool turn can use
  /// most of that before the final sentence arrives.
  static const Duration _streamTimeout = Duration(seconds: 120);

  Future<String> _idToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw SupabaseException(
        'Not signed in',
        'Please sign in before chatting with Celia.',
      );
    }
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw SupabaseException('Not signed in', 'Could not read your session.');
    }
    return token;
  }

  String _baseUrl() {
    final base = backendBaseUrl().trim();
    if (base.isEmpty) {
      throw SupabaseException(
        'Backend not configured',
        'Provide CELIA_BACKEND_BASE_URL via --dart-define before using chat.',
      );
    }
    return base;
  }

  /// Sends a turn and streams Celia's reply.
  ///
  /// Pass [approvals] to answer confirmations she asked for on the previous
  /// turn; [message] may be empty in that case.
  Stream<CeliaStreamEvent> send({
    String? conversationId,
    String message = '',
    Map<String, dynamic>? userState,
    List<({String approvalId, bool approved})> approvals = const [],
  }) {
    final controller = StreamController<CeliaStreamEvent>();

    Future<void> run() async {
      try {
        final token = await _idToken();
        final request = http.Request(
          'POST',
          Uri.parse('${_baseUrl()}/api/mobile/chat'),
        );
        request.headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
          'Authorization': 'Bearer $token',
        });
        request.body = jsonEncode({
          if (conversationId != null && conversationId.isNotEmpty)
            'conversationId': conversationId,
          if (message.isNotEmpty) 'message': message,
          'tzOffsetMinutes': DateTime.now().timeZoneOffset.inMinutes,
          if (userState != null) 'state': userState,
          if (approvals.isNotEmpty)
            'approvals': approvals
                .map((a) => {'approvalId': a.approvalId, 'approved': a.approved})
                .toList(),
        });

        final response = await _httpClient.send(request);

        if (response.statusCode < 200 || response.statusCode >= 300) {
          final body = await response.stream.bytesToString();
          controller.add(CeliaStreamError(_errorFrom(body, response.statusCode)));
          return;
        }

        final serverConversationId = response.headers['x-conversation-id'];
        if (serverConversationId != null && serverConversationId.isNotEmpty) {
          controller.add(CeliaConversationStarted(serverConversationId));
        }

        final state = _StreamState();

        final lines = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .timeout(_streamTimeout);

        await for (final line in lines) {
          if (!line.startsWith('data:')) continue;
          final payload = line.substring(5).trim();
          if (payload.isEmpty || payload == '[DONE]') continue;

          final Map<String, dynamic> part;
          try {
            final decoded = jsonDecode(payload);
            if (decoded is! Map<String, dynamic>) continue;
            part = decoded;
          } catch (_) {
            continue;
          }

          final event = _decodePart(part, state);
          if (event != null) controller.add(event);
        }
      } catch (e) {
        controller.add(CeliaStreamError(_friendlyError(e)));
      } finally {
        await controller.close();
      }
    }

    run();
    return controller.stream;
  }

  CeliaStreamEvent? _decodePart(Map<String, dynamic> part, _StreamState state) {
    final type = part['type']?.toString() ?? '';

    switch (type) {
      case 'text-start':
        // A turn that calls a tool speaks twice: once before the call and once
        // after it, as two separate text blocks. Without a break here the
        // sentence before the call runs straight into the answer after it.
        return state.wroteText ? const CeliaTextDelta('\n\n') : null;

      case 'text-delta':
        final delta = part['delta'];
        if (delta is! String || delta.isEmpty) return null;
        state.wroteText = true;
        return CeliaTextDelta(delta);

      case 'tool-input-start':
        final id = part['toolCallId']?.toString() ?? '';
        if (id.isEmpty) return null;
        final call = ChatToolCall(
          toolCallId: id,
          toolName: part['toolName']?.toString() ?? '',
          phase: ToolPhase.preparing,
        );
        state.calls[id] = call;
        return CeliaToolUpdate(call);

      case 'tool-input-available':
        final id = part['toolCallId']?.toString() ?? '';
        if (id.isEmpty) return null;
        final existing =
            state.calls[id] ??
            ChatToolCall(
              toolCallId: id,
              toolName: part['toolName']?.toString() ?? '',
            );
        final updated = existing.copyWith(
          toolName: part['toolName']?.toString(),
          // Writes get held at awaitingApproval by the approval-request part
          // that follows; reads start executing immediately.
          phase: ToolPhase.running,
          input: part['input'] is Map
              ? Map<String, dynamic>.from(part['input'] as Map)
              : null,
        );
        state.calls[id] = updated;
        return CeliaToolUpdate(updated);

      case 'tool-approval-request':
        final id = part['toolCallId']?.toString() ?? '';
        if (id.isEmpty) return null;
        // An automatic decision needs no prompt.
        if (part['isAutomatic'] == true) return null;
        final existing =
            state.calls[id] ?? ChatToolCall(toolCallId: id, toolName: '');
        final updated = existing.copyWith(
          phase: ToolPhase.awaitingApproval,
          approvalId: part['approvalId']?.toString(),
        );
        state.calls[id] = updated;
        return CeliaToolUpdate(updated);

      case 'tool-output-available':
        final id = part['toolCallId']?.toString() ?? '';
        if (id.isEmpty) return null;
        final existing =
            state.calls[id] ?? ChatToolCall(toolCallId: id, toolName: '');
        final updated = existing.copyWith(
          phase: ToolPhase.done,
          output: part['output'] is Map
              ? Map<String, dynamic>.from(part['output'] as Map)
              : null,
        );
        state.calls[id] = updated;
        return CeliaToolUpdate(updated);

      case 'tool-output-denied':
        final id = part['toolCallId']?.toString() ?? '';
        if (id.isEmpty) return null;
        final existing =
            state.calls[id] ?? ChatToolCall(toolCallId: id, toolName: '');
        final updated = existing.copyWith(phase: ToolPhase.denied);
        state.calls[id] = updated;
        return CeliaToolUpdate(updated);

      case 'tool-output-error':
        final id = part['toolCallId']?.toString() ?? '';
        if (id.isEmpty) return null;
        final existing =
            state.calls[id] ?? ChatToolCall(toolCallId: id, toolName: '');
        final updated = existing.copyWith(phase: ToolPhase.failed);
        state.calls[id] = updated;
        return CeliaToolUpdate(updated);

      case 'error':
        return CeliaStreamError(
          part['errorText']?.toString() ?? 'Celia ran into a problem.',
        );

      default:
        // start / start-step / finish-step / finish / text-end and any future
        // part types need no UI state of their own.
        return null;
    }
  }

  /// Loads the user's saved conversations, newest first.
  Future<List<ChatConversation>> listConversations() async {
    final token = await _idToken();
    final response = await _httpClient
        .get(
          Uri.parse('${_baseUrl()}/api/mobile/chat/conversations'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));

    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SupabaseException(_errorFrom(body, response.statusCode), body);
    }

    final json = body.isEmpty ? const {} : jsonDecode(body);
    final list = json is Map ? json['conversations'] : null;
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((row) => ChatConversation.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  /// Loads the messages of one conversation.
  Future<List<CeliaMessage>> loadConversation(String conversationId) async {
    final token = await _idToken();
    final response = await _httpClient
        .get(
          Uri.parse(
            '${_baseUrl()}/api/mobile/chat/conversations/$conversationId',
          ),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));

    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SupabaseException(_errorFrom(body, response.statusCode), body);
    }

    final json = body.isEmpty ? const {} : jsonDecode(body);
    final list = json is Map ? json['messages'] : null;
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(
          (row) => CeliaMessage.fromStoredJson(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  Future<void> deleteConversation(String conversationId) async {
    final token = await _idToken();
    final response = await _httpClient
        .delete(
          Uri.parse(
            '${_baseUrl()}/api/mobile/chat/conversations/$conversationId',
          ),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = utf8.decode(response.bodyBytes);
      throw SupabaseException(_errorFrom(body, response.statusCode), body);
    }
  }

  String _errorFrom(String body, int statusCode) {
    if (statusCode == 401) return 'Your session expired. Please sign in again.';
    try {
      final json = jsonDecode(body);
      if (json is Map && json['error'] != null) return json['error'].toString();
    } catch (_) {
      // Fall through to the generic message.
    }
    return 'Celia is unavailable right now. Please try again.';
  }

  String _friendlyError(Object error) {
    if (error is SupabaseException) return error.message;
    if (error is TimeoutException) {
      return 'Celia took too long to reply. Please try again.';
    }
    return 'Celia is unavailable right now. Please try again.';
  }

  void dispose() {
    _httpClient.close();
  }
}

/// Per-stream bookkeeping.
///
/// Tool calls are tracked because the protocol sends a call's name, input and
/// output as separate events, and each update needs to carry the full state.
class _StreamState {
  final Map<String, ChatToolCall> calls = {};
  bool wroteText = false;
}
