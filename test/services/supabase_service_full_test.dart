import 'dart:convert';

import 'package:celia_flutter/models/routine.dart';
import 'package:celia_flutter/models/video.dart';
import 'package:celia_flutter/services/supabase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}

class MockFbUser extends Mock implements fb.User {}

class MockHttpClient extends Mock implements http.Client {}

class _FakeBaseClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  _handler;
  _FakeBaseClient(this._handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _handler(request);
}

http.StreamedResponse _streamedJson(
  Object? jsonBody,
  int statusCode,
  http.BaseRequest request, {
  Map<String, String>? headers,
}) {
  final bodyBytes = utf8.encode(jsonEncode(jsonBody));
  return http.StreamedResponse(
    Stream<List<int>>.value(bodyBytes),
    statusCode,
    request: request,
    headers: {'content-type': 'application/json', ...?headers},
  );
}

http.StreamedResponse _streamedText(
  String body,
  int statusCode,
  http.BaseRequest request, {
  Map<String, String>? headers,
}) {
  final bodyBytes = utf8.encode(body);
  return http.StreamedResponse(
    Stream<List<int>>.value(bodyBytes),
    statusCode,
    request: request,
    headers: {...?headers},
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.test'));
  });

  tearDown(() {
    SupabaseService.resetForTesting();
  });

  test('SupabaseException.toString formats with/without details', () {
    expect(SupabaseException('m').toString(), 'm');
    expect(SupabaseException('m', 'd').toString(), 'm: d');
  });

  test('initialize success path sets client', () async {
    final origUrl = SupabaseService.supabaseUrl;
    final origAnon = SupabaseService.supabaseAnonKey;
    final origInit = SupabaseService.supabaseInitialize;
    final origFactory = SupabaseService.supabaseClientFactory;

    final dummyHttp = _FakeBaseClient(
      (req) async => _streamedJson([], 200, req),
    );
    final realClient = sb.SupabaseClient(
      'https://supabase.test',
      'anon',
      httpClient: dummyHttp,
    );

    try {
      SupabaseService.supabaseUrl = () => 'https://example.supabase.test';
      SupabaseService.supabaseAnonKey = () => 'anon';
      SupabaseService.supabaseInitialize =
          ({required url, required anonKey}) async {};
      SupabaseService.supabaseClientFactory = () => realClient;

      await SupabaseService.initialize();
      expect(SupabaseService.instance.client, same(realClient));
    } finally {
      SupabaseService.supabaseUrl = origUrl;
      SupabaseService.supabaseAnonKey = origAnon;
      SupabaseService.supabaseInitialize = origInit;
      SupabaseService.supabaseClientFactory = origFactory;
    }
  });

  test('routine + video CRUD and lookups use Supabase client chain', () async {
    final mockHttp = _FakeBaseClient((request) async {
      final path = request.url.path;
      final qp = request.url.queryParameters;
      final method = request.method.toUpperCase();

      // Routines
      if (path.endsWith('/rest/v1/routines') && method == 'GET') {
        // maybeSingle uses object accept and returns 406 for 0 rows.
        final accept =
            request.headers['accept'] ?? request.headers['Accept'] ?? '';
        final wantsObject = accept.contains('vnd.pgrst.object+json');
        final idFilter = qp['id'];
        if (idFilter == 'eq.missing') {
          // Return an empty list; PostgrestBuilder's maybeSingle logic converts [] -> null.
          return _streamedJson(
            const [],
            200,
            request,
            headers: {'content-range': '0-0/0'},
          );
        }
        if (wantsObject && idFilter == 'eq.r1') {
          return _streamedJson(
            {
              'id': 'r1',
              'title': 'T',
              'description': 'D',
              'category': 'strength',
              'difficulty': 'easy',
              'duration_minutes': 10,
              'equipment': 'None',
              'steps': const [],
              'is_published': true,
              'is_curated': false,
              'created_at': DateTime(2026, 1, 1).toIso8601String(),
              'created_by': 'u',
            },
            200,
            request,
          );
        }
        return _streamedJson(
          [
            {
              'id': 'r1',
              'title': 'T',
              'description': 'D',
              'category': 'strength',
              'difficulty': 'easy',
              'duration_minutes': 10,
              'equipment': 'None',
              'steps': const [],
              'is_published': true,
              'is_curated': false,
              'created_at': DateTime(2026, 1, 1).toIso8601String(),
              'created_by': 'u',
            },
          ],
          200,
          request,
          headers: {'content-range': '0-0/*'},
        );
      }
      if (path.endsWith('/rest/v1/routines') && method == 'POST') {
        // insert + select + single
        return _streamedJson(
          {
            'id': 'r2',
            'title': 't',
            'description': '',
            'category': 'strength',
            'difficulty': 'easy',
            'duration_minutes': 5,
            'equipment': 'None',
            'steps': const [],
            'is_published': false,
            'is_curated': false,
            'created_at': DateTime(2026, 1, 1).toIso8601String(),
            'created_by': 'u',
          },
          201,
          request,
        );
      }
      if (path.endsWith('/rest/v1/routines') && method == 'PATCH') {
        return _streamedJson(
          {
            'id': 'r2',
            'title': 't',
            'description': '',
            'category': 'strength',
            'difficulty': 'easy',
            'duration_minutes': 5,
            'equipment': 'None',
            'steps': const [],
            'is_published': false,
            'is_curated': false,
            'created_at': DateTime(2026, 1, 1).toIso8601String(),
            'created_by': 'u',
          },
          200,
          request,
        );
      }
      if (path.endsWith('/rest/v1/routines') && method == 'DELETE') {
        return _streamedText('', 204, request);
      }

      // Videos
      if (path.endsWith('/rest/v1/videos') && method == 'GET') {
        final accept =
            request.headers['accept'] ?? request.headers['Accept'] ?? '';
        final wantsObject = accept.contains('vnd.pgrst.object+json');
        final idFilter = qp['id'];
        final cfFilter = qp['cloudflare_video_id'];
        final legacyFilter = qp['stream_id'];

        if (wantsObject && idFilter == 'eq.v1') {
          return _streamedJson(
            {
              'id': 'v1',
              'cloudflare_video_id': 'cf1',
              'title': 'Clip',
              'duration_seconds': 12,
              'thumbnail_url': null,
              'playback_url': 'hls',
              'status': 'ready',
              'uploaded_by': 'admin',
              'uploaded_at': DateTime(2026, 1, 1).toIso8601String(),
              'tags': const <String>[],
              'category': null,
              'file_size': 123,
            },
            200,
            request,
          );
        }

        if (cfFilter == 'eq.throw') {
          return _streamedText('nope', 500, request);
        }

        if (wantsObject && cfFilter == 'eq.cfOk') {
          return _streamedJson(
            {
              'id': 'vOk',
              'cloudflare_video_id': 'cfOk',
              'title': 'Ok',
              'duration_seconds': 1,
              'thumbnail_url': null,
              'playback_url': 'hls',
              'status': 'ready',
              'uploaded_by': 'admin',
              'uploaded_at': DateTime(2026, 1, 1).toIso8601String(),
              'tags': const <String>[],
            },
            200,
            request,
          );
        }

        if (cfFilter == 'eq.legacy') {
          // Force first attempt (cloudflare_video_id) to return null
          return _streamedJson(
            const [],
            200,
            request,
            headers: {'content-range': '0-0/0'},
          );
        }

        if (legacyFilter == 'eq.throw') {
          return _streamedJson(
            const [],
            200,
            request,
            headers: {'content-range': '0-0/0'},
          );
        }

        if (wantsObject && legacyFilter == 'eq.legacy') {
          return _streamedJson(
            {
              'id': 'v2',
              'stream_id': 'legacy',
              'title': 'Legacy',
              'duration_seconds': 0,
              'playback_url': '',
              'status': 'processing',
              'created_at': DateTime(2026, 1, 1).toIso8601String(),
              'tags': const <String>[],
            },
            200,
            request,
          );
        }

        // list
        return _streamedJson(
          [
            {
              'id': 'v1',
              'cloudflare_video_id': 'cf1',
              'title': 'Clip',
              'duration_seconds': 12,
              'thumbnail_url': null,
              'playback_url': 'hls',
              'status': 'ready',
              'uploaded_by': 'admin',
              'uploaded_at': DateTime(2026, 1, 1).toIso8601String(),
              'tags': const <String>[],
              'category': null,
              'file_size': 123,
            },
          ],
          200,
          request,
          headers: {'content-range': '0-0/*'},
        );
      }
      if (path.endsWith('/rest/v1/videos') && method == 'POST') {
        return _streamedJson(
          {
            'id': 'v3',
            'cloudflare_video_id': 'cf3',
            'title': 't',
            'duration_seconds': 0,
            'thumbnail_url': null,
            'playback_url': '',
            'status': 'processing',
            'uploaded_by': 'admin',
            'uploaded_at': DateTime(2026, 1, 1).toIso8601String(),
            'tags': const <String>[],
          },
          201,
          request,
        );
      }
      if (path.endsWith('/rest/v1/videos') && method == 'PATCH') {
        return _streamedJson(
          {
            'id': 'v3',
            'cloudflare_video_id': 'cf3',
            'title': 't',
            'duration_seconds': 0,
            'thumbnail_url': null,
            'playback_url': '',
            'status': 'processing',
            'uploaded_by': 'admin',
            'uploaded_at': DateTime(2026, 1, 1).toIso8601String(),
            'tags': const <String>[],
          },
          200,
          request,
        );
      }
      if (path.endsWith('/rest/v1/videos') && method == 'DELETE') {
        return _streamedText('', 204, request);
      }

      // user_routines
      if (path.endsWith('/rest/v1/user_routines') && method == 'GET') {
        return _streamedJson(
          [
            {
              'id': 'ur1',
              'user_id': 'u',
              'routine_id': 'r1',
              'saved_at': DateTime(2026, 1, 1).toIso8601String(),
              'is_favorite': false,
              'completion_count': 0,
            },
          ],
          200,
          request,
        );
      }
      if (path.endsWith('/rest/v1/user_routines') && method == 'POST') {
        final req = request as http.Request;
        final decoded = jsonDecode(req.body);
        final Map<String, dynamic> row = decoded is List
            ? (decoded.first as Map<String, dynamic>)
            : (decoded as Map<String, dynamic>);
        return _streamedJson(
          {
            'id': 'ur2',
            'user_id': row['user_id'],
            'routine_id': row['routine_id'],
            'saved_at': row['saved_at'],
            'is_favorite': false,
            'completion_count': 0,
          },
          201,
          request,
        );
      }
      if (path.endsWith('/rest/v1/user_routines') && method == 'PATCH') {
        return _streamedText('', 204, request);
      }
      if (path.endsWith('/rest/v1/user_routines') && method == 'DELETE') {
        return _streamedText('', 204, request);
      }

      if (path.endsWith('/rest/v1/rpc/increment_routine_completion') &&
          method == 'POST') {
        return _streamedJson(null, 200, request);
      }

      return _streamedText(
        'unhandled ${request.method} ${request.url}',
        500,
        request,
      );
    });

    final sbClient = sb.SupabaseClient(
      'https://supabase.test',
      'anon',
      httpClient: mockHttp,
    );
    SupabaseService.setClientForTesting(sbClient);
    final svc = SupabaseService.instance;

    // Published routines with/without filters
    final published = await svc.getPublishedRoutines();
    expect(published, isNotEmpty);
    await svc.getPublishedRoutines(category: RoutineCategory.strength);
    await svc.getPublishedRoutines(difficulty: RoutineDifficulty.easy);
    await svc.getPublishedRoutines(isCurated: false);

    // User-created routines
    await svc.getUserCreatedRoutines(userId: 'u');

    // Routine lookup
    final r = await svc.getRoutine('r1');
    expect(r, isNotNull);
    final missing = await svc.getRoutine('missing');
    expect(missing, isNull);

    // Create/update/delete routine
    final created = await svc.createRoutine(
      Routine(
        id: 'r2',
        title: 't',
        description: '',
        category: RoutineCategory.strength,
        difficulty: RoutineDifficulty.easy,
        durationMinutes: 5,
        equipment: 'None',
        steps: const [],
        isPublished: false,
        isCurated: false,
        createdAt: DateTime(2026, 1, 1),
        createdBy: 'u',
      ),
    );
    expect(created.id, 'r2');
    await svc.updateRoutine(created);
    await svc.deleteRoutine(created.id);

    // Videos list + lookup-by-any-id paths
    final videos = await svc.getVideos();
    expect(videos.first.durationSeconds, 12);
    await svc.getVideos(category: 'c', status: VideoStatus.ready);
    expect(await svc.getVideoByAnyId('  '), isNull);
    expect(await svc.getVideoByAnyId('v1'), isNotNull);

    // getVideoByStreamId: new column throws -> legacy succeeds
    expect(await svc.getVideoByStreamId('throw'), isNull);
    expect(await svc.getVideoByStreamId('cfOk'), isNotNull);
    expect(await svc.getVideoByStreamId('legacy'), isNotNull);

    // Cover supabase-row mapping branches (DateTime + stream_id + streamId)
    svc.videoFromSupabaseRowForTesting({
      'id': 'vx',
      'cloudflare_video_id': 'cfX',
      'title': 't',
      'duration_seconds': 1,
      'playback_url': '',
      'status': 'processing',
      'uploaded_by': 'admin',
      'uploaded_at': DateTime(2026, 1, 1),
      'tags': const <String>[],
    });
    svc.videoFromSupabaseRowForTesting({
      'id': 'vy',
      'stream_id': 'legacy',
      'title': 't',
      'duration_seconds': 1,
      'playback_url': '',
      'status': 'processing',
      'uploaded_by': 'admin',
      'uploaded_at': DateTime(2026, 1, 1),
      'tags': const <String>[],
    });
    svc.videoFromSupabaseRowForTesting({
      'id': 'vz',
      'streamId': 'legacy2',
      'title': 't',
      'duration_seconds': 1,
      'playback_url': '',
      'status': 'processing',
      'uploaded_by': 'admin',
      'uploaded_at': DateTime(2026, 1, 1),
      'tags': const <String>[],
    });

    // create/update/delete video
    final v = await svc.createVideo(
      Video(
        id: 'v3',
        streamId: 'cf3',
        title: 't',
        description: null,
        durationSeconds: 0,
        thumbnailUrl: null,
        playbackUrl: '',
        status: VideoStatus.processing,
        uploadedBy: 'admin',
        uploadedAt: DateTime(2026, 1, 1),
        tags: const [],
        category: null,
        fileSize: null,
      ),
    );
    await svc.updateVideo(v);
    await svc.deleteVideo(v.id);

    // User routines
    final urs = await svc.getUserRoutines('u');
    expect(urs, isNotEmpty);
    final saved = await svc.saveRoutine('u', 'r1');
    expect(saved.userId, 'u');
    await svc.unsaveRoutine('u', 'r1');
    await svc.toggleFavorite('ur1', true);
    await svc.recordCompletion('ur1');
  });

  test('generateRoutineOnServer handles success + error responses', () async {
    final origBase = SupabaseService.backendBaseUrl;
    final origAuth = SupabaseService.firebaseAuthFactory;
    final origHttp = SupabaseService.httpClient;

    final auth = MockFirebaseAuth();
    final user = MockFbUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken()).thenAnswer((_) async => 'tok');

    final client = MockHttpClient();

    try {
      SupabaseService.backendBaseUrl = () => 'https://example.test';
      SupabaseService.firebaseAuthFactory = () => auth;
      SupabaseService.httpClient = client;

      // Non-2xx with JSON error
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(jsonEncode({'error': 'bad'}), 400),
      );
      final svc = SupabaseService.instance;
      await expectLater(
        svc.generateRoutineOnServer(
          request: 'r',
          durationMinutes: 10,
          difficulty: RoutineDifficulty.easy,
          equipment: const [],
        ),
        throwsA(isA<SupabaseException>()),
      );

      // 2xx but invalid body
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('{}', 200));
      await expectLater(
        svc.generateRoutineOnServer(
          request: 'r',
          durationMinutes: 10,
          difficulty: RoutineDifficulty.easy,
          equipment: const [],
        ),
        throwsA(isA<SupabaseException>()),
      );

      // success
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'routine': {
              'id': 'r1',
              'title': 'T',
              'description': '',
              'category': 'strength',
              'difficulty': 'easy',
              'duration_minutes': 10,
              'equipment': 'None',
              'steps': const [],
              'is_published': false,
              'is_curated': false,
              'created_at': DateTime(2026, 1, 1).toIso8601String(),
              'created_by': 'u',
            },
          }),
          200,
        ),
      );
      final routine = await svc.generateRoutineOnServer(
        request: 'r',
        durationMinutes: 10,
        difficulty: RoutineDifficulty.easy,
        equipment: const [],
      );
      expect(routine.id, 'r1');
    } finally {
      SupabaseService.backendBaseUrl = origBase;
      SupabaseService.firebaseAuthFactory = origAuth;
      SupabaseService.httpClient = origHttp;
    }
  });

  test('generateRoutineOnServer throws when user not signed in', () async {
    final origBase = SupabaseService.backendBaseUrl;
    final origAuth = SupabaseService.firebaseAuthFactory;

    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(null);

    try {
      SupabaseService.backendBaseUrl = () => 'https://example.test';
      SupabaseService.firebaseAuthFactory = () => auth;

      await expectLater(
        SupabaseService.instance.generateRoutineOnServer(
          request: 'r',
          durationMinutes: 10,
          difficulty: RoutineDifficulty.easy,
          equipment: const [],
        ),
        throwsA(isA<SupabaseException>()),
      );
    } finally {
      SupabaseService.backendBaseUrl = origBase;
      SupabaseService.firebaseAuthFactory = origAuth;
    }
  });

  test('default supabaseInitialize function is invoked (coverage)', () async {
    // We don't rely on the call succeeding in unit tests; we only want to execute
    // the default function body for coverage.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    try {
      await SupabaseService.supabaseInitialize(
        url: 'https://supabase.test',
        anonKey: 'anon',
      );
    } catch (_) {
      // ignore
    }
  });
}
