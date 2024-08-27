import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './src/tetris_bloc.dart';

void main() {
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => TetrisBloc(),
        child: const TetrisScreen(),
      ),
    );
  }
}

class TetrisScreen extends StatelessWidget {
  const TetrisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          TetrisGrid(),
          TetrisControls(),
          TetrisModal(),
        ],
      ),
    );
  }
}

class TetrisGrid extends StatelessWidget {
  const TetrisGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TetrisBloc, TetrisState>(
      builder: (context, state) {
        if (state is TetrisInitial || state is TetrisGameOver) {
          return const Center(
            child: Text('Start a New Game'),
          );
        }

        if (state is TetrisInProgress) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: 200, // 10x20 grid
            itemBuilder: (context, index) {
              int x = index % 10;
              int y = index ~/ 10;

              String value = state.grid[y][x].toString();

              return Container(
                margin: const EdgeInsets.all(1.0),
                color: _getColor(value),
              );
            },
          );
        }

        return Container();
      },
    );
  }

  Color _getColor(String value) {
    switch (value) {
      case 'I':
        return Colors.cyan;
      case 'T':
        return Colors.purple;
      case 'J':
        return Colors.blue;
      case 'L':
        return Colors.orange;
      case 'S':
        return Colors.green;
      case 'Z':
        return Colors.red;
      case 'O':
        return Colors.yellow;
      case '1':
        return Colors.white;
      default:
        return Colors.black;
    }
  }
}

class TetrisControls extends StatelessWidget {
  const TetrisControls({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dy > 0) {
          BlocProvider.of<TetrisBloc>(context).add(TetrisMoveDown());
        } else if (details.delta.dy < 0) {
          BlocProvider.of<TetrisBloc>(context).add(TetrisMoveUp());
        } else if (details.delta.dx > 0) {
          BlocProvider.of<TetrisBloc>(context).add(TetrisMoveRight());
        } else if (details.delta.dx < 0) {
          BlocProvider.of<TetrisBloc>(context).add(TetrisMoveLeft());
        }
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<TetrisBloc>(context)
                      .add(TetrisRotateCounterClockwise());
                },
                child: const Icon(Icons.rotate_left),
              ),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<TetrisBloc>(context)
                      .add(TetrisRotateClockwise());
                },
                child: const Icon(Icons.rotate_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TetrisModal extends StatelessWidget {
  const TetrisModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TetrisBloc, TetrisState>(
      builder: (context, state) {
        if (state is TetrisInitial || state is TetrisGameOver) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<TetrisBloc>(context)
                          .add(TetrisStartNewGame());
                    },
                    child: const Text('New Game'),
                  ),
                  const SizedBox(height: 16.0),
                  Text('High Score: ${state.highScore}'),
                  if (state is TetrisGameOver) ...[
                    const SizedBox(height: 16.0),
                    Text('Your Score: ${state.score}'),
                  ],
                ],
              ),
            ),
          );
        }

        return Container();
      },
    );
  }
}
