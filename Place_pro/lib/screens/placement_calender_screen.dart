// lib/screens/placement_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PlacementCalendarScreen extends StatefulWidget {
  const PlacementCalendarScreen({super.key});

  @override
  PlacementCalendarScreenState createState() => PlacementCalendarScreenState();
}

class PlacementCalendarScreenState extends State<PlacementCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('calendar_events')
        .orderBy('date')
        .get();
    
    Map<DateTime, List<Map<String, dynamic>>> events = {};
    
    for (var doc in snapshot.docs) {
      var eventData = doc.data() as Map<String, dynamic>;
      DateTime date = (eventData['date'] as Timestamp).toDate();
      DateTime dateKey = DateTime(date.year, date.month, date.day);
      
      if (events[dateKey] == null) {
        events[dateKey] = [];
      }
      
      events[dateKey]!.add({
        'id': doc.id,
        'title': eventData['title'] ?? 'Event',
        'type': eventData['type'] ?? 'Other',
        'time': eventData['time'] ?? '',
      });
    }
    
    if (!mounted) return;
    setState(() {
      _events = events;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Color _getEventColor(String type) {
    switch (type.toLowerCase()) {
      case 'drive':
        return Colors.blue;
      case 'interview':
        return Colors.green;
      case 'test':
        return Colors.orange;
      case 'deadline':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Placement Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: const CalendarStyle(
              markersMaxCount: 4,
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add event screen (admin only)
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventList() {
    final events = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];
    
    if (events.isEmpty) {
      return const Center(
        child: Text('No events for this day'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 12,
              height: 60,
              decoration: BoxDecoration(
                color: _getEventColor(event['type']),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            title: Text(
              event['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(_selectedDay!),
                  style: const TextStyle(fontSize: 14),
                ),
                if (event['time'].isNotEmpty)
                  Text(
                    'Time: ${event['time']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                Text(
                  'Type: ${event['type']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getEventColor(event['type']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  // Edit event (admin only)
                } else if (value == 'delete') {
                  // Delete event (admin only)
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}