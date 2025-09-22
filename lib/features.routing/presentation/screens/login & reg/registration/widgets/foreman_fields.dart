import 'package:flutter/material.dart';
import 'package:flutter_valhalla/core/theme/app_colors.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/registration/widgets/custom_text_field.dart';

class ForemanFields extends StatelessWidget {
  final TextEditingController experience;
  final TextEditingController objectsCount;
  final TextEditingController jobCost;
  final String? idPhotoPath;
  final List<String> workPhotosPaths;
  final bool isSafeDealWorker;
  final bool isConditionsAccepted;
  final void Function(bool?) onSafeDealChanged;
  final void Function(bool?) onConditionsChanged;
  final void Function() onPickIdPhoto;
  final void Function() onPickWorkPhotos;

  final Widget Function(String label, VoidCallback onPressed, String? fileName)
      buildPhotoUploadButton;

  final Widget Function(String label, VoidCallback onPressed, List<String> fileNames)
      buildMultiPhotoUploadButton;

  const ForemanFields({
    super.key,
    required this.experience,
    required this.objectsCount,
    required this.jobCost,
    required this.idPhotoPath,
    required this.workPhotosPaths,
    required this.isSafeDealWorker,
    required this.isConditionsAccepted,
    required this.onSafeDealChanged,
    required this.onConditionsChanged,
    required this.onPickIdPhoto,
    required this.onPickWorkPhotos,
    required this.buildPhotoUploadButton,
    required this.buildMultiPhotoUploadButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: experience,
          label: 'Опыт работы (в годах)',
          icon: Icons.timeline,
          keyboard: TextInputType.number,
        ),
        CustomTextField(
          controller: objectsCount,
          label: 'Количество выполненных объектов',
          icon: Icons.business,
          keyboard: TextInputType.number,
        ),
        CustomTextField(
          controller: jobCost,
          label: 'Средняя стоимость работ (₸)',
          icon: Icons.price_change,
          keyboard: TextInputType.number,
        ),
        const SizedBox(height: 12),
        buildPhotoUploadButton('Фото удостоверения', onPickIdPhoto, idPhotoPath),
        const SizedBox(height: 12),
        buildMultiPhotoUploadButton('Фото выполненных работ', onPickWorkPhotos, workPhotosPaths),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: const Text('Работаю по безопасной сделке'),
          value: isSafeDealWorker,
          onChanged: onSafeDealChanged,
          activeColor: AppColors.primary,
        ),
        CheckboxListTile(
          title: const Text('Согласен с условиями'),
          value: isConditionsAccepted,
          onChanged: onConditionsChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
