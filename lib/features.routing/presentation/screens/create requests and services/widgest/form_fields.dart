import 'package:flutter/material.dart';

Widget buildTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String labelText,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  TextCapitalization textCapitalization = TextCapitalization.sentences,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    textCapitalization: textCapitalization,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.blue, width: 2.0),
      ),
      alignLabelWithHint: maxLines > 1,
    ),
    validator: validator,
  );
}

/// ✅ именно такая сигнатура, как ты используешь в других экранах
Widget buildDateField(
  BuildContext context,
  TextEditingController controller,
  String labelText,
  Future<void> Function(BuildContext, TextEditingController) onSelect,
) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
      ),
      suffixIcon: const Icon(Icons.calendar_today),
    ),
    readOnly: true,
    onTap: () => onSelect(context, controller),
    validator: (value) => value!.isEmpty ? 'Выберите дату' : null,
  );
}

Widget buildTimeField(
  BuildContext context,
  TextEditingController controller,
  String labelText,
  Future<void> Function(BuildContext, TextEditingController) onSelect,
) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
      ),
      suffixIcon: const Icon(Icons.access_time),
    ),
    readOnly: true,
    onTap: () => onSelect(context, controller),
    validator: (value) => value!.isEmpty ? 'Выберите время' : null,
  );
}
