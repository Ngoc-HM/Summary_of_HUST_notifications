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
  List<List<dynamic>> _filteredNotifications = [];

  DateTime? fromDate;
  DateTime? toDate;
  bool showTeams = true;
  bool showOutlook = true;
  bool showQLDT = true;
  bool showEhust = true;

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
      _filteredNotifications = csvTable.sublist(1); // Bỏ qua header
      _sortNotificationsByDate();
    });
  }

  void _sortNotificationsByDate() {
    _filteredNotifications.sort((a, b) {
      final dateA = _parseDate(a[3]);
      final dateB = _parseDate(b[3]);
      return dateB.compareTo(dateA);
    });
  }

  DateTime _parseDate(String date) {
    try {
      return DateFormat('yyyy-MM-dd').parse(date);
    } catch (e) {
      return DateTime(1900); // Invalid date fallback
    }
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

  void _applyFilters() {
    setState(() {
      _filteredNotifications = _notifications.sublist(1).where((notification) {
        final title = notification[0].toString();
        final date = _parseDate(notification[3]);
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
          final title = notification[0];
          final description = notification[1];
          final time = notification[2];
          final date = _parseDate(notification[3]);
          final formattedDate = DateFormat('dd/MM/yyyy').format(date);

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
                  Text(time, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
