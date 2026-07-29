import 'package:celia_flutter/models/video.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Video derived properties + JSON', () {
    final v = Video(
      id: 'id',
      streamId: 'abc-123',
      title: 'T',
      description: null,
      durationSeconds: 65,
      thumbnailUrl: null,
      playbackUrl: 'hls',
      status: VideoStatus.ready,
      uploadedBy: 'admin',
      uploadedAt: DateTime(2026, 1, 10),
      tags: const ['x'],
      category: 'yoga',
      fileSize: 123,
    );

    expect(v.durationLabel, '1:05');
    expect(v.isReady, isTrue);
    expect(v.streamThumbnailUrl, contains('/abc-123/thumbnails/thumbnail.jpg'));

    final roundTrip = Video.fromJson(v.toJson());
    expect(roundTrip.streamId, 'abc-123');
    expect(roundTrip.status, VideoStatus.ready);
  });

  test('VideoUploadRequest/Response JSON', () {
    const req = VideoUploadRequest(
      filename: 'a.mp4',
      maxDurationSeconds: 300,
      metadata: {'k': 'v'},
    );
    expect(VideoUploadRequest.fromJson(req.toJson()).filename, 'a.mp4');

    final res = VideoUploadResponse(
      uploadUrl: 'https://upload',
      streamId: 'uid',
      expiresAt: DateTime(2026, 1, 10),
    );
    expect(VideoUploadResponse.fromJson(res.toJson()).streamId, 'uid');
  });
}
