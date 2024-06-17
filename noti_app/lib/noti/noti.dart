import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noti_app/bottom_navigator/bottom_navigator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<Map<dynamic, dynamic>> _notifications = [];
  List<Map<dynamic, dynamic>> _filteredNotifications = [];

  DateTime? fromDate;
  DateTime? toDate;
  bool showTeams = true;
  bool showOutlook = true;
  bool showQLDT = true;
  bool showEhust = true;

  final databaseRef = FirebaseDatabase.instance.ref().child('data');

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadData();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showTeams = prefs.getBool('showTeams') ?? true;
      showOutlook = prefs.getBool('showOutlook') ?? true;
      showQLDT = prefs.getBool('showQLDT') ?? true;
      showEhust = prefs.getBool('showEhust') ?? true;
    });
  }

  void _loadData() {
    databaseRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print(data); // In dữ liệu ra để kiểm tra

      if (data is List) {
        final List<Map<dynamic, dynamic>> loadedItems = data.map((item) {
          if (item is List && item.length >= 4) {
            return {
              'title': item[0],
              'description': item[1],
              'time': item[2],
              'datetime': item[3]
            };
          } else if (item is Map) {
            return Map<dynamic, dynamic>.from(item);
          } else {
            return <dynamic, dynamic>{}; // Trường hợp không xác định
          }
        }).toList();

        setState(() {
          _notifications = loadedItems.where((item) => item.isNotEmpty).toList();
          _filteredNotifications = _notifications;
          _applyFilters(); // Áp dụng bộ lọc sau khi tải dữ liệu
        });
      } else if (data is Map) {
        final List<Map<dynamic, dynamic>> loadedItems = [];
        data.forEach((key, value) {
          if (value is Map) {
            loadedItems.add(Map<dynamic, dynamic>.from(value));
          }
        });

        setState(() {
          _notifications = loadedItems;
          _filteredNotifications = loadedItems;
          _applyFilters(); // Áp dụng bộ lọc sau khi tải dữ liệu
        });
      }
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredNotifications = _notifications.where((notification) {
        final title = notification['title'].toString();
        final date = _parseDateTime(notification['datetime'], notification['time']);
        bool matchesTitle = (showTeams && title == 'Teams') ||
            (showOutlook && title == 'Outlook') ||
            (showQLDT && title == 'QLDT') ||
            (showEhust && title == 'eHUST');
        bool matchesDate = (fromDate == null || date.isAfter(fromDate!)) &&
            (toDate == null || date.isBefore(toDate!));
        return matchesTitle && matchesDate;
      }).toList();
      _sortNotificationsByDate();
    });
  }

  void _sortNotificationsByDate() {
    _filteredNotifications.sort((a, b) {
      final dateTimeA = _parseDateTime(a['datetime'], a['time']);
      final dateTimeB = _parseDateTime(b['datetime'], b['time']);
      return dateTimeB.compareTo(dateTimeA);
    });
  }

  DateTime _parseDateTime(String? date, String? time) {
    try {
      if (date != null && time != null) {
        return DateFormat('yyyy-MM-dd HH:mm').parse('$date $time');
      } else if (date != null) {
        return DateFormat('yyyy-MM-dd').parse(date);
      }
    } catch (e) {
      // Handle parsing error
    }
    return DateTime(1900); // Invalid date fallback
  }


  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Lọc Thông Báo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDateRow('Ngày Bắt Đầu:', fromDate, (date) {
                    setState(() => fromDate = date);
                  }),
                  _buildDateRow('Ngày Kết Thúc:', toDate, (date) {
                    setState(() => toDate = date);
                  }),
                  _buildCheckbox('Teams', showTeams, (value) {
                    setState(() => showTeams = value!);
                  }),
                  _buildCheckbox('Outlook', showOutlook, (value) {
                    setState(() => showOutlook = value!);
                  }),
                  _buildCheckbox('QLDT', showQLDT, (value) {
                    setState(() => showQLDT = value!);
                  }),
                  _buildCheckbox('eHUST', showEhust, (value) {
                    setState(() => showEhust = value!);
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _applyFilters();
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

  Row _buildDateRow(String label, DateTime? date, Function(DateTime?) onDateSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        TextButton(
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            onDateSelected(selectedDate);
          },
          child: Text(date == null ? 'Chọn ngày' : DateFormat('dd/MM/yyyy').format(date)),
        ),
      ],
    );
  }

  CheckboxListTile _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(widget.title, style: TextStyle(fontSize: 25)),
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
      body: _filteredNotifications.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = _filteredNotifications[index];
          final title = notification['title'] ?? '';
          final description = notification['description'] ?? '';
          final time = notification['time'] ?? '';
          final date = _parseDateTime(notification['datetime'], time);
          final formattedDate = DateFormat('dd/MM/yyyy').format(date);
          final formattedTime = DateFormat('HH:mm').format(date);

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: _getLeadingIcon(title),
              title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(description),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formattedDate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(formattedTime, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
