import 'package:flutter/material.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/registration/widgets/custom_text_field.dart';

class SupplierFields extends StatelessWidget {
  final TextEditingController experience;
  final TextEditingController objectsCount;
  final String? idPhotoPath;
  final List<String> workPhotosPaths;
  final VoidCallback onPickIdPhoto;
  final VoidCallback onPickWorkPhotos;
  final bool isSafeDealWorker;
  final bool isConditionsAccepted;
  final void Function(bool?) onSafeDealChanged;
  final void Function(bool?) onConditionsChanged;



  final Widget Function(String label, VoidCallback onPressed, String? fileName)
      buildPhotoUploadButton;

  final Widget Function(String label, VoidCallback onPressed, List<String> fileNames)
      buildMultiPhotoUploadButton;

  const SupplierFields({
    super.key,
    required this.experience,
    required this.objectsCount,
    required this.idPhotoPath,
    required this.workPhotosPaths,
    required this.onPickIdPhoto,
    required this.onPickWorkPhotos,
    required this.buildPhotoUploadButton,
    required this.buildMultiPhotoUploadButton,
    required this.isSafeDealWorker,
    required this.isConditionsAccepted,
    required this.onSafeDealChanged,
    required this.onConditionsChanged,
    
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: experience,
          label: 'Опыт',
          icon: Icons.timeline,
        ),
        CustomTextField(
          controller: objectsCount,
          label: 'Кол-во объектов',
          icon: Icons.business,
        ),
        buildPhotoUploadButton(
          'Фото удостоверения',
          onPickIdPhoto,
          idPhotoPath,
        ),
        buildMultiPhotoUploadButton(
          'Фото продукции',
          onPickWorkPhotos,
          workPhotosPaths,
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
