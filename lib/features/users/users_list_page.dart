import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/models/user_model.dart';
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/widgets/custom_stream_builder.dart';
import 'package:drive_or_drunk_app/widgets/users/user_card.dart';
import 'package:flutter/material.dart';

class UsersListPage extends StatefulWidget {
  final String? nameQuery;
  const UsersListPage({super.key, this.nameQuery});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  late final Stream<List<User>> usersStream;

  @override
  void initState() {
    super.initState();
    final svc = FirestoreService();
    usersStream =
        (widget.nameQuery != null && widget.nameQuery!.trim().isNotEmpty)
            ? svc.searchUsersByName(widget.nameQuery!.trim())
            : svc.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.nameQuery == null || widget.nameQuery!.isEmpty)
        ? 'All Users'
        : 'Results for “${widget.nameQuery}”';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: CustomStreamBuilder<User>(
          stream: usersStream,
          customListTileBuilder: (user) => Padding(
            padding: const EdgeInsets.all(AppSizes.sm),
            child: UserCard(user: user),
          ),
        ),
      ),
    );
  }
}
