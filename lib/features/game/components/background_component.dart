import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../endless_runner_game.dart';

class ParallaxBackgroundComponent extends Component
    with HasGameRef<EndlessRunnerGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add sky gradient
    add(SkyGradient());

    // Add mountain layer
    add(MountainLayer());

    // Add multiple cloud layers for parallax effect
    add(CloudLayer(speed: 20, yPosition: 50, count: 3));
    add(CloudLayer(speed: 35, yPosition: 120, count: 4));
    add(CloudLayer(speed: 50, yPosition: 180, count: 5));
  }
}

class SkyGradient extends PositionComponent with HasGameRef<EndlessRunnerGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = gameRef.size;
    position = Vector2.zero();
    priority = -100;
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF87CEEB), Color(0xFFB0E0E6), Color(0xFFE0F6FF)],
    );

    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }
}

class CloudLayer extends PositionComponent with HasGameRef<EndlessRunnerGame> {
  final double speed;
  final double yPosition;
  final int count;
  List<Vector2> cloudPositions = [];

  CloudLayer({
    required this.speed,
    required this.yPosition,
    required this.count,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = gameRef.size;
    position = Vector2.zero();
    priority = -90;

    cloudPositions = List.generate(
      count,
      (index) => Vector2((gameRef.size.x / count) * index, yPosition),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (int i = 0; i < cloudPositions.length; i++) {
      cloudPositions[i].x -= speed * dt;

      if (cloudPositions[i].x < -100) {
        cloudPositions[i].x = gameRef.size.x + 50;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    for (final pos in cloudPositions) {
      _drawCloud(canvas, pos, cloudPaint);
    }
  }

  void _drawCloud(Canvas canvas, Vector2 position, Paint paint) {
    canvas.drawCircle(Offset(position.x, position.y), 20, paint);
    canvas.drawCircle(Offset(position.x + 25, position.y), 25, paint);
    canvas.drawCircle(Offset(position.x + 50, position.y), 20, paint);
    canvas.drawCircle(Offset(position.x + 25, position.y - 15), 22, paint);
  }
}

class MountainLayer extends PositionComponent
    with HasGameRef<EndlessRunnerGame> {
  List<Vector2> mountainPositions = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = gameRef.size;
    position = Vector2.zero();
    priority = -80;

    mountainPositions = [
      Vector2(0, gameRef.size.y - 200),
      Vector2(200, gameRef.size.y - 250),
      Vector2(450, gameRef.size.y - 220),
      Vector2(700, gameRef.size.y - 240),
    ];
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (int i = 0; i < mountainPositions.length; i++) {
      mountainPositions[i].x -= 15 * dt;

      if (mountainPositions[i].x < -300) {
        mountainPositions[i].x = gameRef.size.x + 100;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final mountainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4A5568), Color(0xFF2D3748)],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    for (final pos in mountainPositions) {
      _drawMountain(canvas, pos, mountainPaint);
    }
  }

  void _drawMountain(Canvas canvas, Vector2 position, Paint paint) {
    final path = Path()
      ..moveTo(position.x, gameRef.size.y - 100)
      ..lineTo(position.x + 100, position.y - 80)
      ..lineTo(position.x + 200, gameRef.size.y - 100)
      ..close();

    canvas.drawPath(path, paint);

    // Snow cap
    final snowPaint = Paint()..color = Colors.white.withOpacity(0.8);
    final snowPath = Path()
      ..moveTo(position.x + 80, position.y - 60)
      ..lineTo(position.x + 100, position.y - 80)
      ..lineTo(position.x + 120, position.y - 60)
      ..close();

    canvas.drawPath(snowPath, snowPaint);
  }
}
