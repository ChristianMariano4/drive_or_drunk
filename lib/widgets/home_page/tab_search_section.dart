import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/widgets/home_page/event_search_form.dart';
import 'package:drive_or_drunk_app/widgets/home_page/user_search_form.dart';
import 'package:flutter/material.dart';

class TabSearchSection extends StatefulWidget {
  const TabSearchSection({super.key});

  @override
  State<TabSearchSection> createState() => _TabSearchSectionState();
}

class _TabSearchSectionState extends State<TabSearchSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // aggiorna lo stack quando cambia tab
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(child: Text("Events")),
            Tab(child: Text("Users")),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        // Usa IndexedStack invece di TabBarView
        IndexedStack(
          index: _tabController.index,
          children: const [
            EventSearchForm(),
            UserSearchForm(),
          ],
        ),
      ],
    );
  }
}
