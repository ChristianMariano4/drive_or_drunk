import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/services/firestore_service.dart'
    show FirestoreService;
import 'package:drive_or_drunk_app/services/user_service.dart';
import 'package:drive_or_drunk_app/utils/image_utils.dart';
import 'package:drive_or_drunk_app/utils/time_utils.dart';
import 'package:drive_or_drunk_app/widgets/circular_button_with_background.dart';
import 'package:drive_or_drunk_app/widgets/clippers/reverse_wavy_clipper.dart';
import 'package:drive_or_drunk_app/widgets/custom_future_builder.dart';
import 'package:drive_or_drunk_app/widgets/theme_change_button.dart';
import 'package:flutter/material.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.event});
  final Event event;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final _firestoreService = FirestoreService();
  late final Future<DocumentReference?> eventRef;
  late final ValueNotifier<bool> isFavorited = ValueNotifier(false);
  late final ValueNotifier<bool> isRegistered = ValueNotifier(false);
  final currentUser = UserService().getUser();
  late final DocumentReference? currentUserRef = UserService().getUserRef();

  @override
  void initState() {
    super.initState();
    eventRef = _firestoreService.getEventReference(widget.event.id!);
    isUserRegistered().then((value) {
      isRegistered.value = value;
    });
  }

  Future<bool> isUserRegistered() async {
    final eventRef =
        await _firestoreService.getEventReference(widget.event.id!);
    return currentUser.registeredEvents.contains(eventRef);
  }

  bool isUserDriver() {
    return widget.event.drivers.contains(currentUserRef);
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    final dateRow = Row(
      children: [
        const Icon(Icons.calendar_today),
        Text(
          getLocalizedDate(
            event.date,
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(),
        ),
      ],
    );
    final locationRow = Row(
      children: [
        const Icon(Icons.location_on),
        Text(
          event.place,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(),
        ),
      ],
    );
    final availableDriverCallout = ValueListenableBuilder(
        valueListenable: isRegistered,
        builder: (context, value, _) {
          return Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(AppSizes.sm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  '${event.drivers.length} drivers available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          );
        });
    final favoriteIconButton = CustomFutureBuilder(
        future: eventRef,
        component: (eventRef) {
          isFavorited.value = currentUser.favoriteEvents.contains(eventRef);

          return CircularButtonWithBackground(
              blendedBackground: true,
              child: ValueListenableBuilder<bool>(
                valueListenable: isFavorited,
                builder: (context, value, _) {
                  return IconButton(
                      onPressed: () {
                        isFavorited.value
                            ? _firestoreService
                                .removeFavoriteEvent(event, currentUser.id!)
                                .then((value) {})
                            : _firestoreService
                                .addFavoriteEvent(event, currentUser.id!)
                                .then((value) {});
                        isFavorited.value = !isFavorited.value;
                      },
                      icon: Icon(
                        isFavorited.value
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: AppSizes.iconLg,
                        color: Theme.of(context).colorScheme.primary,
                      ));
                },
              ));
        });
    final registerDrunkardButton = ValueListenableBuilder(
        valueListenable: isRegistered,
        builder: (context, isRegisteredValue, _) {
          return FilledButton(
              onPressed: () {
                if (isUserDriver()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'You cannot register as a drunkard if you are a driver.',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                if (!isRegisteredValue) {
                  _firestoreService
                      .addDrunkardToEvent(
                    event.id!,
                    currentUserRef!,
                  )
                      .then((isRegisteredValue) {
                    isRegistered.value = true;
                    event.drunkards.add(currentUserRef!);
                  });
                } else {
                  _firestoreService
                      .removeDrunkardFromEvent(
                    event.id!,
                    currentUserRef!,
                  )
                      .then((value) {
                    isRegistered.value = false;
                    event.drunkards.remove(currentUserRef!);
                  });
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: isRegisteredValue && !isUserDriver()
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                spacing: AppSizes.sm,
                children: [
                  Text(
                    'Drunkard',
                    style: isRegisteredValue && !isUserDriver()
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                          )
                        : null,
                  ),
                  Icon(
                    isRegisteredValue && !isUserDriver()
                        ? Icons.no_drinks_rounded
                        : Icons.liquor_rounded,
                    size: AppSizes.iconLg,
                  ),
                ],
              ));
        });
    final registerDriverButton = ValueListenableBuilder(
        valueListenable: isRegistered,
        builder: (context, isRegisteredValue, _) {
          return FilledButton(
            onPressed: () {
              if (isRegisteredValue && !isUserDriver()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'You are already registered as a drunkard. You cannot register as a driver.',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              if (!isRegisteredValue) {
                _firestoreService
                    .addDriverToEvent(
                  event.id!,
                  currentUserRef!,
                )
                    .then((value) {
                  isRegistered.value = true;
                  event.drivers.add(currentUserRef!);
                });
              } else {
                _firestoreService
                    .removeDriverFromEvent(
                  event.id!,
                  currentUserRef!,
                )
                    .then((value) {
                  isRegistered.value = false;
                  event.drivers.remove(currentUserRef!);
                });
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: isUserDriver()
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.primary,
            ),
            child: Row(
              spacing: AppSizes.sm,
              children: [
                Text(
                  'Driver',
                  style: isUserDriver()
                      ? const TextStyle(
                          decoration: TextDecoration.lineThrough,
                        )
                      : null,
                ),
                const Icon(
                  Icons.drive_eta,
                  size: AppSizes.iconLg,
                ),
              ],
            ),
          );
        });
    final registrationCallout = ValueListenableBuilder(
        valueListenable: isRegistered,
        builder: (context, isRegisteredValue, _) {
          if (!isRegisteredValue) {
            return Container();
          }
          return Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withAlpha(25),
              borderRadius: BorderRadius.circular(AppSizes.sm),
            ),
            child: Row(
              spacing: AppSizes.sm,
              children: [
                Icon(
                  isUserDriver() ? Icons.drive_eta : Icons.liquor_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                Text(
                  isUserDriver()
                      ? 'You are registered as a driver'
                      : 'You are registered as a drunkard',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          );
        });
    return Scaffold(
      body: Column(
        children: [
          Stack(children: [
            Positioned(
              child: ClipPath(
                  clipper: ReverseWavyClipper(),
                  child: imageFromBase64(
                    event.image,
                    defaultImagePath: 'assets/events/event1.png',
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: double.infinity,
                  )),
            ),
            Positioned(
              top: AppSizes.appBarHeight,
              left: AppSizes.md,
              child: CircularButtonWithBackground(
                blendedBackground: true,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                  ), // Change icon color if needed
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const Positioned(
                top: AppSizes.appBarHeight,
                right: AppSizes.md,
                child: CircularButtonWithBackground(
                  blendedBackground: true,
                  child: ThemeChangeButton(),
                )),
            Positioned(
              bottom: 0,
              left: 0,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Row(
                      children: [
                        if (event.author == currentUser.id)
                          CircularButtonWithBackground(
                            blendedBackground: true,
                            child: IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.upsertEvent,
                                    arguments: event,
                                  );
                                },
                                icon: Icon(
                                  Icons.edit,
                                  size: AppSizes.iconLg,
                                  color: Theme.of(context).colorScheme.primary,
                                )),
                          ),
                        favoriteIconButton,
                      ],
                    )
                  ],
                ),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSizes.sm,
              children: [
                Row(
                  spacing: AppSizes.sm,
                  children: [
                    dateRow,
                    locationRow,
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                  child: Text(
                    'About this event',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.titleMedium?.fontSize,
                    ),
                  ),
                ),
                Text(
                  event.description ?? '',
                ),
                registrationCallout,
                availableDriverCallout,
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(
                left: AppSizes.sm,
                right: AppSizes.sm,
                top: AppSizes.md,
                bottom: AppSizes.xl * 1.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                registerDrunkardButton,
                registerDriverButton,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
