import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert';

void main() {
  runApp(TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ModeSelectionScreen(),
    );
  }
}

class ModeSelectionScreen extends StatefulWidget {
  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  String selectedDifficulty = "Medium";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tic Tac Toe")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedDifficulty,
              items: ["Easy", "Medium", "Hard", "Impossible"].map((String value) {
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicTacToeGame(
                      isAgainstComputer: true,
                      difficulty: selectedDifficulty,
                    ),
                  ),
                );
              },
              child: Text("Play Against Computer"),
            ),
          ],
        ),
      ),
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
  Map<String, int> qTable = {};
  String previousState = "";
  int previousMove = -1;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    _loadQTable();
  }

  Future<void> _loadQTable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString("qTable");
    if (storedData != null) {
      setState(() {
        qTable = Map<String, int>.from(jsonDecode(storedData));
      });
    }
  }

  Future<void> _saveQTable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("qTable", jsonEncode(qTable));
  }

  String _checkWinner() {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];
    for (var pattern in winPatterns) {
      String a = board[pattern[0]], b = board[pattern[1]], c = board[pattern[2]];
      if (a == b && b == c && a != "") {
        return a;
      }
    }
    if (!board.contains("")) {
      return "Draw";
    }
    return "";
  }

  int _findBestMove() {
    List<int> availableMoves = [];
    for (int i = 0; i < 9; i++) {
      if (board[i] == "") availableMoves.add(i);
    }
    if (availableMoves.isEmpty) return -1;
    return availableMoves[random.nextInt(availableMoves.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tic Tac Toe")),
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
                child: Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: Text(
                      board[index],
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          Text(
            winner.isNotEmpty ? (winner == "Draw" ? "It's a Draw!" : "$winner Wins!") : "", 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetGame,
            child: Text("Reset Game"),
          ),
        ],
      ),
    );
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

  void _computerMove() {
    Future.delayed(Duration(milliseconds: 500), () {
      previousState = board.join();
      int bestMove = _findBestMove();
      if (bestMove != -1) {
        setState(() {
          board[bestMove] = "O";
          isXTurn = true;
          winner = _checkWinner();
          previousMove = bestMove;
        });
      }
    });
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, "");
      isXTurn = true;
      winner = "";
    });
  }
}