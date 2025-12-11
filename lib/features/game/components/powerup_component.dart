import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../endless_runner_game.dart';
import '../bloc/game_cubit.dart';

class PowerUpComponent extends PositionComponent
    with HasGameRef<EndlessRunnerGame>, CollisionCallbacks {
  final PowerUpType type;
  static const double speed = 200;
  late Paint powerUpPaint;
  double rotationAngle = 0;

  PowerUpComponent({required this.type}) : super(size: Vector2(40, 40));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(
      gameRef.size.x,
      gameRef.size.y - 180 - Random().nextDouble() * 100,
    );

    add(RectangleHitbox());
  }

  Color _getColorForType() {
    switch (type) {
      case PowerUpType.shield:
        return Color(0xFF00BCD4);
      case PowerUpType.magnet:
        return Color(0xFFFFD700);
      case PowerUpType.doubleScore:
        return Color(0xFFFF6584);
      case PowerUpType.slowMotion:
        return Color(0xFF9C27B0);
    }
  }

  IconData _getIconForType() {
    switch (type) {
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.magnet:
        return Icons.attractions;
      case PowerUpType.doubleScore:
        return Icons.star;
      case PowerUpType.slowMotion:
        return Icons.av_timer;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;
    rotationAngle += dt * 2;

    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(rotationAngle);

    // Outer glow
    final glowPaint = Paint()
      ..color = _getColorForType().withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset.zero, 25, glowPaint);

    // Main circle
    final mainPaint = Paint()
      ..shader = RadialGradient(
        colors: [_getColorForType(), _getColorForType().withOpacity(0.6)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 20));
    canvas.drawCircle(Offset.zero, 20, mainPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset.zero, 20, borderPaint);

    canvas.restore();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other.parent?.parent is EndlessRunnerGame) {
      gameRef.collectPowerUp(type);
      removeFromParent();
    }
  }
}
