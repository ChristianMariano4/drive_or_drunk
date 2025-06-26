import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/constants/global_keys.dart';
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/services/firestore_service.dart'
    show FirestoreService;
import 'package:drive_or_drunk_app/utils/image_utils.dart'
    show base64StringFromImage;
import 'package:drive_or_drunk_app/utils/time_utils.dart'
    show getLocalizedDateInNumberFormat;
import 'package:drive_or_drunk_app/widgets/custom_elevated_button.dart';
import 'package:drive_or_drunk_app/widgets/date_input_field.dart';
import 'package:drive_or_drunk_app/widgets/google_maps.dart'
    show GoogleMaps, createMarker;
import 'package:drive_or_drunk_app/widgets/image_input_field.dart';
import 'package:drive_or_drunk_app/widgets/theme_change_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UpsertEventPage extends StatefulWidget {
  const UpsertEventPage({super.key, this.event});
  final Event? event;

  @override
  State<UpsertEventPage> createState() => _UpsertEventPageState();
}

class _UpsertEventPageState extends State<UpsertEventPage> {
  final FirestoreService _firestoreService = FirestoreService();

  final currentUser = FirebaseAuth.instance.currentUser;

  final ValueNotifier<bool> newLocation = ValueNotifier(false);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    final isUpdate = widget.event != null;
    if (isUpdate) {
      _titleController.text = widget.event!.name;
      _descriptionController.text = widget.event!.description ?? '';
      _dateController.text = getLocalizedDateInNumberFormat(
        widget.event!.date,
      );
      _placeController.text = widget.event!.place;
      _imageController.text = widget.event!.image ?? '';
      _locationController.text = widget.event!.location != null
          ? '${widget.event!.location!.latitude}, ${widget.event!.location!.longitude}'
          : '';
    }

    super.initState();
  }

  void _saveEvent() {
    GlobalKeys.upsertEventFormKey.currentState
        ?.save(); // Save also calls validate unfortunately I couldn't find a way to avoid it
    if (GlobalKeys.upsertEventFormKey.currentState!.validate()) {
      final String title = _titleController.text;
      final String description = _descriptionController.text;
      final String date = _dateController.text;
      final String place = _placeController.text;
      final String imageBase64 = _imageController.text;
      final String location = _locationController.text;

      // Clear the form
      _titleController.clear();
      _descriptionController.clear();
      _dateController.clear();
      _placeController.clear();
      _imageController.clear();
      _locationController.clear();
      final upsertEvent = Event(
        author: currentUser != null
            ? currentUser!.uid
            : throw Exception('User is not logged in'),
        name: title,
        description: description,
        date: DateTime.parse(date.split('/').reversed.join('-')),
        place: place,
        image: imageBase64,
        location: location == ''
            ? null
            : GeoPoint(
                double.parse(location.split(',')[0]),
                double.parse(location.split(',')[1]),
              ),
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

    Map<String, Marker> markers = {
      if (widget.event?.location != null)
        'event_location': createMarker(
          context,
          location: LatLng(widget.event!.location!.latitude,
              widget.event!.location!.longitude),
          id: 'event_location',
          title: _titleController.text,
          snippet: _placeController.text,
        )
    };

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
          key: GlobalKeys.upsertEventFormKey,
          child: SingleChildScrollView(
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
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: AppSizes.productImageHeight * 1.5,
                  child: ValueListenableBuilder(
                    valueListenable: newLocation,
                    builder: (context, value, _) {
                      return GoogleMaps(
                        markers: markers,
                        onLongPress: (position) {
                          _locationController.text =
                              '${position.latitude}, ${position.longitude}';
                          markers = {
                            'event_location': createMarker(
                              context,
                              location:
                                  LatLng(position.latitude, position.longitude),
                              id: 'event_location',
                              title: _titleController.text,
                              snippet: _placeController.text,
                            )
                          };
                          newLocation.value = !newLocation.value;
                        },
                      );
                    },
                  ),
                ),
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
      ),
    );
  }
}
