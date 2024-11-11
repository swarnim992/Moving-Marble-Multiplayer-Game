import 'package:flutter/material.dart';


class GridRotation extends StatefulWidget {
  @override
  _GridRotationState createState() => _GridRotationState();
}

class _GridRotationState extends State<GridRotation> {
  // Initialize the grid with values
  List<List<int>> grid = List.generate(
    4,
        (i) => List.generate(4, (j) => 0),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // GridView to display 4x4 grid
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              int row = index ~/ 4;
              int col = index % 4;

              return Card(
                // color: Colors.blue,
                margin: EdgeInsets.all(8),
                child: InkWell(
                  onTap: ()async{
                    grid[row][col] = isFirst ? 1 : 2;

                    isFirst = !isFirst;
                    flag  = hasFourInARow(grid);

                    if(flag){
                      setState(() {

                      });
                      showDialog(context: context,
                          builder: (context)=>AlertDialog(
                            title: Text('Player ${isFirst ? 'Player 2' : 'Player 1'} Won'),
                            content: Text('Do you really want Restart the GAME'),
                            actions: [
                              TextButton(
                                onPressed: (){
                                  grid = List.generate(
                                    4,
                                        (i) => List.generate(4, (j) => 0),
                                  );
                                  Navigator.of(context).pop();

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
                          ))
                      ;
                    }
                    else {
                      setState(() {

                      });
                      await Future.delayed(Duration(seconds: 2));
                      rotateGrid();
                    }
                  },
                  child: AnimatedContainer(
                    color: grid[row][col] == 0 ?
                            Colors.blue :
                              grid[row][col] == 1
                              ? Colors.red : Colors.yellow,
                    alignment: Alignment.centerRight,
                    duration: Duration(milliseconds: 700),
                    curve: Curves.linearToEaseOut,
                    child: Center(
                      child: Text(
                        '${grid[row][col]}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Button to rotate grid
        ElevatedButton(
          onPressed: (){
            grid = List.generate(
              4,
                  (i) => List.generate(4, (j) => 0),
            );
            setState(() {

            });
          },
          child: Text('Reset Game'),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}


// class ColorWipe extends StatefulWidget {
//   @override
//   _ColorWipeState createState() => _ColorWipeState();
// }
// class _ColorWipeState extends State<ColorWipe> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _animation;
//   bool _isWiped = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 1),
//     );
//
//     _animation = Tween<Offset>(
//       begin: Offset(0.0, -1.0),
//       end: Offset(0.0, 0.0),
//     ).animate(_controller);
//   }
//
//   void _onButtonPressed() {
//     setState(() {
//       _isWiped = !_isWiped;
//       _isWiped ? _controller.forward() : _controller.reverse();
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Stack(
//           children: [
//             Container(
//               width: 200,
//               height: 100,
//               color: Colors.grey, // Background color
//             ),
//             SlideTransition(
//               position: _animation,
//               child: Container(
//                 width: 200,
//                 height: 100,
//                 color: Colors.blue, // Wipe color
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 20),
//         ElevatedButton(
//           onPressed: _onButtonPressed,
//           child: Text('Animate Color Wipe'),
//         ),
//       ],
//     );
//   }
// }