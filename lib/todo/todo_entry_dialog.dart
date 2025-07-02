// lib/todo/todo_entry_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TodoEntryDialog extends StatefulWidget {
  final Todo? existing;
  final Function(Todo) onSave;

  const TodoEntryDialog({
    super.key,
    this.existing,
    required this.onSave,
  });

  @override
  State<TodoEntryDialog> createState() => _TodoEntryDialogState();
}

class _TodoEntryDialogState extends State<TodoEntryDialog> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String priority = 'high';
  String status = 'ongoing';
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      titleController.text = widget.existing!.title;
      descController.text = widget.existing!.description;
      priority = widget.existing!.priority;
      status = widget.existing!.status;
      date = DateTime.parse(widget.existing!.date);
      time = TimeOfDay(
        hour: int.parse(widget.existing!.time.split(":")[0]),
        minute: int.parse(widget.existing!.time.split(":")[1]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? "Add Todo" : "Edit Todo"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            DropdownButton<String>(
              value: priority,
              items: const [
                DropdownMenuItem(value: 'high', child: Text("High Priority")),
                DropdownMenuItem(value: 'medium', child: Text("Medium Priority")),
                DropdownMenuItem(value: 'low', child: Text("Low Priority")),
              ],
              onChanged: (val) => setState(() => priority = val!),
            ),
            DropdownButton<String>(
              value: status,
              items: const [
                DropdownMenuItem(value: 'ongoing', child: Text("Ongoing")),
                DropdownMenuItem(value: 'completed', child: Text("Completed")),
              ],
              onChanged: (val) => setState(() => status = val!),
            ),
            ElevatedButton(
              child: Text(DateFormat.yMMMEd().format(date)),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => date = picked);
              },
            ),
            ElevatedButton(
              child: Text(time.format(context)),
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: time,
                );
                if (picked != null) setState(() => time = picked);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final todo = Todo(
              id: widget.existing?.id,
              title: titleController.text.trim(),
              description: descController.text.trim(),
              priority: priority,
              status: status,
              date: DateFormat('yyyy-MM-dd').format(date),
              time: "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
              createdAt: DateTime.now().toIso8601String(),
            );
            widget.onSave(todo);
            Navigator.pop(context);
          },
          child: const Text("Save"),
        )
      ],
    );
  }
}
