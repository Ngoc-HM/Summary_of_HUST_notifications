import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
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

  Future<void> writeDataToCSV() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/assets';
      final filePath = '$path/data.csv';

      // Kiểm tra và tạo thư mục nếu chưa tồn tại
      final directoryExists = await Directory(path).exists();
      if (!directoryExists) {
        await Directory(path).create(recursive: true);
      }

      final file = File(filePath);

      // Dữ liệu mẫu để ghi vào file CSV
      String csvData = "title,description,time,datetime\n";

      for (var item in items) {
        final title = item['title'] ?? 'No title';
        final description = item['description'] ?? 'No description';
        final time = item['time'] ?? 'No time';
        final datetime = item['datetime'] ?? 'No datetime';
        csvData += '$title,$description,$time,$datetime\n';
      }

      // Ghi đè dữ liệu vào file CSV
      await file.writeAsString(csvData);
      print('File CSV đã được ghi đè thành công.');
    } catch (e) {
      print('Có lỗi xảy ra: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Realtime Database'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: writeDataToCSV,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item['title'] ?? 'No title'),
            subtitle: Text(item['description'] ?? 'No description'),
            trailing: Text(item['datetime'] ?? 'No datetime'),
          );
        },
      ),
    );
  }
}
