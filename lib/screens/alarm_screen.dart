import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../models/alarm_model.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({Key? key}) : super(key: key);

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<AlarmModel> _alarms = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }
  
  Future<void> _loadAlarms() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final snapshot = await _firebaseService
          .getUserData(authProvider.user!.id)
          .collection('alarms')
          .get();
      
      final alarms = snapshot.docs.map((doc) {
        return AlarmModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
      
      setState(() {
        _alarms = alarms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _addAlarm() async {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    List<bool> selectedDays = List.filled(7, false);
    bool isForMe = true;
    bool isForPartner = false;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Alarm'),
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
                  Row(
                    children: [
                      const Text('Waktu: '),
                      TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          
                          if (time != null) {
                            setState(() {
                              selectedTime = time;
                            });
                          }
                        },
                        child: Text(
                          selectedTime.format(context),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Hari:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildDayChip(0, 'Sen', selectedDays, setState),
                      _buildDayChip(1, 'Sel', selectedDays, setState),
                      _buildDayChip(2, 'Rab', selectedDays, setState),
                      _buildDayChip(3, 'Kam', selectedDays, setState),
                      _buildDayChip(4, 'Jum', selectedDays, setState),
                      _buildDayChip(5, 'Sab', selectedDays, setState),
                      _buildDayChip(6, 'Min', selectedDays, setState),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Untuk:'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Saya'),
                          value: isForMe,
                          onChanged: (value) {
                            setState(() {
                              isForMe = value ?? false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Pasangan'),
                          value: isForPartner,
                          onChanged: (value) {
                            setState(() {
                              isForPartner = value ?? false;
                            });
                          },
                        ),
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
                  if (!selectedDays.contains(true)) return;
                  if (!isForMe && !isForPartner) return;
                  
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  if (authProvider.user == null) return;
                  
                  final alarm = AlarmModel(
                    title: titleController.text,
                    time: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                    days: selectedDays,
                    isActive: true,
                    isForMe: isForMe,
                    isForPartner: isForPartner,
                  );
                  
                  await _firebaseService.addAlarm(
                    authProvider.user!.id,
                    alarm.toMap(),
                  );
                  
                  Navigator.pop(context);
                  _loadAlarms();
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildDayChip(int index, String label, List<bool> selectedDays, StateSetter setState) {
    return FilterChip(
      label: Text(label),
      selected: selectedDays[index],
      onSelected: (selected) {
        setState(() {
          selectedDays[index] = selected;
        });
      },
      selectedColor: Colors.pinkAccent.withOpacity(0.3),
      checkmarkColor: Colors.pinkAccent,
    );
  }
  
  Future<void> _toggleAlarmStatus(AlarmModel alarm) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;
    
    final updatedAlarm = alarm.copyWith(
      isActive: !alarm.isActive,
    );
    
    await _firebaseService.updateAlarm(
      authProvider.user!.id,
      alarm.id!,
      updatedAlarm.toMap(),
    );
    
    _loadAlarms();
  }
  
  Future<void> _deleteAlarm(AlarmModel alarm) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;
    
    await _firebaseService.deleteAlarm(
      authProvider.user!.id,
      alarm.id!,
    );
    
    _loadAlarms();
  }
  
  String _getDaysText(List<bool> days) {
    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final selectedDays = <String>[];
    
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        selectedDays.add(dayNames[i]);
      }
    }
    
    if (selectedDays.isEmpty) {
      return 'Tidak ada hari dipilih';
    }
    
    if (selectedDays.length == 7) {
      return 'Setiap hari';
    }
    
    if (selectedDays.length == 5 &&
        days[0] && days[1] && days[2] && days[3] && days[4]) {
      return 'Setiap hari kerja';
    }
    
    if (selectedDays.length == 2 && days[5] && days[6]) {
      return 'Akhir pekan';
    }
    
    return selectedDays.join(', ');
  }
  
  String _getForText(bool isForMe, bool isForPartner) {
    if (isForMe && isForPartner) {
      return 'Untuk keduanya';
    } else if (isForMe) {
      return 'Untuk saya';
    } else if (isForPartner) {
      return 'Untuk pasangan';
    } else {
      return '';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _alarms.isEmpty
              ? const Center(
                  child: Text('Belum ada alarm'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _alarms.length,
                  itemBuilder: (context, index) {
                    final alarm = _alarms[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ListTile(
                        title: Text(
                          alarm.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alarm.time),
                            Text(_getDaysText(alarm.days)),
                            Text(
                              _getForText(alarm.isForMe, alarm.isForPartner),
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        leading: Icon(
                          Icons.alarm,
                          color: alarm.isActive ? Colors.pinkAccent : Colors.grey,
                          size: 36,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: alarm.isActive,
                              activeColor: Colors.pinkAccent,
                              onChanged: (_) => _toggleAlarmStatus(alarm),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteAlarm(alarm),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
              Navigator.pushReplacementNamed(context, '/calendar');
              break;
            case 2:
              // Already on alarm
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