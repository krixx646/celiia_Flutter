import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';

class BotpressApi {
  static const String _baseUrl = 'https://chat.botpress.cloud/71a1f5b1-470d-483a-a35b-45fab38502f1/';
  
  final http.Client _client = http.Client();

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

  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = json.decode(response.body);
      return fromJson(data);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.request?.url} -> ${response.body}');
    }
  }

  Future<BotpressUserResponse> createUser(CreateUserRequest request) async {
    final url = Uri.parse('${_baseUrl}users');
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Botpress] POST $url body=${request.toJson()}');
    }
    final response = await _client.post(url, headers: _getHeaders(), body: json.encode(request.toJson()));
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Botpress] <- ${response.statusCode} ${response.body}');
    }
    return _handleResponse(response, BotpressUserResponse.fromJson);
  }

  Future<BotpressConversationResponse> createConversation(
    String userKey,
    CreateConversationRequest request,
  ) async {
    final url = Uri.parse('${_baseUrl}conversations');
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Botpress] POST $url headers={X-User-Key:$userKey} body=${request.toJson()}');
    }
    final response = await _client.post(url, headers: _getHeaders(userKey: userKey), body: json.encode(request.toJson()));
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Botpress] <- ${response.statusCode} ${response.body}');
    }
    return _handleResponse(response, BotpressConversationResponse.fromJson);
  }

  Future<BotpressMessageResponse> sendMessage(
    String userKey,
    String conversationId,
    SimpleMessageRequest request,
  ) async {
    // Use the Kotlin app's direct message route: POST /messages with conversationId + payload
    final url = Uri.parse('${_baseUrl}messages');
    final body = MessageWithConversation(
      conversationId: conversationId,
      payload: MessagePayload(type: request.type, text: request.text),
    ).toJson();
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Botpress] POST $url headers={X-User-Key:$userKey} body=$body');
    }
    final response = await _client.post(url, headers: _getHeaders(userKey: userKey), body: json.encode(body));
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Botpress] <- ${response.statusCode} ${response.body}');
    }
    return _handleResponse(response, BotpressMessageResponse.fromJson);
  }

  Future<BotpressMessageResponse> sendMessagePayload(
    String userKey,
    String conversationId,
    MessagePayload payload,
  ) async {
    final url = Uri.parse('${_baseUrl}messages');
    final body = MessageWithConversation(
      conversationId: conversationId,
      payload: payload,
    ).toJson();
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Botpress] POST $url headers={X-User-Key:$userKey} body=$body');
    }
    final response = await _client.post(url, headers: _getHeaders(userKey: userKey), body: json.encode(body));
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Botpress] <- ${response.statusCode} ${response.body}');
    }
    return _handleResponse(response, BotpressMessageResponse.fromJson);
  }

  Future<BotpressMessagesResponse> getMessages(
    String userKey,
    String conversationId,
  ) async {
    final url = Uri.parse('${_baseUrl}conversations/$conversationId/messages');
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Botpress] GET $url headers={X-User-Key:$userKey}');
    }
    final response = await _client.get(url, headers: _getHeaders(userKey: userKey));
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Botpress] <- ${response.statusCode} ${response.body}');
    }
    return _handleResponse(response, BotpressMessagesResponse.fromJson);
  }

  Future<void> deleteConversation(String userKey, String conversationId) async {
    final url = Uri.parse('${_baseUrl}conversations/$conversationId');
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Botpress] DELETE $url headers={X-User-Key:$userKey}');
    }
    final response = await _client.delete(url, headers: _getHeaders(userKey: userKey));
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Botpress] <- ${response.statusCode} ${response.body}');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete conversation: ${response.request?.url} -> ${response.body}');
    }
  }

  void dispose() {
    _client.close();
  }
}


