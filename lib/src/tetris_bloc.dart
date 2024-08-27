import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tetris_engine.dart';

abstract class TetrisEvent {}

class TetrisStartNewGame extends TetrisEvent {}

class TetrisTick extends TetrisEvent {}

class TetrisMoveLeft extends TetrisEvent {}

class TetrisMoveRight extends TetrisEvent {}

class TetrisMoveDown extends TetrisEvent {}

class TetrisMoveUp extends TetrisEvent {}

class TetrisRotateClockwise extends TetrisEvent {}

class TetrisRotateCounterClockwise extends TetrisEvent {}

abstract class TetrisState {
  final List<List<dynamic>> grid;
  final int highScore;
  final int score;

  TetrisState(this.grid, this.highScore, this.score);
}

class TetrisInitial extends TetrisState {
  TetrisInitial(List<List<dynamic>> grid, int highScore)
      : super(grid, highScore, 0);
}

class TetrisInProgress extends TetrisState {
  TetrisInProgress(super.grid, super.highScore, super.score);
}

class TetrisGameOver extends TetrisState {
  TetrisGameOver(super.grid, super.highScore, super.score);
}

class TetrisBloc extends Bloc<TetrisEvent, TetrisState> {
  TetrisEngine _engine = TetrisEngine();
  int _highScore = 0;

  TetrisBloc() : super(TetrisInitial([], 0)) {
    _loadHighScore();
    on<TetrisStartNewGame>((event, emit) {
      _engine = TetrisEngine();
      emit(TetrisInProgress(_engine.grid, _highScore, 0));
      _startGameLoop();
    });

    on<TetrisTick>((event, emit) {
      _engine.tick();
      if (_engine.isGameOver) {
        _updateHighScore(_engine.score);
        emit(TetrisGameOver(_engine.grid, _highScore, _engine.score));
      } else {
        emit(TetrisInProgress(_engine.grid, _highScore, _engine.score));
      }
    });

    on<TetrisMoveLeft>((event, emit) {
      _engine.moveLeft();
      emit(TetrisInProgress(_engine.grid, _highScore, _engine.score));
    });

    on<TetrisMoveRight>((event, emit) {
      _engine.moveRight();
      emit(TetrisInProgress(_engine.grid, _highScore, _engine.score));
    });

    on<TetrisMoveDown>((event, emit) {
      _engine.moveDown();
      emit(TetrisInProgress(_engine.grid, _highScore, _engine.score));
    });

    on<TetrisMoveUp>((event, emit) {
      _engine.moveUp();
      emit(TetrisInProgress(_engine.grid, _highScore, _engine.score));
    });

    on<TetrisRotateClockwise>((event, emit) {
      _engine.rotateClockwise();
      emit(TetrisInProgress(_engine.grid, _highScore, _engine.score));
    });

    on<TetrisRotateCounterClockwise>((event, emit) {
      _engine.rotateCounterClockwise();
      emit(TetrisInProgress(_engine.grid, _highScore, _engine.score));
    });
  }

  void _startGameLoop() async {
    while (_engine.isGameOver == false) {
      await Future.delayed(const Duration(milliseconds: 2000));
      add(TetrisTick());
    }
  }

  void _loadHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('highScore') ?? 0;
  }

  void _updateHighScore(int newScore) async {
    if (newScore > _highScore) {
      _highScore = newScore;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('highScore', _highScore);
    }
  }
}
