import 'package:equatable/equatable.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}

class ToggleFavorite extends FavoriteEvent {
  final Map<String, dynamic> service; // 👈 сохраняем целый объект
  final String userId;
  const ToggleFavorite({
    required this.service,
    required this.userId,
  });

  @override
  List<Object> get props => [service, userId];
}
