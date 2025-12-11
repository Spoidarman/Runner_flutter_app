import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../endless_runner_game.dart';
import 'player_component.dart';

class CoinComponent extends PositionComponent
    with HasGameRef<EndlessRunnerGame>, CollisionCallbacks {
  static const double speed = 200;
  final CoinType coinType;
  double rotationAngle = 0;
  late int value;

  CoinComponent({this.coinType = CoinType.bronze})
    : super(size: Vector2(30, 30));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    value = coinType == CoinType.bronze
        ? 1
        : coinType == CoinType.silver
        ? 5
        : 10;

    position = Vector2(
      gameRef.size.x,
      gameRef.size.y - 150 - Random().nextDouble() * 80,
    );

    priority = 5;
    add(CircleHitbox());
  }

  Color _getCoinColor() {
    switch (coinType) {
      case CoinType.bronze:
        return Color(0xFFFFD700);
      case CoinType.silver:
        return Color(0xFFC0C0C0);
      case CoinType.gold:
        return Color(0xFFFFAA00);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;
    rotationAngle += dt * 4;

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

    final shinePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          _getCoinColor(),
          _getCoinColor().withOpacity(0.8),
        ],
        stops: [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 15));

    canvas.drawCircle(Offset.zero, 15, shinePaint);

    final borderPaint = Paint()
      ..color = _getCoinColor().withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset.zero, 15, borderPaint);

    canvas.restore();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      gameRef.collectCoin(value);
      removeFromParent();
    }
  }
}

enum CoinType { bronze, silver, gold }
