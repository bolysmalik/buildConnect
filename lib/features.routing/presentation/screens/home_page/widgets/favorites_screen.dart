import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/favorites/favorite_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/favorites/favorite_state.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/favorites/favorite_event.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/home_page/widgets/service_card.dart';
import '../../../../../../core/mock/mock_service_manager.dart';
import '../../../../../../core/utils/contact_helper.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Получаем ID текущего пользователя
    final MockServiceManager _serviceManager =
    MockServiceManager();
    final String currentUserId = _serviceManager.auth.currentUser?['id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        centerTitle: true,
      ),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          // ✅ Получаем список избранных сервисов для текущего пользователя
          final favoriteServices = state.favoriteItemsByUser[currentUserId]?.toList() ?? [];

          if (favoriteServices.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'В избранном пока ничего нет.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: favoriteServices.length,
            itemBuilder: (context, index) {
              final service = favoriteServices[index];

              return ServiceCard(
                service: service,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Просмотр деталей: ${service['title']}')),
                  );
                },
                onContact: () => ContactHelper.openChat(context, service), // ✅ Убран userId, так как в этом методе его нет
                isFavorite: true,
                onFavoriteToggle: () {
                  // ✅ Передаем userId в событие ToggleFavorite
                  context.read<FavoriteBloc>().add(
                    ToggleFavorite(
                      service: service,
                      userId: currentUserId,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}