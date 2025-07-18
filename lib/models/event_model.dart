import 'package:cloud_firestore/cloud_firestore.dart'
    show
        DocumentReference,
        FieldValue,
        FirebaseException,
        FirebaseFirestore,
        GeoPoint,
        Query,
        Timestamp;
import 'package:drive_or_drunk_app/core/constants/constants.dart'
    show Collections, mapCircleRadius;
import 'package:drive_or_drunk_app/services/user_service.dart';
import 'package:drive_or_drunk_app/widgets/google_maps.dart'
    show isLocationWithinRadius;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Event {
  final String? id;
  final String name;
  final String lower_name;
  final String? description;
  final String? image;
  final DateTime date;
  final List<DocumentReference> drivers;
  final List<DocumentReference> drunkards;
  final GeoPoint? location;
  final String place;
  final String author;

  Event(
      {this.id,
      required this.name,
      required this.author,
      this.drivers = const [],
      this.drunkards = const [],
      this.location,
      this.description,
      this.image,
      required this.date,
      required this.place})
      : lower_name = name.toLowerCase();

  factory Event.fromMap(Map<String, dynamic> data, String documentId) {
    return Event(
      id: documentId,
      name: data['name'] ?? '',
      author: data['author'] ?? '',
      drivers: List<DocumentReference>.from(data['drivers'] ?? []),
      drunkards: List<DocumentReference>.from(data['drunkards'] ?? []),
      location: data['location'],
      description: data['description'],
      image: data['image'],
      date: (data['date'] as Timestamp).toDate(),
      place: data['place'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'drivers': drivers,
      'drunkards': drunkards,
      'location': location,
      'description': description,
      'image': image,
      'date': Timestamp.fromDate(date),
      'place': place,
      'author': author,
    };
  }

  Event copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    DateTime? date,
    List<DocumentReference>? drivers,
    List<DocumentReference>? drunkards,
    GeoPoint? location,
    String? place,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      date: date ?? this.date,
      drivers: drivers ?? this.drivers,
      drunkards: drunkards ?? this.drunkards,
      location: location ?? this.location,
      place: place ?? this.place,
      author: author,
    );
  }
}

Future<void> addEvent(Event event, FirebaseFirestore db) async {
  if (event.id == null) {
    db.collection(Collections.events).add(event.toMap());
  } else {
    throw FirebaseException(
      plugin: 'Firestore',
      message: 'A event with that ID already exists.',
    );
  }
}

Future<Event?> getEvent(String id, FirebaseFirestore db) async {
  final doc = await db.collection(Collections.events).doc(id).get();
  if (doc.exists) {
    return Event.fromMap(doc.data()!, doc.id);
  }
  return null;
}

Future<DocumentReference?> getEventReference(
    String id, FirebaseFirestore db) async {
  return db.collection(Collections.events).doc(id);
}

Stream<List<Event>> getEvents(FirebaseFirestore db) {
  return db.collection(Collections.events).snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => Event.fromMap(doc.data(), doc.id)).toList()
        ..sort((a, b) => a.date.compareTo(b.date)));
}

Future<void> updateEvent(
    String id, Map<String, dynamic> data, FirebaseFirestore db) async {
  await db.collection(Collections.events).doc(id).update(data);
}

Future<void> deleteEvent(String id, FirebaseFirestore db) async {
  await db.collection(Collections.events).doc(id).delete();
}

Stream<List<Event>> searchEvents(FirebaseFirestore db,
    {String? eventName,
    String? place,
    DateTimeRange? dateRange,
    LatLng? locationSearchCenter}) {
  eventName = eventName?.toLowerCase();
  Query<Map<String, dynamic>> query = db.collection('Event');

  if (eventName != null && eventName.isNotEmpty) {
    query = query
        .where('lower_name', isGreaterThanOrEqualTo: eventName)
        .where('lower_name', isLessThanOrEqualTo: '$eventName\uf8ff');
  }

  if (place != null && place.isNotEmpty) {
    query = query.where('place', isEqualTo: place);
  }

  if (dateRange != null) {
    query = query
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end));
  }

  return query.snapshots().map((snapshot) {
    final List<Event> eventList = [];

    for (var doc in snapshot.docs) {
      if (locationSearchCenter != null) {
        final event = Event.fromMap(doc.data(), doc.id);

        if (event.location == null) {
          continue; // Skip this event if it has no location
        }
        if (!isLocationWithinRadius(
            event.location!, locationSearchCenter, mapCircleRadius)) {
          continue; // Skip this event if it's not within the search radius
        }
      }

      eventList.add(Event.fromMap(doc.data(), doc.id));
    }
    return eventList;
  });
}

Future<void> addDriver(
    String eventId, DocumentReference driverRef, FirebaseFirestore db) async {
  final event = await getEvent(eventId, db);
  if (event != null) {
    event.drivers.add(driverRef);
    await updateEvent(eventId, {'drivers': event.drivers}, db);
    final eventRef = await getEventReference(eventId, db);
    await db.collection(Collections.users).doc(driverRef.id).update({
      'registeredEvents': FieldValue.arrayUnion([eventRef])
    });
    UserService().refreshUser();
  }
}

Future<void> addDrunkard(
    String eventId, DocumentReference drunkardRef, FirebaseFirestore db) async {
  final event = await getEvent(eventId, db);
  if (event != null) {
    event.drunkards.add(drunkardRef);
    await updateEvent(eventId, {'drunkards': event.drunkards}, db);
    await db
        .collection(Collections.users)
        .doc(drunkardRef.id)
        .update({'registeredEvents': FieldValue.arrayUnion([])});
    final eventRef = await getEventReference(eventId, db);
    await db.collection(Collections.users).doc(drunkardRef.id).update({
      'registeredEvents': FieldValue.arrayUnion([eventRef])
    });
    UserService().refreshUser();
  }
}

Future<void> removeDriver(
    String eventId, DocumentReference driverRef, FirebaseFirestore db) async {
  final event = await getEvent(eventId, db);
  if (event != null) {
    event.drivers.remove(driverRef);
    await updateEvent(eventId, {'drivers': event.drivers}, db);
    final eventRef = await getEventReference(eventId, db);
    await db.collection(Collections.users).doc(driverRef.id).update({
      'registeredEvents': FieldValue.arrayRemove([eventRef])
    });
    UserService().refreshUser();
  }
}

Future<void> removeDrunkard(
    String eventId, DocumentReference drunkardRef, FirebaseFirestore db) async {
  final event = await getEvent(eventId, db);
  if (event != null) {
    event.drunkards.remove(drunkardRef);
    await updateEvent(eventId, {'drunkards': event.drunkards}, db);
    final eventRef = await getEventReference(eventId, db);
    await db.collection(Collections.users).doc(drunkardRef.id).update({
      'registeredEvents': FieldValue.arrayRemove([eventRef])
    });
    UserService().refreshUser();
  }
}
