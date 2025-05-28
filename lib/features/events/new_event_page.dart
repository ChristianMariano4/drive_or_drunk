import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/services/firestore_service.dart'
    show FirestoreService;
import 'package:drive_or_drunk_app/utils/image_utils.dart'
    show base64StringFromImage;
import 'package:drive_or_drunk_app/utils/time_utils.dart'
    show getLocalizedDateInNumberFormat;
import 'package:drive_or_drunk_app/widgets/custom_elevated_button.dart';
import 'package:drive_or_drunk_app/widgets/date_input_field.dart';
import 'package:drive_or_drunk_app/widgets/image_input_field.dart';
import 'package:drive_or_drunk_app/widgets/theme_change_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpsertEventPage extends StatefulWidget {
  const UpsertEventPage({super.key, this.event});
  final Event? event;

  @override
  State<UpsertEventPage> createState() => _UpsertEventPageState();
}

class _UpsertEventPageState extends State<UpsertEventPage> {
  final FirestoreService _firestoreService = FirestoreService();

  final currentUser = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  void _saveEvent() {
    _formKey.currentState
        ?.save(); // Save also calls validate unfortunately I couldn't find a way to avoid it
    if (_formKey.currentState!.validate()) {
      final String title = _titleController.text;
      final String description = _descriptionController.text;
      final String date = _dateController.text;
      final String place = _placeController.text;
      final String imageBase64 = _imageController.text;

      // Clear the form
      _titleController.clear();
      _descriptionController.clear();
      _dateController.clear();
      _placeController.clear();
      _imageController.clear();
      final upsertEvent = Event(
        author: currentUser != null
            ? currentUser!.uid
            : throw Exception('User is not logged in'),
        name: title,
        description: description,
        date: DateTime.parse(date.split('/').reversed.join('-')),
        place: place,
        image: imageBase64,
      );

      if (widget.event != null) {
        _firestoreService.updateEvent(
          widget.event!.id!,
          upsertEvent
              .copyWith(
                drivers: widget.event!.drivers,
                drunkards: widget.event!.drunkards,
              )
              .toMap(),
        );

        // Pop twice to remove the old event details page
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(
          AppRoutes.eventDetails,
          arguments: upsertEvent.copyWith(
            id: widget.event!.id,
          ),
        );
      } else {
        _firestoreService.addEvent(
          upsertEvent,
        );

        // Optionally navigate back or show a success message
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.event != null;
    if (isUpdate) {
      _titleController.text = widget.event!.name;
      _descriptionController.text = widget.event!.description ?? '';

      _dateController.text = getLocalizedDateInNumberFormat(
        widget.event!.date,
      );
      _placeController.text = widget.event!.place;
      _imageController.text = widget.event!.image ?? '';
    }
    return Scaffold(
      appBar: AppBar(
        title: isUpdate
            ? const Text('Update Event')
            : const Text('Create New Event'),
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
                decoration: const InputDecoration(labelText: 'Event Title*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Event Description',
                ),
                maxLines: 2,
              ),
              DateInputField(
                controller: _dateController,
                required: true,
              ),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(
                  labelText: 'Event Place',
                ),
              ),
              // TODO: add geolocation input
              ImageInputField(
                onImageSelected: (image) {
                  _imageController.text = base64StringFromImage(image);
                },
                initialImage: _imageController.text.isNotEmpty
                    ? _imageController.text
                    : null,
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
