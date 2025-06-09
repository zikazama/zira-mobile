import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  DateTime? _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.relationshipDate != null) {
      setState(() {
        _selectedDate = authProvider.user!.relationshipDate;
      });
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateRelationshipDate(picked);
    }
  }
  
  Future<void> _linkPartner() async {
    final partnerEmailController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hubungkan dengan Pasangan'),
        content: TextField(
          controller: partnerEmailController,
          decoration: const InputDecoration(
            labelText: 'Email Pasangan',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (partnerEmailController.text.isEmpty) return;
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.linkWithPartner(
                partnerEmailController.text.trim(),
              );
              
              Navigator.pop(context);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Undangan telah dikirim ke pasangan'),
                  ),
                );
              }
            },
            child: const Text('Kirim Undangan'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Email'),
                    subtitle: Text(authProvider.user?.email ?? ''),
                    leading: const Icon(Icons.email),
                  ),
                  ListTile(
                    title: const Text('Nama'),
                    subtitle: Text(authProvider.user?.name ?? ''),
                    leading: const Icon(Icons.person),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      // Edit name functionality
                    },
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
                    'Hubungan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Tanggal Jadian'),
                    subtitle: _selectedDate != null
                        ? Text(DateFormat('dd MMMM yyyy').format(_selectedDate!))
                        : const Text('Belum diatur'),
                    leading: const Icon(Icons.favorite),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectDate(context),
                  ),
                  ListTile(
                    title: const Text('Pasangan'),
                    subtitle: authProvider.user?.partnerEmail != null
                        ? Text(authProvider.user!.partnerEmail!)
                        : const Text('Belum terhubung'),
                    leading: const Icon(Icons.people),
                    trailing: const Icon(Icons.link),
                    onTap: _linkPartner,
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
                    'Tampilan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Background Beranda'),
                    subtitle: const Text('Ubah gambar latar beranda'),
                    leading: const Icon(Icons.image),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Background selection functionality
                    },
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
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Notifikasi Ciuman'),
                    subtitle: const Text('Terima notifikasi saat pasangan mengirim ciuman'),
                    value: true,
                    onChanged: (value) {
                      // Toggle notification settings
                    },
                    secondary: const Icon(Icons.notifications),
                  ),
                  SwitchListTile(
                    title: const Text('Notifikasi Sentuhan'),
                    subtitle: const Text('Terima notifikasi saat pasangan mengirim sentuhan'),
                    value: true,
                    onChanged: (value) {
                      // Toggle notification settings
                    },
                    secondary: const Icon(Icons.notifications),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}