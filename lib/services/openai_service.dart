import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/routine.dart';
import 'package:uuid/uuid.dart';

/// Service for interacting with OpenAI API to generate routines
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-4o-mini'; // Cost-effective for routine generation

  final String _apiKey;
  final _uuid = const Uuid();

  OpenAIService({String? apiKey}) : _apiKey = apiKey ?? Env.openaiApiKey;

  /// Generate a fitness routine based on user request
  Future<Routine> generateRoutine({
    required String userRequest,
    int? targetDurationMinutes,
    RoutineDifficulty? preferredDifficulty,
    List<String>? availableEquipment,
    List<String>? availableVideoIds,
  }) async {
    const systemPrompt = '''
You are Celia, an AI fitness coach. Generate a structured fitness routine based on the user's request.

IMPORTANT: Respond ONLY with valid JSON matching this exact structure:
{
  "title": "Routine Title",
  "description": "Brief description of the routine",
  "durationMinutes": 20,
  "difficulty": "easy|medium|hard",
  "category": "strength|cardio|flexibility|mindfulness|dance|hiit|yoga|custom",
  "steps": [
    {
      "title": "Exercise Name",
      "description": "How to perform this exercise",
      "durationSeconds": 60
    }
  ],
  "tags": ["tag1", "tag2"],
  "caloriesBurned": 150,
  "equipment": "None" or "Dumbbells, Mat"
}

Guidelines:
- Create realistic, safe exercises
- Include warm-up and cool-down if appropriate
- Match difficulty to user's request
- Be encouraging and motivating in descriptions
- Total duration should match requested time (±5 minutes)
''';

    final userPrompt = StringBuffer();
    userPrompt.writeln('Create a fitness routine with these requirements:');
    userPrompt.writeln('Request: $userRequest');
    
    if (targetDurationMinutes != null) {
      userPrompt.writeln('Target duration: $targetDurationMinutes minutes');
    }
    if (preferredDifficulty != null) {
      userPrompt.writeln('Difficulty: ${preferredDifficulty.name}');
    }
    if (availableEquipment != null && availableEquipment.isNotEmpty) {
      userPrompt.writeln('Available equipment: ${availableEquipment.join(', ')}');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt.toString()},
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode != 200) {
        throw OpenAIException(
          'Failed to generate routine: ${response.statusCode}',
          response.body,
        );
      }

      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      final routineJson = jsonDecode(content) as Map<String, dynamic>;

      // Convert to Routine model with generated IDs
      final now = DateTime.now();
      final routineId = _uuid.v4();

      final steps = (routineJson['steps'] as List<dynamic>)
          .asMap()
          .entries
          .map((entry) => RoutineStep(
                id: _uuid.v4(),
                title: entry.value['title'] as String,
                description: entry.value['description'] as String?,
                durationSeconds: entry.value['durationSeconds'] as int,
                orderIndex: entry.key,
              ))
          .toList();

      return Routine(
        id: routineId,
        title: routineJson['title'] as String,
        description: routineJson['description'] as String?,
        durationMinutes: routineJson['durationMinutes'] as int,
        difficulty: _parseDifficulty(routineJson['difficulty'] as String),
        category: _parseCategory(routineJson['category'] as String),
        steps: steps,
        createdBy: 'ai',
        createdAt: now,
        isPublished: false, // AI routines need review before publishing
        isCurated: false,
        tags: (routineJson['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        caloriesBurned: routineJson['caloriesBurned'] as int?,
        equipment: routineJson['equipment'] as String?,
      );
    } catch (e) {
      if (e is OpenAIException) rethrow;
      throw OpenAIException('Failed to generate routine', e.toString());
    }
  }

  /// Generate a routine description/summary
  Future<String> generateRoutineDescription(List<String> exerciseNames) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a fitness coach. Write a brief, motivating 2-3 sentence description for a workout routine.'
          },
          {
            'role': 'user',
            'content':
                'Write a description for a routine with these exercises: ${exerciseNames.join(', ')}'
          },
        ],
        'temperature': 0.7,
        'max_tokens': 200,
      }),
    );

    if (response.statusCode != 200) {
      throw OpenAIException(
        'Failed to generate description: ${response.statusCode}',
        response.body,
      );
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'] as String;
  }

  RoutineDifficulty _parseDifficulty(String value) {
    switch (value.toLowerCase()) {
      case 'easy':
        return RoutineDifficulty.easy;
      case 'medium':
        return RoutineDifficulty.medium;
      case 'hard':
        return RoutineDifficulty.hard;
      default:
        return RoutineDifficulty.medium;
    }
  }

  RoutineCategory _parseCategory(String value) {
    switch (value.toLowerCase()) {
      case 'strength':
        return RoutineCategory.strength;
      case 'cardio':
        return RoutineCategory.cardio;
      case 'flexibility':
        return RoutineCategory.flexibility;
      case 'mindfulness':
        return RoutineCategory.mindfulness;
      case 'dance':
        return RoutineCategory.dance;
      case 'hiit':
        return RoutineCategory.hiit;
      case 'yoga':
        return RoutineCategory.yoga;
      default:
        return RoutineCategory.custom;
    }
  }
}

/// Exception for OpenAI API errors
class OpenAIException implements Exception {
  final String message;
  final String? details;

  OpenAIException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}

