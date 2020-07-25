import 'package:chess_app_example/utils/utils.dart';
import 'package:flutter/src/widgets/image.dart';

enum PieceType{
  pawn,
  knight,
  bishop,
  queen,
  king,
  rook
}

enum PieceColor{
  white,
  black
}

class BoardManager{

  BoardManager(){
    board = new List<List<Space>>();
    for(int i = 0; i<8; i++)
    {
      List<Space> row = [];
      board.add(row);

      for(int j = 0; j<8; j++)
      {
        row.add(new Space());
      }
    }
  }

  List<List<Space>> board;

  void PlacePiece(Piece piece, BoardPosition pos) {
    board[pos.row][pos.col].piece = piece;

    // TODO Also remove piece from wherever it previously was
  }

  void Setup() {

    for(int i = 0; i < 8; i++)
      {
        for(int j = 0; j<8; j++)
        {
          BoardPosition pos = new BoardPosition(i, j);
          if(i == 1) {PlacePiece(new Pawn(PieceColor.black), pos);}
          else if(i == 6) {PlacePiece(new Pawn(PieceColor.white), pos);}
          else if(i == 0 || i == 7){
            PieceColor pieceColor = i==0 ? PieceColor.black : PieceColor.white;
            if(j == 0 || j == 7) PlacePiece(new Rook(pieceColor), pos);
            else if(j == 1 || j==6) PlacePiece(new Knight(pieceColor), pos);
            else if(j == 2 || j==5) PlacePiece(new Bishop(pieceColor), pos);
            else if(j == 3) PlacePiece(new Queen(pieceColor), pos);
            else PlacePiece(new King(pieceColor), pos);
          }
          else{
            PlacePiece(null, pos);
          }

        }
      }

  }

  Piece GetPiece(BoardPosition pos) {
    return board[pos.row][pos.col].piece;
  }

}

class Space {
  Piece piece = null;
}

class Piece{
  Piece(this.color);
  PieceType type;
  PieceColor color;
  List<BoardPosition> ValidMoves = [];
}

class Pawn extends Piece{Pawn(PieceColor color) : super(color) {this.type = PieceType.pawn;}}
class Knight extends Piece{Knight(PieceColor color) : super(color){this.type = PieceType.knight;}}
class Bishop extends Piece{Bishop(PieceColor color) : super(color){this.type = PieceType.bishop;}}
class King extends Piece{King(PieceColor color) : super(color){this.type = PieceType.king;}}
class Queen extends Piece{Queen(PieceColor color) : super(color){this.type = PieceType.queen;}}
class Rook extends Piece{Rook(PieceColor color) : super(color){this.type = PieceType.rook;}}

class BoardPosition {

  BoardPosition(this.row, this.col);

  int row;
  int col;
}