import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:triple_vector_brawler/game/game.dart';

/// A placeholder boss visual: a rectangle that flashes by incoming
/// direction and by parry result. Swap for sprite animations later.
///
/// Direction is shown by both color and glyph so it doesn't rely on color
/// vision alone.
class BossComponent extends PositionComponent {
  BossComponent({required super.position})
    : super(anchor: Anchor.center, size: Vector2.all(64));

  final _rect = RectangleComponent(
    size: Vector2.all(64),
    anchor: Anchor.center,
    position: Vector2.all(32),
    paint: Paint()..color = _colorFor(Direction.overhead),
  );

  final TextComponent _glyph = TextComponent(
    anchor: Anchor.center,
    position: Vector2.all(32),
    textRenderer: TextPaint(
      style: const TextStyle(color: Colors.white, fontSize: 28),
    ),
  );

  @override
  Future<void> onLoad() async {
    await addAll([_rect, _glyph]);
  }

  void updateForState(RunState state) {
    final result = state.lastResult;
    _rect.paint.color = switch (result) {
      ParryResult.hit => Colors.greenAccent,
      ParryResult.miss || ParryResult.timeout => Colors.redAccent,
      null => _colorFor(state.direction),
    };
    _glyph.text = switch (result) {
      ParryResult.hit => '✓',
      ParryResult.miss || ParryResult.timeout => '✗',
      null => _glyphFor(state.direction),
    };
  }

  static Color _colorFor(Direction direction) => switch (direction) {
    Direction.left => Colors.blueAccent,
    Direction.right => Colors.orangeAccent,
    Direction.overhead => Colors.purpleAccent,
  };

  static String _glyphFor(Direction direction) => switch (direction) {
    Direction.left => '←',
    Direction.right => '→',
    Direction.overhead => '↓',
  };
}
