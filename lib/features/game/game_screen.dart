import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'endless_runner_game.dart';
import 'bloc/game_cubit.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameCubit gameCubit;
  late EndlessRunnerGame game;

  @override
  void initState() {
    super.initState();
    gameCubit = GameCubit();
    game = EndlessRunnerGame(gameCubit: gameCubit);
  }

  @override
  void dispose() {
    gameCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: gameCubit,
      child: BlocListener<GameCubit, GamePlayState>(
        listener: (context, state) {
          print(
            '🎮 BLoC State changed: ${state.gameState}, Lives: ${state.lives}',
          );
          if (state.gameState == GameState.gameOver) {
            print('🎮 BLoC detected game over state!');
          }
        },
        child: Scaffold(
          body: GameWidget(
            game: game,
            overlayBuilderMap: {
              'GameOver': (context, game) => GameOverOverlay(
                game: game as EndlessRunnerGame,
                gameCubit: gameCubit,
              ),
            },
          ),
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatefulWidget {
  final EndlessRunnerGame game;
  final GameCubit gameCubit;

  const GameOverOverlay({Key? key, required this.game, required this.gameCubit})
    : super(key: key);

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GamePlayState>(
      builder: (context, state) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Color(0xFF6C63FF), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6C63FF).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFD700).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          size: 60,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Game Over!',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 28,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF0f0f1e),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Color(0xFFFFD700),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Your Score',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${state.score}',
                              style: GoogleFonts.poppins(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Coins: ${state.coins}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                            if (state.score > state.highScore)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '🎉 New High Score!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Color(0xFFFF6584),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          widget.game.resetGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Play Again',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Back to Home',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
