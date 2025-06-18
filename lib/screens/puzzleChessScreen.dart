import 'dart:async';
import 'package:flutter/material.dart';

class PuzzleChessScreen extends StatefulWidget {
  const PuzzleChessScreen({super.key});

  @override
  State<PuzzleChessScreen> createState() => _PuzzleChessScreenState();
}

class _PuzzleChessScreenState extends State<PuzzleChessScreen> {
  late List<List<String>> board;
  final int rows = 5;
  final int cols = 4;
  int? selectedRow;
  int? selectedCol;
  int moveCount = 0;
  int secondsElapsed = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _createBoard();
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  void _resetPuzzle() {
    setState(() {
      moveCount = 0;
      secondsElapsed = 0;
      selectedRow = null;
      selectedCol = null;
      _createBoard();
      _startTimer();
    });
  }

  void _createBoard() {
    board = List.generate(rows, (i) => List.generate(cols, (j) => ''));
    board[0][0] = '♜';
    board[4][3] = '🎯';
    for (int j = 0; j < cols; j++) {
      board[1][j] = '♗';
      board[2][j] = '♘';
      board[3][j] = '♙';
    }
  }

  bool _isLegalMove(String piece, int fromRow, int fromCol, int toRow, int toCol) {
    if ((toRow == 0 && toCol != 0) || (toRow == 4 && toCol != 3)) return false;

    int dRow = (toRow - fromRow).abs();
    int dCol = (toCol - fromCol).abs();

    switch (piece) {
      case '♜':
        if (fromRow == toRow || fromCol == toCol) {
          int rowStep = toRow == fromRow ? 0 : (toRow - fromRow).sign;
          int colStep = toCol == fromCol ? 0 : (toCol - fromCol).sign;
          int r = fromRow + rowStep;
          int c = fromCol + colStep;
          while (r != toRow || c != toCol) {
            if (board[r][c] != '') return false;
            r += rowStep;
            c += colStep;
          }
          return board[toRow][toCol] == '' || board[toRow][toCol] == '🎯';
        }
        return false;
      case '♗':
        if (dRow == dCol) {
          int rowStep = (toRow - fromRow).sign;
          int colStep = (toCol - fromCol).sign;
          int r = fromRow + rowStep;
          int c = fromCol + colStep;
          while (r != toRow && c != toCol) {
            if (board[r][c] != '') return false;
            r += rowStep;
            c += colStep;
          }
          return board[toRow][toCol] == '';
        }
        return false;
      case '♘':
        return (dRow == 2 && dCol == 1) || (dRow == 1 && dCol == 2);
      case '♙':
        return toRow == fromRow - 1 && fromCol == toCol && board[toRow][toCol] == '';
      default:
        return false;
    }
  }

  void _onTap(int r, int c) {
    final current = board[r][c];
    if (selectedRow != null && selectedCol != null) {
      final selectedPiece = board[selectedRow!][selectedCol!];
      if (_isLegalMove(selectedPiece, selectedRow!, selectedCol!, r, c)) {
        setState(() {
          board[r][c] = selectedPiece;
          board[selectedRow!][selectedCol!] = '';
          selectedRow = null;
          selectedCol = null;
          moveCount++;

          if (board[4][3] == '♜') {
            timer?.cancel();
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('¡Victoria!'),
                content: Text('Resuelto en $moveCount movimientos y $secondsElapsed segundos.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _resetPuzzle();
                    },
                    child: const Text('Reiniciar'),
                  )
                ],
              ),
            );
          }
        });
        return;
      }
    }
    if (current != '' && current != '🎯') {
      setState(() {
        selectedRow = r;
        selectedCol = c;
      });
    }
  }

  Widget _square(int r, int c) {
    if ((r == 0 && c != 0) || (r == 4 && c != 3)) {
      return const SizedBox.shrink();
    }

    final piece = board[r][c];
    final selected = r == selectedRow && c == selectedCol;
    return GestureDetector(
      onTap: () => _onTap(r, c),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          color: selected
              ? Colors.amberAccent
              : (r + c) % 2 == 0
                  ? Colors.white
                  : Colors.grey.shade300,
        ),
        child: Center(
          child: Text(
            piece,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Puzzle'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Movs: $moveCount'),
                Text('Tiempo: ${secondsElapsed}s'),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetPuzzle,
          ),
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(rows, (i) => Expanded(
                  child: Row(
                    children: List.generate(cols, (j) => Expanded(child: _square(i, j))),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
