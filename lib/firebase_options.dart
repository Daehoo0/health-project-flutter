import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: "AIzaSyCF6bdnk5pGq6KcHYXXaRaMq2eYX1FDDOA",
    appId: "1:733895919503:web:e4627f337884730fcf6dfa",  // Ganti dengan appId Anda
    messagingSenderId: "733895919503",  // Ganti dengan senderId Anda
    projectId: "healthproject-83a51",  // Ganti dengan projectId Anda
    authDomain: "healthproject-83a51.firebaseapp.com",  // Ganti dengan authDomain Anda
    storageBucket: "healthproject-83a51.appspot.com",  // Ganti dengan storageBucket Anda
    databaseURL: "https:healthproject-83a51.firebaseio.com",  // Jika Anda menggunakan Realtime Database
    measurementId: "your-measurement-id",  // Ganti dengan measurementId Anda (untuk Google Analytics)
    iosClientId: "your-ios-client-id.apps.googleusercontent.com",  // Jika Anda menargetkan iOS
    iosBundleId: "com.yourcompany.yourapp",  // Jika Anda menargetkan iOS
    androidClientId: "your-android-client-id.apps.googleusercontent.com",  // Jika Anda menargetkan Android
  );
}