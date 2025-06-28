import 'package:flutter/material.dart';

Widget licencesBrowser({
  required BuildContext context,
  required Function(String value) onChange,
  required void Function() onSearch,
}) {
  return Column(
    children: [
      Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 300,
          ), // o el ancho que tú quieras
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Licencia',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: onChange,
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: onSearch,
                child: Icon(Icons.arrow_forward_outlined),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 20),
    ],
  );
}
