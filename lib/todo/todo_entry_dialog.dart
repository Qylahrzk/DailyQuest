// lib/todo/todo_entry_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

/// ✅ TodoEntryDialog
///
/// A modal dialog that allows the user to:
/// - Create a new Todo
/// - Edit an existing Todo
///
/// Returns the created/updated [Todo] object via the [onSave] callback.
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
  /// Controllers for text fields
  final titleController = TextEditingController();
  final descController = TextEditingController();

  /// Dropdown values
  String priority = 'high';
  String status = 'ongoing';

  /// Date and time pickers
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();

  @override
  void initState() {
    super.initState();

    // If editing an existing todo, fill in all values
    if (widget.existing != null) {
      titleController.text = widget.existing!.title;
      descController.text = widget.existing!.description;
      priority = widget.existing!.priority;
      status = widget.existing!.status;
      date = DateTime.parse(widget.existing!.date);

      // Convert stored time string back to TimeOfDay
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
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Title input
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            /// Description input
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            /// Priority dropdown
            DropdownButtonFormField<String>(
              value: priority,
              decoration: const InputDecoration(
                labelText: "Priority",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'high', child: Text("High Priority")),
                DropdownMenuItem(value: 'medium', child: Text("Medium Priority")),
                DropdownMenuItem(value: 'low', child: Text("Low Priority")),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => priority = val);
                }
              },
            ),
            const SizedBox(height: 12),

            /// Status dropdown
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'ongoing', child: Text("Ongoing")),
                DropdownMenuItem(value: 'completed', child: Text("Completed")),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => status = val);
                }
              },
            ),
            const SizedBox(height: 12),

            /// Date picker button
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(DateFormat.yMMMEd().format(date)),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => date = picked);
                }
              },
            ),
            const SizedBox(height: 8),

            /// Time picker button
            ElevatedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(time.format(context)),
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: time,
                );
                if (picked != null) {
                  setState(() => time = picked);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        /// Cancel button
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        /// Save button
        ElevatedButton(
          onPressed: () {
            // Create a Todo instance
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

            // Return the new/updated todo via callback
            widget.onSave(todo);

            // Close the dialog
            Navigator.pop(context);
          },
          child: const Text("Save"),
        )
      ],
    );
  }
}
