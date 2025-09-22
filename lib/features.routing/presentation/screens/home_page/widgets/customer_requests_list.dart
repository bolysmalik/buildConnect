import 'package:flutter/material.dart';
import '../../../../../../app.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../widgets/request_card.dart';

typedef RequestCallback = dynamic Function(Map<String, dynamic>);

class CustomerRequestsList extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> requests;
  final UserRole userRole;
  final Future<void> Function() onRefresh;
  final RequestCallback onDetails;
  final RequestCallback onRespond;
  final VoidCallback? onTap;

  const CustomerRequestsList({
    super.key,
    required this.isLoading,
    required this.requests,
    required this.userRole,
    required this.onRefresh,
    required this.onDetails,
    required this.onRespond,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 Строим список заявок. Количество: ${requests.length}');
    debugPrint('🔄 Загружается: $isLoading');

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkIconSecondary
                  : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Нет доступных заявок',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Заявки появятся здесь, когда заказчики создадут их',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextHint
                    : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return InkWell(
            onTap: onTap,
            child: RequestCard(
              request: request,
              userRole: userRole,
              onDetails: onDetails,
              onRespond: onRespond,
            ),
          );
        },
      ),
    );
  }
}
