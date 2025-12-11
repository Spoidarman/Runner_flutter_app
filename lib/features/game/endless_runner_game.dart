import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/player_component.dart';
import 'components/ground_component.dart';
import 'components/obstacle_component.dart';
import 'components/background_component.dart';
import 'components/coin_component.dart';
import 'components/powerup_component.dart';
import 'managers/spawn_manager.dart';
import 'bloc/game_cubit.dart';

class EndlessRunnerGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  late PlayerComponent player;
  late SpawnManager spawnManager;
  GameCubit? gameCubit;
  bool gameOverTriggered = false; // This is already non-nullable

  EndlessRunnerGame({this.gameCubit});

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    print('Game loading... Size: ${size.x} x ${size.y}');

    gameOverTriggered = false;
    gameCubit?.startGame();

    final background = ParallaxBackgroundComponent();
    await add(background);

    final ground = GroundComponent();
    await add(ground);

    player = PlayerComponent();
    await add(player);

    spawnManager = SpawnManager(this);
    await add(spawnManager);

    final hud = GameHUD();
    await add(hud);

    print('✅ Game loaded successfully!');
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameCubit?.state.gameState == GameState.playing) {
      player.startJump();
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    player.endJump();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    player.endJump();
  }

  void incrementScore(int points) {
    final multiplier =
        gameCubit?.state.activePowerUps.containsKey(PowerUpType.doubleScore) ??
            false
        ? 2
        : 1;
    gameCubit?.incrementScore(points * multiplier);
  }

  void collectCoin(int value) {
    gameCubit?.addCoins(value);
    incrementScore(value * 5);
  }

  void collectPowerUp(PowerUpType type) {
    gameCubit?.activatePowerUp(type, 10);

    switch (type) {
      case PowerUpType.shield:
        player.activateShield();
        break;
      case PowerUpType.slowMotion:
        _activateSlowMotion();
        break;
      case PowerUpType.magnet:
        player.activateMagnet();
        break;
      case PowerUpType.doubleScore:
        break;
    }

    Future.delayed(Duration(seconds: 10), () {
      gameCubit?.deactivatePowerUp(type);
      if (type == PowerUpType.shield) {
        player.deactivateShield();
      } else if (type == PowerUpType.magnet) {
        player.deactivateMagnet();
      }
    });
  }

  void _activateSlowMotion() {
    children.whereType<ObstacleComponent>().forEach((obstacle) {
      obstacle.speed *= 0.5;
    });
  }

  void gameOver() {
    if (gameOverTriggered) {
      print('⚠️ Game over already triggered, ignoring...');
      return;
    }

    gameOverTriggered = true;
    print('⚠️ GAME OVER TRIGGERED! Pausing engine and showing overlay...');

    gameCubit?.gameOver();
    pauseEngine();

    Future.delayed(Duration(milliseconds: 100), () {
      if (!overlays.isActive('GameOver')) {
        overlays.add('GameOver');
        print('✅ Game Over overlay added');
      }
    });
  }

  void resetGame() {
    print('🔄 Resetting game...');
    gameOverTriggered = false;

    overlays.remove('GameOver');
    gameCubit?.startGame();

    children.whereType<ObstacleComponent>().forEach((obstacle) {
      obstacle.removeFromParent();
    });

    children.whereType<CoinComponent>().forEach((coin) {
      coin.removeFromParent();
    });

    children.whereType<PowerUpComponent>().forEach((powerup) {
      powerup.removeFromParent();
    });

    player.reset();

    resumeEngine();
    print('✅ Game reset complete and resumed');
  }
}

class GameHUD extends PositionComponent with HasGameRef<EndlessRunnerGame> {
  late TextComponent scoreText;
  late TextComponent coinsText;
  late TextComponent livesText;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    priority = 100;

    scoreText = TextComponent(
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black54, offset: Offset(2, 2), blurRadius: 4),
          ],
        ),
      ),
    );

    coinsText = TextComponent(
      position: Vector2(20, 50),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black54, offset: Offset(2, 2), blurRadius: 4),
          ],
        ),
      ),
    );

    livesText = TextComponent(
      position: Vector2(20, 75),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Color(0xFFFF6584),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black54, offset: Offset(2, 2), blurRadius: 4),
          ],
        ),
      ),
    );

    add(scoreText);
    add(coinsText);
    add(livesText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final state = gameRef.gameCubit?.state;

    scoreText.text = 'Score: ${state?.score ?? 0}';
    coinsText.text = '🪙 ${state?.coins ?? 0}';
    livesText.text = '❤️ ${state?.lives ?? 3}';
  }
}
