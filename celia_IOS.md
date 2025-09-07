# Celia iOS Conversion - Complete Step-by-Step Plan

**Convert Android Kotlin app to iOS using Flutter + Windows + Codemagic (No Mac Required)**

## Overview

This plan converts your existing Android Celia app to iOS using:
- ✅ **Flutter framework** (single codebase for both platforms)
- ✅ **Windows development** (no Mac needed)
- ✅ **Codemagic cloud builds** (handles iOS compilation)
- ✅ **OpenSSL certificate generation** (Windows-based)

**Timeline: 7-9 days total**

---

## Phase 1: Environment Setup (Day 1, 2-4 hours)

### Step 1.1: Install Flutter
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\flutter
# Add C:\flutter\bin to your PATH environment variable

# Verify installation
flutter doctor
# Install any missing components for Android development
```

### Step 1.2: Create Flutter Project Structure
```bash
# Navigate to your workspace
cd C:\Users\ADMIN\Desktop

# Create new Flutter project
flutter create celia_flutter
cd celia_flutter

# Verify it works
flutter run -d <your-android-device-or-emulator>
```

### Step 1.3: Project Structure Overview
```
celia_flutter/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── chat_models.dart
│   ├── services/
│   │   ├── botpress_api.dart
│   │   └── firebase_service.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── chat_repository.dart
│   │   └── chat_history_repository.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── chat_provider.dart
│   ├── screens/
│   │   ├── auth_screen.dart
│   │   ├── email_verification_screen.dart
│   │   └── chat_screen.dart
│   └── widgets/
│       └── loading_indicator.dart
├── android/
├── ios/
├── assets/
│   └── images/
└── pubspec.yaml
```

---

## Phase 2: Dependencies Configuration (Day 1, 1 hour)

### Step 2.1: Update pubspec.yaml
Replace the content of `pubspec.yaml`:

```yaml
name: celia_flutter
description: Celia AI Fitness Coach - Flutter version
publish_to: 'none'
version: 1.1.3+5

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  google_sign_in: ^6.1.6
  
  # Networking
  http: ^1.1.0
  
  # JSON Serialization
  json_annotation: ^4.8.1
  
  # UI Components
  cupertino_icons: ^1.0.2
  url_launcher: ^6.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  json_serializable: ^6.7.1
  build_runner: ^2.4.7

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

### Step 2.2: Install Dependencies
```bash
flutter pub get
```

---

## Phase 3: Models Implementation (Day 2, 4-6 hours)

### Step 3.1: Create Chat Models
Create `lib/models/chat_models.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'chat_models.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String? name;
  final String? email;
  final Map<String, String>? metadata;

  User({
    required this.id,
    this.name,
    this.email,
    this.metadata,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Conversation {
  final String id;
  final String userId;
  final String created;
  final String? updated;
  final Map<String, String>? metadata;

  Conversation({
    required this.id,
    required this.userId,
    required this.created,
    this.updated,
    this.metadata,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}

@JsonSerializable()
class Message {
  final String id;
  final String conversationId;
  final String userId;
  final String? text;
  final String type;
  final String created;
  final String? imageUrl;
  final List<MessageOption>? options;
  final Map<String, String>? metadata;
  bool interacted;

  Message({
    required this.id,
    required this.conversationId,
    required this.userId,
    this.text,
    this.type = "text",
    required this.created,
    this.imageUrl,
    this.options,
    this.metadata,
    this.interacted = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class MessageOption {
  final String label;
  final String value;

  MessageOption({
    required this.label,
    required this.value,
  });

  factory MessageOption.fromJson(Map<String, dynamic> json) => _$MessageOptionFromJson(json);
  Map<String, dynamic> toJson() => _$MessageOptionToJson(this);
}

@JsonSerializable()
class SimpleMessageRequest {
  final String type;
  final String text;

  SimpleMessageRequest({
    this.type = "text",
    required this.text,
  });

  factory SimpleMessageRequest.fromJson(Map<String, dynamic> json) => _$SimpleMessageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SimpleMessageRequestToJson(this);
}

@JsonSerializable()
class BotpressUser {
  final String id;
  final String createdAt;
  final String updatedAt;

  BotpressUser({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BotpressUser.fromJson(Map<String, dynamic> json) => _$BotpressUserFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressUserToJson(this);
}

@JsonSerializable()
class BotpressUserResponse {
  final BotpressUser? user;
  final String? key;
  final String? id;
  final int? code;
  final String? type;
  final String? message;

  BotpressUserResponse({
    this.user,
    this.key,
    this.id,
    this.code,
    this.type,
    this.message,
  });

  factory BotpressUserResponse.fromJson(Map<String, dynamic> json) => _$BotpressUserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressUserResponseToJson(this);
}

@JsonSerializable()
class BotpressMessage {
  final String id;
  final String conversationId;
  final String? userId;
  final List<String>? tags;
  final MessagePayload payload;
  final String createdAt;
  final String? updatedAt;

  BotpressMessage({
    required this.id,
    required this.conversationId,
    this.userId,
    this.tags,
    required this.payload,
    required this.createdAt,
    this.updatedAt,
  });

  factory BotpressMessage.fromJson(Map<String, dynamic> json) => _$BotpressMessageFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressMessageToJson(this);
}

@JsonSerializable()
class MessagePayload {
  final String type;
  final String? text;
  final String? imageUrl;
  final List<MessageOption>? options;

  MessagePayload({
    this.type = "text",
    this.text,
    this.imageUrl,
    this.options,
  });

  factory MessagePayload.fromJson(Map<String, dynamic> json) => _$MessagePayloadFromJson(json);
  Map<String, dynamic> toJson() => _$MessagePayloadToJson(this);
}

@JsonSerializable()
class BotpressMessageResponse {
  final BotpressMessage message;
  final String? error;
  final int? code;

  BotpressMessageResponse({
    required this.message,
    this.error,
    this.code,
  });

  factory BotpressMessageResponse.fromJson(Map<String, dynamic> json) => _$BotpressMessageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressMessageResponseToJson(this);
}

@JsonSerializable()
class BotpressMessagesResponse {
  final List<BotpressMessage> messages;
  final Map<String, String> meta;

  BotpressMessagesResponse({
    required this.messages,
    this.meta = const {},
  });

  factory BotpressMessagesResponse.fromJson(Map<String, dynamic> json) => _$BotpressMessagesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressMessagesResponseToJson(this);
}

@JsonSerializable()
class CreateUserRequest {
  final String name;
  final String email;
  final Map<String, String> metadata;

  CreateUserRequest({
    this.name = "Flutter User",
    this.email = "user@example.com",
    this.metadata = const {"platform": "flutter", "deviceType": "mobile"},
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) => _$CreateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);
}

@JsonSerializable()
class CreateConversationRequest {
  final String? userId;
  final Map<String, String> metadata;

  CreateConversationRequest({
    this.userId,
    this.metadata = const {"source": "flutter"},
  });

  factory CreateConversationRequest.fromJson(Map<String, dynamic> json) => _$CreateConversationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateConversationRequestToJson(this);
}

@JsonSerializable()
class BotpressConversation {
  final String id;
  final String createdAt;
  final String updatedAt;

  BotpressConversation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BotpressConversation.fromJson(Map<String, dynamic> json) => _$BotpressConversationFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressConversationToJson(this);
}

@JsonSerializable()
class BotpressConversationResponse {
  final BotpressConversation conversation;

  BotpressConversationResponse({required this.conversation});

  factory BotpressConversationResponse.fromJson(Map<String, dynamic> json) => _$BotpressConversationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressConversationResponseToJson(this);
}
```

### Step 3.2: Generate JSON Serialization Code
```bash
flutter packages pub run build_runner build
```

---

## Phase 4: Services Layer (Day 2-3, 4-6 hours)

### Step 4.1: Create Firebase Service
Create `lib/services/firebase_service.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static GoogleSignIn get googleSignIn => GoogleSignIn();

  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  static User? get currentUser => auth.currentUser;
  
  static bool get isAuthenticated => currentUser != null;
  
  static bool get isEmailVerified => currentUser?.emailVerified ?? false;
}
```

### Step 4.2: Create Botpress API Service
Create `lib/services/botpress_api.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_models.dart';

class BotpressApi {
  static const String _baseUrl = 'https://chat.botpress.cloud/71a1f5b1-470d-483a-a35b-45fab38502f1/';
  
  final http.Client _client = http.Client();

  Map<String, String> _getHeaders({String? userKey}) {
    final headers = {
      'Content-Type': 'application/json',
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
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<BotpressUserResponse> createUser(CreateUserRequest request) async {
    final response = await _client.post(
      Uri.parse('${_baseUrl}users'),
      headers: _getHeaders(),
      body: json.encode(request.toJson()),
    );
    return _handleResponse(response, BotpressUserResponse.fromJson);
  }

  Future<BotpressConversationResponse> createConversation(
    String userKey,
    CreateConversationRequest request,
  ) async {
    final response = await _client.post(
      Uri.parse('${_baseUrl}conversations'),
      headers: _getHeaders(userKey: userKey),
      body: json.encode(request.toJson()),
    );
    return _handleResponse(response, BotpressConversationResponse.fromJson);
  }

  Future<BotpressMessageResponse> sendMessage(
    String userKey,
    String conversationId,
    SimpleMessageRequest request,
  ) async {
    final response = await _client.post(
      Uri.parse('${_baseUrl}conversations/$conversationId/message'),
      headers: _getHeaders(userKey: userKey),
      body: json.encode(request.toJson()),
    );
    return _handleResponse(response, BotpressMessageResponse.fromJson);
  }

  Future<BotpressMessagesResponse> getMessages(
    String userKey,
    String conversationId,
  ) async {
    final response = await _client.get(
      Uri.parse('${_baseUrl}conversations/$conversationId/messages'),
      headers: _getHeaders(userKey: userKey),
    );
    return _handleResponse(response, BotpressMessagesResponse.fromJson);
  }

  Future<void> deleteConversation(String userKey, String conversationId) async {
    final response = await _client.delete(
      Uri.parse('${_baseUrl}conversations/$conversationId'),
      headers: _getHeaders(userKey: userKey),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete conversation: ${response.body}');
    }
  }

  void dispose() {
    _client.close();
  }
}
```

---

## Phase 5: Repositories Layer (Day 3, 4-6 hours)

### Step 5.1: Create Auth Repository
Create `lib/repositories/auth_repository.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firebase_service.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseService.auth;
  final GoogleSignIn _googleSignIn = FirebaseService.googleSignIn;

  User? get currentUser => _auth.currentUser;
  bool get isUserAuthenticated => currentUser != null;
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  Future<User> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        return result.user!;
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<User> signUp(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        try {
          await result.user!.sendEmailVerification();
        } catch (e) {
          print('Failed to send verification email: ${e.toString()}');
        }
        return result.user!;
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      if (result.user != null) {
        return result.user!;
      } else {
        throw Exception('Google sign-in failed');
      }
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      } else {
        throw Exception('No user logged in');
      }
    } catch (e) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  Future<User> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return _auth.currentUser!;
      } else {
        throw Exception('No user logged in');
      }
    } catch (e) {
      throw Exception('User reload failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
```

### Step 5.2: Create Chat Repository
Create `lib/repositories/chat_repository.dart`:

```dart
import '../services/botpress_api.dart';
import '../models/chat_models.dart';

class ChatRepository {
  final BotpressApi _api = BotpressApi();

  Future<User> createUser({String? name, String? email}) async {
    try {
      final request = CreateUserRequest(
        name: name ?? "Flutter User",
        email: email ?? "user@example.com",
      );
      
      final response = await _api.createUser(request);
      
      if (response.message != null && response.code != null) {
        throw Exception("API Error (${response.code}): ${response.message}");
      }
      
      if (response.user != null && response.key != null) {
        return User(
          id: response.key!,
          name: name ?? "Flutter User",
          email: email,
        );
      } else {
        throw Exception("Failed to parse user response: $response");
      }
    } catch (e) {
      throw Exception("Error creating user: ${e.toString()}");
    }
  }

  Future<Conversation> createConversation(String userKey) async {
    try {
      final request = CreateConversationRequest();
      final response = await _api.createConversation(userKey, request);
      
      return Conversation(
        id: response.conversation.id,
        userId: "user",
        created: response.conversation.createdAt,
        updated: response.conversation.updatedAt,
      );
    } catch (e) {
      throw Exception("Error creating conversation: ${e.toString()}");
    }
  }

  Future<Message> sendMessage(String userKey, String conversationId, String text) async {
    try {
      final request = SimpleMessageRequest(type: "text", text: text);
      final response = await _api.sendMessage(userKey, conversationId, request);
      
      return Message(
        id: response.message.id,
        conversationId: response.message.conversationId,
        userId: response.message.userId ?? "user",
        text: response.message.payload.text,
        type: response.message.payload.type,
        created: response.message.createdAt,
        imageUrl: response.message.payload.imageUrl,
        options: response.message.payload.options,
      );
    } catch (e) {
      throw Exception("Error sending message: ${e.toString()}");
    }
  }

  Future<List<Message>> getMessages(String userKey, String conversationId) async {
    try {
      final response = await _api.getMessages(userKey, conversationId);
      
      print("Raw response: ${response.messages.length} messages");
      
      final messages = response.messages.map((botpressMessage) {
        String messageType;
        if (botpressMessage.payload.type == "choice") {
          messageType = "choice";
        } else if (botpressMessage.payload.type == "dropdown") {
          messageType = "dropdown";
        } else if (botpressMessage.payload.type == "image") {
          messageType = "image";
        } else if (botpressMessage.payload.type == "button") {
          messageType = "button";
        } else if (botpressMessage.payload.options?.isNotEmpty == true) {
          messageType = "button";
        } else {
          messageType = "text";
        }
        
        final isUserMessage = botpressMessage.userId?.contains(userKey) == true;
        final userId = isUserMessage 
            ? "user_${botpressMessage.userId}"
            : "bot_${botpressMessage.userId ?? "botpress"}";
        
        print("Message ${botpressMessage.id} processed - userId: $userId, type: $messageType");
        
        return Message(
          id: botpressMessage.id,
          conversationId: botpressMessage.conversationId,
          userId: userId,
          text: botpressMessage.payload.text,
          type: messageType,
          created: botpressMessage.createdAt,
          imageUrl: botpressMessage.payload.imageUrl,
          options: botpressMessage.payload.options,
        );
      }).toList();
      
      print("Converted messages: ${messages.length}");
      
      return messages;
    } catch (e) {
      throw Exception("Error getting messages: ${e.toString()}");
    }
  }

  void dispose() {
    _api.dispose();
  }
}
```

### Step 5.3: Create Chat History Repository
Create `lib/repositories/chat_history_repository.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/chat_provider.dart';

class ChatHistoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveConversation(SavedConversation conversation) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No authenticated user');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversation.id)
        .set(conversation.toJson());
  }

  Future<List<SavedConversation>> getConversations() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No authenticated user');

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SavedConversation.fromJson(doc.data()))
        .toList();
  }

  Future<void> deleteConversation(String conversationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No authenticated user');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .delete();
  }
}
```

---

## Phase 6: State Management (Day 4, 6-8 hours)

### Step 6.1: Create Auth Provider
Create `lib/providers/auth_provider.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class AuthUiState {
  final bool isAuthenticated;
  final bool isLoading;
  final User? currentUser;
  final bool isEmailVerified;
  final bool needsEmailVerification;
  final bool verificationEmailSent;
  final String? authError;
  final bool passwordResetEmailSent;
  final String lastUsedEmail;

  AuthUiState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.currentUser,
    this.isEmailVerified = false,
    this.needsEmailVerification = false,
    this.verificationEmailSent = false,
    this.authError,
    this.passwordResetEmailSent = false,
    this.lastUsedEmail = '',
  });

  AuthUiState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    User? currentUser,
    bool? isEmailVerified,
    bool? needsEmailVerification,
    bool? verificationEmailSent,
    String? authError,
    bool? passwordResetEmailSent,
    String? lastUsedEmail,
  }) {
    return AuthUiState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      needsEmailVerification: needsEmailVerification ?? this.needsEmailVerification,
      verificationEmailSent: verificationEmailSent ?? this.verificationEmailSent,
      authError: authError,
      passwordResetEmailSent: passwordResetEmailSent ?? this.passwordResetEmailSent,
      lastUsedEmail: lastUsedEmail ?? this.lastUsedEmail,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  AuthUiState _uiState = AuthUiState();
  AuthUiState get uiState => _uiState;

  String _signUpEmail = '';

  bool get isUserAuthenticated => _authRepository.isUserAuthenticated;
  bool get isEmailVerified => _authRepository.isEmailVerified;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      _uiState = _uiState.copyWith(
        isAuthenticated: true,
        currentUser: currentUser,
        isEmailVerified: currentUser.emailVerified,
      );

      if (!currentUser.emailVerified) {
        _uiState = _uiState.copyWith(needsEmailVerification: true);
      }
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _uiState = _uiState.copyWith(
      isLoading: true,
      authError: null,
    );
    notifyListeners();

    try {
      final user = await _authRepository.signIn(email, password);
      await _authRepository.reloadUser();
      
      _uiState = _uiState.copyWith(
        isAuthenticated: true,
        isLoading: false,
        currentUser: user,
        isEmailVerified: user.emailVerified,
        needsEmailVerification: !user.emailVerified,
        authError: null,
        lastUsedEmail: email,
      );
    } catch (e) {
      _uiState = _uiState.copyWith(
        isAuthenticated: false,
        isLoading: false,
        authError: e.toString(),
      );
    }
    notifyListeners();
  }

  void saveEmailForVerification(String email) {
    print('DEBUG: Saving email for verification: $email');
    _uiState = _uiState.copyWith(lastUsedEmail: email);
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    saveEmailForVerification(email);
    
    _uiState = _uiState.copyWith(
      isLoading: true,
      authError: null,
    );
    notifyListeners();
    
    _signUpEmail = email;

    try {
      final user = await _authRepository.signUp(email, password);
      
      _uiState = _uiState.copyWith(
        isAuthenticated: true,
        isLoading: false,
        currentUser: user,
        isEmailVerified: false,
        needsEmailVerification: true,
        authError: null,
        lastUsedEmail: email,
      );
    } catch (e) {
      _uiState = _uiState.copyWith(
        isAuthenticated: false,
        isLoading: false,
        authError: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _uiState = _uiState.copyWith(
      isLoading: true,
      authError: null,
      passwordResetEmailSent: false,
    );
    notifyListeners();

    try {
      await _authRepository.resetPassword(email);
      _uiState = _uiState.copyWith(
        isLoading: false,
        passwordResetEmailSent: true,
        authError: null,
      );
    } catch (e) {
      _uiState = _uiState.copyWith(
        isLoading: false,
        passwordResetEmailSent: false,
        authError: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> sendVerificationEmail() async {
    _uiState = _uiState.copyWith(
      isLoading: true,
      verificationEmailSent: false,
      authError: null,
    );
    notifyListeners();

    try {
      await _authRepository.sendEmailVerification();
      _uiState = _uiState.copyWith(
        isLoading: false,
        verificationEmailSent: true,
      );
    } catch (e) {
      _uiState = _uiState.copyWith(
        isLoading: false,
        authError: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> checkEmailVerification() async {
    try {
      final user = await _authRepository.reloadUser();
      _uiState = _uiState.copyWith(
        isEmailVerified: user.emailVerified,
        needsEmailVerification: !user.emailVerified,
      );
      notifyListeners();
    } catch (e) {
      print('Error checking email verification: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    _uiState = _uiState.copyWith(
      isLoading: true,
      authError: null,
    );
    notifyListeners();

    try {
      final user = await _authRepository.signInWithGoogle();
      _uiState = _uiState.copyWith(
        isAuthenticated: true,
        isLoading: false,
        currentUser: user,
        isEmailVerified: true,
        needsEmailVerification: false,
        authError: null,
      );
    } catch (e) {
      _uiState = _uiState.copyWith(
        isAuthenticated: false,
        isLoading: false,
        authError: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _uiState = AuthUiState();
    notifyListeners();
  }

  void clearError() {
    _uiState = _uiState.copyWith(authError: null);
    notifyListeners();
  }

  void clearPasswordResetEmailSent() {
    _uiState = _uiState.copyWith(passwordResetEmailSent: false);
    notifyListeners();
  }

  void clearVerificationEmailSent() {
    _uiState = _uiState.copyWith(verificationEmailSent: false);
    notifyListeners();
  }

  void setAuthError(String errorMessage) {
    _uiState = _uiState.copyWith(
      authError: errorMessage,
      isLoading: false,
    );
    notifyListeners();
  }
}
```

### Step 6.2: Create Chat Provider
Create `lib/providers/chat_provider.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/chat_models.dart';
import '../repositories/chat_repository.dart';
import '../repositories/chat_history_repository.dart';

class SavedConversation {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime timestamp;
  final String userId;
  final String userKey;

  SavedConversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.userId,
    required this.userKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastMessage': lastMessage,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'userKey': userKey,
    };
  }

  factory SavedConversation.fromJson(Map<String, dynamic> json) {
    return SavedConversation(
      id: json['id'],
      title: json['title'],
      lastMessage: json['lastMessage'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      userKey: json['userKey'],
    );
  }
}

class ChatUiState {
  final List<Message> messages;
  final bool isLoading;
  final bool isLoadingInitial;
  final bool isSendingMessage;
  final bool pollingEnabled;
  final String? error;
  final bool hasActiveConversation;
  final bool isTyping;
  final List<SavedConversation> conversationHistory;
  final bool isLoadingHistory;
  final bool showNewConversationButton;
  final bool showStartNewConversationDialog;
  final bool showHistory;
  final bool showSettingsDialog;
  final bool showUserProfileDialog;
  final bool showRestartConfirmation;
  final String? currentConversationId;
  final String? currentUserKey;
  final String? userIdForBotpress;
  final bool hasInitialized;

  ChatUiState({
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingInitial = false,
    this.isSendingMessage = false,
    this.pollingEnabled = false,
    this.error,
    this.hasActiveConversation = false,
    this.isTyping = false,
    this.conversationHistory = const [],
    this.isLoadingHistory = false,
    this.showNewConversationButton = false,
    this.showStartNewConversationDialog = false,
    this.showHistory = false,
    this.showSettingsDialog = false,
    this.showUserProfileDialog = false,
    this.showRestartConfirmation = false,
    this.currentConversationId,
    this.currentUserKey,
    this.userIdForBotpress,
    this.hasInitialized = false,
  });

  ChatUiState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isLoadingInitial,
    bool? isSendingMessage,
    bool? pollingEnabled,
    String? error,
    bool? hasActiveConversation,
    bool? isTyping,
    List<SavedConversation>? conversationHistory,
    bool? isLoadingHistory,
    bool? showNewConversationButton,
    bool? showStartNewConversationDialog,
    bool? showHistory,
    bool? showSettingsDialog,
    bool? showUserProfileDialog,
    bool? showRestartConfirmation,
    String? currentConversationId,
    String? currentUserKey,
    String? userIdForBotpress,
    bool? hasInitialized,
  }) {
    return ChatUiState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      pollingEnabled: pollingEnabled ?? this.pollingEnabled,
      error: error,
      hasActiveConversation: hasActiveConversation ?? this.hasActiveConversation,
      isTyping: isTyping ?? this.isTyping,
      conversationHistory: conversationHistory ?? this.conversationHistory,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      showNewConversationButton: showNewConversationButton ?? this.showNewConversationButton,
      showStartNewConversationDialog: showStartNewConversationDialog ?? this.showStartNewConversationDialog,
      showHistory: showHistory ?? this.showHistory,
      showSettingsDialog: showSettingsDialog ?? this.showSettingsDialog,
      showUserProfileDialog: showUserProfileDialog ?? this.showUserProfileDialog,
      showRestartConfirmation: showRestartConfirmation ?? this.showRestartConfirmation,
      currentConversationId: currentConversationId ?? this.currentConversationId,
      currentUserKey: currentUserKey ?? this.currentUserKey,
      userIdForBotpress: userIdForBotpress ?? this.userIdForBotpress,
      hasInitialized: hasInitialized ?? this.hasInitialized,
    );
  }
}

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final ChatHistoryRepository _historyRepository = ChatHistoryRepository();
  
  ChatUiState _uiState = ChatUiState();
  ChatUiState get uiState => _uiState;

  Timer? _pollingTimer;

  Future<void> initializeChat() async {
    if (_uiState.hasInitialized) return;

    _uiState = _uiState.copyWith(
      isLoadingInitial: true,
      error: null,
    );
    notifyListeners();

    try {
      final user = await _chatRepository.createUser();
      
      _uiState = _uiState.copyWith(
        currentUserKey: user.id,
        userIdForBotpress: user.id,
        hasInitialized: true,
        isLoadingInitial: false,
      );
      notifyListeners();
      
      await loadConversationHistory();
    } catch (e) {
      _uiState = _uiState.copyWith(
        error: e.toString(),
        isLoadingInitial: false,
      );
      notifyListeners();
    }
  }

  Future<void> startNewConversation() async {
    if (_uiState.currentUserKey == null) {
      await initializeChat();
    }

    _uiState = _uiState.copyWith(
      isLoading: true,
      error: null,
    );
    notifyListeners();

    try {
      final conversation = await _chatRepository.createConversation(_uiState.currentUserKey!);
      
      _uiState = _uiState.copyWith(
        currentConversationId: conversation.id,
        messages: [],
        hasActiveConversation: true,
        isLoading: false,
        showNewConversationButton: false,
      );
      notifyListeners();
      
      _startPolling();
    } catch (e) {
      _uiState = _uiState.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (_uiState.currentUserKey == null || _uiState.currentConversationId == null) {
      _uiState = _uiState.copyWith(error: "No active conversation");
      notifyListeners();
      return;
    }

    _uiState = _uiState.copyWith(
      isSendingMessage: true,
      error: null,
    );
    notifyListeners();

    try {
      await _chatRepository.sendMessage(
        _uiState.currentUserKey!,
        _uiState.currentConversationId!,
        text,
      );
      
      _uiState = _uiState.copyWith(isSendingMessage: false);
      notifyListeners();
      
      await loadMessages();
    } catch (e) {
      _uiState = _uiState.copyWith(
        error: e.toString(),
        isSendingMessage: false,
      );
      notifyListeners();
    }
  }

  Future<void> loadMessages() async {
    if (_uiState.currentUserKey == null || _uiState.currentConversationId == null) {
      return;
    }

    try {
      final messages = await _chatRepository.getMessages(
        _uiState.currentUserKey!,
        _uiState.currentConversationId!,
      );
      
      _uiState = _uiState.copyWith(
        messages: messages,
        error: null,
      );
      notifyListeners();
    } catch (e) {
      _uiState = _uiState.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_uiState.hasActiveConversation) {
        loadMessages();
      }
    });
    
    _uiState = _uiState.copyWith(pollingEnabled: true);
    notifyListeners();
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _uiState = _uiState.copyWith(pollingEnabled: false);
    notifyListeners();
  }

  Future<void> loadConversationHistory() async {
    _uiState = _uiState.copyWith(isLoadingHistory: true);
    notifyListeners();

    try {
      final history = await _historyRepository.getConversations();
      _uiState = _uiState.copyWith(
        conversationHistory: history,
        isLoadingHistory: false,
      );
      notifyListeners();
    } catch (e) {
      _uiState = _uiState.copyWith(
        error: e.toString(),
        isLoadingHistory: false,
      );
      notifyListeners();
    }
  }

  Future<void> saveCurrentConversation() async {
    if (_uiState.currentConversationId == null || _uiState.messages.isEmpty) {
      return;
    }

    try {
      final lastMessage = _uiState.messages.last.text ?? "No message";
      final title = _uiState.messages.isNotEmpty 
          ? _uiState.messages.first.text?.substring(0, 30) ?? "Conversation"
          : "Conversation";

      final savedConversation = SavedConversation(
        id: _uiState.currentConversationId!,
        title: title,
        lastMessage: lastMessage,
        timestamp: DateTime.now(),
        userId: _uiState.userIdForBotpress ?? "unknown",
        userKey: _uiState.currentUserKey ?? "unknown",
      );

      await _historyRepository.saveConversation(savedConversation);
      await loadConversationHistory();
    } catch (e) {
      print("Error saving conversation: $e");
    }
  }

  Future<void> restartConversation() async {
    _stopPolling();
    await saveCurrentConversation();
    
    _uiState = _uiState.copyWith(
      messages: [],
      hasActiveConversation: false,
      currentConversationId: null,
      showNewConversationButton: true,
      showRestartConfirmation: false,
    );
    notifyListeners();
  }

  void handleOptionClick(String value) {
    sendMessage(value);
  }

  void toggleHistory() {
    _uiState = _uiState.copyWith(showHistory: !_uiState.showHistory);
    notifyListeners();
  }

  void toggleSettings() {
    _uiState = _uiState.copyWith(showSettingsDialog: !_uiState.showSettingsDialog);
    notifyListeners();
  }

  void toggleUserProfile() {
    _uiState = _uiState.copyWith(showUserProfileDialog: !_uiState.showUserProfileDialog);
    notifyListeners();
  }

  void showRestartDialog() {
    _uiState = _uiState.copyWith(showRestartConfirmation: true);
    notifyListeners();
  }

  void hideRestartDialog() {
    _uiState = _uiState.copyWith(showRestartConfirmation: false);
    notifyListeners();
  }

  void clearError() {
    _uiState = _uiState.copyWith(error: null);
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _chatRepository.dispose();
    super.dispose();
  }
}
```

---

## Phase 7: UI Implementation (Day 5-6, 8-12 hours)

### Step 7.1: Create Main App Entry Point
Create `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const CeliaApp());
}

class CeliaApp extends StatelessWidget {
  const CeliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Celia Integral Coach',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
        ),
        home: const AppNavigator(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final uiState = authProvider.uiState;
        
        if (!uiState.isAuthenticated) {
          return const AuthScreen();
        } else if (!uiState.isEmailVerified) {
          return const EmailVerificationScreen();
        } else {
          return const ChatScreen();
        }
      },
    );
  }
}
```

### Step 7.2: Create UI Screens
Create the following screen files:

#### `lib/screens/auth_screen.dart`
*[Include the complete auth_screen.dart file from previous response]*

#### `lib/screens/email_verification_screen.dart`
*[Include the complete email_verification_screen.dart file from previous response]*

#### `lib/screens/chat_screen.dart`
*[Include the complete chat_screen.dart file from previous response]*

### Step 7.3: Create Widgets
Create `lib/widgets/loading_indicator.dart`:

```dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;
  
  const LoadingIndicator({
    super.key,
    this.message = "Loading...",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          color: Color(0xFFF57C00),
          strokeWidth: 4,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
```

---

## Phase 8: Testing & Debugging (Day 7, 4-6 hours)

### Step 8.1: Test on Android
```bash
# Generate final JSON serialization
flutter packages pub run build_runner build --delete-conflicting-outputs

# Test on Android
flutter run -d <your-android-device>

# Debug common issues:
# - Check Firebase configuration
# - Verify API endpoints
# - Test authentication flow
# - Test chat functionality
```

### Step 8.2: Debug Common Issues
- **Firebase errors**: Ensure google-services.json is in android/app/
- **API errors**: Check Botpress endpoint URL
- **Authentication issues**: Verify Firebase project settings
- **JSON serialization**: Run build_runner if models change

---

## Phase 9: iOS Certificate Generation (Day 8, 2-4 hours)

### Step 9.1: Install OpenSSL for Windows
```bash
# Download from https://slproweb.com/products/Win32OpenSSL.html
# Or use Git Bash (recommended)
```

### Step 9.2: Generate Certificates
```bash
# Generate private key
openssl genrsa -out ios-dist-key.pem 2048

# Generate Certificate Signing Request
openssl req -new -key ios-dist-key.pem -out ios-dist.csr \
  -subj "/emailAddress=your-email@domain.com, CN=Your Name, O=Your Organization, C=US"
```

### Step 9.3: Apple Developer Portal Setup
1. Login to [developer.apple.com](https://developer.apple.com)
2. Go to **Certificates, Identifiers & Profiles**
3. Create **App ID** for `eu.thefit.celia`
4. Upload `ios-dist.csr` to create **Distribution Certificate**
5. Download `ios_distribution.cer`
6. Create **App Store Provisioning Profile**
7. Download `.mobileprovision` file

### Step 9.4: Convert Certificate to P12
```bash
# Convert certificate to PEM
openssl x509 -in ios_distribution.cer -inform DER -out ios_distribution.pem

# Create P12 bundle
openssl pkcs12 -export \
  -inkey ios-dist-key.pem \
  -in ios_distribution.pem \
  -out ios_distribution.p12 \
  -passout pass:YOUR_STRONG_PASSWORD
```

---

## Phase 10: iOS Configuration (Day 8, 1-2 hours)

### Step 10.1: Configure iOS Info.plist
Update `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Celia Integral Coach</string>
    <key>CFBundleDisplayName</key>
    <string>Celia</string>
    <key>CFBundleIdentifier</key>
    <string>eu.thefit.celia</string>
    <key>CFBundleVersion</key>
    <string>5</string>
    <key>CFBundleShortVersionString</key>
    <string>1.1.3</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
    </array>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
```

### Step 10.2: Add Firebase Configuration
1. Download `GoogleService-Info.plist` from Firebase Console (iOS section)
2. Place in `ios/Runner/` directory

### Step 10.3: Setup Assets
```bash
# Create assets directory
mkdir -p assets/images

# Copy logo from Android project (convert if needed)
# Place logo_the_fit.png in assets/images/
```

---

## Phase 11: Codemagic Setup (Day 9, 2-4 hours)

### Step 11.1: Create Codemagic Account
1. Go to [codemagic.io](https://codemagic.io)
2. Sign up with GitHub/GitLab/Bitbucket
3. Connect your Flutter project repository

### Step 11.2: Upload Certificates
In Codemagic → Your App → Settings → Code signing:
1. Upload `ios_distribution.p12` with password
2. Upload `.mobileprovision` file
3. Enter Apple Team ID
4. Enable **Automatic code signing**

### Step 11.3: Create Codemagic Configuration
Create `codemagic.yaml` in project root:

```yaml
workflows:
  ios-workflow:
    name: iOS Build & Deploy
    instance_type: mac_mini_m2
    max_build_duration: 120
    environment:
      flutter: stable
      xcode: latest
      ios_signing:
        distribution_type: app_store
        bundle_identifier: eu.thefit.celia
      vars:
        APP_STORE_CONNECT_ISSUER_ID: your_issuer_id
        APP_STORE_CONNECT_KEY_IDENTIFIER: your_key_id
        APP_STORE_CONNECT_PRIVATE_KEY: your_private_key
        CERTIFICATE_PRIVATE_KEY: your_certificate_private_key
    scripts:
      - name: Set up local properties
        script: |
          echo "flutter.sdk=$HOME/programs/flutter" > "$CM_BUILD_DIR/android/local.properties"
      - name: Get Flutter dependencies
        script: |
          flutter packages pub get
      - name: Generate code
        script: |
          flutter packages pub run build_runner build --delete-conflicting-outputs
      - name: Install CocoaPods dependencies
        script: |
          cd ios && pod install --repo-update && cd ..
      - name: Flutter build iOS
        script: |
          flutter build ios --release --no-codesign
      - name: Build iOS app
        script: |
          xcode-project build-ipa \
            --workspace ios/Runner.xcworkspace \
            --scheme Runner \
            --config Release
    artifacts:
      - build/ios/ipa/*.ipa
      - /tmp/xcodebuild_logs/*.log
      - flutter_drive.log
    publishing:
      email:
        recipients:
          - your-email@domain.com
        notify:
          success: true
          failure: true
      app_store_connect:
        auth: integration
        submit_to_testflight: true
        beta_review_details:
          contact_email: your-email@domain.com
          contact_first_name: Your Name
          contact_last_name: Last Name
          contact_phone: +1234567890
          demo_account_name: demo@example.com
          demo_account_password: demopassword
          notes: Celia AI Fitness Coach App
```

---

## Phase 12: First iOS Build (Day 9, 1-2 hours)

### Step 12.1: Commit and Push
```bash
git add .
git commit -m "Complete Flutter iOS conversion with Codemagic setup"
git push origin main
```

### Step 12.2: Monitor Build
1. Go to Codemagic dashboard
2. Watch build progress
3. Check logs for any errors
4. Download IPA file when successful

### Step 12.3: Common Build Issues & Solutions
- **CocoaPods errors**: Update iOS deployment target to 11.0+
- **Certificate errors**: Verify P12 file and password
- **Bundle ID mismatch**: Ensure consistent bundle identifier
- **Provisioning profile**: Check expiration and device inclusion

---

## Phase 13: TestFlight & App Store (Final Day)

### Step 13.1: TestFlight Testing
1. Build automatically uploads to TestFlight
2. Add test users in App Store Connect
3. Send TestFlight invitations
4. Test on real iOS devices
5. Gather feedback and fix issues

### Step 13.2: App Store Submission
1. Complete App Store metadata:
   - App description
   - Screenshots (use simulator or real device)
   - Keywords
   - App icon (1024x1024)
   - Privacy policy URL
2. Submit for review
3. Respond to Apple feedback if needed
4. Release to App Store

---

## Final Checklist

### ✅ **Development Complete**
- [ ] All Flutter files implemented
- [ ] Android testing successful
- [ ] Firebase integration working
- [ ] Chat functionality verified

### ✅ **iOS Ready**
- [ ] Apple Developer Account active
- [ ] Certificates generated and uploaded
- [ ] Codemagic configured
- [ ] iOS build successful

### ✅ **Deployed**
- [ ] TestFlight build distributed
- [ ] iOS testing complete
- [ ] App Store submission done
- [ ] App published

**Total Timeline: 7-9 days**
**Cost: $99 Apple Developer + free tools**
**Result: Single Flutter codebase running on both Android and iOS**