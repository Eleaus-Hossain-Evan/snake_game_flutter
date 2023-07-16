import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum Snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomeScreenState extends State<HomeScreen> {
  // grid dimension
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  // currentScore
  int currentScore = 0;

  // game start flag
  bool gameHasStarted = false;

  // snake position
  List<int> snakePos = [0, 1, 2];

  // food position
  int foodPos = 55;

  // snake direction; initially the direction is right

  var currentDirection = Snake_Direction.RIGHT;

  // start the game!
  void startGame() {
    //  game starting
    gameHasStarted = true;

    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        // keep the snake moving!!
        moveSnake();

        // check if the game is over
        if (gameOver()) {
          timer.cancel();

          // display a message to the user

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Game Over!"),
              content: Text("You score is $currentScore"),
              actions: [
                TextButton(
                    onPressed: () {
                      // reset the game
                      resetGame();
                      // close the dialog
                      Navigator.of(context).pop();
                    },
                    child: const Text("Play Again"))
              ],
            ),
          );
        }
      });
    });
  }

  eatFood() {
    currentScore++;
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case Snake_Direction.RIGHT:
        {
          // add a new head
          // if snake is at the right wall, need to re adjust
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
        break;
      case Snake_Direction.LEFT:
        {
          // add a new head
          // if snake is at the left wall, need to re adjust
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;
      case Snake_Direction.UP:
        {
          // add a new head
          // if snake is at the top wall, need to re adjust
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;
      case Snake_Direction.DOWN:
        {
          // add a new head
          // if snake is at the top wall, need to re adjust
          if (snakePos.last + rowSize > totalNumberOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;
      default:
    }

    // check if snake eats food
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      // remove the tail
      snakePos.removeAt(0);
    }
  }

  // GAME OVER!!
  bool gameOver() {
    //  the game is over when the snake runs into itself,,
    //  this occurs when there is a duplicate value inside snakePos list...

    //  this list is the body of the snake ( no head )
    List<int> body = snakePos.sublist(0, snakePos.length - 1);

    if (body.contains(snakePos.last)) {
      return true;
    }

    return false;
  }

  // reset the game
  void resetGame() {
    snakePos = [0, 1, 2];
    foodPos = 55;
    currentDirection = Snake_Direction.RIGHT;
    gameHasStarted = false;
    currentScore = 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0 && currentDirection != Snake_Direction.UP) {
            currentDirection = Snake_Direction.DOWN;
          } else if (details.delta.dy < 0 &&
              currentDirection != Snake_Direction.DOWN) {
            currentDirection = Snake_Direction.UP;
          }
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0 &&
              currentDirection != Snake_Direction.LEFT) {
            currentDirection = Snake_Direction.RIGHT;
          } else if (details.delta.dx < 0 &&
              currentDirection != Snake_Direction.RIGHT) {
            currentDirection = Snake_Direction.LEFT;
          }
        },
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text.rich(
                  TextSpan(
                    text: "Current Score: ",
                    style: const TextStyle(
                      fontSize: 32,
                    ),
                    children: [
                      TextSpan(
                        text: "$currentScore",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: GridView.builder(
                  itemCount: totalNumberOfSquares,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowSize,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (snakePos.contains(index)) {
                      return const SnakePixel();
                    } else if (foodPos == index) {
                      return const FoodPixel();
                    } else {
                      return const BlankPixel();
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: MaterialButton(
                  color: Colors.deepPurple,
                  onPressed: gameHasStarted ? null : startGame,
                  child: const Text(
                    "Play",
                    style: TextStyle(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlankPixel extends StatelessWidget {
  const BlankPixel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class SnakePixel extends StatelessWidget {
  const SnakePixel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class FoodPixel extends StatelessWidget {
  const FoodPixel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
