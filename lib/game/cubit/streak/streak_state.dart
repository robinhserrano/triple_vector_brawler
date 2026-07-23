part of 'streak_cubit.dart';

class StreakState extends Equatable {
  const StreakState({required this.current, required this.best});

  final int current;
  final int best;

  StreakState copyWith({int? current, int? best}) {
    return StreakState(
      current: current ?? this.current,
      best: best ?? this.best,
    );
  }

  @override
  List<Object?> get props => [current, best];
}
