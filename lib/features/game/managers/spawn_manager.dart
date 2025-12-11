import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import '../endless_runner_game.dart';
import '../components/obstacle_component.dart';
import '../components/coin_component.dart';
import '../components/powerup_component.dart';
import '../bloc/game_cubit.dart';

class SpawnManager extends Component with HasGameRef<EndlessRunnerGame> {
  final Random random = Random();
  Timer? obstacleTimer;
  Timer? coinTimer;
  Timer? powerUpTimer;

  double obstacleInterval = 3.0; // Increased from 2.0
  double coinInterval = 2.0;
  double powerUpInterval = 20.0;

  int patternIndex = 0;
  ObstacleDifficulty currentDifficulty = ObstacleDifficulty.easy;

  SpawnManager(EndlessRunnerGame game);

  @override
  void onMount() {
    super.onMount();

    obstacleTimer = Timer(
      obstacleInterval,
      onTick: _spawnObstaclePattern,
      repeat: true,
    );

    coinTimer = Timer(coinInterval, onTick: _spawnCoins, repeat: true);

    powerUpTimer = Timer(powerUpInterval, onTick: _spawnPowerUp, repeat: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    obstacleTimer?.update(dt);
    coinTimer?.update(dt);
    powerUpTimer?.update(dt);

    _updateDifficulty();
  }

  void _updateDifficulty() {
    final score = gameRef.gameCubit?.state.score ?? 0;

    if (score > 500) {
      currentDifficulty = ObstacleDifficulty.extreme;
      obstacleInterval = 1.8;
    } else if (score > 300) {
      currentDifficulty = ObstacleDifficulty.hard;
      obstacleInterval = 2.2;
    } else if (score > 150) {
      currentDifficulty = ObstacleDifficulty.medium;
      obstacleInterval = 2.5;
    }

    obstacleTimer?.limit = obstacleInterval;
  }

  void _spawnObstaclePattern() {
    if (gameRef.gameCubit?.state.gameState != GameState.playing) return;

    patternIndex++;

    // Simpler patterns
    if (patternIndex % 5 == 0 && currentDifficulty != ObstacleDifficulty.easy) {
      _spawnDoubleObstacle();
    } else {
      _spawnSingleObstacle();
    }
  }

  void _spawnSingleObstacle() {
    final types = [ObstacleType.cactus, ObstacleType.rock];
    final type = types[random.nextInt(types.length)];
    gameRef.add(
      ObstacleComponent(obstacleType: type, difficulty: currentDifficulty),
    );
  }

  void _spawnDoubleObstacle() {
    gameRef.add(
      ObstacleComponent(
        obstacleType: ObstacleType.cactus,
        difficulty: currentDifficulty,
      ),
    );

    Future.delayed(Duration(milliseconds: 800), () {
      if (gameRef.gameCubit?.state.gameState == GameState.playing) {
        gameRef.add(
          ObstacleComponent(
            obstacleType: ObstacleType.rock,
            difficulty: currentDifficulty,
          ),
        );
      }
    });
  }

  void _spawnCoins() {
    if (gameRef.gameCubit?.state.gameState != GameState.playing) return;

    if (random.nextDouble() > 0.6) {
      _spawnSingleCoin();
    }
  }

  void _spawnSingleCoin() {
    final coinType = random.nextDouble() > 0.8
        ? CoinType.silver
        : CoinType.bronze;

    gameRef.add(CoinComponent(coinType: coinType));
  }

  void _spawnPowerUp() {
    if (gameRef.gameCubit?.state.gameState != GameState.playing) return;

    final types = PowerUpType.values;
    final type = types[random.nextInt(types.length)];

    gameRef.add(PowerUpComponent(type: type));
  }
}
