// lib/todo/todo_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/todo_dao.dart';
import '../models/todo.dart';
import 'todo_entry_dialog.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final all = await TodoDao.getAll();
    setState(() {
      _todos = all;
    });
  }

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

  void _viewTodo(Todo todo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(todo.title),
        content: Text(todo.description),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

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

  void _deleteTodo(int id) async {
    await TodoDao.delete(id);
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.grey.shade300,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Text(
                        DateFormat.yMMMMd().format(DateTime.parse(entry.key)),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...entry.value.map((todo) => ListTile(
                          title: Text(todo.title),
                          subtitle: Text(todo.time),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => _showOptions(todo),
                          ),
                        )),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
