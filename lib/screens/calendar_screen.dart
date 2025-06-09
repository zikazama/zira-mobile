import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../models/calendar_event_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<CalendarEventModel>> _events = {};
  
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }
  
  Future<void> _loadEvents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;
    
    try {
      final snapshot = await _firebaseService.getCalendarEvents(authProvider.user!.id);
      final Map<DateTime, List<CalendarEventModel>> events = {};
      
      for (var doc in snapshot.docs) {
        final event = CalendarEventModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        
        final date = DateTime(
          event.date.year,
          event.date.month,
          event.date.day,
        );
        
        if (events[date] == null) {
          events[date] = [];
        }
        
        events[date]!.add(event);
      }
      
      setState(() {
        _events = events;
      });
    } catch (e) {
      // Handle error
    }
  }
  
  List<CalendarEventModel> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }
  
  Future<void> _addEvent() async {
    if (_selectedDay == null) return;
    
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    File? imageFile;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Momen'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            setState(() {
                              imageFile = File(image.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.photo),
                        label: const Text('Pilih Foto'),
                      ),
                      const SizedBox(width: 8),
                      if (imageFile != null)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  if (titleController.text.isEmpty) return;
                  
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  if (authProvider.user == null) return;
                  
                  String? imageUrl;
                  if (imageFile != null) {
                    imageUrl = await _firebaseService.uploadImage(
                      authProvider.user!.id,
                      'calendar/${DateTime.now().millisecondsSinceEpoch}.jpg',
                      imageFile,
                    );
                  }
                  
                  final event = CalendarEventModel(
                    title: titleController.text,
                    description: descriptionController.text,
                    date: _selectedDay!,
                    creatorId: authProvider.user!.id,
                    imageUrl: imageUrl,
                  );
                  
                  await _firebaseService.addCalendarEvent(
                    authProvider.user!.id,
                    event.toMap(),
                  );
                  
                  Navigator.pop(context);
                  _loadEvents();
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _viewEvent(CalendarEventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanggal: ${DateFormat('dd MMMM yyyy').format(event.date)}'),
            const SizedBox(height: 8),
            Text('Deskripsi: ${event.description}'),
            const SizedBox(height: 16),
            if (event.imageUrl != null)
              Image.network(
                event.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender'),
        backgroundColor: Colors.pinkAccent,
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
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: Colors.pinkAccent,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonTextStyle: TextStyle(color: Colors.pinkAccent),
              titleTextStyle: TextStyle(
                color: Colors.pinkAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Text('Pilih tanggal untuk melihat momen'),
                  )
                : _getEventsForDay(_selectedDay!).isEmpty
                    ? const Center(
                        child: Text('Tidak ada momen pada tanggal ini'),
                      )
                    : ListView.builder(
                        itemCount: _getEventsForDay(_selectedDay!).length,
                        itemBuilder: (context, index) {
                          final event = _getEventsForDay(_selectedDay!)[index];
                          return ListTile(
                            title: Text(event.title),
                            subtitle: Text(
                              event.description.length > 50
                                  ? '${event.description.substring(0, 50)}...'
                                  : event.description,
                            ),
                            leading: event.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      event.imageUrl!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const CircleAvatar(
                                    child: Icon(Icons.event),
                                  ),
                            onTap: () => _viewEvent(event),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _selectedDay != null
          ? FloatingActionButton(
              onPressed: _addEvent,
              backgroundColor: Colors.pinkAccent,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBar.item(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBar.item(
            icon: Icon(Icons.calendar_today),
            label: 'Kalender',
          ),
          BottomNavigationBar.item(
            icon: Icon(Icons.alarm),
            label: 'Alarm',
          ),
          BottomNavigationBar.item(
            icon: Icon(Icons.check_box),
            label: 'To-Do',
          ),
          BottomNavigationBar.item(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard');
              break;
            case 1:
              // Already on calendar
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/alarm');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/todo');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/budget');
              break;
          }
        },
      ),
    );
  }
}