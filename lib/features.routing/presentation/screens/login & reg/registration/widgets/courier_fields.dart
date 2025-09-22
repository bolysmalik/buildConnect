import 'package:flutter/material.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/registration/widgets/custom_text_field.dart';

class CourierFields extends StatelessWidget {
  final TextEditingController carMake;
  final TextEditingController licensePlate;
  final TextEditingController carColor;
  final String? courierBodyType;
  final void Function(String?) onBodyTypeSelected;
  final bool isSafeDealWorker;
  final bool isConditionsAccepted;
  final void Function(bool?) onSafeDealChanged;
  final void Function(bool?) onConditionsChanged;

  
  const CourierFields({
    super.key,
    required this.carMake,
    required this.licensePlate,
    required this.carColor,
    required this.courierBodyType,
    required this.onBodyTypeSelected,
    required this.isSafeDealWorker,
    required this.isConditionsAccepted,
    required this.onSafeDealChanged,
    required this.onConditionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bodyTypes = ["Седан", "Универсал", "Фургон"];

    return Column(
      children: [
        CustomTextField(
          controller: carMake,
          label: "Марка авто",
          icon: Icons.directions_car,
        ),
        CustomTextField(
          controller: licensePlate,
          label: "Гос номер",
          icon: Icons.confirmation_number,
        ),
        CustomTextField(
          controller: carColor,
          label: "Цвет авто",
          icon: Icons.color_lens,
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: courierBodyType,
              items: bodyTypes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onBodyTypeSelected,
              decoration: const InputDecoration(
                border: InputBorder.none,
                labelText: "Тип кузова",
                prefixIcon: Icon(Icons.local_shipping),
              ),
            ),
          ),
        ),
        CheckboxListTile(
          title: const Text('Работаю по безопасной сделке'),
          value: isSafeDealWorker,
          onChanged: onSafeDealChanged,
        ),
        CheckboxListTile(
          title: const Text('Согласен с условиями'),
          value: isConditionsAccepted,
          onChanged: onConditionsChanged,
        ),
      ],
    );
  }
}
