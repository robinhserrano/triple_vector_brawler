import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/game.dart' hide Route;
import 'package:flame_audio/bgm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triple_vector_brawler/game/game.dart';
import 'package:triple_vector_brawler/gen/assets.gen.dart';
import 'package:triple_vector_brawler/l10n/l10n.dart';
import 'package:triple_vector_brawler/loading/cubit/cubit.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const GamePage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final audioCache = context.read<PreloadCubit>().audio;
        return AudioCubit(
          audioPlayer: AudioPlayer()..audioCache = audioCache,
          backgroundMusic: Bgm(audioCache: audioCache),
        );
      },
      child: const Scaffold(body: SafeArea(child: GameView())),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key, this.game});

  final FlameGame? game;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  FlameGame? _game;

  late final Bgm bgm;
  late final RunCubit runCubit;
  late final StreakCubit streakCubit;

  @override
  void initState() {
    super.initState();
    bgm = context.read<AudioCubit>().bgm;
    unawaited(bgm.play(Assets.audio.background));
    runCubit = RunCubit();
    streakCubit = StreakCubit(preferences: SharedPreferencesAsync());
  }

  @override
  void dispose() {
    unawaited(bgm.pause());
    unawaited(runCubit.close());
    unawaited(streakCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.bodySmall!.copyWith(color: Colors.white, fontSize: 4);

    _game ??=
        widget.game ??
        TripleVectorBrawler(
          l10n: context.l10n,
          effectPlayer: context.read<AudioCubit>().effectPlayer,
          textStyle: textStyle,
          runCubit: runCubit,
          images: context.read<PreloadCubit>().images,
        );
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: runCubit),
        BlocProvider.value(value: streakCubit),
      ],
      child: BlocListener<RunCubit, RunState>(
        listenWhen: (previous, current) =>
            previous.outcome == null && current.outcome != null,
        listener: (context, state) => streakCubit.recordRun(state.outcome!),
        child: Stack(
          children: [
            Positioned.fill(child: GameWidget(game: _game!)),
            Align(
              alignment: Alignment.topRight,
              child: BlocBuilder<AudioCubit, AudioState>(
                builder: (context, state) {
                  return IconButton(
                    icon: Icon(
                      state.volume == 0 ? Icons.volume_off : Icons.volume_up,
                    ),
                    onPressed: () => context.read<AudioCubit>().toggleVolume(),
                  );
                },
              ),
            ),
            const Positioned.fill(child: ResultOverlay()),
          ],
        ),
      ),
    );
  }
}
