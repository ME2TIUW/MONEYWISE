import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCUsyasLurlgUXdHNEPEO9UjQAU942Oq_8',
    appId: '1:942862515931:web:37c92a2d517b6f4772d6fe',
    messagingSenderId: '942862515931',
    projectId: 'money-wise-873dd',
    authDomain: 'money-wise-873dd.firebaseapp.com',
    storageBucket: 'money-wise-873dd.firebasestorage.app',
    measurementId: 'G-V2MYHR1SKM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZcEHGJY6juSEhk_IeU8XpArLD-kC2oFM',
    appId: '1:942862515931:android:db68b8a97326d49a72d6fe',
    messagingSenderId: '942862515931',
    projectId: 'money-wise-873dd',
    storageBucket: 'money-wise-873dd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyASFJbST_JIfCWlc7o_tQPLtGHhTv5gxSY',
    appId: '1:942862515931:ios:2d7524e7b58d187072d6fe',
    messagingSenderId: '942862515931',
    projectId: 'money-wise-873dd',
    storageBucket: 'money-wise-873dd.firebasestorage.app',
    androidClientId: '942862515931-mkmrkqsk8jitk7b73a2n8248vjl88k16.apps.googleusercontent.com',
    iosClientId: '942862515931-e6kkucatp93j4ph4bspr8dhu00g66l9a.apps.googleusercontent.com',
    iosBundleId: 'id.ac.binus.moneyWise',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyASFJbST_JIfCWlc7o_tQPLtGHhTv5gxSY',
    appId: '1:942862515931:ios:2d7524e7b58d187072d6fe',
    messagingSenderId: '942862515931',
    projectId: 'money-wise-873dd',
    storageBucket: 'money-wise-873dd.firebasestorage.app',
    androidClientId: '942862515931-mkmrkqsk8jitk7b73a2n8248vjl88k16.apps.googleusercontent.com',
    iosClientId: '942862515931-e6kkucatp93j4ph4bspr8dhu00g66l9a.apps.googleusercontent.com',
    iosBundleId: 'id.ac.binus.moneyWise',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCUsyasLurlgUXdHNEPEO9UjQAU942Oq_8',
    appId: '1:942862515931:web:46dde39d4b54c57a72d6fe',
    messagingSenderId: '942862515931',
    projectId: 'money-wise-873dd',
    authDomain: 'money-wise-873dd.firebaseapp.com',
    storageBucket: 'money-wise-873dd.firebasestorage.app',
    measurementId: 'G-FTGH7QWF1Q',
  );

}