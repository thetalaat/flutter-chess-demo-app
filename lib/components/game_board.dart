import 'package:chess/components/dead_piece.dart';
import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/helper_methods.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // 2-dimentional list representing the board
  late List<List<Piece?>> board;

  // selected piece
  Piece? selectedPiece;

  // selected piece position (default -1)
  int selectedRow = -1;
  int selectedCol = -1;

  // list of valid moves for the currenlty selected piece
  List<List<int>> validMoves = [];

  // list of white dead pieces
  List<Piece> whiteDeadPieces = [];

  // list of black dead pieces
  List<Piece> blackDeadPieces = [];

  // a boolean to track turns
  bool isWhiteTurn = true;

  // keep track of the kings position
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  // INITIALIZE THE BOARD
  void _initializeBoard() {
    List<List<Piece?>> startingBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // place pawns
    for (int i = 0; i < 8; i++) {
      startingBoard[1][i] = Piece(
          type: PieceType.pawn,
          isWhite: false,
          imagePath: 'lib/assets/pawn.png');
    }
    for (int i = 0; i < 8; i++) {
      startingBoard[6][i] = Piece(
          type: PieceType.pawn,
          isWhite: true,
          imagePath: 'lib/assets/pawn.png');
    }

    // place rooks
    startingBoard[0][0] = Piece(
        type: PieceType.rook, isWhite: false, imagePath: 'lib/assets/rook.png');
    startingBoard[0][7] = Piece(
        type: PieceType.rook, isWhite: false, imagePath: 'lib/assets/rook.png');
    startingBoard[7][0] = Piece(
        type: PieceType.rook, isWhite: true, imagePath: 'lib/assets/rook.png');
    startingBoard[7][7] = Piece(
        type: PieceType.rook, isWhite: true, imagePath: 'lib/assets/rook.png');

    // place knights
    startingBoard[0][1] = Piece(
        type: PieceType.knight,
        isWhite: false,
        imagePath: 'lib/assets/knight.png');
    startingBoard[0][6] = Piece(
        type: PieceType.knight,
        isWhite: false,
        imagePath: 'lib/assets/knight.png');
    startingBoard[7][1] = Piece(
        type: PieceType.knight,
        isWhite: true,
        imagePath: 'lib/assets/knight.png');
    startingBoard[7][6] = Piece(
        type: PieceType.knight,
        isWhite: true,
        imagePath: 'lib/assets/knight.png');

    // place bishops
    startingBoard[0][2] = Piece(
        type: PieceType.bishop,
        isWhite: false,
        imagePath: 'lib/assets/bishop.png');
    startingBoard[0][5] = Piece(
        type: PieceType.bishop,
        isWhite: false,
        imagePath: 'lib/assets/bishop.png');
    startingBoard[7][2] = Piece(
        type: PieceType.bishop,
        isWhite: true,
        imagePath: 'lib/assets/bishop.png');
    startingBoard[7][5] = Piece(
        type: PieceType.bishop,
        isWhite: true,
        imagePath: 'lib/assets/bishop.png');

    // place queens
    startingBoard[0][3] = Piece(
        type: PieceType.queen,
        isWhite: false,
        imagePath: 'lib/assets/queen.png');
    startingBoard[7][3] = Piece(
        type: PieceType.queen,
        isWhite: true,
        imagePath: 'lib/assets/queen.png');

    // place kings
    startingBoard[0][4] = Piece(
        type: PieceType.king, isWhite: false, imagePath: 'lib/assets/king.png');
    startingBoard[7][4] = Piece(
        type: PieceType.king, isWhite: true, imagePath: 'lib/assets/king.png');

    board = startingBoard;
  }

  // USER SELECTED A PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // No piece selected yet
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]?.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }

      // There is a piece selected
      else if (board[row][col] != null) {
        // select enemy piece and capture it
        if (board[row][col]?.isWhite != selectedPiece?.isWhite &&
            (validMoves
                .any((element) => element[0] == row && element[1] == col))) {
          // add enemy to dead list
          board[row][col]?.isWhite == true
              ? whiteDeadPieces.add(board[row][col]!)
              : blackDeadPieces.add(board[row][col]!);
          movePiece(row, col);
        }

        // select another one of your pieces
        else {
          if (board[row][col]?.isWhite == isWhiteTurn) {
            selectedPiece = board[row][col];
            selectedRow = row;
            selectedCol = col;
          } else {
            selectedPiece = null;
            selectedRow = -1;
            selectedCol = -1;
            validMoves = [];
          }
        }
      }

      // move to valid position without capturing
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      // clear selection
      else {
        selectedPiece = null;
        selectedRow = -1;
        selectedCol = -1;
        validMoves = [];
      }

      // calculate its valid moves
      validMoves = calculateRawValidMoves(row, col, selectedPiece);
    });
  }

  // CALCULATE RAW VALID MOVES
  List<List<int>> calculateRawValidMoves(int row, int col, Piece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) return [];

    // different directions based on their color
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case PieceType.pawn:
        // 1 square forward if square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        // 2 squares forward if at initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + direction * 2, col) &&
              board[row + direction * 2][col] == null) {
            candidateMoves.add([row + direction * 2, col]);
          }
        }
        // capture diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;

      case PieceType.rook:
        // horizontal and vertical directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) break;

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case PieceType.knight:
        // eight possible L shapes
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) continue;

          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }

          candidateMoves.add([newRow, newCol]);
        }
        break;
      case PieceType.bishop:
        // diagonal directions
        var directions = [
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) break;

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case PieceType.queen:
        // all directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) break;

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case PieceType.king:
        // 1 square in all directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];

          if (!isInBoard(newRow, newCol)) continue;

          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      default:
    }

    return candidateMoves;
  }

  // CALCULATE REAL VALID MOVES
  List<List<int>> calculateRealValidMoves(
      int row, int col, Piece? piece, bool checkSimulation) {}

  // MOVE PIECE
  void movePiece(int newRow, int newCol) {
    // check if piece is king
    if (selectedPiece!.type == PieceType.king) {
      selectedPiece!.isWhite
          ? whiteKingPosition = [newRow, newCol]
          : blackKingPosition = [newRow, newCol];
    }

    // move
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // check if kings are under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // clear selection
    selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
    validMoves = [];

    // switch turns
    isWhiteTurn = !isWhiteTurn;
  }

  // IS KING UNDER ATTACK
  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // check if any pieces can attack
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip empty squares and same color pieces
        if (board[i][j] == null || board[i][j]?.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> piecesValidMoves =
            calculateRawValidMoves(i, j, board[i][j]);

        if (piecesValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // dead white pieces
          Expanded(
              child: GridView.builder(
            itemCount: whiteDeadPieces.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8),
            itemBuilder: (context, index) => DeadPiece(
              imagePath: whiteDeadPieces[index].imagePath,
              isWhite: true,
            ),
          )),

          // check status
          Text(checkStatus ? "CHECK!" : ""),

          // board grid
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) {
                // get position of current square
                int row = index ~/ 8;
                int col = index % 8;

                // check if square is selected
                bool isSelected = selectedRow == row && selectedCol == col;

                // check if valid move
                bool isValidMove = false;
                for (var position in validMoves) {
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(row, col),
                );
              },
            ),
          ),

          // dead black pieces
          Expanded(
              child: GridView.builder(
            itemCount: blackDeadPieces.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8),
            itemBuilder: (context, index) => DeadPiece(
              imagePath: blackDeadPieces[index].imagePath,
              isWhite: false,
            ),
          )),
        ],
      ),
    );
  }
}
