import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:noti_app/bottom_navigator/bottom_navigator.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final databaseRef = FirebaseDatabase.instance.ref().child('data');
  List<Map<dynamic, dynamic>> items = [];
  Map<DateTime, List<Map<String, String>>> _events = {};

  bool isNotificationOn = true;
  late AnimationController _animationController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    databaseRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print(data); // In dữ liệu ra để kiểm tra
      if (data is Map) {
        final List<Map<dynamic, dynamic>> loadedItems = [];
        data.forEach((key, value) {
          loadedItems.add(Map<dynamic, dynamic>.from(value));
        });
        setState(() {
          items = loadedItems;
          _convertItemsToEvents();
        });
      } else if (data is List) {
        final List<Map<dynamic, dynamic>> loadedItems = data.map((item) => Map<dynamic, dynamic>.from(item)).toList();
        setState(() {
          items = loadedItems;
          _convertItemsToEvents();
        });
      }
    });

    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _selectedDay = _focusedDay;
  }

  void _convertItemsToEvents() {
    Map<DateTime, List<Map<String, String>>> events = {};
    for (var item in items) {
      // Kiểm tra và xử lý giá trị null
      if (item['datetime'] == null || item['title'] == null || item['description'] == null || item['time'] == null) {
        continue;
      }
      DateTime date = DateTime.parse(item['datetime']);
      Map<String, String> event = {
        'title': item['title'] ?? '',
        'description': item['description'] ?? '',
        'time': item['time'] ?? ''
      };
      events.update(date, (list) => list..add(event), ifAbsent: () => [event]);
    }
    setState(() {
      _events = events;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleNotification() {
    setState(() {
      isNotificationOn = !isNotificationOn;
      isNotificationOn ? _animationController.reverse() : _animationController.forward();
    });
  }

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello ITSS in 日本語(2)', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(width: 10),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: ClipOval(child: Image.asset("assets/images/avatar.png", fit: BoxFit.cover, width: 60, height: 60)),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hoàng Minh Ngọc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('20200440', style: TextStyle(fontSize: 14)),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    Icon(isNotificationOn ? Icons.notifications_active : Icons.notifications_off, color: isNotificationOn ? Colors.orange : Colors.red),
                    Switch(value: isNotificationOn, onChanged: (value) => _toggleNotification(), activeColor: Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(15),
            child: TableCalendar(
              firstDay: DateTime(2023, 1, 1),
              lastDay: DateTime(2024, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) => setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              }),
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(markerBuilder: (context, date, items) {
                return items.isNotEmpty ? Positioned(bottom: 1, child: _buildEventsMarker()) : Container();
              }),
            ),
          ),
          Expanded(child: _buildEventList()),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0, onTap: (index) {}),
    );
  }

  Widget _buildEventList() {
    final items = _getEventsForDay(_selectedDay!);
    if (items.isEmpty) {
      return Center(child: Text('No events found'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        var event = items[index];
        print("data ${event['title']}"); // In dữ liệu ra để kiểm tra
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: Image.asset(
              event['title'] == 'eHUST'
                  ? 'assets/images/ehust.png'
                  : event['title'] == 'Teams'
                  ? 'assets/images/teams.png'
                  : event['title'] == 'QLDT'
                  ? 'assets/images/hust.png'
                  : 'assets/images/outlook.png',
              width: 50,
              height: 50,
            ),
            title: Text(event['title']!),
            subtitle: Text(event['description']!),
            trailing: Text(event['time']!),
          ),
        );
      },
    );
  }

  Widget _buildEventsMarker() {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
      width: 7.0,
      height: 7.0,
    );
  }
}
