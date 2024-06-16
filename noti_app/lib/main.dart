import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Realtime Demo',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final databaseRef = FirebaseDatabase.instance.ref().child('data');
  List<Map<dynamic, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    databaseRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final List<Map<dynamic, dynamic>> loadedItems = [];
        data.forEach((key, value) {
          loadedItems.add(Map<dynamic, dynamic>.from(value));
        });
        setState(() {
          items = loadedItems;
        });
      } else if (data is List) {
        final List<Map<dynamic, dynamic>> loadedItems = data.map((item) => Map<dynamic, dynamic>.from(item)).toList();
        setState(() {
          items = loadedItems;
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Realtime Database'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item['title'] ?? 'No title'),
            subtitle: Text(item['description'] ?? 'No description'),
          );
        },
      ),
    );
  }
}
