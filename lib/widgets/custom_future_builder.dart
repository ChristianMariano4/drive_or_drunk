import 'package:flutter/material.dart';

class CustomFutureBuilder<T> extends StatefulWidget {
  final Future<T> future;
  final Widget Function(T data) component;

  const CustomFutureBuilder(
      {super.key, required this.future, required this.component});

  @override
  State<CustomFutureBuilder> createState() => _CustomFutureBuilderState<T>();
}

class _CustomFutureBuilderState<T> extends State<CustomFutureBuilder<T>> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center();
        } else if (snapshot.hasError) {
          debugPrint("Error loading future: ${snapshot.error}");
          return const Icon(Icons.error);
        } else if (snapshot.hasData) {
          return widget.component(snapshot.data as T);
        } else {
          return const Icon(Icons.error_outline_rounded);
        }
      },
    );
  }
}
