import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'GameHistory.dart';

class GridRotation extends StatefulWidget {
  @override
  _GridRotationState createState() => _GridRotationState();
}

class _GridRotationState extends State<GridRotation> with TickerProviderStateMixin{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadPreferences();
  }

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

    if(!history.contains(grid))
      history.add([...grid.map((subList) => [...subList])]);
      // history = [...history,grid];
  }
  bool isFirst = true;
  bool flag = false;
  bool gameStarted = false;
  bool timerRunning = true;
  bool isLoading = false;
  bool isGameOver = false;
  late LinearTimerController timerController = LinearTimerController(this);

  int gridClickCount = 0;
  bool isTimerEnabled = true;
  int timerValue = 30;
  String player1 = 'Player 1';
  String player2 = 'Player 2';
  final TextEditingController secondsController = TextEditingController();
  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();
  Key key = UniqueKey();
  List winnerGrid =[];
  bool isShow = false;
  bool showHistory = false;
  int indOfHistory = 0;
  List<List<List<int>>> history = [];


  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      // Check if preferences exist, otherwise set default values
      timerValue = prefs.getInt('userPreferredTime') ?? 30;
      player1 = prefs.getString('player1Name') ?? 'Player 1';
      player2 = prefs.getString('player2Name') ?? 'Player 2';
    });

    // If keys don't exist in SharedPreferences, save the default values
    if (!prefs.containsKey('userPreferredTime')) {
      await prefs.setInt('userPreferredTime',30);
    }
    if (!prefs.containsKey('player1Name')) {
      await prefs.setString('player1Name', player1);
    }
    if (!prefs.containsKey('player2Name')) {
      await prefs.setString('player2Name', player2);
    }
  }

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
          winnerGrid = [[i,j],[i,j+1],[i,j+2],[i,j+3]];
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
          winnerGrid = [[i,j],[i+1,j],[i+2,j],[i+3,j]];
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
          winnerGrid = [[i,j],[i+1,j+1],[i+2,j+2],[i+3,j+3]];
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
          winnerGrid = [[i,j],[i-1,j+1],[i-2,j+2],[i-3,j+3]];
          return true;
        }
      }
    }

    return false;
  }

  Future<void> _showDialog(bool isTimeout, bool isDraw)  async {
    timerController.stop();
    print('isShow');
    print(isShow);
    if(!isShow) {
      setState(() {
        isShow = true;
        timerController.stop();
      });

      print('isTimeout');
      print(isTimeout);
      int sec = isTimeout ? 0 : 3;
      await Future.delayed(Duration(seconds: sec));
      timerController.stop();
      showDialog(
          context: context,
          builder: (context)=>AlertDialog(
            backgroundColor: Colors.brown[50],
            title: isDraw ? Text('Match has been DRAW because there is no moves',
              style: GoogleFonts.itim(fontWeight: FontWeight.bold),):
            Text('${isFirst ? player2 : player1} Won ${isTimeout? 'by Timeout' : ''}',
              style: GoogleFonts.itim(fontWeight: FontWeight.bold),),
            content: Text('Do you really want Restart the GAME',
              style: GoogleFonts.itim(fontSize: 20),),
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
                  gridClickCount = 0;
                  timerController.reset();
                  setState(() {
                    timerController.stop();
                    isGameOver = false;
                    winnerGrid =[];
                    history=[];
                    isShow = true;
                  });
                },
                child: Text('Yes',style: TextStyle(fontSize: 20,color: Colors.green)),
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('NO',style: TextStyle(fontSize: 16,color: Colors.red)),
              ),

              if(!isTimeout)...[
                TextButton(
                  onPressed: (){
                    // if(!history.contains(grid))
                    //   history.add([...grid.map((subList) => [...subList])]);
                    Navigator.of(context).push(
                        MaterialPageRoute(builder:
                            (context) => Gamehistory(history: history, player1: player1, player2: player2, winnerGrid: winnerGrid,)
                        ));
                  },
                  child: Text('Replay',style: TextStyle(fontSize: 20,color: Colors.blue),),
                ),
              ],
            ],
          ));
    }

  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    secondsController.text = timerValue.toString();
    player1Controller.text = player1.toString();
    player2Controller.text = player2.toString();

    print(history);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (hasFourInARow(grid)) {
        isGameOver = true;
        // _showDialog(false,false);
        // isShow=false;
        // if(isShow)
        if(!history.contains(grid))
          history.add([...grid.map((subList) => [...subList])]);
        _showDialog(false,false);
        // showHistory = true;
      }else{
        isShow = false;
      }

      if(gridClickCount == 16){
        isGameOver=true;
        gridClickCount = 0;
        _showDialog(false,true);
      }
    });
    // timerController.start();
    // print('in build');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
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
      ),
    );
  }

  mobileView(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        topBar(),

        Text('Moving Marble Game',
          style: GoogleFonts.lobster(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            color: Colors.brown[900]
          ),),

        SizedBox(height: 30,),

        Text('${isFirst? player1 : player2}\'s Turn',
          style: GoogleFonts.kodeMono(fontSize: 24,fontWeight: FontWeight.bold),),

        SizedBox(height: 20,),

        Visibility(
          visible: isTimerEnabled,
            child: Container(
          height: 15,
          decoration: BoxDecoration(
              color: Colors.blue[900],
              border: Border.all(color: Colors.black)
          ),
          child: LinearTimer(
            key: key,
            duration: Duration(seconds: timerValue),
            controller: timerController,
            onTimerEnd: () {
              setState(() {
                isGameOver = true;
                _showDialog(true,false);
              });
            },
            minHeight: 8,
            color: isLoading ? Colors.white : !isFirst ? Colors.red : Colors.yellow,
          ),
        )
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
                    child: Text('Start Game' , style: GoogleFonts.permanentMarker(
                        color: Colors.white,
                        fontSize: 25
                    ),),
                    decoration: BoxDecoration(
                      // color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage("assets/bgButton.jpg"), // Background image
                        fit: BoxFit.fill, // Cover the entire screen
                      ),
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



        // SizedBox(height: 20,),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     IconButton(onPressed: (){
        //       setState(() {
        //         if(indOfHistory > 0){
        //           indOfHistory-=1;
        //         }
        //       });
        //     }, icon: Icon(Icons.arrow_back_sharp)),
        //     IconButton(onPressed: (){
        //       setState(() {
        //         if(indOfHistory < history.length-1){
        //           indOfHistory+=1;
        //         }
        //       });
        //     }, icon: Icon(Icons.arrow_forward_sharp)),
        //   ],
        // ) ,

        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.brown)
          ),
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
              winnerGrid =[];
              isShow = true;
              history=[];
              gameStarted = false;
              gridClickCount = 0;
            });
          },
          child: Text('Reset Game', style: GoogleFonts.inter(color: Colors.white),),
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              topBar(),

              SizedBox(height: 30,),

              Text('Moving Marble Game',
                style: GoogleFonts.lobster(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[900]
                ),),

              SizedBox(height: 20,),

              Text('${isFirst? player1 : player2}\'s Turn',
                style: GoogleFonts.kodeMono(fontSize: 18),),

              SizedBox(height: 20,),

              Visibility(
                  visible: isTimerEnabled,
                  child: Container(
                    height: 15,
                    width: MediaQuery.sizeOf(context).width * 0.4 ,
                    decoration: BoxDecoration(
                        color: Colors.blue[900],
                        border: Border.all(color: Colors.black)
                    ),
                    child: LinearTimer(
                      key: key,
                      duration: Duration(seconds: timerValue),
                      controller: timerController,
                      onTimerEnd: () {
                        setState(() {
                          isGameOver = true;
                          _showDialog(true,false);
                        });
                      },
                      minHeight: 8,
                      color: isLoading ? Colors.white : !isFirst ? Colors.red : Colors.yellow,
                    ),
                  )
              ),


              SizedBox(height: 40,),

              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.brown)
                ),
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
                    winnerGrid =[];
                    history=[];
                    isShow = true;
                    gameStarted = false;
                    gridClickCount = 0;
                  });
                },
                child: Text('Reset Game', style: GoogleFonts.inter(color: Colors.white),),
              ),
              // SizedBox(height: 20),
            ],
          ),

          SizedBox(width: 20,),
          Visibility(
            visible: gameStarted,
            replacement:
            Container(
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
                    height: 70,
                    width: MediaQuery.sizeOf(context).width * 0.5,
                    child: Text('Start Game' , style: GoogleFonts.permanentMarker(
                        color: Colors.white,
                        fontSize: 25
                    ),),
                    decoration: BoxDecoration(
                      // color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage("assets/bgButton.jpg"), // Background image
                        fit: BoxFit.fill, // Cover the entire screen
                      ),
                    ),
                  ),
                  // Container(
                  //   alignment: Alignment.center,
                  //   height: 50,
                  //   width: MediaQuery.sizeOf(context).width * 0.5,
                  //   child: Text('Start Game'),
                  //   color: Colors.red,
                  // ),
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

  topBar(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: (){
          showDialog(
              context: context,
              builder: (context)=>AlertDialog(
                backgroundColor: Colors.brown[50],
                title: Text('How to Play the Game',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(
                          text: '1. Starting the Game:\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '   • Decide which player will go first.\n',
                        ),
                        TextSpan(
                          text: '   • The first player places one of their marbles on any empty cell within the 4x4 grid.\n\n',
                        ),
                        TextSpan(
                          text: '2. Taking Turns:\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '   • Players alternate turns, placing one marble on any empty cell each time.\n',
                        ),
                        TextSpan(
                          text: '   • After each marble is placed, all marbles on the board move one cell counterclockwise:\n',
                        ),
                        TextSpan(
                          text: '       - Marbles in each row shift one step left.\n',
                        ),
                        TextSpan(
                          text: '       - Marbles in the leftmost cells move to the start of the row below (or above for the bottom row).\n\n',
                        ),
                        TextSpan(
                          text: '3. Winning the Game:\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '   • Align four of your own marbles in a straight line—horizontally, vertically, or diagonally.\n',
                        ),
                        TextSpan(
                          text: '   • The first player to achieve this alignment wins the game.\n\n',
                        ),
                        TextSpan(
                          text: '4. Ending the Game:\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '   • If no player aligns four marbles consecutively and no more moves are possible, the game is a draw.',
                        ),
                      ],
                    ),
                  ),
                ),
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

        IconButton(onPressed: (){
          timerController.stop();
          final TextEditingController secondsController = TextEditingController();
          final TextEditingController player1Controller = TextEditingController();
          final TextEditingController player2Controller = TextEditingController();

          secondsController.text =timerValue.toString();
          player1Controller.text = player1;
          player2Controller.text = player2;
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context)=>AlertDialog(
                backgroundColor: Colors.brown[50],
                title: Text('Settings',style: GoogleFonts.itim(fontWeight: FontWeight.bold),),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter  setState) {
                    return Container(
                      height: 220,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Timer',style: GoogleFonts.itim(fontSize: 18,fontWeight: FontWeight.w500),),
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
                                      style: GoogleFonts.itim(),
                                      controller: secondsController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Enter seconds",
                                        border: OutlineInputBorder(),
                                        labelStyle: GoogleFonts.itim()
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
                                style: GoogleFonts.itim(),
                                decoration: InputDecoration(
                                  labelText: "Player 1 Name",
                                  border: OutlineInputBorder(),
                                    labelStyle: GoogleFonts.itim()
                                ),
                              ),
                            ),
                        
                            SizedBox(height: 20,),
                            Container(
                              height: 40,
                              // width: 150,
                              child: TextField(
                                controller: player2Controller,
                                style: GoogleFonts.itim(),
                                decoration: InputDecoration(
                                  labelText: "Player 2 Name",
                                  border: OutlineInputBorder(),
                                    labelStyle: GoogleFonts.itim()
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },

                ),
                actions: [
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('Cancel', style: GoogleFonts.itim(color: Colors.red),),
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

                            _savePreferences(timerValue,player1,player2);
                            // gameStarted = false;
                            key = UniqueKey();

                            grid = List.generate(
                              4,
                                  (i) => List.generate(4, (j) => 0),
                            );
                            isFirst = true;
                            flag = false;
                            gameStarted = false;
                            gridClickCount = 0;
                            timerController.reset();
                            timerController.stop();
                            isGameOver = false;
                            winnerGrid =[];
                            history=[];
                            isShow = true;
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
                    child: Text('Submit',style: GoogleFonts.itim(color: Colors.green,fontWeight: FontWeight.bold)),
                  ),
                ],
              ));
        },
            icon: Icon(Icons.settings,size: 30,color: Colors.blue,)),

      ],
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

          // print(isGameOver);
          // print(winnerGrid.contains([row,col]));
          // print(winnerGrid);

          bool containsTarget = false;
          if(winnerGrid.length > 0)
           containsTarget = winnerGrid.any((element) => (element[0]==row && element[1]==col));

          // print(containsTarget);

          return
            Card(
            // color: Colors.blue,
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: ()async{
                if(!isGameOver && grid[row][col]==0) {
                  gridClickCount++;
                  grid[row][col] = isFirst ? 1 : 2;
                  timerController.stop();

                  // history.add(grid);
                  // print(history);
                  // history+=(grid);
                  isFirst = !isFirst;
                  flag = hasFourInARow(grid);
                  if (flag) {
                    setState(() {
                      isGameOver = true;
                    });

                    // await Future.delayed(Duration(seconds: 5));
                    // _showDialog(false,false);
                  } else {
                    setState(() {});
                    // isLoading = true;
                    _showImageWithBlur();
                    timerController.stop();
                    await Future.delayed(Duration(milliseconds: 1000));
                    rotateGrid();
                    timerController.reset();
                    timerController.start();
                  }
                }
              },
              child: AnimatedContainer(
                alignment: Alignment.centerRight,
                duration: Duration(milliseconds: 800),
                curve: Curves.linearToEaseOut,
                decoration: BoxDecoration(
                color: isGameOver ? containsTarget ? Colors.green : Colors.blue[50]
                    : Colors.blue[50],
                  // color: Colors.blue[50],
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
    Timer(Duration(milliseconds: 1000), () {
      setState(() {
        isLoading = false;
      });
    });
  }


  Future<void> _savePreferences(int time , String p1, String p2) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userPreferredTime', time);
    await prefs.setString('player1Name', p1);
    await prefs.setString('player2Name', p2);
  }
}
