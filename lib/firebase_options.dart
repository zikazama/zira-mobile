import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Konfigurasi default untuk Firebase
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions tidak tersedia untuk platform ini.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB-Xhg92BOqR8tKdOkB-U278SCWlVXFt60',
    appId: '1:687930698850:web:7c1c3f1211513e1c69b53b',
    messagingSenderId: '687930698850',
    projectId: 'zira-56797',
    authDomain: 'zira-56797.firebaseapp.com',
    databaseURL: 'https://zira-56797-default-rtdb.firebaseio.com',
    storageBucket: 'zira-56797.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-Xhg92BOqR8tKdOkB-U278SCWlVXFt60',
    appId: '1:687930698850:android:7c1c3f1211513e1c69b53b',
    messagingSenderId: '687930698850',
    projectId: 'zira-56797',
    databaseURL: 'https://zira-56797-default-rtdb.firebaseio.com',
    storageBucket: 'zira-56797.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB-Xhg92BOqR8tKdOkB-U278SCWlVXFt60',
    appId: '1:687930698850:ios:7c1c3f1211513e1c69b53b',
    messagingSenderId: '687930698850',
    projectId: 'zira-56797',
    databaseURL: 'https://zira-56797-default-rtdb.firebaseio.com',
    storageBucket: 'zira-56797.firebasestorage.app',
    iosClientId: 'com.tokodizital.zira',
    iosBundleId: 'com.tokodizital.zira',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB-Xhg92BOqR8tKdOkB-U278SCWlVXFt60',
    appId: '1:687930698850:macos:7c1c3f1211513e1c69b53b',
    messagingSenderId: '687930698850',
    projectId: 'zira-56797',
    databaseURL: 'https://zira-56797-default-rtdb.firebaseio.com',
    storageBucket: 'zira-56797.firebasestorage.app',
    iosClientId: 'com.tokodizital.zira',
    iosBundleId: 'com.tokodizital.zira',
  );
}