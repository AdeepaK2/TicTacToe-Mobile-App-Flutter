import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF424242)), // Corrected TextTheme
        ),
      ),
      home: ModeSelectionScreen(),
    );
  }
}

class ModeSelectionScreen extends StatefulWidget {
  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  String selectedDifficulty = "Normal";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tic Tac Toe"),
        backgroundColor: Color(0xFF2196F3),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton("Play with 2 Players", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TicTacToeGame(isAgainstComputer: false, difficulty: ""),
                ),
              );
            }),
            SizedBox(height: 20),
            Text("Select Difficulty:", style: TextStyle(fontSize: 18, color: Colors.black)),
            DropdownButton<String>(
              value: selectedDifficulty,
              dropdownColor: Colors.white,
              style: TextStyle(color: Colors.black, fontSize: 16),
              items: ["Normal", "Hard"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedDifficulty = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            _buildMenuButton("Play Against Computer", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TicTacToeGame(
                    isAgainstComputer: true,
                    difficulty: selectedDifficulty,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2196F3),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  final bool isAgainstComputer;
  final String difficulty;
  TicTacToeGame({required this.isAgainstComputer, required this.difficulty});

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> board = List.filled(9, "");
  bool isXTurn = true;
  String winner = "";
  Random random = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tic Tac Toe"), backgroundColor: Color(0xFF2196F3), elevation: 0),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _handleTap(index),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      board[index],
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: board[index] == "X" ? Colors.redAccent : Colors.blueAccent,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          Text(
            winner.isNotEmpty ? (winner == "Draw" ? "It's a Draw!" : "$winner Wins!") : "",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 20),
          _buildGameButton("Reset Game", _resetGame),
        ],
      ),
    );
  }

  Widget _buildGameButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, "");
      isXTurn = true;
      winner = "";
    });
  }

  void _handleTap(int index) {
    if (board[index] == "" && winner == "") {
      setState(() {
        board[index] = isXTurn ? "X" : "O";
        isXTurn = !isXTurn;
        winner = _checkWinner();
      });

      if (widget.isAgainstComputer && !isXTurn && winner == "") {
        _computerMove();
      }
    }
  }

  String _checkWinner() {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],  // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8],  // Columns
      [0, 4, 8], [2, 4, 6]              // Diagonals
    ];

    for (var pattern in winPatterns) {
      String a = board[pattern[0]], b = board[pattern[1]], c = board[pattern[2]];
      if (a.isNotEmpty && a == b && b == c) {
        return a; // Return "X" or "O" as the winner
      }
    }

    if (!board.contains("")) return "Draw"; // If board is full and no winner

    return ""; // No winner yet
  }

  void _computerMove() {
    Future.delayed(Duration(milliseconds: 500), () {
      int bestMove = _findBestMove();
      if (bestMove != -1) {
        setState(() {
          board[bestMove] = "O";
          isXTurn = true;
          winner = _checkWinner();
        });
      }
    });
  }

  int _findBestMove() {
    if (widget.difficulty == "Normal") {
      List<int> availableMoves = [for (int i = 0; i < 9; i++) if (board[i] == "") i];
      return availableMoves[random.nextInt(availableMoves.length)];
    } else {
      return _minimax(board, true, -1000, 1000).move;
    }
  }

  Move _minimax(List<String> boardState, bool isMaximizing, int alpha, int beta) {
    String result = _checkWinner();
    if (result == "O") return Move(10, -1);
    if (result == "X") return Move(-10, -1);
    if (!boardState.contains("")) return Move(0, -1);

    int bestScore = isMaximizing ? -1000 : 1000;
    int bestMove = -1;
    for (int i = 0; i < 9; i++) {
      if (boardState[i] == "") {
        boardState[i] = isMaximizing ? "O" : "X";
        int score = _minimax(boardState, !isMaximizing, alpha, beta).score;
        boardState[i] = "";
        if (isMaximizing ? score > bestScore : score < bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    return Move(bestScore, bestMove);
  }
}

class Move {
  int score;
  int move;
  Move(this.score, this.move);
}
