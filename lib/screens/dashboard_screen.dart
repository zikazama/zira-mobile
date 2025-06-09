import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final PageController _pageController = PageController();
  bool _showKiss = false;
  
  // Canvas drawing
  List<Offset?> _points = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _calculateRelationshipDuration(DateTime? startDate) {
    if (startDate == null) {
      return "Belum ada tanggal jadian";
    }

    final now = DateTime.now();
    final difference = now.difference(startDate);
    
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;
    final days = difference.inDays % 30;
    
    String duration = '';
    
    if (years > 0) {
      duration += '$years tahun ';
    }
    
    if (months > 0) {
      duration += '$months bulan ';
    }
    
    duration += '$days hari';
    
    return duration;
  }

  void _sendKiss(String? partnerId) async {
    if (partnerId == null) return;
    
    setState(() {
      _showKiss = true;
    });
    
    await _firebaseService.sendNotificationToPartner(
      partnerId,
      'Ciuman',
      'Pasangan mengirim ciuman untukmu!',
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showKiss = false;
        });
      }
    });
  }

  void _sendTouch(String? partnerId) async {
    if (partnerId == null) return;
    
    await _firebaseService.sendNotificationToPartner(
      partnerId,
      'Sentuhan',
      'Pasangan menyentuhmu!',
    );
    
    // Clear canvas after sending
    setState(() {
      _points = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.user;
    
    // Placeholder background images
    final List<String> backgroundImages = [
      'https://images.unsplash.com/photo-1518199266791-5375a83190b7',
      'https://images.unsplash.com/photo-1545389336-cf090694435e',
      'https://images.unsplash.com/photo-1478476868527-002ae3f3e159',
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zira'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image slider
          PageView.builder(
            controller: _pageController,
            itemCount: backgroundImages.length,
            itemBuilder: (context, index) {
              return Image.network(
                backgroundImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Relationship duration card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Lama Jadian',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _calculateRelationshipDuration(user?.relationshipDate),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent,
                            ),
                          ),
                          if (user?.relationshipDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Tanggal Jadian: ${DateFormat('dd MMMM yyyy').format(user!.relationshipDate!)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Kiss button
                ElevatedButton.icon(
                  onPressed: () => _sendKiss(user?.partnerId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.favorite),
                  label: const Text('Kirim Ciuman'),
                ),
                
                const SizedBox(height: 24),
                
                // Touch canvas
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Sentuh Pasangan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white),
                            ),
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                                  _points.add(renderBox.globalToLocal(details.globalPosition));
                                  Vibration.vibrate(duration: 10);
                                });
                              },
                              onPanEnd: (details) {
                                _points.add(null);
                              },
                              child: CustomPaint(
                                painter: TouchPainter(points: _points),
                                size: Size.infinite,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _points = [];
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.pinkAccent,
                              ),
                              child: const Text('Hapus'),
                            ),
                            ElevatedButton(
                              onPressed: () => _sendTouch(user?.partnerId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Kirim Sentuhan'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Kiss animation overlay
          if (_showKiss)
            Center(
              child: AnimatedOpacity(
                opacity: _showKiss ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 150,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
              // Already on dashboard
              break;
            case 1:
              Navigator.pushNamed(context, '/calendar');
              break;
            case 2:
              Navigator.pushNamed(context, '/alarm');
              break;
            case 3:
              Navigator.pushNamed(context, '/todo');
              break;
            case 4:
              Navigator.pushNamed(context, '/budget');
              break;
          }
        },
      ),
    );
  }
}

class TouchPainter extends CustomPainter {
  final List<Offset?> points;
  
  TouchPainter({required this.points});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.pinkAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [points[i]!], paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(TouchPainter oldDelegate) => oldDelegate.points != points;
}