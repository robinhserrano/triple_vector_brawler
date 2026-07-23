import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triple_vector_brawler/game/game.dart';

/// Full-screen win/lose overlay shown when a [RunCubit] run ends.
class ResultOverlay extends StatelessWidget {
  const ResultOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RunCubit, RunState>(
      buildWhen: (previous, current) => previous.outcome != current.outcome,
      builder: (context, state) {
        final outcome = state.outcome;
        if (outcome == null) return const SizedBox.shrink();

        return ColoredBox(
          color: Colors.black.withValues(alpha: 0.75),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  outcome == RunOutcome.victory ? 'VICTORY' : 'DEFEATED',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<StreakCubit, StreakState>(
                  builder: (context, streak) => Text(
                    'Deathless streak: ${streak.current}  '
                    '(best ${streak.best})',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.read<RunCubit>().reset(),
                  child: const Text('Retry ladder'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
