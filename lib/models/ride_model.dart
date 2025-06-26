import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, FirebaseException, FirebaseFirestore;
import 'package:drive_or_drunk_app/core/constants/constants.dart'
    show Collections;
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/models/user_model.dart';

class Ride {
  final String? id;
  final DocumentReference eventId;
  final DocumentReference? driverId;
  final List<DocumentReference> drunkards;
  final int capacity;

  Ride(
      {this.id,
      required this.eventId,
      this.driverId,
      this.drunkards = const [],
      required this.capacity});

  factory Ride.fromMap(Map<String, dynamic> data, String documentId) {
    return Ride(
      id: documentId,
      eventId: data['eventId'],
      driverId: data['driverId'],
      drunkards: List<DocumentReference>.from(data['drunkards'] ?? []),
      capacity: (data['capacity'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'driverId': driverId,
      'drunkards': drunkards,
      'capacity': capacity,
    };
  }
}

Future<void> addRide(Ride ride, FirebaseFirestore db) async {
  if (ride.id == null) {
    db.collection(Collections.rides).add(ride.toMap());
    addDriver(ride.eventId.id, ride.driverId!, db);
  } else {
    throw FirebaseException(
      plugin: 'Firestore',
      message: 'A Ride with that ID already exists.',
    );
  }
}

Future<Ride?> getRide(String id, FirebaseFirestore db) async {
  final doc = await db.collection(Collections.rides).doc(id).get();
  if (doc.exists) {
    return Ride.fromMap(doc.data()!, doc.id);
  }
  return null;
}

Stream<List<Ride>> getRidesByEvent(String eventId, FirebaseFirestore db) {
  return getEventReference(eventId, db)
      .asStream()
      .asyncExpand((eventReference) {
    if (eventReference == null) return Stream.value([]);
    return db
        .collection(Collections.rides)
        .where('eventId', isEqualTo: eventReference)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ride.fromMap(doc.data(), doc.id))
            .toList());
  });
}

Stream<List<Ride>> getRidesByDriver(String driverId, FirebaseFirestore db) {
  return getUserReference(driverId, db)
      .asStream()
      .asyncExpand((driverReference) {
    if (driverReference == null) return Stream.value([]);
    return db
        .collection(Collections.rides)
        .where('driverId', isEqualTo: driverReference)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ride.fromMap(doc.data(), doc.id))
            .toList());
  });
}

Stream<List<Ride>> getRidesByDrunkard(String userId, FirebaseFirestore db) {
  return getUserReference(userId, db).asStream().asyncExpand((userReference) {
    if (userReference == null) {
      return Stream.value([]);
    }
    return db
        .collection(Collections.rides)
        .where('drunkards', arrayContains: userReference)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ride.fromMap(doc.data(), doc.id))
            .toList());
  });
}

Future<void> addDrunkard(
    String rideId, DocumentReference drunkardRef, FirebaseFirestore db) async {
  final ride = await getRide(rideId, db);
  if (ride != null) {
    ride.drunkards.add(drunkardRef);
    await updateRide(rideId, {'drunkards': ride.drunkards}, db);
  }
}

Future<void> removeDrunkard(
    String rideId, DocumentReference drunkardRef, FirebaseFirestore db) async {
  final ride = await getRide(rideId, db);
  if (ride != null) {
    ride.drunkards.remove(drunkardRef);
    await updateRide(rideId, {'drunkards': ride.drunkards}, db);
  }
}

/// Updates a ride document with the given data.
Future<void> updateRide(
    String rideId, Map<String, dynamic> data, FirebaseFirestore db) async {
  await db.collection(Collections.rides).doc(rideId).update(data);
}

Future<void> deleteRide(String id, FirebaseFirestore db) async {
  await db.collection(Collections.rides).doc(id).delete();
}
