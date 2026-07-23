import 'package:flame/game.dart';
import 'package:triple_vector_brawler/game/models/models.dart';

/// Classifies a total drag delta into one of the three parry directions.
/// Returns null when the swipe is too short to be intentional.
Direction? classifySwipe(Vector2 delta, {double minDistance = 24}) {
  if (delta.length < minDistance) return null;
  if (delta.y > delta.x.abs()) return Direction.overhead;
  return delta.x < 0 ? Direction.left : Direction.right;
}
