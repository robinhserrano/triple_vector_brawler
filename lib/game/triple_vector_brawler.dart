import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:triple_vector_brawler/game/game.dart';
import 'package:triple_vector_brawler/game/utils/swipe_classifier.dart';
import 'package:triple_vector_brawler/l10n/l10n.dart';

class TripleVectorBrawler extends FlameGame with DragCallbacks {
  TripleVectorBrawler({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required this.runCubit,
    required Images images,
  }) {
    this.images = images;
  }

  final AppLocalizations l10n;
  final AudioPlayer effectPlayer;
  final TextStyle textStyle;
  final RunCubit runCubit;

  BossComponent? bossComponent;
  HudComponent? hudComponent;
  CameraComponent? _camera;
  StreamSubscription<RunState>? _runSubscription;
  Vector2 _dragTotal = Vector2.zero();
  Vector2 _cameraHome = Vector2.zero();
  double _shakeTimeLeft = 0;
  final _random = Random();

  static const _hitStopDuration = Duration(milliseconds: 60);
  static const _shakeDuration = 0.25;
  static const _shakeMagnitude = 6.0;

  @override
  Color backgroundColor() => const Color(0xFF15182B);

  @override
  Future<void> onLoad() async {
    final boss = bossComponent = BossComponent(position: size / 2);
    final hud = hudComponent = HudComponent(position: Vector2(0, 0));

    final world = World(children: [boss]);
    final camera = _camera = CameraComponent(world: world);
    await addAll([world, camera]);
    _cameraHome = size / 2;
    camera.viewfinder.position = _cameraHome;

    camera.viewport.add(hud);
    _positionHud(size);

    _applyState(runCubit.state);
    _runSubscription = runCubit.stream.listen(_applyState);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_shakeTimeLeft <= 0) return;
    _shakeTimeLeft -= dt;
    final viewfinder = _camera?.viewfinder;
    if (viewfinder == null) return;
    if (_shakeTimeLeft <= 0) {
      viewfinder.position = _cameraHome;
      return;
    }
    viewfinder.position =
        _cameraHome +
        Vector2(
          (_random.nextDouble() - 0.5) * _shakeMagnitude,
          (_random.nextDouble() - 0.5) * _shakeMagnitude,
        );
  }

  void _applyState(RunState state) {
    bossComponent?.updateForState(state);
    hudComponent?.updateForState(state);
    switch (state.lastResult) {
      case ParryResult.hit:
        _triggerHitStop();
      case ParryResult.miss || ParryResult.timeout:
        _shakeTimeLeft = _shakeDuration;
      case null:
        break;
    }
  }

  void _triggerHitStop() {
    pauseEngine();
    Future.delayed(_hitStopDuration, resumeEngine);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _positionHud(size);
  }

  void _positionHud(Vector2 size) {
    hudComponent?.position = Vector2(10, size.y - 10);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragTotal = Vector2.zero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _dragTotal += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final direction = classifySwipe(_dragTotal);
    if (direction != null) runCubit.parry(direction);
  }

  @override
  void onRemove() {
    unawaited(_runSubscription?.cancel());
    super.onRemove();
  }
}
