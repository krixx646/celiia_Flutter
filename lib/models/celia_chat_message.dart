// Chat models for the Celia coach.
//
// A message carries the tools Celia used while answering, not just its text, so
// the UI can show what she did and ask permission before she changes anything.

enum ChatRole { user, assistant }

/// Where a tool call has got to. Anything that writes to the user's data pauses
/// at [awaitingApproval] until they confirm.
enum ToolPhase { preparing, awaitingApproval, running, done, denied, failed }

class ChatToolCall {
  final String toolCallId;
  final String toolName;
  final ToolPhase phase;
  final Map<String, dynamic>? input;
  final Map<String, dynamic>? output;

  /// Set when Celia is waiting on a yes/no. Sent back to approve or decline.
  final String? approvalId;

  const ChatToolCall({
    required this.toolCallId,
    required this.toolName,
    this.phase = ToolPhase.preparing,
    this.input,
    this.output,
    this.approvalId,
  });

  ChatToolCall copyWith({
    String? toolName,
    ToolPhase? phase,
    Map<String, dynamic>? input,
    Map<String, dynamic>? output,
    String? approvalId,
  }) {
    return ChatToolCall(
      toolCallId: toolCallId,
      toolName: toolName ?? this.toolName,
      phase: phase ?? this.phase,
      input: input ?? this.input,
      output: output ?? this.output,
      approvalId: approvalId ?? this.approvalId,
    );
  }

  /// Present-tense status shown while the tool runs.
  String get activityLabel {
    switch (toolName) {
      case 'get_my_progress':
        return 'Checking your progress';
      case 'get_today_nutrition':
        return 'Checking what you ate today';
      case 'list_my_meals':
        return 'Reviewing your recent meals';
      case 'list_my_routines':
        return 'Looking at your routines';
      case 'get_routine_details':
        return 'Reading that routine';
      case 'search_exercises':
        return 'Searching the exercise library';
      case 'create_routine':
        return 'Building your routine';
      case 'log_meal':
        return 'Logging your meal';
      case 'save_routine':
        return 'Saving to your library';
      default:
        return 'Working on it';
    }
  }

  /// The question to put to the user before a write runs.
  String get approvalPrompt {
    switch (toolName) {
      case 'create_routine':
        final title = input?['title'];
        final steps = input?['steps'];
        final count = steps is List ? steps.length : 0;
        final name = title is String && title.isNotEmpty
            ? title
            : 'this routine';
        return count > 0
            ? 'Save "$name" with $count exercises to your library?'
            : 'Save "$name" to your library?';
      case 'log_meal':
        final title = input?['title'];
        final calories = input?['calories'];
        final name = title is String && title.isNotEmpty ? title : 'this meal';
        return calories is num
            ? 'Log "$name" at ${calories.round()} kcal?'
            : 'Log "$name"?';
      case 'save_routine':
        return 'Add this routine to your library?';
      default:
        return 'Allow Celia to do this?';
    }
  }

  /// The exercises in a pending `create_routine`, for previewing the plan.
  List<String> get proposedExercises {
    final steps = input?['steps'];
    if (steps is! List) return const [];
    return steps
        .map((step) {
          if (step is! Map) return '';
          final title = step['title'];
          if (title is String && title.isNotEmpty) return title;
          final slug = step['exerciseSlug'];
          return slug is String ? slug.replaceAll('-', ' ') : '';
        })
        .where((title) => title.isNotEmpty)
        .cast<String>()
        .toList();
  }
}

class CeliaMessage {
  final String id;
  final ChatRole role;
  final String text;
  final List<ChatToolCall> toolCalls;

  /// True while deltas are still arriving for this message.
  final bool isStreaming;
  final String? error;

  const CeliaMessage({
    required this.id,
    required this.role,
    this.text = '',
    this.toolCalls = const [],
    this.isStreaming = false,
    this.error,
  });

  factory CeliaMessage.user(String text) {
    return CeliaMessage(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.user,
      text: text,
    );
  }

  bool get isUser => role == ChatRole.user;

  /// The write Celia is currently waiting on permission for, if any.
  ChatToolCall? get pendingApproval {
    for (final call in toolCalls) {
      if (call.phase == ToolPhase.awaitingApproval && call.approvalId != null) {
        return call;
      }
    }
    return null;
  }

  /// The routine this message should offer to open: one Celia just created, or
  /// the original she pointed to instead of saving a duplicate of it.
  ({String routineId, String title, bool alreadyExisted})? get createdRoutine {
    for (final call in toolCalls) {
      if (call.toolName != 'create_routine') continue;
      final output = call.output;
      if (output == null) continue;
      final alreadyExisted = output['alreadyExists'] == true;
      if (output['created'] != true && !alreadyExisted) continue;
      final id = output['routineId'];
      final title = output['title'];
      if (id is String && id.isNotEmpty) {
        return (
          routineId: id,
          title: title is String ? title : 'Your routine',
          alreadyExisted: alreadyExisted,
        );
      }
    }
    return null;
  }

  /// Nothing rendered yet — used to show a thinking indicator.
  bool get isEmpty => text.trim().isEmpty && toolCalls.isEmpty;

  CeliaMessage copyWith({
    String? id,
    String? text,
    List<ChatToolCall>? toolCalls,
    bool? isStreaming,
    String? error,
  }) {
    return CeliaMessage(
      id: id ?? this.id,
      role: role,
      text: text ?? this.text,
      toolCalls: toolCalls ?? this.toolCalls,
      isStreaming: isStreaming ?? this.isStreaming,
      error: error ?? this.error,
    );
  }

  /// Rebuilds a persisted message from the `parts` stored by the backend.
  factory CeliaMessage.fromStoredJson(Map<String, dynamic> json) {
    final role = json['role'] == 'user' ? ChatRole.user : ChatRole.assistant;
    final parts = json['parts'];
    final buffer = StringBuffer();
    final calls = <ChatToolCall>[];

    if (parts is List) {
      for (final part in parts) {
        if (part is! Map) continue;
        final type = part['type'];
        if (type == 'text') {
          final text = part['text'];
          if (text is String && text.isNotEmpty) {
            if (buffer.isNotEmpty) buffer.write('\n');
            buffer.write(text);
          }
        } else if (type is String && type.startsWith('tool-')) {
          calls.add(
            ChatToolCall(
              toolCallId: part['toolCallId']?.toString() ?? '',
              toolName: type.substring('tool-'.length),
              phase: _phaseFromStoredState(part['state']?.toString()),
              input: part['input'] is Map
                  ? Map<String, dynamic>.from(part['input'] as Map)
                  : null,
              output: part['output'] is Map
                  ? Map<String, dynamic>.from(part['output'] as Map)
                  : null,
            ),
          );
        }
      }
    }

    final content = json['content'];
    final text = buffer.isNotEmpty
        ? buffer.toString()
        : (content is String ? content : '');

    return CeliaMessage(
      id:
          json['id']?.toString() ??
          'stored_${DateTime.now().microsecondsSinceEpoch}',
      role: role,
      text: text,
      toolCalls: calls,
    );
  }

  static ToolPhase _phaseFromStoredState(String? state) {
    switch (state) {
      case 'approval-requested':
        return ToolPhase.awaitingApproval;
      case 'output-available':
        return ToolPhase.done;
      case 'output-denied':
        return ToolPhase.denied;
      case 'output-error':
        return ToolPhase.failed;
      default:
        // Includes 'approval-responded': the decision was already made, and a
        // reloaded conversation should not re-prompt for it.
        return ToolPhase.done;
    }
  }
}

/// A saved conversation in the history list.
class ChatConversation {
  final String id;
  final String title;
  final DateTime updatedAt;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Chat',
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
