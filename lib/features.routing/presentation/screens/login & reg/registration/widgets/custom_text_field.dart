import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType keyboard;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.obscure = false,
    this.keyboard = TextInputType.text,
    this.formatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          inputFormatters: formatters,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).primaryColor) : null,
          ),
          validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Обязательное поле' : null,
        ),
      ),
    );
  }
}
