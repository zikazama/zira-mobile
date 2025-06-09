import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../widgets/heart_animation.dart';
import '../widgets/couple_avatar.dart';
import '../widgets/gradient_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  final PageController _pageController = PageController();
  bool _showKiss = false;
  
  // Canvas drawing
  List<Offset?> _points = [];
  
  // Animation controller for heart beat
  late AnimationController _heartAnimationController;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heartAnimationController.dispose();
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
    
    _heartAnimationController.reset();
    _heartAnimationController.forward();
    
    await _firebaseService.sendNotificationToPartner(
      partnerId,
      'Ciuman',
      'Pasangan mengirim ciuman untukmu!',
    );
    
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [100, 50, 100, 50, 100]);
    }
    
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
    
    // Default background images if user doesn't have custom ones
    final List<String> backgroundImages = user?.backgroundImages ?? [
      'https://images.unsplash.com/photo-1518199266791-5375a83190b7',
      'https://images.unsplash.com/photo-1545389336-cf090694435e',
      'https://images.unsplash.com/photo-1478476868527-002ae3f3e159',
    ];
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink[100]!,
              Colors.pink[50]!,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background image slider
            PageView.builder(
              controller: _pageController,
              itemCount: backgroundImages.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(backgroundImages[index]),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.pink.withOpacity(0.3),
                        BlendMode.overlay,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Content
            SafeArea(
              child: Column(
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Zira',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[700],
                            shadows: [
                              Shadow(
                                blurRadius: 5.0,
                                color: Colors.white.withOpacity(0.5),
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.settings, color: Colors.pink[700]),
                              onPressed: () {
                                Navigator.pushNamed(context, '/settings');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Couple avatars
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CoupleAvatar(
                          name: user?.name ?? 'You',
                          imageUrl: null, // Replace with actual image URL
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red[400],
                            size: 32,
                          ),
                        ),
                        CoupleAvatar(
                          name: 'Partner',
                          imageUrl: null, // Replace with actual partner image URL
                        ),
                      ],
                    ),
                  ),
                  
                  // Relationship duration card
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Lama Jadian',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _calculateRelationshipDuration(user?.relationshipDate),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink[400],
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
                  GradientButton(
                    onPressed: () => _sendKiss(user?.partnerId),
                    gradient: LinearGradient(
                      colors: [Colors.pink[300]!, Colors.pink[500]!],
                    ),
                    icon: Icons.favorite,
                    label: 'Kirim Ciuman',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Touch canvas
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Sentuh Pasangan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink[700],
                              shadows: [
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.white.withOpacity(0.5),
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.pink[200]!),
                              ),
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                                    _points.add(renderBox.globalToLocal(details.globalPosition));
                                    if (Vibration.hasVibrator() != null) {
                                      Vibration.vibrate(duration: 10);
                                    }
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
                                  backgroundColor: Colors.pink[100],
                                  foregroundColor: Colors.pink[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text('Hapus'),
                              ),
                              ElevatedButton(
                                onPressed: () => _sendTouch(user?.partnerId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink[400],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text('Kirim Sentuhan'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom navigation
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(Icons.calendar_today, 'Kalender', () {
                          Navigator.pushNamed(context, '/calendar');
                        }),
                        _buildNavItem(Icons.check_box, 'Todo', () {
                          Navigator.pushNamed(context, '/todo');
                        }),
                        _buildNavItem(Icons.access_alarm, 'Alarm', () {
                          Navigator.pushNamed(context, '/alarm');
                        }),
                        _buildNavItem(Icons.account_balance_wallet, 'Budget', () {
                          Navigator.pushNamed(context, '/budget');
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Kiss animation overlay
            if (_showKiss)
              HeartAnimation(controller: _heartAnimationController),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.pink[400]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.pink[700],
              ),
            ),
          ],
        ),
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
      ..color = Colors.pink[300]!
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
      
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        // Draw a single point as a small circle
        canvas.drawCircle(points[i]!, 2.5, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(TouchPainter oldDelegate) => oldDelegate.points != points;
}