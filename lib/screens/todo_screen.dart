import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../models/todo_model.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<TodoModel> _todos = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadTodos();
  }
  
  Future<void> _loadTodos() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final snapshot = await _firebaseService
          .getUserData(authProvider.user!.id)
          .collection('todos')
          .orderBy('createdAt', descending: true)
          .get();
      
      final todos = snapshot.docs.map((doc) {
        return TodoModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
      
      setState(() {
        _todos = todos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _addTodo() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tugas'),
        content: Column(
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
                labelText: 'Deskripsi (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
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
              
              final todo = TodoModel(
                title: titleController.text,
                description: descriptionController.text.isNotEmpty
                    ? descriptionController.text
                    : null,
                isCompleted: false,
                createdAt: DateTime.now(),
                creatorId: authProvider.user!.id,
              );
              
              await _firebaseService.addTodoItem(
                authProvider.user!.id,
                todo.toMap(),
              );
              
              Navigator.pop(context);
              _loadTodos();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _toggleTodoStatus(TodoModel todo) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;
    
    final updatedTodo = todo.copyWith(
      isCompleted: !todo.isCompleted,
    );
    
    await _firebaseService.updateTodoItem(
      authProvider.user!.id,
      todo.id!,
      updatedTodo.toMap(),
    );
    
    _loadTodos();
  }
  
  Future<void> _deleteTodo(TodoModel todo) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;
    
    await _firebaseService.deleteTodoItem(
      authProvider.user!.id,
      todo.id!,
    );
    
    _loadTodos();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _todos.isEmpty
              ? const Center(
                  child: Text('Belum ada tugas'),
                )
              : ListView.builder(
                  itemCount: _todos.length,
                  itemBuilder: (context, index) {
                    final todo = _todos[index];
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => _deleteTodo(todo),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Hapus',
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: todo.description != null
                            ? Text(
                                todo.description!,
                                style: TextStyle(
                                  decoration: todo.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              )
                            : null,
                        leading: Checkbox(
                          value: todo.isCompleted,
                          activeColor: Colors.pinkAccent,
                          onChanged: (_) => _toggleTodoStatus(todo),
                        ),
                        onTap: () => _toggleTodoStatus(todo),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
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
              Navigator.pushReplacementNamed(context, '/alarm');
              break;
            case 3:
              // Already on todo
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