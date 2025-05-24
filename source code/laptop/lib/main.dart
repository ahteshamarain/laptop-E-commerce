
import 'package:laptop/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:laptop/splashScreen_gif.dart';
import 'package:laptop/welcome.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
//options: const FirebaseOptions(apiKey:'Your API key',appId:'mobilesdk_app_id',messagingSenderId:'project_number',projectId:'project_id')

    options: const FirebaseOptions(
     apiKey: 'AIzaSyCs7TxtB8D9-mAFtjBsGEXto9lV7jodeY8',
    appId: '1:171016321341:web:a1dee15f06ef422c0f6d54',
    messagingSenderId: '171016321341',
    projectId: 'mylaptop-94cb2',
    authDomain: 'mylaptop-94cb2.firebaseapp.com',
    storageBucket: 'mylaptop-94cb2.firebasestorage.app',
    measurementId: 'G-JB4WJ2585H',
    ),
  );
  // await Future.delayed(const Duration(seconds: 3));
  // FlutterNativeSplash.remove();

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        //'Dashboard': (context) => Dash(),
        'splash_Screen': (context) => SplashScreen(),
      }));
}
