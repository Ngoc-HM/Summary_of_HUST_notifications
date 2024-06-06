import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

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
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xin chào ITSS in Japanese(2)'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: ClipOval(
                    child: Image.network(
                      'https://scontent.fhan2-5.fna.fbcdn.net/v/t39.30808-6/442417032_2200132937006625_2840452249868358038_n.jpg?_nc_cat=104&ccb=1-7&_nc_sid=5f2048&_nc_eui2=AeFePTbNarAIVvJ_zTQlu6JcRDnAhPbjJ9tEOcCE9uMn22OuT7dAb6mLV3FgUq0J2RcgMSV8PogEPBsg8cee8sVj&_nc_ohc=ifY0v8jrOnIQ7kNvgG_MPXt&_nc_ht=scontent.fhan2-5.fna&oh=00_AYANv1ZPS50Wx8FHOznBaNPt0q2xWzyRW5hRocjWheG7tg&oe=666747C6',
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
          TableCalendar(
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
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.orange,
      ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay!);
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
            leading: Image.network(
              event['title'] == 'eHUST'
                  ? 'https://via.placeholder.com/50x50.png?text=eHUST'
                  : event['title'] == 'Teams'
                  ? 'https://via.placeholder.com/50x50.png?text=Teams'
                  : 'https://via.placeholder.com/50x50.png?text=Outlook',
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
