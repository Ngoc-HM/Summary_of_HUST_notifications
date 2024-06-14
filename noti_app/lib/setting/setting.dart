import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:noti_app/bottom_navigator/bottom_navigator.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Setting App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SettingPage(title: 'Ứng Dụng'),
    );
  }
}


class SettingPage extends StatefulWidget {
  const SettingPage({super.key, required this.title});
  final String title;

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<List<dynamic>> _notifications = [];
  bool isSwitchedTeams = false;
  bool isSwitchedOutlook = false;
  bool isSwitchedQLDT = false;


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
          //IconButton(
          //  icon: Icon(Icons.filter_list),
          //  onPressed: _showFilterDialog,
          //),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          print("Tapped on index $index");
        },
      ),
      body: Container(
        padding: EdgeInsets.all(35),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 218, 214, 198),
              ),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    _getLeadingIcon('teams_app'),
                    SizedBox(width: 20),
                    Text('Teams', style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                    ),
                    SizedBox(width: 150),
                    Switch(
                      value: isSwitchedTeams,
                      onChanged: (value) {
                        setState(() {
                          isSwitchedTeams = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 218, 214, 198),
              ),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    _getLeadingIcon('Outlook'),
                    SizedBox(width: 20),
                    Text('Outlook', style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                    ),
                    SizedBox(width: 140),
                    Switch(
                      value: isSwitchedOutlook,
                      onChanged: (value) {
                        setState(() {
                          isSwitchedOutlook = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 218, 214, 198),
              ),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    _getLeadingIcon('eHUST'),
                    SizedBox(width: 20),
                    Text('Quản lý đào tạo', style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),),
                    SizedBox(width: 70),
                    Switch(
                      value: isSwitchedQLDT,
                      onChanged: (value) {
                        setState(() {
                          isSwitchedQLDT = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
          ]
        ),
      ),
    );
  }
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
      case 'teams_app':
        return Image.asset("assets/images/teams.png", width: 50, height: 50);
      //case 'teams_app':
      //  return Image.asset("assets/iconapp/teams_app.png", width: 50, height: 50);
      default:
        return Icon(Icons.notifications);
    }
  }

