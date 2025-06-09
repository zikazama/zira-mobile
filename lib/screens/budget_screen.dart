import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../models/budget_model.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }
  
  Future<void> _loadBudgets() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final snapshot = await _firebaseService.firestore
          .collection('users')
          .doc(authProvider.user!.id)
          .collection('budget')
          .orderBy('createdAt', descending: true)
          .get();
      
      final budgets = snapshot.docs.map((doc) {
        return BudgetModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
      
      setState(() {
        _budgets = budgets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _addBudget() async {
    final titleController = TextEditingController();
    final targetAmountController = TextEditingController();
    final currentAmountController = TextEditingController();
    DateTime? targetDate;
    String savingFrequency = 'monthly';
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Target Tabungan'),
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
                    controller: targetAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Jumlah',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: currentAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Saat Ini',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Tanggal Target: '),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          
                          if (date != null) {
                            setState(() {
                              targetDate = date;
                            });
                          }
                        },
                        child: Text(
                          targetDate != null
                              ? DateFormat('dd/MM/yyyy').format(targetDate!)
                              : 'Pilih Tanggal',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: savingFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Frekuensi Menabung',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'daily',
                        child: Text('Harian'),
                      ),
                      DropdownMenuItem(
                        value: 'weekly',
                        child: Text('Mingguan'),
                      ),
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text('Bulanan'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          savingFrequency = value;
                        });
                      }
                    },
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
                  if (titleController.text.isEmpty ||
                      targetAmountController.text.isEmpty ||
                      currentAmountController.text.isEmpty) {
                    return;
                  }
                  
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  if (authProvider.user == null) return;
                  
                  final budget = BudgetModel(
                    title: titleController.text,
                    targetAmount: double.parse(targetAmountController.text),
                    currentAmount: double.parse(currentAmountController.text),
                    createdAt: DateTime.now(),
                    targetDate: targetDate,
                    savingFrequency: savingFrequency,
                  );
                  
                  await _firebaseService.saveBudgetGoal(
                    authProvider.user!.id,
                    budget.toMap(),
                  );
                  
                  Navigator.pop(context);
                  _loadBudgets();
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Future<void> _updateBudgetAmount(BudgetModel budget) async {
    final currentAmountController = TextEditingController(
      text: budget.currentAmount.toString(),
    );
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perbarui Jumlah Tabungan'),
        content: TextField(
          controller: currentAmountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Jumlah Saat Ini',
            border: OutlineInputBorder(),
            prefixText: 'Rp ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (currentAmountController.text.isEmpty) return;
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (authProvider.user == null) return;
              
              final updatedBudget = BudgetModel(
                id: budget.id,
                title: budget.title,
                targetAmount: budget.targetAmount,
                currentAmount: double.parse(currentAmountController.text),
                createdAt: budget.createdAt,
                targetDate: budget.targetDate,
                savingFrequency: budget.savingFrequency,
              );
              
              await _firebaseService.updateBudgetGoal(
                authProvider.user!.id,
                budget.id!,
                updatedBudget.toMap(),
              );
              
              Navigator.pop(context);
              _loadBudgets();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
  
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
  
  String _getSavingFrequencyText(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Harian';
      case 'weekly':
        return 'Mingguan';
      case 'monthly':
        return 'Bulanan';
      default:
        return 'Bulanan';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perencanaan Anggaran'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _budgets.isEmpty
              ? const Center(
                  child: Text('Belum ada target tabungan'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _budgets.length,
                  itemBuilder: (context, index) {
                    final budget = _budgets[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    budget.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _updateBudgetAmount(budget),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: budget.currentAmount / budget.targetAmount,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.pinkAccent,
                              ),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatCurrency(budget.currentAmount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(budget.targetAmount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Progress: ${budget.progressPercentage.toStringAsFixed(1)}%',
                            ),
                            if (budget.targetDate != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Target: ${DateFormat('dd MMMM yyyy').format(budget.targetDate!)}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sisa: ${budget.calculateDaysToTarget()} hari',
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Frekuensi menabung: ${_getSavingFrequencyText(budget.savingFrequency)}',
                            ),
                            const SizedBox(height: 8),
                            if (budget.targetDate != null)
                              Text(
                                'Perlu menabung: ${_formatCurrency(budget.calculateRequiredSavingRate())} per ${budget.savingFrequency == 'daily' ? 'hari' : budget.savingFrequency == 'weekly' ? 'minggu' : 'bulan'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBudget,
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Alarm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'To-Do',
          ),
          BottomNavigationBarItem(
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
              Navigator.pushReplacementNamed(context, '/alarm');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/todo');
              break;
            case 4:
              // Already on budget
              break;
          }
        },
      ),
    );
  }
}