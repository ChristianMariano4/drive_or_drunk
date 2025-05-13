import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/utils/time_utils.dart'
    show getLocalizedDateInNumberFormat;
import 'package:drive_or_drunk_app/widgets/custom_elevated_button.dart';
import 'package:drive_or_drunk_app/widgets/custom_text_form_field.dart';
import 'package:drive_or_drunk_app/widgets/theme_change_button.dart';
import 'package:flutter/material.dart';

class NewEventPage extends StatefulWidget {
  const NewEventPage({super.key});

  @override
  State<NewEventPage> createState() => _NewEventPageState();
}

//TODO:  Date input fixes: actions not centered, error message always shown.

class _NewEventPageState extends State<NewEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;
    final pickedDateFormatted = getLocalizedDateInNumberFormat(pickedDate);
    if (pickedDateFormatted != _dateController.text) {
      setState(() {
        _dateController.text = getLocalizedDateInNumberFormat(pickedDate);
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final String title = _titleController.text;
      final String description = _descriptionController.text;
      final String date = _dateController.text;

      // Clear the form
      _titleController.clear();
      _descriptionController.clear();
      _dateController.clear();

      // Optionally navigate back or show a success message
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Event'),
        actions: const [ThemeChangeButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: AppSizes.spaceBtwInputFields,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              CustomTextFormField(
                controller: _descriptionController,
                labelText: 'Description',
              ),
              Stack(
                fit: StackFit.passthrough,
                children: [
                  TextFormField(
                    controller: _dateController,
                    onChanged: (value) {
                      setState(() {
                        _dateController.text = value;
                      });
                      debugPrint(_dateController.text);
                    },
                    decoration: const InputDecoration(
                        labelText: 'Event Date', hintText: 'dd/mm/yyyy'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a date';
                      }
                      final dateParts = value.split('/');
                      if (dateParts.length != 3) {
                        return 'Invalid date format';
                      }
                      final day = int.tryParse(dateParts[0]);
                      final month = int.tryParse(dateParts[1]);
                      final year = int.tryParse(dateParts[2]);
                      if (day == null || month == null || year == null) {
                        return 'Invalid date format';
                      }
                      final isValidDate = DateTime.tryParse(
                          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}');
                      if (isValidDate == null) {
                        return 'Invalid date';
                      }
                      return null;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_dateController.text != '')
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _dateController.clear();
                            });
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        color: Theme.of(context).primaryColor,
                        onPressed: _pickDate,
                      ),
                    ],
                  )
                ],
              ),
              CustomElevatedButton(
                onPressed: _saveEvent,
                labelText: 'Save Event',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
