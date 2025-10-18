import 'package:equatable/equatable.dart';

class FavoriteState extends Equatable {
  final Map<String, Set<Map<String, dynamic>>> favoriteItemsByUser;

  const FavoriteState({this.favoriteItemsByUser = const {}});

  @override
  List<Object> get props => [favoriteItemsByUser];

  FavoriteState copyWith({Map<String, Set<Map<String, dynamic>>>? favoriteItemsByUser}) {
    return FavoriteState(
      favoriteItemsByUser: favoriteItemsByUser ?? this.favoriteItemsByUser,
    );
  }
}