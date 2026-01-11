import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:celia_flutter/providers/auth_provider.dart' as app_auth;
import 'package:celia_flutter/providers/theme_provider.dart';
import 'package:celia_flutter/repositories/auth_repository.dart';
import 'package:celia_flutter/screens/profile/edit_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}
class MockFbUser extends Mock implements fb.User {}
class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockReference extends Mock implements Reference {}
class MockImagePicker extends Mock implements ImagePicker {}

class FakeTaskSnapshot extends Fake implements TaskSnapshot {}

class FakeUploadTask extends Fake implements UploadTask {
  final Future<TaskSnapshot> _future;
  FakeUploadTask(this._future);

  @override
  TaskSnapshot get snapshot => FakeTaskSnapshot();

  @override
  Stream<TaskSnapshot> get snapshotEvents => const Stream.empty();

  @override
  Future<S> then<S>(
    FutureOr<S> Function(TaskSnapshot value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }

  @override
  Future<TaskSnapshot> catchError(Function onError, {bool Function(Object error)? test}) {
    return _future.catchError(onError, test: test);
  }

  @override
  Future<TaskSnapshot> whenComplete(FutureOr<void> Function() action) {
    return _future.whenComplete(action);
  }

  @override
  Stream<TaskSnapshot> asStream() => _future.asStream();

  @override
  Future<TaskSnapshot> timeout(Duration timeLimit, {FutureOr<TaskSnapshot> Function()? onTimeout}) {
    return _future.timeout(timeLimit, onTimeout: onTimeout);
  }
}

Uint8List _transparentPng() => Uint8List.fromList(<int>[
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
      0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82,
    ]);

Widget _wrap(Widget child, {required app_auth.AuthProvider auth, required ThemeProvider theme}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>.value(value: theme),
      ChangeNotifierProvider<app_auth.AuthProvider>.value(value: auth),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(File('x'));
  });

  testWidgets('uses EditProfileScreen default factories when no deps are passed', (tester) async {
    final origAuth = EditProfileScreen.defaultAuth;
    final origStorage = EditProfileScreen.defaultStorage;
    final origPicker = EditProfileScreen.defaultPicker;
    addTearDown(() {
      EditProfileScreen.defaultAuth = origAuth;
      EditProfileScreen.defaultStorage = origStorage;
      EditProfileScreen.defaultPicker = origPicker;
    });

    final mockAuth = MockFirebaseAuth();
    when(() => mockAuth.currentUser).thenReturn(null);
    final mockStorage = MockFirebaseStorage();
    final mockPicker = MockImagePicker();

    EditProfileScreen.defaultAuth = () => mockAuth;
    EditProfileScreen.defaultStorage = () => mockStorage;
    EditProfileScreen.defaultPicker = () => mockPicker;

    final repo = MockAuthRepository();
    when(() => repo.currentUser).thenReturn(null);
    final authProvider = app_auth.AuthProvider(authRepository: repo);
    addTearDown(authProvider.dispose);

    await tester.pumpWidget(_wrap(EditProfileScreen(), auth: authProvider, theme: ThemeProvider()));
    await tester.pump();
    expect(find.text('Edit Profile'), findsOneWidget);
  });

  testWidgets('save success pops; pick photo triggers upload and updateProfile', (tester) async {
    final uid = 'u';

    final repo = MockAuthRepository();
    final fbUser = MockFbUser();
    when(() => fbUser.uid).thenReturn(uid);
    when(() => fbUser.displayName).thenReturn('Old');
    when(() => fbUser.photoURL).thenReturn('');
    when(() => fbUser.emailVerified).thenReturn(true);
    when(() => repo.currentUser).thenReturn(fbUser);
    when(() => repo.updateProfile(displayName: any(named: 'displayName'), photoUrl: any(named: 'photoUrl'))).thenAnswer((_) async {});
    when(() => repo.reloadUser()).thenAnswer((_) async => fbUser);
    final authProvider = app_auth.AuthProvider(authRepository: repo);
    addTearDown(authProvider.dispose);

    // create a real temp image file
    final dir = await Directory.systemTemp.createTemp('celia_test');
    addTearDown(() async => dir.delete(recursive: true));
    final imgPath = '${dir.path}${Platform.pathSeparator}p.png';
    await File(imgPath).writeAsBytes(_transparentPng());
    final xfile = XFile(imgPath);

    final picker = MockImagePicker();
    when(() => picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1024))
        .thenAnswer((_) async => xfile);

    final storage = MockFirebaseStorage();
    final rootRef = MockReference();
    final childRef = MockReference();
    when(() => storage.ref()).thenReturn(rootRef);
    when(() => rootRef.child('profile_photos/$uid.jpg')).thenReturn(childRef);
    when(() => childRef.putFile(any())).thenReturn(FakeUploadTask(Future.value(FakeTaskSnapshot())));
    when(() => childRef.getDownloadURL()).thenAnswer((_) async => 'https://example.test/photo.jpg');

    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(fbUser);

    final theme = ThemeProvider();

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(auth: auth, storage: storage, picker: picker),
                  ),
                ),
                child: const Text('OPEN_EDIT'),
              ),
            ),
          ),
        ),
        auth: authProvider,
        theme: theme,
      ),
    );

    await tester.tap(find.text('OPEN_EDIT'));
    await tester.pumpAndSettle();

    // pick photo
    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pump();

    // save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(() => childRef.putFile(any())).called(1);
    verify(() => repo.updateProfile(displayName: any(named: 'displayName'), photoUrl: 'https://example.test/photo.jpg')).called(1);
    expect(find.text('OPEN_EDIT'), findsOneWidget); // popped back
  });

  testWidgets('save error shows snackbar and does not pop', (tester) async {
    final uid = 'u';

    final repo = MockAuthRepository();
    final fbUser = MockFbUser();
    when(() => fbUser.uid).thenReturn(uid);
    when(() => fbUser.displayName).thenReturn('Old');
    when(() => fbUser.photoURL).thenReturn('');
    when(() => fbUser.emailVerified).thenReturn(true);
    when(() => repo.currentUser).thenReturn(fbUser);
    when(() => repo.updateProfile(displayName: any(named: 'displayName'), photoUrl: any(named: 'photoUrl')))
        .thenThrow(Exception('boom'));
    final authProvider = app_auth.AuthProvider(authRepository: repo);
    addTearDown(authProvider.dispose);

    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(fbUser);

    final storage = MockFirebaseStorage();
    final picker = MockImagePicker();

    final theme = ThemeProvider();

    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: EditProfileScreen(auth: auth, storage: storage, picker: picker),
        ),
        auth: authProvider,
        theme: theme,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pump(); // start async
    await tester.pump(); // show snackbar

    expect(find.textContaining('Failed to update profile'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
  });
}

