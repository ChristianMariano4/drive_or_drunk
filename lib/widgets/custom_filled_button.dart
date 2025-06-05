import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  final void Function()? onPressed;
  final String labelText;

  const CustomFilledButton({
    super.key,
    required this.onPressed,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        fixedSize: const Size(400, 60),
      ),
      child: Text(labelText,
          style: const TextStyle(
            fontSize: 25,
          )),
    );
  }
}
