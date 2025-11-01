// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
    const CalendarScreen({super.key});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late Map<String, String> _southIndianDate;
  final List<String> _tamilMonths = [
    'சித்திரை', 'வைகாசி', 'ஆனி', 'ஆடி', 'ஆவணி', 'புரட்டாசி',
    'ஐப்பசி', 'கார்த்திகை', 'மார்கழி', 'தை', 'மாசி', 'பங்குனி'
  ];
  final List<String> _tamilWeekdays = [
    'ஞாயிறு', 'திங்கள்', 'செவ்வாய்', 'புதன்', 'வியாழன்', 'வெள்ளி', 'சனி'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _updateSouthIndianDate();
  }

  void _updateSouthIndianDate() {
    // Convert Gregorian to South Indian (Tamil) date
    // This is a simplified conversion and may not be 100% accurate
    // For production, consider using a proper Indian calendar library
    final gregorianYear = _selectedDate.year;
    final gregorianMonth = _selectedDate.month;
    final gregorianDay = _selectedDate.day;
    
    // Tamil New Year is typically on April 14th
    final isAfterNewYear = (gregorianMonth > 4) || (gregorianMonth == 4 && gregorianDay >= 14);
    final tamilYear = isAfterNewYear ? gregorianYear + 78 : gregorianYear + 77;
    
    // Simple month mapping (approximate)
    int tamilMonthIndex = (gregorianMonth + 8) % 12;
    
    setState(() {
      _southIndianDate = {
        'year': tamilYear.toString(),
        'month': _tamilMonths[tamilMonthIndex],
        'day': gregorianDay.toString(),
        'weekday': _tamilWeekdays[_selectedDate.weekday % 7],
      };
    });
  }

  void _onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      _selectedDate = selectedDate;
      _updateSouthIndianDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('தேதி நாட்காட்டி / Calendar'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gregorian Calendar
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: CalendarDatePicker(
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        onDateChanged: (date) => _onDaySelected(date, date),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // South Indian (Tamil) Date
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'தமிழ் நாள்காட்டி',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_southIndianDate['weekday']}, ${_southIndianDate['day']} ${_southIndianDate['month']}, ${_southIndianDate['year']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Note: This is a simplified conversion. For accurate Tamil calendar dates, consider using a dedicated Tamil calendar service.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // Calendar Legend
            const SizedBox(height: 24),
            FutureBuilder(
              future: Future.value(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return Card(
                  elevation: 4,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tamil Months (Chithirai to Panguni):',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'சித்திரை (Chithirai) - April/May\n'
                          'வைகாசி (Vaikasi) - May/June\n'
                          'ஆனி (Aani) - June/July\n'
                          'ஆடி (Aadi) - July/August\n'
                          'ஆவணி (Aavani) - August/September\n'
                          'புரட்டாசி (Purattasi) - September/October\n'
                          'ஐப்பசி (Aippasi) - October/November\n'
                          'கார்த்திகை (Karthikai) - November/December\n'
                          'மார்கழி (Margazhi) - December/January\n'
                          'தை (Thai) - January/February\n'
                          'மாசி (Maasi) - February/March\n'
                          'பங்குனி (Panguni) - March/April',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
