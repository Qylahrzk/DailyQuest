// lib/todo/todo_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/todo_dao.dart';
import '../models/todo.dart';
import 'todo_entry_dialog.dart';

/// ✅ TodoListScreen
///
/// Shows a list of all todos, grouped by date.
/// Allows the user to:
/// - View details
/// - Edit a todo
/// - Delete a todo
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  /// The list of all loaded todos
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  /// 🔹 Loads all todos from the database
  Future<void> _loadTodos() async {
    final all = await TodoDao.getAll();
    setState(() {
      _todos = all;
    });
  }

  /// 🔹 Shows a bottom sheet with actions for a todo
  void _showOptions(Todo todo) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text("View"),
            onTap: () {
              Navigator.pop(context);
              _viewTodo(todo);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit"),
            onTap: () {
              Navigator.pop(context);
              _editTodo(todo);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Delete"),
            onTap: () {
              Navigator.pop(context);
              _deleteTodo(todo.id!);
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 Displays a simple dialog showing todo details
  void _viewTodo(Todo todo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(todo.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Description: ${todo.description}"),
            const SizedBox(height: 8),
            Text("Priority: ${todo.priority}"),
            Text("Status: ${todo.status}"),
            Text("Date: ${todo.date}"),
            Text("Time: ${todo.time}"),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  /// 🔹 Opens the edit dialog for the given todo
  void _editTodo(Todo todo) {
    showDialog(
      context: context,
      builder: (_) => TodoEntryDialog(
        existing: todo,
        onSave: (updated) async {
          await TodoDao.update(updated);
          _loadTodos();
        },
      ),
    );
  }

  /// 🔹 Deletes the todo from the database
  void _deleteTodo(int id) async {
    await TodoDao.delete(id);
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    /// Group todos by date (e.g. 2025-07-04)
    final grouped = <String, List<Todo>>{};

    for (var todo in _todos) {
      grouped[todo.date] = [...(grouped[todo.date] ?? []), todo];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Tasks"),
      ),
      body: grouped.isEmpty
          ? const Center(child: Text("No tasks found."))
          : ListView(
              children: grouped.entries.map((entry) {
                final date = DateTime.parse(entry.key);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Group header
                    Container(
                      color: Colors.grey.shade300,
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Text(
                        DateFormat.yMMMMd().format(date),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    /// List all todos under this date
                    ...entry.value.map(
                      (todo) => ListTile(
                        title: Text(todo.title),
                        subtitle: Text(
                          "Time: ${todo.time} | Priority: ${todo.priority}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showOptions(todo),
                        ),
                      ),
                    )
                  ],
                );
              }).toList(),
            ),
    );
  }
}
