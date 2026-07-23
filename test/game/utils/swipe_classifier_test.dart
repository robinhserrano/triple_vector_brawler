import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triple_vector_brawler/game/models/models.dart';
import 'package:triple_vector_brawler/game/utils/swipe_classifier.dart';

void main() {
  group('classifySwipe', () {
    test('too-short drags are ignored', () {
      expect(classifySwipe(Vector2(5, 0)), isNull);
    });

    test('a leftward swipe classifies as Direction.left', () {
      expect(classifySwipe(Vector2(-40, 0)), Direction.left);
    });

    test('a rightward swipe classifies as Direction.right', () {
      expect(classifySwipe(Vector2(40, 0)), Direction.right);
    });

    test('a downward swipe classifies as Direction.overhead', () {
      expect(classifySwipe(Vector2(0, 40)), Direction.overhead);
    });

    test('a diagonal swipe favors the dominant axis', () {
      expect(classifySwipe(Vector2(-10, 40)), Direction.overhead);
      expect(classifySwipe(Vector2(-40, 10)), Direction.left);
    });
  });
}
