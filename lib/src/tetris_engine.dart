class TetrisEngine {
  final Map<String, List<List<List<int>>>> shapes = {
    "I": [
      [
        [0, 0, 0, 0],
        [1, 1, 1, 1],
        [0, 0, 0, 0],
        [0, 0, 0, 0]
      ],
      [
        [0, 0, 1, 0],
        [0, 0, 1, 0],
        [0, 0, 1, 0],
        [0, 0, 1, 0]
      ],
      [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [1, 1, 1, 1],
        [0, 0, 0, 0]
      ],
      [
        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0]
      ]
    ],
    "J": [
      [
        [1, 0, 0],
        [1, 1, 1],
        [0, 0, 0]
      ],
      [
        [0, 1, 1],
        [0, 1, 0],
        [0, 1, 0]
      ],
      [
        [0, 0, 0],
        [1, 1, 1],
        [0, 0, 1]
      ],
      [
        [0, 1, 0],
        [0, 1, 0],
        [1, 1, 0]
      ]
    ],
    "L": [
      [
        [0, 0, 1],
        [1, 1, 1],
        [0, 0, 0]
      ],
      [
        [0, 1, 0],
        [0, 1, 0],
        [0, 1, 1]
      ],
      [
        [0, 0, 0],
        [1, 1, 1],
        [1, 0, 0]
      ],
      [
        [1, 1, 0],
        [0, 1, 0],
        [0, 1, 0]
      ]
    ],
    "O": [
      [
        [0, 0, 0, 0],
        [0, 1, 1, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0]
      ],
      [
        [0, 0, 0, 0],
        [0, 1, 1, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0]
      ],
      [
        [0, 0, 0, 0],
        [0, 1, 1, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0]
      ],
      [
        [0, 0, 0, 0],
        [0, 1, 1, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0]
      ]
    ],
    "S": [
      [
        [0, 1, 1],
        [1, 1, 0],
        [0, 0, 0]
      ],
      [
        [0, 1, 0],
        [0, 1, 1],
        [0, 0, 1]
      ],
      [
        [0, 0, 0],
        [0, 1, 1],
        [1, 1, 0]
      ],
      [
        [1, 0, 0],
        [1, 1, 0],
        [0, 1, 0]
      ]
    ],
    "T": [
      [
        [0, 1, 0],
        [1, 1, 1],
        [0, 0, 0]
      ],
      [
        [0, 1, 0],
        [0, 1, 1],
        [0, 1, 0]
      ],
      [
        [0, 0, 0],
        [1, 1, 1],
        [0, 1, 0]
      ],
      [
        [0, 1, 0],
        [1, 1, 0],
        [0, 1, 0]
      ]
    ],
    "Z": [
      [
        [1, 1, 0],
        [0, 1, 1],
        [0, 0, 0]
      ],
      [
        [0, 0, 1],
        [0, 1, 1],
        [0, 1, 0]
      ],
      [
        [0, 0, 0],
        [1, 1, 0],
        [0, 1, 1]
      ],
      [
        [0, 1, 0],
        [1, 1, 0],
        [1, 0, 0]
      ]
    ]
  };

  final List<int> scores = [0, 100, 300, 500, 800];
  late int width;
  late int height;
  late List<List<int>> grid;
  Map<String, dynamic>? currentPiece;
  Map<String, dynamic>? nextPiece;
  List<String> bag = [];
  int score = 0;
  bool isGameOver = false;
  Map<String, bool> wallKickCache = {};

  TetrisEngine({this.width = 10, this.height = 20}) {
    grid = List.generate(height, (_) => List.filled(width, 0));
    generateNewPiece();
    updateGrid();
  }

  Map<String, dynamic> getPieceFromBag() {
    if (bag.isEmpty) {
      bag = shapes.keys.toList();
      shuffleBag();
    }

    String shapeType = bag.removeLast();
    List<List<int>> pieceShape = getPieceShape(shapeType, 0);
    int topRowOffset = pieceShape.indexWhere((row) => row.contains(1));

    int leftmostCol = pieceShape[0].length;
    int rightmostCol = 0;
    for (var row in pieceShape) {
      for (int col = 0; col < row.length; col++) {
        if (row[col] == 1) {
          leftmostCol = leftmostCol < col ? leftmostCol : col;
          rightmostCol = rightmostCol > col ? rightmostCol : col;
        }
      }
    }

    int centerCol = ((leftmostCol + rightmostCol) / 2).floor();

    return {
      'type': shapeType,
      'rotation': 0,
      'x': (width / 2).floor() - centerCol,
      'y': -topRowOffset,
    };
  }

  void generateNewPiece() {
    currentPiece = getPieceFromBag();

    if (nextPiece == null) {
      generateNextPiece();
    }
  }

  void generateNextPiece() {
    nextPiece = getPieceFromBag();
    wallKickCache = {};
  }

  void shuffleBag() {
    bag.shuffle();
  }

  void setGameOver({String reason = ""}) {
    if (reason.isNotEmpty) {
      print("GAME OVER, reason: $reason");
    }
    isGameOver = true;
  }

  void tick() {
    if (isGameOver) return;
    if (currentPiece == null) return;

    final isValid = isValidMove(
        currentPiece!['x'], currentPiece!['y'] + 1, currentPiece!['rotation']);
    // print("tick: $isValid");

    if (isValidMove(currentPiece!['x'], currentPiece!['y'] + 1,
        currentPiece!['rotation'])) {
      currentPiece!['y']++;
    } else {
      lockPiece();
      clearLines();
      currentPiece = nextPiece;
      generateNextPiece();

      if (!isValidMove(
          currentPiece!['x'], currentPiece!['y'], currentPiece!['rotation'])) {
        setGameOver(reason: "(tick) can't spawn new piece");
      }
    }

    updateGrid();
  }

  void movePiece(String move) {
    if (isGameOver) return;
    if (currentPiece == null) return;

    if (move == "up") {
      while (isValidMove(currentPiece!['x'], currentPiece!['y'] + 1,
          currentPiece!['rotation'])) {
        currentPiece!['y']++;
      }
      lockPiece();
      clearLines();
      currentPiece = nextPiece;
      generateNextPiece();
      if (!isValidMove(
          currentPiece!['x'], currentPiece!['y'], currentPiece!['rotation'])) {
        setGameOver(reason: "(movePiece) can't move");
      }
    } else if (move == "down") {
      if (isValidMove(currentPiece!['x'], currentPiece!['y'] + 1,
          currentPiece!['rotation'])) {
        currentPiece!['y']++;
      }
    } else if (move == "left" &&
        isValidMove(currentPiece!['x'] - 1, currentPiece!['y'],
            currentPiece!['rotation'])) {
      currentPiece!['x']--;
    } else if (move == "right" &&
        isValidMove(currentPiece!['x'] + 1, currentPiece!['y'],
            currentPiece!['rotation'])) {
      currentPiece!['x']++;
    }

    updateGrid();
  }

  void moveLeft() => movePiece("left");

  void moveRight() => movePiece("right");

  void moveDown() => movePiece("down");

  void moveUp() => movePiece("up");

  void rotateClockwise() => rotatePiece(1);

  void rotateCounterClockwise() => rotatePiece(-1);

  bool isValidMove(int x, int y, int rotation) {
    final piece = getPieceShape(currentPiece!['type'], rotation);

    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        if (piece[row][col] == 1) {
          final newX = x + col;
          final newY = y + row;

          // Check if out of bounds
          if (newX < 0 || newX >= width || newY >= height) {
            return false;
          }

          // Check if overlapping existing blocks (non-zero and not the current piece in play)
          if (newY >= 0 && grid[newY][newX] != 0 && grid[newY][newX] != 1) {
            return false;
          }
        }
      }
    }

    return true;
  }

  void lockPiece() {
    List<List<int>> piece =
        getPieceShape(currentPiece!['type'], currentPiece!['rotation']);

    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        if (piece[row][col] == 1) {
          int x = currentPiece!['x'] + col;
          int y = currentPiece!['y'] + row;

          if (y >= 0) {
            grid[y][x] = currentPiece!['type'].codeUnitAt(0);
          }
        }
      }
    }
  }

  void clearLines() {
    int linesCleared = 0;

    for (int row = height - 1; row >= 0; row--) {
      if (grid[row].every((cell) => cell != 0)) {
        linesCleared++;
      }
    }

    if (linesCleared == 0) return;

    for (int i = 0; i < linesCleared; i++) {
      grid.removeLast();
      grid.insert(0, List.filled(width, 0));
    }

    int addToScore = scores[linesCleared];
    score += addToScore;
  }

  List<List<int>> getPieceShape(String type, int rotation) {
    return shapes[type]![rotation];
  }

  void rotatePiece(int direction) {
    if (isGameOver) return;
    if (currentPiece == null) return;

    int newRotation = (currentPiece!['rotation'] + direction + 4) % 4;
    String pieceType = currentPiece!['type'];

    if (pieceType == "O") return;

    Map<String, List<List<int>>> wallKickDataForJLSZT = {
      '0->R': [
        [0, 0],
        [-1, 0],
        [-1, 1],
        [0, -2],
        [-1, -2]
      ],
      'R->0': [
        [0, 0],
        [1, 0],
        [1, -1],
        [0, 2],
        [1, 2]
      ],
      'R->2': [
        [0, 0],
        [1, 0],
        [1, -1],
        [0, 2],
        [1, 2]
      ],
      '2->R': [
        [0, 0],
        [-1, 0],
        [-1, 1],
        [0, -2],
        [-1, -2]
      ],
      '2->L': [
        [0, 0],
        [1, 0],
        [1, 1],
        [0, -2],
        [1, -2]
      ],
      'L->2': [
        [0, 0],
        [-1, 0],
        [-1, -1],
        [0, 2],
        [-1, 2]
      ],
      'L->0': [
        [0, 0],
        [-1, 0],
        [-1, -1],
        [0, 2],
        [-1, 2]
      ],
      '0->L': [
        [0, 0],
        [1, 0],
        [1, 1],
        [0, -2],
        [1, -2]
      ]
    };

    Map<String, Map<String, List<List<int>>>> wallKickData = {
      "O": {},
      "I": {
        '0->R': [
          [0, 0],
          [-2, 0],
          [1, 0],
          [-2, -1],
          [1, 2]
        ],
        'R->0': [
          [0, 0],
          [2, 0],
          [-1, 0],
          [2, 1],
          [-1, -2]
        ],
        'R->2': [
          [0, 0],
          [-1, 0],
          [2, 0],
          [-1, 2],
          [2, -1]
        ],
        '2->R': [
          [0, 0],
          [1, 0],
          [-2, 0],
          [1, -2],
          [-2, 1]
        ],
        '2->L': [
          [0, 0],
          [2, 0],
          [-1, 0],
          [2, 1],
          [-1, -2]
        ],
        'L->2': [
          [0, 0],
          [-2, 0],
          [1, 0],
          [-2, -1],
          [1, 2]
        ],
        'L->0': [
          [0, 0],
          [1, 0],
          [-2, 0],
          [1, -2],
          [-2, 1]
        ],
        '0->L': [
          [0, 0],
          [-1, 0],
          [2, 0],
          [-1, 2],
          [2, -1]
        ]
      },
      "J": wallKickDataForJLSZT,
      "L": wallKickDataForJLSZT,
      "S": wallKickDataForJLSZT,
      "T": wallKickDataForJLSZT,
      "Z": wallKickDataForJLSZT,
    };

    String startRotationState = currentPiece!['rotation'] == 1
        ? 'R'
        : (currentPiece!['rotation'] == 3
            ? 'L'
            : '${currentPiece!['rotation']}');
    String endRotationState =
        newRotation == 1 ? 'R' : (newRotation == 3 ? 'L' : '$newRotation');
    String currentRotationState = '$startRotationState->$endRotationState';

    for (List<int> test in wallKickData[pieceType]![currentRotationState]!) {
      int newX = currentPiece!['x'] + test[0];
      int newY = currentPiece!['y'] + test[1];

      String cacheKey =
          '$pieceType-${currentPiece!['x']}-${currentPiece!['y']}-$currentRotationState-${test[0]}-${test[1]}';
      if (wallKickCache[cacheKey] == true) {
        continue;
      }

      if (isValidMove(newX, newY, newRotation)) {
        currentPiece!['x'] = newX;
        currentPiece!['y'] = newY;
        currentPiece!['rotation'] = newRotation;

        wallKickCache[cacheKey] = true;

        updateGrid();
        return;
      }
    }
  }

  void updateGrid() {
    List<List<int>> newGrid =
        List.generate(height, (_) => List.filled(width, 0));

    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        if (grid[row][col] is String) {
          newGrid[row][col] = grid[row][col];
        }
      }
    }

    if (currentPiece != null) {
      List<List<int>> pieceShape =
          getPieceShape(currentPiece!['type'], currentPiece!['rotation']);
      for (int row = 0; row < pieceShape.length; row++) {
        for (int col = 0; col < pieceShape[row].length; col++) {
          if (pieceShape[row][col] == 1) {
            int x = currentPiece!['x'] + col;
            int y = currentPiece!['y'] + row;
            if (x >= 0 && x < width && y >= 0 && y < height) {
              newGrid[y][x] = 1;
            }
          }
        }
      }
    }

    grid = newGrid;
  }
}
