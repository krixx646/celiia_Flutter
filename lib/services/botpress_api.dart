import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';

class BotpressApi {
  static const String _baseUrl =
      'https://chat.botpress.cloud/71a1f5b1-470d-483a-a35b-45fab38502f1/';

  final http.Client _client;
  final String _base;

  BotpressApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _base = (baseUrl ?? _baseUrl);

  Map<String, String> _getHeaders({String? userKey}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (userKey != null) {
      headers['X-User-Key'] = userKey;
    }
    return headers;
  }

  void _logRequest(String method, Uri url, {String? userKey}) {
    if (!kDebugMode) return;
    final authState = userKey == null ? 'public' : 'authenticated';
    debugPrint('[Botpress] $method $url ($authState)');
  }

  void _logResponse(http.Response response, Uri url) {
    if (!kDebugMode) return;
    debugPrint(
      '[Botpress] <- ${response.statusCode} ${response.request?.url ?? url} (${response.body.length} chars)',
    );
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = json.decode(response.body);
      return fromJson(data);
    } else {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.request?.url} -> ${response.body}',
      );
    }
  }

  Future<BotpressUserResponse> createUser(CreateUserRequest request) async {
    final url = Uri.parse('${_base}users');
    _logRequest('POST', url);
    final response = await _client.post(
      url,
      headers: _getHeaders(),
      body: json.encode(request.toJson()),
    );
    _logResponse(response, url);
    return _handleResponse(response, BotpressUserResponse.fromJson);
  }

  Future<BotpressConversationResponse> createConversation(
    String userKey,
    CreateConversationRequest request,
  ) async {
    final url = Uri.parse('${_base}conversations');
    _logRequest('POST', url, userKey: userKey);
    final response = await _client.post(
      url,
      headers: _getHeaders(userKey: userKey),
      body: json.encode(request.toJson()),
    );
    _logResponse(response, url);
    return _handleResponse(response, BotpressConversationResponse.fromJson);
  }

  Future<BotpressMessageResponse> sendMessage(
    String userKey,
    String conversationId,
    SimpleMessageRequest request,
  ) async {
    // Use the Kotlin app's direct message route: POST /messages with conversationId + payload
    final url = Uri.parse('${_base}messages');
    final body = MessageWithConversation(
      conversationId: conversationId,
      payload: MessagePayload(type: request.type, text: request.text),
    ).toJson();
    _logRequest('POST', url, userKey: userKey);
    final response = await _client.post(
      url,
      headers: _getHeaders(userKey: userKey),
      body: json.encode(body),
    );
    _logResponse(response, url);
    return _handleResponse(response, BotpressMessageResponse.fromJson);
  }

  Future<BotpressMessageResponse> sendMessagePayload(
    String userKey,
    String conversationId,
    MessagePayload payload,
  ) async {
    final url = Uri.parse('${_base}messages');
    final body = MessageWithConversation(
      conversationId: conversationId,
      payload: payload,
    ).toJson();
    _logRequest('POST', url, userKey: userKey);
    final response = await _client.post(
      url,
      headers: _getHeaders(userKey: userKey),
      body: json.encode(body),
    );
    _logResponse(response, url);
    return _handleResponse(response, BotpressMessageResponse.fromJson);
  }

  Future<BotpressMessagesResponse> getMessages(
    String userKey,
    String conversationId,
  ) async {
    final url = Uri.parse('${_base}conversations/$conversationId/messages');
    _logRequest('GET', url, userKey: userKey);
    final response = await _client.get(
      url,
      headers: _getHeaders(userKey: userKey),
    );
    _logResponse(response, url);
    return _handleResponse(response, BotpressMessagesResponse.fromJson);
  }

  Future<void> deleteConversation(String userKey, String conversationId) async {
    final url = Uri.parse('${_base}conversations/$conversationId');
    _logRequest('DELETE', url, userKey: userKey);
    final response = await _client.delete(
      url,
      headers: _getHeaders(userKey: userKey),
    );
    _logResponse(response, url);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to delete conversation: ${response.request?.url} -> ${response.body}',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
