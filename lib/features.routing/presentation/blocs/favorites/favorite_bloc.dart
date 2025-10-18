import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(const FavoriteState()) {
    on<ToggleFavorite>((event, emit) {
      final userId = event.userId;
      final service = event.service;

      // Получаем или создаем набор избранного для этого пользователя
      final currentFavorites = state.favoriteItemsByUser[userId]?.toSet() ?? {};

      // Проверяем наличие элемента
      final exists = currentFavorites.any((item) => item['id'] == service['id']);

      if (exists) {
        currentFavorites.removeWhere((item) => item['id'] == service['id']);
      } else {
        currentFavorites.add(service);
      }

      // Создаем новую карту для нового состояния
      final newFavoriteItemsByUser = Map<String, Set<Map<String, dynamic>>>.from(state.favoriteItemsByUser);
      newFavoriteItemsByUser[userId] = currentFavorites;

      emit(state.copyWith(favoriteItemsByUser: newFavoriteItemsByUser));
    });
  }
}