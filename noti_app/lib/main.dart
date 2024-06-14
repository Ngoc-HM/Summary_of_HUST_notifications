import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:noti_app/homepage/homepage.dart';
import 'firebase_options.dart';


//void main() => runApp(MyApp());

void main() async{
   /*await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );*/
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
