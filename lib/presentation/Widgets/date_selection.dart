import 'package:flutter/material.dart';

class DateInput extends StatefulWidget {
  final DateTime startDate;
  final DateTime lastDate;
  final String labelText;
  final void Function(DateTime date)? onChanged;
  DateInput({
    super.key,
    required this.startDate,
    required this.lastDate,
    required this.labelText,
    this.onChanged,
  });

  @override
  _DateInputState createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(
        widget.startDate.year,
        widget.startDate.month,
        widget.startDate.day,
      ),
      lastDate: DateTime(
        widget.lastDate.year,
        widget.lastDate.month,
        widget.lastDate.day,
      ),
      locale: const Locale("es", "ES"), // Opcional: para idioma español
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _controller.text =
            "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () => _seleccionarFecha(context),
      onChanged: (value) => widget.onChanged?.call(_selectedDate!),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor seleccione una fecha';
        }
        return null;
      },
    );
  }
}
