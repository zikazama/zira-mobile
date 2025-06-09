import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../models/menstruation_model.dart';

class MenstruationScreen extends StatefulWidget {
  const MenstruationScreen({Key? key}) : super(key: key);

  @override
  _MenstruationScreenState createState() => _MenstruationScreenState();
}

class _MenstruationScreenState extends State<MenstruationScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  MenstruationModel? _lastPeriod;
  List<DateTime> _periodDays = [];
  List<DateTime> _predictedPeriodDays = [];
  bool _isLoading = false;
  
  final _cycleLengthController = TextEditingController(text: '28');
  
  @override
  void initState() {
    super.initState();
    _loadMenstruationData();
  }
  
  @override
  void dispose() {
    _cycleLengthController.dispose();
    super.dispose();
  }
  
  Future<void> _loadMenstruationData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final snapshot = await _firebaseService.getMenstruationData(authProvider.user!.id);
      
      if (snapshot.docs.isNotEmpty) {
        final lastPeriod = MenstruationModel.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>,
          snapshot.docs.first.id,
        );
        
        setState(() {
          _lastPeriod = lastPeriod;
          _cycleLengthController.text = lastPeriod.cycleLength.toString();
          _calculatePeriodDays(lastPeriod);
        });
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _calculatePeriodDays(MenstruationModel period) {
    final periodDays = <DateTime>[];
    final predictedDays = <DateTime>[];
    
    // Calculate actual period days
    if (period.endDate != null) {
      final difference = period.endDate!.difference(period.startDate).inDays;
      
      for (int i = 0; i <= difference; i++) {
        final day = DateTime(
          period.startDate.year,
          period.startDate.month,
          period.startDate.day + i,
        );
        periodDays.add(day);
      }
    } else {
      // Assume 5 days if no end date
      for (int i = 0; i < 5; i++) {
        final day = DateTime(
          period.startDate.year,
          period.startDate.month,
          period.startDate.day + i,
        );
        periodDays.add(day);
      }
    }
    
    // Calculate predicted period days
    final nextPeriodStart = period.predictNextPeriod();
    
    for (int i = 0; i < 5; i++) {
      final day = DateTime(
        nextPeriodStart.year,
        nextPeriodStart.month,
        nextPeriodStart.day + i,
      );
      predictedDays.add(day);
    }
    
    setState(() {
      _periodDays = periodDays;
      _predictedPeriodDays = predictedDays;
    });
  }
  
  Future<void> _addPeriodStart() async {
    if (_selectedDay == null) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;
    
    final cycleLength = int.tryParse(_cycleLengthController.text) ?? 28;
    
    final period = MenstruationModel(
      startDate: _selectedDay!,
      cycleLength: cycleLength,
    );
    
    await _firebaseService.saveMenstruationData(
      authProvider.user!.id,
      period.toMap(),
    );
    
    _loadMenstruationData();
  }
  
  Future<void> _addPeriodEnd() async {
    if (_selectedDay == null || _lastPeriod == null) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;
    
    if (_selectedDay!.isBefore(_lastPeriod!.startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal akhir harus setelah tanggal mulai'),
        ),
      );
      return;
    }
    
    final updatedPeriod = MenstruationModel(
      id: _lastPeriod!.id,
      startDate: _lastPeriod!.startDate,
      endDate: _selectedDay,
      cycleLength: _lastPeriod!.cycleLength,
    );
    
    await _firebaseService.updateMenstruationData(
      authProvider.user!.id,
      _lastPeriod!.id!,
      updatedPeriod.toMap(),
    );
    
    _loadMenstruationData();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelacak Menstruasi'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Periode Terakhir',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _lastPeriod != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mulai: ${DateFormat('dd MMMM yyyy').format(_lastPeriod!.startDate)}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    if (_lastPeriod!.endDate != null)
                                      Text(
                                        'Selesai: ${DateFormat('dd MMMM yyyy').format(_lastPeriod!.endDate!)}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Prediksi periode berikutnya: ${DateFormat('dd MMMM yyyy').format(_lastPeriod!.predictNextPeriod())}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pinkAccent,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Belum ada data periode',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Panjang Siklus',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _cycleLengthController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Hari',
                              border: OutlineInputBorder(),
                              suffixText: 'hari',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
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
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        for (final periodDay in _periodDays) {
                          if (isSameDay(day, periodDay)) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.pinkAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                day.day.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }
                        }
                        
                        for (final predictedDay in _predictedPeriodDays) {
                          if (isSameDay(day, predictedDay)) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.pinkAccent),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                day.day.toString(),
                                style: const TextStyle(color: Colors.pinkAccent),
                              ),
                            );
                          }
                        }
                        
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedDay != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _addPeriodStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                          ),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Mulai Periode'),
                        ),
                        if (_lastPeriod != null && _lastPeriod!.endDate == null)
                          ElevatedButton.icon(
                            onPressed: _addPeriodEnd,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                            ),
                            icon: const Icon(Icons.stop),
                            label: const Text('Akhiri Periode'),
                          ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}