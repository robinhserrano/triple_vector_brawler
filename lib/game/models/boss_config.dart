import 'package:equatable/equatable.dart';
import 'package:triple_vector_brawler/game/models/direction.dart';

class BossConfig extends Equatable {
  const BossConfig({
    required this.name,
    required this.health,
    required this.telegraphDuration,
    required this.pattern,
  });

  final String name;
  final int health;
  final Duration telegraphDuration;
  final List<Direction> pattern;

  @override
  List<Object?> get props => [name, health, telegraphDuration, pattern];
}
