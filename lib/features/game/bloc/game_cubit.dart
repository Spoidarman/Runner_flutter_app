import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameState { idle, playing, paused, gameOver }

enum PowerUpType { shield, magnet, doubleScore, slowMotion }

class GameCubit extends Cubit<GamePlayState> {
  GameCubit() : super(GamePlayState.initial()) {
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final highScore = await _getHighScore();
    emit(state.copyWith(highScore: highScore));
  }

  void startGame() {
    emit(
      state.copyWith(
        gameState: GameState.playing,
        score: 0,
        coins: 0,
        distance: 0,
        lives: 3,
      ),
    );
  }

  void pauseGame() {
    emit(state.copyWith(gameState: GameState.paused));
  }

  void resumeGame() {
    emit(state.copyWith(gameState: GameState.playing));
  }

  void gameOver() async {
    print('🎮 GameCubit: gameOver called, current state: ${state.gameState}');

    final highScore = await _getHighScore();
    final newHighScore = state.score > highScore ? state.score : highScore;

    if (state.score > highScore) {
      await _saveHighScore(state.score);
      print('🏆 New high score saved: ${state.score}');
    }

    emit(
      state.copyWith(gameState: GameState.gameOver, highScore: newHighScore),
    );

    print('✅ GameCubit: State changed to gameOver, lives: ${state.lives}');
  }

  void incrementScore(int points) {
    emit(state.copyWith(score: state.score + points));
  }

  void addCoins(int amount) {
    emit(state.copyWith(coins: state.coins + amount));
  }

  void updateDistance(double distance) {
    emit(state.copyWith(distance: state.distance + distance));
  }

  void activatePowerUp(PowerUpType type, int duration) {
    final activePowerUps = Map<PowerUpType, int>.from(state.activePowerUps);
    activePowerUps[type] = duration;
    emit(state.copyWith(activePowerUps: activePowerUps));
  }

  void deactivatePowerUp(PowerUpType type) {
    final activePowerUps = Map<PowerUpType, int>.from(state.activePowerUps);
    activePowerUps.remove(type);
    emit(state.copyWith(activePowerUps: activePowerUps));
  }

  void loseLife() {
    final newLives = state.lives - 1;
    print(
      '💔 loseLife called. Current lives: ${state.lives}, New lives: $newLives',
    );
    emit(state.copyWith(lives: newLives));
    print('✅ Lives updated to: ${state.lives}');
  }

  void updateDifficulty(int level) {
    emit(state.copyWith(difficultyLevel: level));
  }

  Future<int> _getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('high_score') ?? 0;
  }

  Future<void> _saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('high_score', score);
  }
}

class GamePlayState {
  final GameState gameState;
  final int score;
  final int coins;
  final double distance;
  final int lives;
  final int highScore;
  final Map<PowerUpType, int> activePowerUps;
  final int difficultyLevel;

  GamePlayState({
    required this.gameState,
    required this.score,
    required this.coins,
    required this.distance,
    required this.lives,
    required this.highScore,
    required this.activePowerUps,
    required this.difficultyLevel,
  });

  factory GamePlayState.initial() {
    return GamePlayState(
      gameState: GameState.idle,
      score: 0,
      coins: 0,
      distance: 0,
      lives: 3,
      highScore: 0,
      activePowerUps: {},
      difficultyLevel: 1,
    );
  }

  GamePlayState copyWith({
    GameState? gameState,
    int? score,
    int? coins,
    double? distance,
    int? lives,
    int? highScore,
    Map<PowerUpType, int>? activePowerUps,
    int? difficultyLevel,
  }) {
    return GamePlayState(
      gameState: gameState ?? this.gameState,
      score: score ?? this.score,
      coins: coins ?? this.coins,
      distance: distance ?? this.distance,
      lives: lives ?? this.lives,
      highScore: highScore ?? this.highScore,
      activePowerUps: activePowerUps ?? this.activePowerUps,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    );
  }
}
