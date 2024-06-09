import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:noti_app/bottom_navigator/bottom_navigator.dart';

class Noti extends StatelessWidget {
  const Noti({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NotiPage(title: 'Thông báo'),
    );
  }
}

class NotiPage extends StatefulWidget {
  const NotiPage({super.key, required this.title});
  final String title;

  @override
  State<NotiPage> createState() => _NotiPageState();
}

class _NotiPageState extends State<NotiPage> {
  List<List<dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    final data = await rootBundle.loadString('assets/data.csv');
    final List<List<dynamic>> csvTable = CsvToListConverter().convert(data);
    setState(() {
      _notifications = csvTable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          print("Tapped on index $index");
        },
      ),
      body: _notifications.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Skip the header row
            return Container();
          }
          final notification = _notifications[index];
          final title = notification[0];
          final description = notification[1];
          final time = notification[2];
          DateTime? dateTime;
          try {
            dateTime = DateFormat('yyyy-MM-dd').parse(notification[3]);
          } catch (e) {
            print("Error parsing date: ${notification[3]}");
          }
          final formattedDate = dateTime != null ? DateFormat('dd/MM/yyyy').format(dateTime) : "Invalid date";

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: _getLeadingIcon(title),
              title: Text(title),
              subtitle: Text(description),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formattedDate),
                  Text(time),
                ],
              ),
            ),
          );
        },
      ),

    );
  }

  Widget _getLeadingIcon(String title) {
    switch (title) {
      case 'eHUST':
        return Image.network('https://via.placeholder.com/50x50.png?text=eHUST');
      case 'Team':
        return Image.network('https://via.placeholder.com/50x50.png?text=Teams');
      case 'Outlook':
        return Image.network('https://via.placeholder.com/50x50.png?text=Outlook');
      case 'QLDT':
        return Image.network('https://via.placeholder.com/50x50.png?text=QLDT');
      default:
        return Icon(Icons.notifications);
    }
  }
}
