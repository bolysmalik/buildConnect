import 'package:flutter/material.dart';

class BaseRequestForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;

  const BaseRequestForm({
    super.key,
    required this.formKey,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
