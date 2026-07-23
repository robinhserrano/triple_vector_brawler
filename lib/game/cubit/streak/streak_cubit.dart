import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triple_vector_brawler/game/cubit/run/run_cubit.dart';

part 'streak_state.dart';

/// Tracks consecutive full-ladder clears. Resets to 0 on any defeat;
/// the best streak persists across app restarts.
class StreakCubit extends Cubit<StreakState> {
  StreakCubit({required this._preferences})
    : super(const StreakState(current: 0, best: 0)) {
    unawaited(_load());
  }

  static const _bestKey = 'best_deathless_streak';

  final SharedPreferencesAsync _preferences;

  Future<void> _load() async {
    final best = await _preferences.getInt(_bestKey) ?? 0;
    if (!isClosed) emit(state.copyWith(best: best));
  }

  Future<void> recordRun(RunOutcome outcome) async {
    final previousBest = state.best;
    final current = outcome == RunOutcome.victory ? state.current + 1 : 0;
    final best = current > previousBest ? current : previousBest;
    emit(StreakState(current: current, best: best));
    if (best > previousBest) {
      await _preferences.setInt(_bestKey, best);
    }
  }
}
