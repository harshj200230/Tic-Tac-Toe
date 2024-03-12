import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const String PLAYER_X = "X";
  static const String PLAYER_Y = "O";

  late String currentPlayer;
  late bool gameEnd;
  late List<String> occupied;
  late List<bool> boxVisibility;
  bool gameWon = false;
  List<int> winningTiles = [];

  @override
  void initState() {
    initializeGame();
    super.initState();
  }

  void initializeGame() {
    currentPlayer = PLAYER_X;
    gameEnd = false;
    occupied = ["", "", "", "", "", "", "", "", ""];
    boxVisibility = List.generate(9, (index) => true);
    gameWon = false;
    winningTiles = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (gameWon) {
            setState(() {
              gameWon = false;
            });
          }
        } ,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xFFDC2424),
              Color(0xFF4A569D),
            ]),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _headerText(),
                _gameContainer(),
                SizedBox(height: 25,),
                _restartButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerText() {
    return Transform.translate(
      offset: Offset(0.0, -23.0),
      child: Column(
        children: [
          Text("Tic Tac Toe", style: GoogleFonts.lemon(fontSize: 42, color: Colors.yellow, shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(6.0, 6.0),
              blurRadius: 15.0,
            ),
          ])),
          SizedBox(height: 15,),
          Text("$currentPlayer 's  turn", style: GoogleFonts.lilitaOne(fontSize: 32, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _gameContainer() {
    return GestureDetector(
      onTap: () {
        if (gameWon) {
          setState(() {
            gameWon = false;
          });
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.height / 2,
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Stack(
          children: [
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: 9,
              itemBuilder: (context, int index) {
                return _box(index);
              },
            ),
            Visibility(
              visible: gameWon,
              child: Center(
                child: Image.asset(
                  'assets/jetha.gif', // Replace with your actual GIF file path
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.height / 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _box(int index) {
    return InkWell(
      onTap: () {
        if (gameEnd || occupied[index].isNotEmpty) {
          return;
        }

        setState(() {
          occupied[index] = currentPlayer;
          changeTurn();
          checkForWinner();
          checkForDraw();
        });
      },
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 700),
        opacity: boxVisibility[index] ? 1.0 : 0.3,
        child: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: occupied[index].isEmpty
                ? Colors.black26
                : occupied[index] == PLAYER_X
                ? Colors.cyan
                : Colors.green.shade600,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: gameWon && winningTiles.contains(index) ? Colors.yellow : Colors.transparent,
              width: 2.0,
            ),
          ),
          child: Center(
            child: Text(
              occupied[index],
              style: TextStyle(
                fontSize: 50,
                color: occupied[index].isEmpty ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontStyle: occupied[index].isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _restartButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          initializeGame();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[200],
        onPrimary: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
          side: BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
      child: const Text(
        'Restart Game',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    );
  }

  void changeTurn() {
    if (currentPlayer == PLAYER_X) {
      currentPlayer = PLAYER_Y;
    } else {
      currentPlayer = PLAYER_X;
    }
  }

  void checkForWinner() {
    List<List<int>> winningList = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var winningPos in winningList) {
      int playerPosition0 = winningPos[0];
      int playerPosition1 = winningPos[1];
      int playerPosition2 = winningPos[2];

      if (occupied[playerPosition0].isNotEmpty &&
          occupied[playerPosition0] == occupied[playerPosition1] &&
          occupied[playerPosition0] == occupied[playerPosition2]) {
        showGameOverMessage("Player ${occupied[playerPosition0]} Won");
        gameEnd = true;
        gameWon = true;
        winningTiles = winningPos;

        // Set visibility to false for non-winning boxes
        for (int i = 0; i < 9; i++) {
          if (occupied[i] != occupied[playerPosition0]) {
            boxVisibility[i] = false;
          }
        }

        return;
      }
    }
  }

  void checkForDraw() {
    if (gameEnd) {
      return;
    }
    bool draw = true;
    for (var occupiedPlayer in occupied) {
      if (occupiedPlayer.isEmpty) {
        draw = false;
      }
    }
    if (draw) {
      showGameOverMessage('It\'s a draw');
      gameEnd = true;
    }
  }

  void showGameOverMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.pinkAccent,
        content: Text(
          "Game Over \n $message",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
