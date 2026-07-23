import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triple_vector_brawler/game/cubit/cubit.dart';
import 'package:triple_vector_brawler/game/models/models.dart';

void main() {
  group('RunCubit', () {
    const telegraph = Duration(milliseconds: 100);
    const resolvedPause = Duration(milliseconds: 400);
    final soleBoss = [
      const BossConfig(
        name: 'Testjaw',
        health: 2,
        telegraphDuration: telegraph,
        pattern: [Direction.left],
      ),
    ];
    final twoBosses = [
      soleBoss.single,
      const BossConfig(
        name: 'Testframe',
        health: 1,
        telegraphDuration: telegraph,
        pattern: [Direction.left],
      ),
    ];

    test('starts in telegraph phase for the first boss', () {
      final cubit = RunCubit(roster: soleBoss);
      addTearDown(cubit.close);

      expect(cubit.state.phase, RunPhase.telegraph);
      expect(cubit.state.bossIndex, 0);
      expect(cubit.state.bossHealth, 2);
      expect(cubit.state.armor, 3);
      expect(cubit.state.outcome, isNull);
    });

    test('a correctly-timed parry damages the boss', () {
      fakeAsync((async) {
        final cubit = RunCubit(roster: soleBoss);
        addTearDown(cubit.close);

        cubit.parry(Direction.left);

        expect(cubit.state.phase, RunPhase.resolved);
        expect(cubit.state.lastResult, ParryResult.hit);
        expect(cubit.state.bossHealth, 1);

        async.elapse(resolvedPause);
        expect(cubit.state.phase, RunPhase.telegraph);
      });
    });

    test('a wrong-direction parry costs armor', () {
      fakeAsync((async) {
        final cubit = RunCubit(roster: soleBoss);
        addTearDown(cubit.close);

        cubit.parry(Direction.right);

        expect(cubit.state.lastResult, ParryResult.miss);
        expect(cubit.state.armor, 2);
        async.elapse(const Duration(milliseconds: 500));
      });
    });

    test('missing the impact window times out as a miss', () {
      fakeAsync((async) {
        final cubit = RunCubit(roster: soleBoss);
        addTearDown(cubit.close);

        async.elapse(telegraph);

        expect(cubit.state.lastResult, ParryResult.timeout);
        expect(cubit.state.armor, 2);
        async.elapse(const Duration(milliseconds: 500));
      });
    });

    test('defeating the last boss ends the run in victory', () {
      fakeAsync((async) {
        final cubit = RunCubit(roster: soleBoss);
        addTearDown(cubit.close);

        cubit.parry(Direction.left);
        async.elapse(resolvedPause);
        cubit.parry(Direction.left);

        expect(cubit.state.outcome, RunOutcome.victory);
        expect(cubit.state.bossHealth, 0);
      });
    });

    test('defeating a boss advances to the next one', () {
      fakeAsync((async) {
        final cubit = RunCubit(roster: twoBosses);
        addTearDown(cubit.close);

        cubit.parry(Direction.left);
        async.elapse(resolvedPause);
        cubit.parry(Direction.left);

        expect(cubit.state.bossIndex, 1);
        expect(cubit.state.bossHealth, 1);
        expect(cubit.state.outcome, isNull);
        async.elapse(const Duration(milliseconds: 500));
      });
    });

    test('running out of armor ends the run in defeat', () {
      fakeAsync((async) {
        final cubit = RunCubit(roster: soleBoss);
        addTearDown(cubit.close);

        cubit.parry(Direction.right);
        async.elapse(resolvedPause);
        cubit.parry(Direction.right);
        async.elapse(resolvedPause);
        cubit.parry(Direction.right);

        expect(cubit.state.outcome, RunOutcome.defeat);
        expect(cubit.state.armor, 0);
      });
    });

    test('ignores parries once the run has ended', () {
      fakeAsync((async) {
        final cubit = RunCubit(roster: soleBoss);
        addTearDown(cubit.close);

        cubit.parry(Direction.left);
        async.elapse(resolvedPause);
        cubit.parry(Direction.left);
        final stateAfterVictory = cubit.state;

        cubit.parry(Direction.left);

        expect(cubit.state, stateAfterVictory);
      });
    });

    test('reset restores the initial state and resumes the loop', () {
      fakeAsync((async) {
        final cubit = RunCubit(roster: soleBoss);
        addTearDown(cubit.close);

        cubit
          ..parry(Direction.right)
          ..reset();

        expect(cubit.state.armor, 3);
        expect(cubit.state.bossHealth, 2);
        expect(cubit.state.phase, RunPhase.telegraph);
        expect(cubit.state.outcome, isNull);
        async.elapse(const Duration(milliseconds: 500));
      });
    });
  });
}
