// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
// import 'package:drive_or_drunk_app/services/firestore_service.dart';
// import 'package:drive_or_drunk_app/widgets/custom_stream_builder.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class RidesListPage extends StatefulWidget {
//   final String userId;
//   final String? eventId;
//   final String? driverId;

//   const RidesListPage(
//       {super.key, required this.userId, this.eventId, this.driverId});

//   @override
//   RidesListPageState createState() => RidesListPageState();
// }

// class RidesListPageState extends State<RidesListPage> {
//   final db = FirestoreService();
//   DocumentReference? userReference;

//   @override
//   void initState() {
//     super.initState();
//     initializeState();
//   }

//   void initializeState() async {
//     userReference = await db.getUserReference(widget.userId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: const Text('Rides'), actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//             },
//           ),
//           IconButton(
//             icon: Icon(
//                 context.watch<ThemeProvider>().themeMode == ThemeMode.light
//                     ? Icons.dark_mode
//                     : Icons.light_mode),
//             onPressed: () {
//               context.read<ThemeProvider>().toggleTheme();
//             },
//           )
//         ]),
//         body: Scaffold(
//         CustomStreamBuilder(
//             stream: widget.driverId != null
//                 ? db.getRidesByDriver(widget.driverId!)
//                 : db.getRidesByEvent(widget.eventId!),
//             customListTileBuilder: (item) {
//               widget.driverId != null
//                   ? RideListForDriverBody(
//                       db: db, item: item, userReference: userReference!)
//                   : RideListforEventBody(db: db, item: item, userReference: userReference!);
//             }));
//   }
// }
