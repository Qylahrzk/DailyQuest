// lib/todo/todo_screen.dart

import 'package:flutter/material.dart';
import '../data/todo_dao.dart';
import '../models/todo.dart';
import 'todo_list_screen.dart';
import 'todo_entry_dialog.dart';

/// ✅ TodoScreen
///
/// Dashboard-style screen showing:
/// - Priority summary cards (high, medium, low)
/// - A carousel of ongoing tasks
/// - A FAB to add new todos
/// - A button to navigate to the full task list
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  /// Lists of todos grouped by filters
  List<Todo> _highPriority = [];
  List<Todo> _mediumPriority = [];
  List<Todo> _lowPriority = [];
  List<Todo> _ongoing = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  /// 🔹 Loads todos from the database and groups them
  Future<void> _loadTodos() async {
    final all = await TodoDao.getAll();
    setState(() {
      _highPriority = all.where((e) => e.priority == 'high').toList();
      _mediumPriority = all.where((e) => e.priority == 'medium').toList();
      _lowPriority = all.where((e) => e.priority == 'low').toList();
      _ongoing = all.where((e) => e.status == 'ongoing').toList();
    });
  }

  /// 🔹 Opens the full todo list screen
  void _openTodoList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TodoListScreen()),
    ).then((_) => _loadTodos());
  }

  /// 🔹 Opens the dialog for creating a new todo
  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => TodoEntryDialog(
        onSave: (todo) async {
          await TodoDao.insert(todo);
          _loadTodos();
        },
      ),
    );
  }

  /// 🔹 Returns a color for the given priority
  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// 🔹 Builds a summary card for a priority level
  Widget _buildPriorityCard(
    String title,
    List<Todo> todos,
    Color color,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${todos.length} tasks',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffD38C4F),
        title: const Text(
          "TO-DO LIST",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            ),
          ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            /// 🔹 Priority summary cards
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildPriorityCard(
                      "First Priority", _highPriority, Colors.green),
                  _buildPriorityCard(
                      "Second Priority", _mediumPriority, Colors.blue),
                  _buildPriorityCard(
                      "Third Priority", _lowPriority, Colors.purple),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 🔹 Ongoing task header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ongoing Tasks",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _openTodoList,
                    child: const Text("View All"),
                  )
                ],
              ),
            ),

            /// 🔹 Ongoing tasks list
            _ongoing.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No ongoing tasks."),
                  )
                : SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _ongoing.length,
                      itemBuilder: (_, index) {
                        final todo = _ongoing[index];
                        return Container(
                          width: 220,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: _priorityColor(todo.priority),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            title: Text(
                              todo.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              todo.description,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
          ],
        ),
      ),

      /// 🔹 FAB to create a new todo
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
