import 'package:chess_app_example/classes/classes.dart';
import 'package:chess_app_example/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  print('app loaded');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Chess App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'My Chess App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final BoardManager bm = new BoardManager();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  BoardPosition hoverHighlight;
  bool hoverWillAccept;

  @override
  void initState() {
    widget.bm.Setup();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(


          title: Text(widget.title),
        ),

        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
          itemCount: 64,
          itemBuilder: (BuildContext context, int index) {
            int i = (index / 8).floor();
            int j = index % 8;

            BoardPosition pos = new BoardPosition(i, j);
            Space space = widget.bm.GetSpace(pos);
            Piece piece = space.piece;
            Image img = getImageOfPiece(piece);

            // Main content for the space
            Widget spaceContent = piece == null ? Empty() :
            Draggable<Piece>(
                dragAnchor: DragAnchor.pointer,
                maxSimultaneousDrags: 1,
                data: piece,
                //feedbackOffset: Offset.fromDirection(0, 50),
                feedback: Transform.translate(
                  offset: Offset(-40, -40),
                  child: SizedBox(
                    child: Opacity(child: img, opacity: 0.5,),
                    width: 80,
                    height: 80,
                  ),
                ),
                childWhenDragging: Container(),
                child: Align(child: img, alignment: Alignment.center,) //FittedBox(fit: BoxFit.none, child: img),
            );

            // Coloured square which represents the highlight when hovering a piece over a square.
            Widget highlight = hoverHighlight == null || !hoverHighlight.Equals(pos) ? Empty() :
              IgnorePointer(
                child: Opacity(
                  child: Container(color: hoverWillAccept ? Colors.green : Colors.red),
                  opacity: 0.3,
                ));

            return DragTarget<Piece>(

              onAccept: (piece) {
                setState(() {
                  widget.bm.ReplacePiece(piece, pos);
                  hoverHighlight = null;
                });

                widget.bm.SwitchTurns();

                // Detect promotion opportunities
                if(widget.bm.DetectPromotion(piece, pos)) {
                  print('promotion detected!');

                  // TODO: Offer promotion, then calculate valid moves

                }
                  else{
                    widget.bm.CalculateValidMoves();
                  }
              },

              onWillAccept: (piece){
                bool isValidMove = widget.bm.IsValidMove(piece, pos);
                setState(() {
                  this.hoverHighlight = pos;
                  this.hoverWillAccept = isValidMove;
                });
                  return isValidMove;
                },

              onLeave: (piece){
                setState(() {
                  this.hoverHighlight = null;
                  this.hoverWillAccept = null;
                });
              },

              builder: (context, List<dynamic> candidateData,
                  List<dynamic> rejectedData) {

                  return Stack(
                    children: [

                      spaceContent,

                      highlight

                    ],
                  );


              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){},
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class Empty extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 0, width:  0);
  }

}
