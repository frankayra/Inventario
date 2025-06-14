import 'package:flutter/material.dart';

class DateInput extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final String labelText;
  final void Function(int date)? onChanged;
  final String? Function(String? value)? validator;
  final String? initialValue;
  final bool Function()? enabled;
  const DateInput({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.labelText,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.enabled,
  });

  @override
  _DateInputState createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  TextEditingController _fechaController = TextEditingController();

  @override
  void dispose() {
    _fechaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fechaController.text = widget.initialValue ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _fechaController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
        );

        if (pickedDate != null) {
          _fechaController.text =
              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          widget.onChanged?.call(
            int.parse(
              "${pickedDate.year}${pickedDate.month.toString().padLeft(2, '0')}${pickedDate.day.toString().padLeft(2, '0')}",
            ),
          );
        }
      },
      validator: widget.validator,
      enabled: widget.enabled != null ? widget.enabled!() : true,
    );
  }
}
