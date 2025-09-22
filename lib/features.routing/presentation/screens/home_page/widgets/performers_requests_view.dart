import 'package:flutter/material.dart';
import 'package:flutter_valhalla/core/mock/mock_auth_service.dart';
import 'package:flutter_valhalla/core/utils/registration_role_extension.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/my%20services/pages/my_services_page.dart';
import '../../../../../../app.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'customer_requests_list.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/my%20responses/view/my_responses_page.dart';

typedef RequestCallback = dynamic Function(Map<String, dynamic>);

class PerformersRequestsView extends StatefulWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> requests;
  final UserRole userRole;
  final Future<void> Function() onRefresh;
  final RequestCallback onDetails;
  final RequestCallback onRespond;

  const PerformersRequestsView({
    super.key,
    required this.isLoading,
    required this.requests,
    required this.userRole,
    required this.onRefresh,
    required this.onDetails,
    required this.onRespond,
  });

  @override
  State<PerformersRequestsView> createState() => _PerformersRequestsViewState();
}

class _PerformersRequestsViewState extends State<PerformersRequestsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _allRequests => widget.requests;


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Все заявки'),
              Tab(text: 'Мои отклики'),
              Tab(text: 'Мои услуги'), 
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              CustomerRequestsList(
                isLoading: widget.isLoading,
                requests: _allRequests,
                userRole: widget.userRole,
                onRefresh: widget.onRefresh,
                onDetails: widget.onDetails,
                onRespond: widget.onRespond,
              ),
              MyResponsesPage(showAppBar: false, showRefreshAction: false,userRole: MockAuthService().getActiveRole()?.toUserRole() ?? UserRole.unauthorized,),
              MyServicesPage(showAppBar: false, showRefreshAction: false, userRole: MockAuthService().getActiveRole()?.toUserRole() ?? UserRole.unauthorized),
            ],
          ),
        ),
      ],
    );
  }
}
