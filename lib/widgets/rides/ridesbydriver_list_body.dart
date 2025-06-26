// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:drive_or_drunk_app/models/event_model.dart';
// import 'package:drive_or_drunk_app/models/ride_model.dart';
// import 'package:drive_or_drunk_app/services/firestore_service.dart';
// import 'package:drive_or_drunk_app/widgets/custom_future_builder.dart';
// import 'package:flutter/material.dart';


// class RidesByDriverListBody extends StatelessWidget {
//   FirestoreService db = FirestoreService();
//   final Ride ride;
//   Event? event;

//   RidesByDriverListBody({
//     super.key,
//     required this.ride,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return CustomFutureBuilder(
//       future: db.getEvent(ride.eventId.id),
//       component: (data) {
//         return Card(
//           child: Column(children: ),
          
//         );
//         // Handle ride tap
//       },
//     );
//   }                         
// }