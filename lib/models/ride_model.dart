import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, FirebaseException, FirebaseFirestore;
import 'package:drive_or_drunk_app/core/constants/constants.dart'
    show Collections;

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

Stream<List<Ride>> getRides(FirebaseFirestore db) {
  return db.collection(Collections.rides).snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => Ride.fromMap(doc.data(), doc.id)).toList());
}

Future<void> updateRide(
    String id, Map<String, dynamic> data, FirebaseFirestore db) async {
  await db.collection(Collections.rides).doc(id).update(data);
}

Future<void> deleteRide(String id, FirebaseFirestore db) async {
  await db.collection(Collections.rides).doc(id).delete();
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
