import 'package:chess_app_example/classes/classes.dart';
import 'package:chess_app_example/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
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

              Piece piece = widget.bm.GetPiece(pos);
              Image img = getImageOfPiece(piece);

              return DragTarget<Piece>(
                onAccept: (data) {
                  setState(() {
                    widget.bm.ReplacePiece(data, pos);
                });
              },
              builder: (context, List<dynamic> candidateData,
                  List<dynamic> rejectedData) {
                return img == null
                    ? SizedBox(
                        height: 0,
                        width: 0,
                      )
                    : Draggable<Piece>(
                        data: piece,
                        //feedbackOffset: Offset.fromDirection(0, 50),
                        feedback: SizedBox(
                          child: img,
                          width: 60,
                          height: 60,
                        ),
                        childWhenDragging: Container(),
                        child: FittedBox(fit: BoxFit.fill, child: img),
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
