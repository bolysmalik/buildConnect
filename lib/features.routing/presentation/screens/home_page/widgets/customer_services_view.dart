import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class CustomerServicesView extends StatelessWidget {
  final String selectedFilter;
  final Widget Function(String, bool) buildServiceFilterChip;
  final Widget servicesList;
  final bool isDark;

  const CustomerServicesView({
    super.key,
    required this.selectedFilter,
    required this.buildServiceFilterChip,
    required this.servicesList,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Заголовок с фильтрами
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildServiceFilterChip('Все', selectedFilter == 'all'),
                const SizedBox(width: 8),
                buildServiceFilterChip('Материалы', selectedFilter == 'material'),
                const SizedBox(width: 8),
                buildServiceFilterChip('Услуги', selectedFilter == 'foreman'),
                const SizedBox(width: 8),
                buildServiceFilterChip('Доставка', selectedFilter == 'courier'),
              ],
            ),
          ),
        ),

        // Список услуг
        Expanded(child: servicesList),
      ],
    );
  }
}
