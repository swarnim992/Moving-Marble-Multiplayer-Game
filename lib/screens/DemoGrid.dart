import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:linear_timer/linear_timer.dart';


class GridRotation extends StatefulWidget {
  @override
  _GridRotationState createState() => _GridRotationState();
}

class _GridRotationState extends State<GridRotation> with TickerProviderStateMixin{
  // Initialize the grid with values
  List<List<int>> grid = List.generate(
    4, (i) => List.generate(4, (j) => 0),
  );

  // Function to rotate the grid clockwise
  void rotateGrid() {
    setState(() {
      int row = 0, col = 0;
      int prev, curr;
      int m=4,n=4;

      while (row < m && col < n) {
        if (row + 1 == m || col + 1 == n)
          break;

        // Store the first element of the next column
        prev = grid[row][col + 1];

        // Move elements of the first column from the remaining rows
        for (int i = row; i < m; i++) {
          curr = grid[i][col];
          grid[i][col] = prev;
          prev = curr;
        }
        col++;

        // Move elements of the last row from the remaining columns
        for (int i = col; i < n; i++) {
          curr = grid[m - 1][i];
          grid[m - 1][i] = prev;
          prev = curr;
        }
        m--;

        // Move elements of the last column from the remaining rows
        if (col < n) {
          for (int i = m - 1; i >= row; i--) {
            curr = grid[i][n - 1];
            grid[i][n - 1] = prev;
            prev = curr;
          }
        }
        n--;

        // Move elements of the first row from the remaining columns
        if (row < m) {
          for (int i = n - 1; i >= col; i--) {
            curr = grid[row][i];
            grid[row][i] = prev;
            prev = curr;
          }
        }
        row++;
      }
    });
  }
  bool isFirst = true;
  bool flag = false;
  bool gameStarted = false;
  bool timerRunning = true;
  bool isLoading = false;
  late LinearTimerController timerController = LinearTimerController(this);
  bool hasFourInARow(List<List<int>> grid) {
    int rows = 4; // fixed 4x4 grid
    int cols = 4;

    // Check horizontally
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j <= cols - 4; j++) {
        if (grid[i][j] == grid[i][j + 1] &&
            grid[i][j] == grid[i][j + 2] &&
            grid[i][j] == grid[i][j + 3] &&
            grid[i][j] != 0
        ) {
          return true;
        }
      }
    }

    // Check vertically
    for (int i = 0; i <= rows - 4; i++) {
      for (int j = 0; j < cols; j++) {
        if (grid[i][j] == grid[i + 1][j] &&
            grid[i][j] == grid[i + 2][j] &&
            grid[i][j] == grid[i + 3][j] &&
            grid[i][j] != 0) {
          return true;
        }
      }
    }

    // Check diagonally (top-left to bottom-right)
    for (int i = 0; i <= rows - 4; i++) {
      for (int j = 0; j <= cols - 4; j++) {
        if (grid[i][j] == grid[i + 1][j + 1] &&
            grid[i][j] == grid[i + 2][j + 2] &&
            grid[i][j] == grid[i + 3][j + 3] &&
            grid[i][j] != 0) {
          return true;
        }
      }
    }

    // Check diagonally (bottom-left to top-right)
    for (int i = 3; i < rows; i++) {
      for (int j = 0; j <= cols - 4; j++) {
        if (grid[i][j] == grid[i - 1][j + 1] &&
            grid[i][j] == grid[i - 2][j + 2] &&
            grid[i][j] == grid[i - 3][j + 3] &&
            grid[i][j] != 0) {
          return true;
        }
      }
    }

    return false;
  }

  void _showDialog(){
    showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          title: Text('Player ${isFirst ? '2' : '1'} Won'),
          content: Text('Do you really want Restart the GAME'),
          actions: [
            TextButton(
              onPressed: (){
                grid = List.generate(
                  4,
                      (i) => List.generate(4, (j) => 0),
                );
                isFirst = true;
                flag = false;
                Navigator.of(context).pop();
                gameStarted = true;
                timerController.reset();
                setState(() {

                });
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text('NO'),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasFourInARow(grid)) {
        _showDialog();
      }
      else{
        // timerController.start();
      }
    });
    // timerController.start();
    print('in build');
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/back.jpg"), // Background image
              fit: BoxFit.fill, // Cover the entire screen
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: orientation == Orientation.landscape ? tabView() : mobileView(),
          ),
        ),
      ),
    );
  }

  mobileView(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Text('Moving Marble Game',
          style: TextStyle(fontSize: 25),),

        SizedBox(height: 20,),

        Text('${isFirst? 'Player 1' : 'Player 2'}\'s Turn',
          style: TextStyle(fontSize: 18),),

        SizedBox(height: 20,),
        LinearTimer(
          duration: const Duration(seconds: 10),
          controller: timerController,
          onTimerEnd: () {
            setState(() {
              _showDialog();
            });
          },
          minHeight: 8,
          color: isFirst ? Colors.red : Colors.yellow,
        ),

        SizedBox(height: 40,),

        Visibility(
          visible: gameStarted,
          replacement: Container(
            height: 450,
            width: MediaQuery.sizeOf(context).width,
            child: Center(
              child: MaterialButton(
                onPressed: (){
                  setState(() {
                    gameStarted = true;
                    timerController.start();
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  width: MediaQuery.sizeOf(context).width,
                  child: Text('Start Game'),
                  color: Colors.red,
                ),
              ),
            ),
          ),
          child: Container(
            height: 450,
            child: isLoading
                ? Container(
              height: 450,
              child: Stack(
                children: [
                  marbleGrid(),
                  Opacity(
                    opacity: 0.1,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 400,
                      child: Image.asset(
                        'assets/rotate.gif', // Replace with your PNG asset
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                ],
              ),
            )
                :marbleGrid(),
          ),
        ),


        ElevatedButton(
          onPressed: (){
            grid = List.generate(
              4,
                  (i) => List.generate(4, (j) => 0),
            );
            setState(() {
              timerController.start();
            });
          },
          child: Text('Reset Game'),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  tabView(){
    return Container(
      height: MediaQuery.sizeOf(context).height,
      width:  MediaQuery.sizeOf(context).width,
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Text('Moving Marble Game',
                style: TextStyle(fontSize: 25),),

              SizedBox(height: 20,),

              Text('${isFirst? 'Player 1' : 'Player 2'}\'s Turn',
                style: TextStyle(fontSize: 18),),

              SizedBox(height: 20,),
              Container(
                width: MediaQuery.sizeOf(context).width * 0.4 ,
                child: LinearTimer(
                  duration: const Duration(seconds: 10),
                  controller: timerController,
                  onTimerEnd: () {
                    setState(() {
                      _showDialog();
                    });
                  },
                  minHeight: 8,
                  color: isFirst ? Colors.red : Colors.yellow,
                ),
              ),

              SizedBox(height: 40,),

              ElevatedButton(
                onPressed: (){
                  grid = List.generate(
                    4,
                        (i) => List.generate(4, (j) => 0),
                  );
                  setState(() {
                    timerController.start();
                  });
                },
                child: Text('Reset Game'),
              ),
              SizedBox(height: 20),
            ],
          ),

          SizedBox(width: 20,),
          Visibility(
            visible: gameStarted,
            replacement: Container(
              height: 450,
              width: MediaQuery.sizeOf(context).width * 0.5,
              child: Center(
                child: MaterialButton(
                  onPressed: (){
                    setState(() {
                      gameStarted = true;
                      timerController.start();
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    width: MediaQuery.sizeOf(context).width * 0.5,
                    child: Text('Start Game'),
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            child: Container(
              // height: ,
              child: isLoading
                  ? Container(
                // height: 450,
                child: Stack(
                  children: [
                    marbleGrid(),
                    Opacity(
                      opacity: 0.1,
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 0.5,
                        height: 400,
                        child: Image.asset(
                          'assets/rotate.gif', // Replace with your PNG asset
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  ],
                ),
              )
                  :marbleGrid(),
            ),
          ),
        ],
      ),
    );
  }

  marbleGrid(){
    SliverGridDelegateWithFixedCrossAxisCount sliverGridDelegateWithFixedCrossAxisCount =
    SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        mainAxisExtent: MediaQuery.sizeOf(context).height * 0.20

    );

    SliverGridDelegateWithFixedCrossAxisCount sliverGridDelegateWithFixedCrossAxisCount1 =
    SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
    );
    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: Orientation.landscape == MediaQuery.of(context).orientation ?
              MediaQuery.sizeOf(context).width * 0.5 :
              MediaQuery.sizeOf(context).width,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        // physics: NeverScrollableScrollPhysics(),
        gridDelegate:Orientation.landscape == MediaQuery.of(context).orientation ?
                    sliverGridDelegateWithFixedCrossAxisCount :
                    sliverGridDelegateWithFixedCrossAxisCount1,
        itemCount: 16,
        itemBuilder: (context, index) {
          int row = index ~/ 4;
          int col = index % 4;

          return
            Card(
            // color: Colors.blue,
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: ()async{
                grid[row][col] = isFirst ? 1 : 2;
                timerController.stop();


                isFirst = !isFirst;
                flag  = hasFourInARow(grid);
                if(flag){
                  setState(() {});
                  _showDialog();
                }
                else {
                  setState(() {

                  });
                  // isLoading = true;
                  _showImageWithBlur();
                  timerController.stop();
                  await Future.delayed(Duration(milliseconds: 1200));
                  rotateGrid();
                  timerController.reset();
                  timerController.start();
                }
              },
              child: AnimatedContainer(
                // color: grid[row][col] == 0 ?
                // Colors.blue :
                // grid[row][col] == 1
                //     ? Colors.red : Colors.yellow,
                alignment: Alignment.centerRight,
                duration: Duration(milliseconds: 1000),
                curve: Curves.linearToEaseOut,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  image:  grid[row][col] == 0 ? null:
                  DecorationImage(
                    image: grid[row][col] == 1
                        ? AssetImage("assets/player1.png") :
                    AssetImage("assets/player2.png"), // Background image
                    fit: BoxFit.fill, // Cover the entire screen
                  ),
                    border: Border.all(color: Colors.black)

                ),
                child: Center(
                  child: Text(
                    ' ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageWithBlur() {
    setState(() {
      isLoading = true;
    });

    // Set a timer to hide the image after 2 seconds
    Timer(Duration(milliseconds: 1200), () {
      setState(() {
        isLoading = false;
      });
    });
  }

}
