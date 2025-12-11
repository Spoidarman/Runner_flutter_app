import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../endless_runner_game.dart';

class ObstacleComponent extends PositionComponent
    with HasGameRef<EndlessRunnerGame>, CollisionCallbacks {
  double speed;
  final Random random = Random();
  late Paint obstaclePaint;
  final ObstacleType type;
  final ObstacleDifficulty difficulty;

  ObstacleComponent({
    ObstacleType? obstacleType,
    this.difficulty = ObstacleDifficulty.easy,
    double? customSpeed,
  }) : type = obstacleType ?? ObstacleType.cactus,
       speed = customSpeed ?? _getSpeedForDifficulty(difficulty),
       super(size: _getSizeForType(obstacleType ?? ObstacleType.cactus));

  static double _getSpeedForDifficulty(ObstacleDifficulty difficulty) {
    switch (difficulty) {
      case ObstacleDifficulty.easy:
        return 220;
      case ObstacleDifficulty.medium:
        return 280;
      case ObstacleDifficulty.hard:
        return 350;
      case ObstacleDifficulty.extreme:
        return 420;
    }
  }

  static Vector2 _getSizeForType(ObstacleType type) {
    switch (type) {
      case ObstacleType.cactus:
        return Vector2(50, 70);
      case ObstacleType.rock:
        return Vector2(60, 50);
      case ObstacleType.log:
        return Vector2(80, 40);
      case ObstacleType.spike:
        return Vector2(45, 60);
      case ObstacleType.bird:
        return Vector2(55, 45);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final yPosition = type == ObstacleType.bird
        ? gameRef.size.y - 200
        : gameRef.size.y - 100 - size.y;

    position = Vector2(gameRef.size.x, yPosition);
    priority = 5;

    obstaclePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _getColorsForType(),
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    // Add collision hitbox
    add(RectangleHitbox(size: size * 0.7, position: size * 0.15));
  }

  List<Color> _getColorsForType() {
    switch (type) {
      case ObstacleType.cactus:
        return [Color(0xFF2E7D32), Color(0xFF1B5E20)];
      case ObstacleType.rock:
        return [Color(0xFF8D6E63), Color(0xFF5D4037)];
      case ObstacleType.log:
        return [Color(0xFF795548), Color(0xFF4E342E)];
      case ObstacleType.spike:
        return [Color(0xFF757575), Color(0xFF424242)];
      case ObstacleType.bird:
        return [Color(0xFFE91E63), Color(0xFFC2185B)];
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (type) {
      case ObstacleType.cactus:
        _drawCactus(canvas);
        break;
      case ObstacleType.rock:
        _drawRock(canvas);
        break;
      case ObstacleType.log:
        _drawLog(canvas);
        break;
      case ObstacleType.spike:
        _drawSpike(canvas);
        break;
      case ObstacleType.bird:
        _drawBird(canvas);
        break;
    }
  }

  void _drawCactus(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 10, 20, size.y - 10),
        Radius.circular(10),
      ),
      obstaclePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(5, 25, 15, 25), Radius.circular(8)),
      obstaclePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(30, 20, 15, 30),
        Radius.circular(8),
      ),
      obstaclePaint,
    );
  }

  void _drawRock(Canvas canvas) {
    final path = Path()
      ..moveTo(size.x * 0.5, 5)
      ..lineTo(size.x * 0.9, size.y * 0.4)
      ..lineTo(size.x * 0.8, size.y)
      ..lineTo(size.x * 0.2, size.y)
      ..lineTo(size.x * 0.1, size.y * 0.4)
      ..close();

    canvas.drawPath(path, obstaclePaint);
  }

  void _drawLog(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.y * 0.3, size.x, size.y * 0.4),
      Radius.circular(size.y * 0.2),
    );
    canvas.drawRRect(rect, obstaclePaint);

    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(15 + i * 25, size.y * 0.5),
        8,
        Paint()..color = Colors.brown.withOpacity(0.3),
      );
    }
  }

  void _drawSpike(Canvas canvas) {
    final path = Path()
      ..moveTo(size.x * 0.5, 0)
      ..lineTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..close();

    canvas.drawPath(path, obstaclePaint);

    canvas.drawLine(
      Offset(size.x * 0.4, 10),
      Offset(size.x * 0.45, 30),
      Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..strokeWidth = 2,
    );
  }

  void _drawBird(Canvas canvas) {
    canvas.drawOval(Rect.fromLTWH(10, 10, 35, 25), obstaclePaint);

    final wingOffset = (DateTime.now().millisecondsSinceEpoch % 500) / 500 * 10;
    canvas.drawOval(Rect.fromLTWH(5, 15 - wingOffset, 20, 10), obstaclePaint);
    canvas.drawOval(Rect.fromLTWH(30, 15 - wingOffset, 20, 10), obstaclePaint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;

    if (position.x < -size.x) {
      removeFromParent();
      gameRef.incrementScore(10);
    }
  }
}

enum ObstacleType { cactus, rock, log, spike, bird }

enum ObstacleDifficulty { easy, medium, hard, extreme }
