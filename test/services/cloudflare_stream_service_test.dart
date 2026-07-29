import 'dart:convert';

import 'package:celia_flutter/services/cloudflare_stream_service.dart';
import 'package:celia_flutter/models/video.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('getPlaybackUrl/getEmbedUrl/getThumbnailUrl format correctly', () {
    final s = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient((_) async => http.Response('{}', 500)),
    );
    expect(
      s.getPlaybackUrl('id'),
      'https://customer-acc.cloudflarestream.com/id/manifest/video.m3u8',
    );
    expect(
      s.getEmbedUrl('id'),
      'https://customer-acc.cloudflarestream.com/id/iframe',
    );
    expect(
      s.getThumbnailUrl('id', time: 3, width: 100, height: 200),
      contains('time=3s'),
    );
    expect(s.getThumbnailUrl('id'), endsWith('/thumbnail.jpg'));
  });

  test('getDirectUploadUrl parses success response', () async {
    final client = MockClient((req) async {
      if (req.url.toString().contains('/direct_upload')) {
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        final meta = body['meta'] as Map<String, dynamic>;
        expect(meta['name'], 'a.mp4');
        expect(meta['foo'], 'bar');
        return http.Response(
          jsonEncode({
            'success': true,
            'result': {'uploadURL': 'https://upload', 'uid': 'uid1'},
          }),
          200,
        );
      }
      return http.Response('no', 500);
    });
    final s = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: client,
    );
    final res = await s.getDirectUploadUrl(
      filename: 'a.mp4',
      maxDurationSeconds: 10,
      metadata: {'foo': 'bar'},
    );
    expect(res.uploadUrl, 'https://upload');
    expect(res.streamId, 'uid1');
  });

  test('getDirectUploadUrl throws on non-200', () async {
    final s = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient((_) async => http.Response('no', 500)),
    );
    expect(
      () => s.getDirectUploadUrl(filename: 'a.mp4'),
      throwsA(isA<CloudflareException>()),
    );
  });

  test('getDirectUploadUrl throws when success=false', () async {
    final s = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'success': false,
            'errors': ['x'],
          }),
          200,
        ),
      ),
    );
    expect(
      () => s.getDirectUploadUrl(filename: 'a.mp4'),
      throwsA(isA<CloudflareException>()),
    );
  });

  test('getVideoDetails throws on non-200 and on success=false', () async {
    final s1 = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient((_) async => http.Response('no', 500)),
    );
    expect(() => s1.getVideoDetails('id'), throwsA(isA<CloudflareException>()));

    final s2 = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient(
        (_) async =>
            http.Response(jsonEncode({'success': false, 'errors': []}), 200),
      ),
    );
    expect(() => s2.getVideoDetails('id'), throwsA(isA<CloudflareException>()));
  });

  test('listVideos supports after param and throws on errors', () async {
    final ok = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient((req) async {
        expect(req.url.queryParameters['limit'], '2');
        expect(req.url.queryParameters['after'], 'a');
        return http.Response(
          jsonEncode({
            'success': true,
            'result': [
              {'uid': '1'},
            ],
          }),
          200,
        );
      }),
    );
    final res = await ok.listVideos(limit: 2, after: 'a');
    expect(res.first['uid'], '1');

    final non200 = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient((_) async => http.Response('no', 500)),
    );
    expect(() => non200.listVideos(), throwsA(isA<CloudflareException>()));

    final fail = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'success': false,
            'errors': ['x'],
          }),
          200,
        ),
      ),
    );
    expect(() => fail.listVideos(), throwsA(isA<CloudflareException>()));
  });

  test('deleteVideo success and failure', () async {
    final ok = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient((req) async {
        expect(req.method, 'DELETE');
        return http.Response('', 200);
      }),
    );
    await ok.deleteVideo('id');

    final bad = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient((_) async => http.Response('no', 500)),
    );
    expect(() => bad.deleteVideo('id'), throwsA(isA<CloudflareException>()));
  });

  test('getVideoStatus maps cloudflare states', () async {
    Future<http.Response> responder(String state) async {
      return http.Response(
        jsonEncode({
          'success': true,
          'result': {
            'status': {'state': state},
          },
        }),
        200,
      );
    }

    final sReady = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient((_) => responder('ready')),
    );
    expect(await sReady.getVideoStatus('x'), VideoStatus.ready);

    final sProg = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient((_) => responder('inprogress')),
    );
    expect(await sProg.getVideoStatus('x'), VideoStatus.processing);

    final sErr = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient((_) => responder('error')),
    );
    expect(await sErr.getVideoStatus('x'), VideoStatus.error);

    final sUnknown = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient((_) => responder('wat')),
    );
    expect(await sUnknown.getVideoStatus('x'), VideoStatus.pending);

    final sNull = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient(
        (_) async =>
            http.Response(jsonEncode({'success': true, 'result': {}}), 200),
      ),
    );
    expect(await sNull.getVideoStatus('x'), VideoStatus.pending);

    final sQueued = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient((_) => responder('queued')),
    );
    expect(await sQueued.getVideoStatus('x'), VideoStatus.processing);

    final sException = CloudflareStreamService(
      accountId: 'acc',
      apiToken: 'tok',
      client: MockClient((_) async => http.Response('no', 500)),
    );
    expect(await sException.getVideoStatus('x'), VideoStatus.error);
  });

  test('CloudflareException.toString formats', () {
    expect(CloudflareException('m').toString(), 'm');
    expect(CloudflareException('m', 'd').toString(), 'm: d');
  });
}
