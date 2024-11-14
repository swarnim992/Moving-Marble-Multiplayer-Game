

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Gamehistory extends StatefulWidget {
  final List<dynamic> history;
  final String player1;
  final String player2;
  final List winnerGrid;
  const Gamehistory({super.key, required this.history, required this.player1, required this.player2, required this.winnerGrid});

  @override
  State<Gamehistory> createState() => _GamehistoryState();
}

class _GamehistoryState extends State<Gamehistory> {

  int indOfHistory = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.history[widget.history.length-1] == widget.history[widget.history.length-2]){
      widget.history.removeLast();
    }
    indOfHistory = widget.history.length-1;
  }

  @override
  Widget build(BuildContext context) {

  final orientation = MediaQuery.of(context).orientation;
  print(indOfHistory);
  print(widget.history[indOfHistory]);
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
        Text('Moving Marble Game',
          style: GoogleFonts.lobster(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.brown[900]
          ),),

        SizedBox(height: 20,),

        Text('${indOfHistory%2==0 ? widget.player1 : widget.player2}\'s Turn',
          style: GoogleFonts.kodeMono(fontSize: 18),),

        SizedBox(height: 20,),

        SizedBox(height: 40,),


        Container(
          height: 450,
          child: marbleGrid(widget.history[indOfHistory]),
        ),


        SizedBox(height: 20,),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: (){
              setState(() {
                if(indOfHistory > 0){
                  indOfHistory-=1;
                }
              });
            }, icon: Icon(Icons.arrow_back_sharp,size: 40,),
            // color: Colors.blue,
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.black54)),),
            IconButton(onPressed: (){
              setState(() {
                if(indOfHistory < widget.history.length-1){
                  indOfHistory+=1;
                }
              });
            }, icon: Icon(Icons.arrow_forward_sharp,size: 40,),
                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.black54))),
          ],
        ) ,

        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.brown)
          ),
          onPressed: (){
              Navigator.pop(context);
              Navigator.pop(context);
          },
          child: Text('Back', style: GoogleFonts.inter(color: Colors.white),),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  tabView(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width * 0.4,
          child: Column(
            children: [
              Text('Moving Marble Game',
                style: GoogleFonts.lobster(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[900]
                ),),

              SizedBox(height: 20,),

              Text('${indOfHistory%2==0 ? widget.player1 : widget.player2}\'s Turn',
                style: GoogleFonts.kodeMono(fontSize: 18),),

              SizedBox(height: 20,),

              SizedBox(height: 40,),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: (){
                    setState(() {
                      if(indOfHistory > 0){
                        indOfHistory-=1;
                      }
                    });
                  }, icon: Icon(Icons.arrow_back_sharp,size: 40,),
                    // color: Colors.blue,
                    style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.black54)),),
                  IconButton(onPressed: (){
                    setState(() {
                      if(indOfHistory < widget.history.length-1){
                        indOfHistory+=1;
                      }
                    });
                  }, icon: Icon(Icons.arrow_forward_sharp,size: 40,),
                      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.black54))),
                ],
              ) ,

              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.brown)
                ),
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('Back', style: GoogleFonts.inter(color: Colors.white),),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),


        Container(
          // height: 450,
          child: marbleGrid(widget.history[indOfHistory]),
        ),
      ],
    );
  }

  marbleGrid(List grid){
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
          if(widget.winnerGrid.length > 0 && indOfHistory == widget.history.length-1)
            containsTarget = widget.winnerGrid.any((element) => (element[0]==row && element[1]==col));

          // print(containsTarget);

          return
            Card(
              // color: Colors.blue,
              margin: EdgeInsets.zero,
              child: InkWell(
                child: AnimatedContainer(
                  alignment: Alignment.centerRight,
                  duration: Duration(milliseconds: 800),
                  curve: Curves.linearToEaseOut,
                  decoration: BoxDecoration(
                      color: containsTarget ? Colors.green : Colors.blue[50],
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
}
