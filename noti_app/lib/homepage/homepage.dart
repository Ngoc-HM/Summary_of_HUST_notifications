import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noti_app/bottom_navigator/bottom_navigator.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool isNotificationOn = true;
  late AnimationController _animationController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, String>>> _events = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _selectedDay = _focusedDay;
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    final data = await rootBundle.loadString('assets/data.csv');
    final List<List<dynamic>> csvTable = CsvToListConverter().convert(data);

    Map<DateTime, List<Map<String, String>>> events = {};
    for (var i = 1; i < csvTable.length; i++) {
      DateTime date = DateTime.parse(csvTable[i][3]);
      Map<String, String> event = {
        'title': csvTable[i][0],
        'description': csvTable[i][1],
        'time': csvTable[i][2]
      };
      if (events[date] == null) {
        events[date] = [event];
      } else {
        events[date]?.add(event);
      }
    }

    setState(() {
      _events = events;
      print("Events loaded: $_events");
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
      if (isNotificationOn) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    print("Getting events for day: $normalizedDay");
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xin chào ITSS in Japanese(2)', style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        
        ),),
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
                  child: ClipOval(
                    child: Image.asset("assets/images/avatar.png",
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hoàng Minh Ngọc',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('20200440', style: TextStyle(fontSize: 14)),
                  ],
                ),
                Spacer(),
                GestureDetector(
                  onTap: _toggleNotification,
                  child: Stack(
                    children: [
                      Icon(
                        Icons.notifications,
                        size: 40,
                        color: Colors.orange,
                      ),
                      if (!isNotificationOn)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Icon(
                            Icons.do_not_disturb,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
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
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` here as well
                  print("Selected day: $_selectedDay");
                });
              },
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: _buildEventsMarker(),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0, onTap: (index) {},
    ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay!);
    print("Events for selected day ($_selectedDay): $events");
    if (events.isEmpty) {
      return Center(child: Text('No events found'));
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        var event = events[index];
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      width: 7.0,
      height: 7.0,
    );
  }
}
