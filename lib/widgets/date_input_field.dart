import 'package:drive_or_drunk_app/utils/time_utils.dart'
    show getLocalizedDateInNumberFormat;
import 'package:flutter/material.dart';

class DateInputField extends StatefulWidget {
  /// A custom widget that provides a date input field for selecting dates.
  ///
  /// ⚠️⚠️⚠️ When using the required parameter, make sure to call the save method of the form. ⚠️⚠️⚠️
  const DateInputField({
    super.key,
    this.required = false,
    required this.controller,
  });
  final TextEditingController controller;
  final bool required;

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<DateInputField> {
  String? _dateForceErrorText;
  final _dateStateKey = GlobalKey<FormFieldState>();

  void _clearDate() {
    setState(() {
      _dateStateKey.currentState?.reset();
      widget.controller.clear();
    });
  }

  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;
    final pickedDateFormatted = getLocalizedDateInNumberFormat(pickedDate);
    if (pickedDateFormatted != widget.controller.text) {
      setState(() {
        widget.controller.text = pickedDateFormatted;
      });
    }
  }

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final dateParts = value.split('/');
    if (dateParts.length != 3) {
      return 'Invalid date format';
    }
    final day = dateParts[0];
    final month = dateParts[1];
    final year = dateParts[2];
    if (day == '' || month == '' || year == '') {
      return 'Invalid date format';
    }

    final isValidDate = DateTime.tryParse('$year-$month-$day');
    if (isValidDate == null) {
      return 'Invalid date';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      key: _dateStateKey,
      onChanged: (value) {
        setState(() {
          _dateForceErrorText = null;
          widget.controller.text = value.trim();
        });
      },
      onSaved: (value) {
        if (widget.required && widget.controller.text.isEmpty) {
          // Text with a space is set to fail the validation after trying to save.
          widget.controller.text = ' ';
          setState(() {
            _dateForceErrorText = 'Please enter a date';
          });
          _dateStateKey.currentState?.validate();
        }
      },
      onTap: () {
        if (widget.controller.text == ' ') {
          setState(() {
            widget.controller.text = '';
          });
        }
      },
      decoration: InputDecoration(
          labelText: widget.required ? 'Event Date*' : 'Event Date',
          hintText: 'dd/mm/yyyy',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.controller.text != '')
                IconButton(
                  visualDensity: const VisualDensity(
                    horizontal: -3,
                  ),
                  icon: const Icon(Icons.clear),
                  onPressed: _clearDate,
                ),
              IconButton(
                visualDensity: VisualDensity(
                  horizontal: widget.controller.text != '' ? -3 : 0,
                ),
                icon: const Icon(Icons.calendar_today),
                onPressed: _pickDate,
              ),
            ],
          )),
      forceErrorText: _dateForceErrorText,
      autovalidateMode: AutovalidateMode.onUnfocus,
      validator: _validator,
    );
  }
}
