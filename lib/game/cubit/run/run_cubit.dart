import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triple_vector_brawler/game/data/boss_roster.dart';
import 'package:triple_vector_brawler/game/models/models.dart';

part 'run_state.dart';

/// Owns the parry-duel timing loop. Pure Dart so it's testable without
/// pumping Flame's game loop: telegraph -> impact window -> resolve.
class RunCubit extends Cubit<RunState> {
  RunCubit({List<BossConfig> roster = bossRoster, Random? random})
    : _roster = roster,
      _random = random ?? Random(),
      super(RunState.initial(roster)) {
    _scheduleAttack();
  }

  final List<BossConfig> _roster;
  final Random _random;
  Timer? _impactTimer;
  Timer? _nextAttackTimer;

  static const _resolvedPause = Duration(milliseconds: 400);

  BossConfig get _currentBoss => _roster[state.bossIndex];

  void _scheduleAttack() {
    final pattern = _currentBoss.pattern;
    final direction = pattern[_random.nextInt(pattern.length)];
    emit(
      state.copyWith(
        phase: RunPhase.telegraph,
        direction: direction,
        clearLastResult: true,
      ),
    );
    _impactTimer = Timer(
      _currentBoss.telegraphDuration,
      () => _resolve(ParryResult.timeout),
    );
  }

  /// Called by the input layer when the player swipes a direction.
  void parry(Direction attempted) {
    if (state.outcome != null || state.phase != RunPhase.telegraph) return;
    _resolve(
      attempted == state.direction ? ParryResult.hit : ParryResult.miss,
    );
  }

  void _resolve(ParryResult result) {
    _impactTimer?.cancel();
    if (result == ParryResult.hit) {
      _onHit();
    } else {
      _onMiss(result);
    }
  }

  void _onHit() {
    final remainingHealth = state.bossHealth - 1;
    if (remainingHealth > 0) {
      emit(
        state.copyWith(
          phase: RunPhase.resolved,
          bossHealth: remainingHealth,
          lastResult: ParryResult.hit,
        ),
      );
      _scheduleNext();
      return;
    }

    final nextBossIndex = state.bossIndex + 1;
    if (nextBossIndex >= _roster.length) {
      emit(
        state.copyWith(
          phase: RunPhase.resolved,
          bossHealth: 0,
          lastResult: ParryResult.hit,
          outcome: RunOutcome.victory,
        ),
      );
      return;
    }

    final nextBoss = _roster[nextBossIndex];
    emit(
      state.copyWith(
        phase: RunPhase.resolved,
        bossIndex: nextBossIndex,
        bossName: nextBoss.name,
        bossHealth: nextBoss.health,
        bossMaxHealth: nextBoss.health,
        lastResult: ParryResult.hit,
      ),
    );
    _scheduleNext();
  }

  void _onMiss(ParryResult result) {
    final remainingArmor = state.armor - 1;
    if (remainingArmor <= 0) {
      emit(
        state.copyWith(
          phase: RunPhase.resolved,
          armor: 0,
          lastResult: result,
          outcome: RunOutcome.defeat,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        phase: RunPhase.resolved,
        armor: remainingArmor,
        lastResult: result,
      ),
    );
    _scheduleNext();
  }

  void _scheduleNext() {
    _nextAttackTimer = Timer(_resolvedPause, () {
      if (!isClosed) _scheduleAttack();
    });
  }

  void reset() {
    _impactTimer?.cancel();
    _nextAttackTimer?.cancel();
    emit(RunState.initial(_roster));
    _scheduleAttack();
  }

  @override
  Future<void> close() {
    _impactTimer?.cancel();
    _nextAttackTimer?.cancel();
    return super.close();
  }
}
