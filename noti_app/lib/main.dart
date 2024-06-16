import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:noti_app/firebase_api.dart';
import 'package:noti_app/login/login.dart';
import 'firebase_options.dart';



//void main() => runApp(MyApp());

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    //await FirebaseApi().initNotifications();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
