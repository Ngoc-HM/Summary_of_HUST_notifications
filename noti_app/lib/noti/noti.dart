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
      title: 'Noti App Mobile',
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime? fromDate;
        DateTime? toDate;
        bool showTeams = true;
        bool showOutlook = true;
        bool showQLDT = true;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('From Date:'),
                      TextButton(
                        onPressed: () async {
                          fromDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          setState(() {});
                        },
                        child: Text(fromDate == null ? 'Select Date' : DateFormat('dd/MM/yyyy').format(fromDate!)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('To Date:'),
                      TextButton(
                        onPressed: () async {
                          toDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          setState(() {});
                        },
                        child: Text(toDate == null ? 'Select Date' : DateFormat('dd/MM/yyyy').format(toDate!)),
                      ),
                    ],
                  ),
                  CheckboxListTile(
                    title: Text('Teams'),
                    value: showTeams,
                    onChanged: (value) {
                      setState(() {
                        showTeams = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Outlook'),
                    value: showOutlook,
                    onChanged: (value) {
                      setState(() {
                        showOutlook = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('QLDT'),
                    value: showQLDT,
                    onChanged: (value) {
                      setState(() {
                        showQLDT = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Apply filters here
                    Navigator.of(context).pop();
                  },
                  child: Text('Apply'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
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
          final formattedDate = dateTime != null
              ? DateFormat('dd/MM/yyyy').format(dateTime)
              : "Invalid date";

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
        return Image.asset("assets/images/ehust.png", width: 50, height: 50);
      case 'Teams':
        return Image.asset("assets/images/teams.png", width: 50, height: 50);
      case 'Outlook':
        return Image.asset("assets/images/outlook.png", width: 50, height: 50);
      case 'QLDT':
        return Image.asset("assets/images/hust.png", width: 50, height: 50);
      default:
        return Icon(Icons.notifications);
    }
  }
}
