import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:triple_vector_brawler/game/cubit/cubit.dart';

void main() {
  group('StreakCubit', () {
    test('loads a persisted best streak', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
            'best_deathless_streak': 4,
          });

      final cubit = StreakCubit(preferences: SharedPreferencesAsync());
      addTearDown(cubit.close);
      await pumpEventQueue();

      expect(cubit.state.best, 4);
    });

    test('a victory increments the current streak', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final cubit = StreakCubit(preferences: SharedPreferencesAsync());
      addTearDown(cubit.close);
      await pumpEventQueue();

      await cubit.recordRun(RunOutcome.victory);

      expect(cubit.state.current, 1);
      expect(cubit.state.best, 1);
    });

    test('a defeat resets the current streak but keeps the best', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final cubit = StreakCubit(preferences: SharedPreferencesAsync());
      addTearDown(cubit.close);
      await pumpEventQueue();

      await cubit.recordRun(RunOutcome.victory);
      await cubit.recordRun(RunOutcome.defeat);

      expect(cubit.state.current, 0);
      expect(cubit.state.best, 1);
    });

    test('persists a new best streak', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final cubit = StreakCubit(preferences: SharedPreferencesAsync());
      addTearDown(cubit.close);
      await pumpEventQueue();

      await cubit.recordRun(RunOutcome.victory);

      final persisted = await SharedPreferencesAsync().getInt(
        'best_deathless_streak',
      );
      expect(persisted, 1);
    });
  });
}
