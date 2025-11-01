// lib/screens/admin/calendar_management_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarManagementScreen extends StatefulWidget {
  const CalendarManagementScreen({super.key});

  @override
  CalendarManagementScreenState createState() => CalendarManagementScreenState();
}

class CalendarManagementScreenState extends State<CalendarManagementScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  String _eventType = 'Drive';
  bool _isLoading = false;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
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
    
    setState(() {
      _events = events;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _addEvent() async {
    if (_formKey.currentState!.validate() && _selectedDay != null) {
      setState(() {
        _isLoading = true;
      });
      
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        await FirebaseFirestore.instance.collection('calendar_events').add({
          'title': _titleController.text.trim(),
          'type': _eventType,
          'date': Timestamp.fromDate(_selectedDay!),
          'time': _timeController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        _clearForm();
        setState(() {
          _isAdding = false;
        });
        
        // Reload events
        await _loadEvents();

        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Event added successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error adding event: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _timeController.clear();
    _eventType = 'Drive';
  }

  Future<void> _deleteEvent(String eventId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navContext = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              navContext.pop();

              setState(() {
                _isLoading = true;
              });

              try {
                await FirebaseFirestore.instance
                    .collection('calendar_events')
                    .doc(eventId)
                    .delete();

                // Reload events
                await _loadEvents();

                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Event deleted successfully')),
                );
              } catch (e) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error deleting event: $e')),
                );
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Calendar Events'),
        actions: [
          IconButton(
            icon: Icon(_isAdding ? Icons.cancel : Icons.add),
            onPressed: () {
              setState(() {
                _isAdding = !_isAdding;
                if (!_isAdding) {
                  _clearForm();
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Add Event Form
                if (_isAdding) _buildAddEventForm(),
                
                // Calendar
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
                
                // Events List
                Expanded(
                  child: _buildEventList(),
                ),
              ],
            ),
    );
  }

  Widget _buildAddEventForm() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Event',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _eventType,
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Drive', child: Text('Drive')),
                  DropdownMenuItem(value: 'Interview', child: Text('Interview')),
                  DropdownMenuItem(value: 'Test', child: Text('Test')),
                  DropdownMenuItem(value: 'Deadline', child: Text('Deadline')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _eventType = value ?? 'Drive';
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${_selectedDay != null ? DateFormat('dd MMM yyyy').format(_selectedDay!) : 'No date selected'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDay ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      
                      if (picked != null) {
                        setState(() {
                          _selectedDay = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 10:00 AM',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addEvent,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add Event'),
              ),
            ],
          ),
        ),
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
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteEvent(event['id']),
            ),
          ),
        );
      },
    );
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
}