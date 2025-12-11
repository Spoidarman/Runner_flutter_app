import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:runner/features/game/bloc/game_cubit.dart';
import 'package:runner/features/game/components/coin_component.dart';
import 'package:runner/features/game/components/powerup_component.dart';
import '../endless_runner_game.dart';
import 'obstacle_component.dart';

class PlayerComponent extends SpriteAnimationComponent
    with HasGameRef<EndlessRunnerGame>, CollisionCallbacks {
  static const double gravity = 1800;
  static const double maxJumpSpeed = -650;
  static const double minJumpSpeed = -400;
  static const double groundLevel = 100;

  double velocityY = 0;
  bool isJumping = false;
  bool isPressingJump = false;
  bool hasShield = false;
  bool hasMagnet = false;
  bool isInvulnerable = false;
  double jumpPressTime = 0;
  static const double maxJumpPressTime = 0.3; // 300ms for full jump

  late SpriteAnimation runAnimation;
  late SpriteAnimation jumpAnimation;

  PlayerComponent() : super(size: Vector2(60, 80));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    priority = 10;

    runAnimation = await _createRunAnimation();
    jumpAnimation = await _createJumpAnimation();

    animation = runAnimation;
    position = Vector2(100, gameRef.size.y - groundLevel - size.y);

    add(RectangleHitbox(size: size * 0.6, position: size * 0.2));

    print('Player loaded at: $position with size: $size');
  }

  Future<SpriteAnimation> _createRunAnimation() async {
    final spriteFutures = List.generate(4, (index) async {
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF5A52D5), Color(0xFF483DC4)],
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(10, 10, 40, 50),
          Radius.circular(8),
        ),
        paint,
      );

      canvas.drawCircle(Offset(30, 15), 12, Paint()..color = Color(0xFFFFD700));

      final legOffset = (index % 2 == 0) ? 5.0 : -5.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(15 + legOffset, 55, 10, 20),
          Radius.circular(4),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(35 - legOffset, 55, 10, 20),
          Radius.circular(4),
        ),
        paint,
      );

      final picture = recorder.endRecording();
      final image = await picture.toImage(size.x.toInt(), size.y.toInt());
      return Sprite(image);
    });

    final sprites = await Future.wait(spriteFutures);
    return SpriteAnimation.spriteList(sprites, stepTime: 0.1);
  }

  Future<SpriteAnimation> _createJumpAnimation() async {
    final spriteFutures = List.generate(2, (index) async {
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6584), Color(0xFFFF4567)],
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.save();
      canvas.translate(30, 30);
      canvas.rotate(-0.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-20, -20, 40, 50),
          Radius.circular(8),
        ),
        paint,
      );
      canvas.restore();

      canvas.drawCircle(Offset(30, 15), 12, Paint()..color = Color(0xFFFFD700));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(18, 50, 10, 18),
          Radius.circular(4),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(32, 50, 10, 18),
          Radius.circular(4),
        ),
        paint,
      );

      final picture = recorder.endRecording();
      final image = await picture.toImage(size.x.toInt(), size.y.toInt());
      return Sprite(image);
    });

    final sprites = await Future.wait(spriteFutures);
    return SpriteAnimation.spriteList(sprites, stepTime: 0.15);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Flash red when invulnerable
    if (isInvulnerable && (DateTime.now().millisecondsSinceEpoch % 200) < 100) {
      final flashPaint = Paint()
        ..color = Colors.red.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), flashPaint);
    }

    if (hasShield) {
      final shieldPaint = Paint()
        ..color = Color(0xFF00BCD4).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 2 + 10,
        shieldPaint,
      );

      // Shield particles
      final particlePaint = Paint()..color = Color(0xFF00BCD4).withOpacity(0.6);
      for (int i = 0; i < 8; i++) {
        final angle =
            (i * 3.14159 * 2 / 8) +
            (DateTime.now().millisecondsSinceEpoch / 1000);
        final x = size.x / 2 + (size.x / 2 + 15) * cos(angle);
        final y = size.y / 2 + (size.y / 2 + 15) * sin(angle);
        canvas.drawCircle(Offset(x, y), 3, particlePaint);
      }
    }

    if (hasMagnet) {
      final magnetPaint = Paint()
        ..color = Color(0xFFFFD700).withOpacity(0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x, magnetPaint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Variable jump mechanics
    if (isPressingJump && isJumping && velocityY < 0) {
      jumpPressTime += dt;
      // Continue applying upward force while button held (up to max time)
      if (jumpPressTime < maxJumpPressTime) {
        velocityY = maxJumpSpeed;
      }
    }

    // Apply gravity
    velocityY += gravity * dt;
    position.y += velocityY * dt;

    // Ground collision
    if (position.y >= gameRef.size.y - groundLevel - size.y) {
      position.y = gameRef.size.y - groundLevel - size.y;
      velocityY = 0;
      if (isJumping) {
        isJumping = false;
        animation = runAnimation;
      }
    }
  }

  void startJump() {
    if (!isJumping) {
      velocityY = maxJumpSpeed;
      isJumping = true;
      isPressingJump = true;
      jumpPressTime = 0;
      animation = jumpAnimation;
      print('Player started jump!');
    }
  }

  void endJump() {
    isPressingJump = false;
    // If jump time is very short, reduce the jump height
    if (jumpPressTime < 0.1 && velocityY < 0) {
      velocityY = minJumpSpeed; // Short hop
      print('Short jump!');
    }
  }

  void activateShield() {
    hasShield = true;
    print('Shield activated!');
  }

  void deactivateShield() {
    hasShield = false;
    print('Shield deactivated!');
  }

  void activateMagnet() {
    hasMagnet = true;
    print('Magnet activated!');
  }

  void deactivateMagnet() {
    hasMagnet = false;
    print('Magnet deactivated!');
  }

  void reset() {
    position = Vector2(100, gameRef.size.y - groundLevel - size.y);
    velocityY = 0;
    isJumping = false;
    isPressingJump = false;
    jumpPressTime = 0;
    hasShield = false;
    hasMagnet = false;
    isInvulnerable = false;
    animation = runAnimation;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // Handle coin collection
    if (other is CoinComponent) {
      gameRef.collectCoin(other.value);
      other.removeFromParent();
      return;
    }

    // Handle power-up collection
    if (other is PowerUpComponent) {
      gameRef.collectPowerUp(other.type);
      other.removeFromParent();
      return;
    }

    // Handle obstacle collision
    if (other is ObstacleComponent && !isInvulnerable) {
      final currentLives = gameRef.gameCubit?.state.lives ?? 0;
      print(
        '🔥 COLLISION! Obstacle: ${other.type}, Shield: $hasShield, Lives: $currentLives',
      );

      if (hasShield) {
        print('🛡️ Shield absorbed hit!');
        deactivateShield();
        gameRef.gameCubit?.deactivatePowerUp(PowerUpType.shield);
        other.removeFromParent();

        isInvulnerable = true;
        Future.delayed(Duration(milliseconds: 1500), () {
          isInvulnerable = false;
        });
      } else {
        print('💔 Player hit! Current lives: $currentLives');
        gameRef.gameCubit?.loseLife();
        other.removeFromParent();

        final newLives = gameRef.gameCubit?.state.lives ?? 0;
        print('❤️ Lives after hit: $newLives');

        if (newLives <= 0) {
          print('☠️ NO LIVES LEFT! Triggering GAME OVER...');
          isInvulnerable = true;
          Future.delayed(Duration(milliseconds: 300), () {
            // Fixed: Changed from gameRef.gameOverTriggered to !gameRef.gameOverTriggered
            if (gameRef.gameOverTriggered == false) {
              gameRef.gameOver();
            }
          });
        } else {
          print('❤️ Lives remaining: $newLives');
          isInvulnerable = true;
          Future.delayed(Duration(seconds: 2), () {
            isInvulnerable = false;
          });
        }
      }
    }
  }
}
