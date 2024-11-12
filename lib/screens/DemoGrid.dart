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
  bool isGameOver = false;
  late LinearTimerController timerController = LinearTimerController(this);

  bool isTimerEnabled = true;
  int timerValue = 30;
  String player1 = 'Player 1';
  String player2 = 'Player 2';
  final TextEditingController secondsController = TextEditingController();
  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();
  Key key = UniqueKey();
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

  void _showDialog(bool isTimeout){
    timerController.stop();
    showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          title: Text('${isFirst ? player2 : player1} Won ${isTimeout? 'by Timeout' : ''}'),
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
                gameStarted = false;
                timerController.reset();
                setState(() {
                  timerController.stop();
                  isGameOver = false;
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
    secondsController.text = timerValue.toString();
    player1Controller.text = player1.toString();
    player2Controller.text = player2.toString();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (hasFourInARow(grid)) {
    //     isGameOver = true;
    //     _showDialog(false);
    //   }
    //   else{
    //     // timerController.start();
    //   }
    // });
    // timerController.start();
    print('in build');
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/back.jpg"), // Background image
              fit: BoxFit.fill, // Cover the entire screen
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: orientation == Orientation.landscape ? tabView() : mobileView(),
            ),
          ),
        ),
      ),
    );
  }

  mobileView(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            IconButton(onPressed: (){
              timerController.stop();
                        final TextEditingController secondsController = TextEditingController();
                        final TextEditingController player1Controller = TextEditingController();
                        final TextEditingController player2Controller = TextEditingController();
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context)=>AlertDialog(
                    title: Text('Settings'),
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter  setState) {
                        return Container(
                          height: 220,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Timer'),
                                  Switch(
                                      value: isTimerEnabled,
                                      onChanged: (s){
                                        print(s);
                                        setState(() {
                                          isTimerEnabled = s;
                                        });
                                      })
                                ],
                              ),

                              if(isTimerEnabled)...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 150,
                                      child: TextField(
                                        controller: secondsController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: "Enter seconds",
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          print(value);
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 30,),
                              ],

                              Container(
                                height: 40,
                                // width: 150,
                                child: TextField(
                                  controller: player1Controller,
                                  // keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Player 1 Name",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),

                              SizedBox(height: 20,),
                              Container(
                                height: 40,
                                // width: 150,
                                child: TextField(
                                  controller: player2Controller,
                                  // keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Player 2 Name",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },

                    ),
                    actions: [
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text('Cancel', style: TextStyle(color: Colors.red),),
                      ),
                      TextButton(
                        onPressed: (){
                          if(secondsController.text != '' && player1Controller.text !=''
                              && player2Controller.text!='') {
                            WidgetsBinding.instance.addPostFrameCallback((_) {

                              setState(() {
                                timerValue = int.parse(
                                    secondsController.text.toString());
                                player1 = player1Controller.text;
                                player2 = player2Controller.text;
                                // gameStarted = false;
                                key = UniqueKey();

                                grid = List.generate(
                                  4,
                                      (i) => List.generate(4, (j) => 0),
                                );
                                isFirst = true;
                                flag = false;
                                gameStarted = false;
                                timerController.reset();
                                timerController.stop();
                                isGameOver = false;
                              });
                            });
                            Navigator.pop(context);
                          }
                          else{
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter all the details'),
                                  duration: Duration(seconds: 2),
                                ),
                              );

                            });
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.green[50])
                        ),
                        child: Text('Submit',style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  ));
            },
                icon: Icon(Icons.settings,size: 30,color: Colors.blue,)),

            IconButton(onPressed: (){
              showDialog(
                  context: context,
                  builder: (context)=>AlertDialog(
                    title: Text(''),
                    content: Text('Do you really want Restart the GAME'),
                    actions: [
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text('Thanks!!'),
                      ),
                    ],
                  ));
            },
                icon: Icon(Icons.help,size: 30,color: Colors.red,)),
          ],
        ),

        Text('Moving Marble Game',
          style: TextStyle(fontSize: 25),),

        SizedBox(height: 20,),

        Text('${isFirst? player1 : player2}\'s Turn',
          style: TextStyle(fontSize: 18),),

        SizedBox(height: 20,),
        LinearTimer(
          key: key,
          duration: Duration(seconds: timerValue),
          controller: timerController,
          onTimerEnd: () {
            setState(() {
              isGameOver = true;
              _showDialog(true);
            });
          },
          minHeight: 8,
          color: isLoading ? Colors.white : !isFirst ? Colors.red : Colors.yellow,
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
                  height: 70,
                  width: MediaQuery.sizeOf(context).width,
                  child: Text('Start Game'),
                  decoration: BoxDecoration(
                  color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(20)
                  ),
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
            isFirst = true;
            isLoading = false;
            flag = false;
            setState(() {
              timerController.reset();
              timerController.stop();
              isGameOver = false;
              gameStarted = false;
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

              Text('${isFirst? player1 : player2}\'s Turn',
                style: TextStyle(fontSize: 18),),

              SizedBox(height: 20,),
              Container(
                width: MediaQuery.sizeOf(context).width * 0.4 ,
                child: LinearTimer(
                  duration: const Duration(seconds: 10),
                  controller: timerController,
                  onTimerEnd: () {
                    setState(() {
                      isGameOver = true;
                      _showDialog(true);
                    });
                  },
                  minHeight: 8,
                  color: isLoading ? Colors.white : !isFirst ? Colors.red : Colors.yellow,
                ),
              ),

              SizedBox(height: 40,),

              ElevatedButton(
                onPressed: (){
                  grid = List.generate(
                    4,
                        (i) => List.generate(4, (j) => 0),
                  );
                  isFirst = true;
                  isLoading = false;
                  flag = false;
                  gameStarted = false;
                  setState(() {
                    timerController.reset();
                    timerController.stop();
                    isGameOver = false;
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
                if(!isGameOver && grid[row][col]==0) {
                  grid[row][col] = isFirst ? 1 : 2;
                  timerController.stop();

                  isFirst = !isFirst;
                  flag = hasFourInARow(grid);
                  if (flag) {
                    setState(() {});
                    isGameOver = true;
                    _showDialog(false);
                  } else {
                    setState(() {});
                    // isLoading = true;
                    _showImageWithBlur();
                    timerController.stop();
                    await Future.delayed(Duration(milliseconds: 1200));
                    rotateGrid();
                    timerController.reset();
                    timerController.start();
                  }
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
