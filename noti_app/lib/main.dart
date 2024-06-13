import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:noti_app/homepage/homepage.dart';


//void main() => runApp(MyApp());

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
