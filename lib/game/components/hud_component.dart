import 'package:flame/components.dart';
import 'package:triple_vector_brawler/game/game.dart';

class HudComponent extends PositionComponent
    with HasGameReference<TripleVectorBrawler> {
  HudComponent({required super.position}) : super(anchor: Anchor.bottomLeft);

  late final TextComponent _text;

  @override
  Future<void> onLoad() async {
    await add(
      _text = TextComponent(
        anchor: Anchor.bottomLeft,
        textRenderer: TextPaint(style: game.textStyle.copyWith(fontSize: 16)),
      ),
    );
  }

  void updateForState(RunState state) {
    _text.text =
        '${state.bossName} (${state.bossIndex + 1}/5)  '
        'HP ${state.bossHealth}/${state.bossMaxHealth}  '
        'Armor ${state.armor}';
  }
}
