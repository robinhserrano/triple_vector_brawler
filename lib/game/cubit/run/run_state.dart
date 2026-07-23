part of 'run_cubit.dart';

enum RunPhase { telegraph, resolved }

enum ParryResult { hit, miss, timeout }

enum RunOutcome { victory, defeat }

class RunState extends Equatable {
  const RunState({
    required this.phase,
    required this.direction,
    required this.bossIndex,
    required this.bossName,
    required this.bossHealth,
    required this.bossMaxHealth,
    required this.armor,
    this.lastResult,
    this.outcome,
  });

  factory RunState.initial(List<BossConfig> roster) {
    final boss = roster.first;
    return RunState(
      phase: RunPhase.telegraph,
      direction: boss.pattern.first,
      bossIndex: 0,
      bossName: boss.name,
      bossHealth: boss.health,
      bossMaxHealth: boss.health,
      armor: 3,
    );
  }

  final RunPhase phase;
  final Direction direction;
  final int bossIndex;
  final String bossName;
  final int bossHealth;
  final int bossMaxHealth;
  final int armor;
  final ParryResult? lastResult;
  final RunOutcome? outcome;

  RunState copyWith({
    RunPhase? phase,
    Direction? direction,
    int? bossIndex,
    String? bossName,
    int? bossHealth,
    int? bossMaxHealth,
    int? armor,
    ParryResult? lastResult,
    bool clearLastResult = false,
    RunOutcome? outcome,
  }) {
    return RunState(
      phase: phase ?? this.phase,
      direction: direction ?? this.direction,
      bossIndex: bossIndex ?? this.bossIndex,
      bossName: bossName ?? this.bossName,
      bossHealth: bossHealth ?? this.bossHealth,
      bossMaxHealth: bossMaxHealth ?? this.bossMaxHealth,
      armor: armor ?? this.armor,
      lastResult: clearLastResult ? null : (lastResult ?? this.lastResult),
      outcome: outcome ?? this.outcome,
    );
  }

  @override
  List<Object?> get props => [
    phase,
    direction,
    bossIndex,
    bossName,
    bossHealth,
    bossMaxHealth,
    armor,
    lastResult,
    outcome,
  ];
}
