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
    show Collections;
import 'package:drive_or_drunk_app/services/user_service.dart';
import 'package:flutter/material.dart';

class Event {
  final String? id;
  final String name;
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
      required this.place});

// THIS PART IS PROBABLY NOT NEEDED BUT JUST IN CASE I LEFT IT IN
  // factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
  //     SnapshotOptions? options) {
  //   final data = snapshot.data();
  //   debugPrint('Event.fromFirestore: $data');
  //   return Event(
  //     name: data?['name'],
  //     drivers: data?['drivers'],
  //     drunkards: data?['drunkards'],
  //     location: data?['location'],
  //   );
  // }

  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'name': name,
  //     'drivers': drivers,
  //     'drunkards': drunkards,
  //     if (location != null) 'location': location,
  //   };
  // }

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

Stream<List<Event>> searchEvents(String? eventName, String? place,
    DateTimeRange? dateRange, FirebaseFirestore db) {
  Query<Map<String, dynamic>> query = db.collection('Event');

  if (eventName != null && eventName.isNotEmpty) {
    query = query
        .where('name', isGreaterThanOrEqualTo: eventName)
        .where('name', isLessThanOrEqualTo: '$eventName\uf8ff');
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

  return query.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => Event.fromMap(doc.data(), doc.id)).toList());
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
