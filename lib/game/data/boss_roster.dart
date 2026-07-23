import 'package:triple_vector_brawler/game/models/models.dart';

/// The 5-boss ladder for a single run. Telegraph duration shrinks per boss
/// to raise difficulty; ponytail: hardcoded list, add data-driven loading
/// only if a designer needs to tweak this without a rebuild.
const bossRoster = <BossConfig>[
  BossConfig(
    name: 'Rustjaw',
    health: 4,
    telegraphDuration: Duration(milliseconds: 1200),
    pattern: Direction.values,
  ),
  BossConfig(
    name: 'Voltframe',
    health: 5,
    telegraphDuration: Duration(milliseconds: 1000),
    pattern: Direction.values,
  ),
  BossConfig(
    name: 'Gravemaw',
    health: 6,
    telegraphDuration: Duration(milliseconds: 850),
    pattern: Direction.values,
  ),
  BossConfig(
    name: 'Skyshear',
    health: 7,
    telegraphDuration: Duration(milliseconds: 700),
    pattern: Direction.values,
  ),
  BossConfig(
    name: 'Nullcrown',
    health: 8,
    telegraphDuration: Duration(milliseconds: 550),
    pattern: Direction.values,
  ),
];
