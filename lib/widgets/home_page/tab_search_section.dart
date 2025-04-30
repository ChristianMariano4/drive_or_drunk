import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/widgets/home_page/event_search_form.dart';
import 'package:drive_or_drunk_app/widgets/home_page/user_search_form.dart';
import 'package:flutter/material.dart';

class TabSearchSection extends StatelessWidget {
  const TabSearchSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [Tab(child: Text("Events")), Tab(child: Text("Users"))],
          ),
          SizedBox(height: AppSizes.sm),
          SizedBox(
            height:
                AppSizes.searchFormHeight, // or flexible depending on layout
            child: TabBarView(
              children: [
                EventSearchForm(),
                UserSearchForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
