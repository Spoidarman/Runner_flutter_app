import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../endless_runner_game.dart';

class GroundComponent extends PositionComponent
    with HasGameRef<EndlessRunnerGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(gameRef.size.x, 100);
    position = Vector2(0, gameRef.size.y - 100);
    priority = -50;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Grass layer
    final grassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
      ).createShader(Rect.fromLTWH(0, 0, size.x, 30));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 30), grassPaint);

    // Dirt layer
    final dirtPaint = Paint()..color = Color(0xFF8D6E63);
    canvas.drawRect(Rect.fromLTWH(0, 30, size.x, 70), dirtPaint);

    // Grass blades
    final bladePaint = Paint()
      ..color = Color(0xFF66BB6A)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.x; x += 15) {
      canvas.drawLine(Offset(x, 28), Offset(x + 3, 15), bladePaint);
    }
  }
}
