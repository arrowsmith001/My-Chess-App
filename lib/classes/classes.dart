import 'dart:math';

import 'package:chess_app_example/utils/utils.dart';
import 'package:flutter/cupertino.dart';
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
  bool whitesTurn = true;

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
          if(i == 1) {PlacePiece(new Pawn(PieceColor.black, pos), pos);}
          else if(i == 6) {PlacePiece(new Pawn(PieceColor.white, pos), pos);}
          else if(i == 0 || i == 7){
            PieceColor pieceColor = i==0 ? PieceColor.black : PieceColor.white;
            if(j == 0 || j == 7) PlacePiece(new Rook(pieceColor, pos), pos);
            else if(j == 1 || j==6) PlacePiece(new Knight(pieceColor, pos), pos);
            else if(j == 2 || j==5) PlacePiece(new Bishop(pieceColor, pos), pos);
            else if(j == 3) PlacePiece(new Queen(pieceColor, pos), pos);
            else PlacePiece(new King(pieceColor, pos), pos);
          }
          else{
            PlacePiece(null, pos);
          }

        }
      }

    CalculateValidMoves();

  }

  void ReplacePiece(Piece piece, BoardPosition pos) {
    board[piece.currentPos.row][piece.currentPos.col].piece = null;
    board[pos.row][pos.col].piece = piece;
    piece.currentPos = pos;
  }

  Space GetSpace(BoardPosition pos) {
    try{
      return board[pos.row][pos.col];
    }catch(e){
      return null;
    }
  }

  bool IsSpaceOccupiedByColour(BoardPosition pos, PieceColor color){
    Piece piece = GetSpace(pos).piece;
    if(piece == null) return false;
    return piece.color == color;

  }

  bool IsSpaceOccupied(BoardPosition pos){
    Piece piece = GetSpace(pos).piece;
    return piece != null;
  }

  bool IsValidMove(Piece piece, BoardPosition pos) {
    Space space = board[pos.row][pos.col];
    return piece.ValidMoves.indexWhere((p) => p.Equals(pos)) != -1;
  }

  void SwitchTurns(){
    whitesTurn = !whitesTurn;
  }

  void CalculateValidMoves() {

    for(int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {

        Piece piece = board[i][j].piece;
        if(piece == null) continue;

        piece.ValidMoves = [];
        if(whitesTurn && piece.color == PieceColor.black) continue;
        if(!whitesTurn && piece.color == PieceColor.white) continue;

        PieceColor enemyColour = piece.color == PieceColor.white ? PieceColor.black : PieceColor.white;

        switch(piece.type)
        {
          case PieceType.pawn:

            int forward = (piece.color == PieceColor.white ? -1 : 1);
            int startRow = (piece.color == PieceColor.white ? 6 : 1);

            // Space in front
            BoardPosition positionInFront = BoardPosition(i + forward, j);
            if(GetSpace(positionInFront)!=null && !IsSpaceOccupied(positionInFront)) piece.ValidMoves.add(positionInFront);

            // 2 spaces if on start row
            if(i==startRow)
            {
              BoardPosition twoSpacesAhead = BoardPosition(i + 2*forward, j);
              if(!IsSpaceOccupied(twoSpacesAhead)) piece.ValidMoves.add(twoSpacesAhead);
            }

            // Check for enemies on diagonals
            BoardPosition frontLeft = BoardPosition(i + forward, j - 1);
            if(GetSpace(frontLeft) != null)
            {  if(IsSpaceOccupiedByColour(frontLeft, enemyColour)) piece.ValidMoves.add(frontLeft); }

            BoardPosition frontRight = BoardPosition(i + forward, j + 1);
            if(GetSpace(frontRight) != null)
            {  if(IsSpaceOccupiedByColour(frontRight, enemyColour)) piece.ValidMoves.add(frontRight); }

            break;
          case PieceType.knight:

            List<List<int>> jumps = [[1, 2], [1, -2], [-1, 2],[-1, -2], [2,1], [2,-1], [-2, 1], [-2, -1]];
            for(List<int> jump in jumps){

              BoardPosition jumpPos = BoardPosition(i + jump[0], j + jump[1]);
              Space jumpSpace = GetSpace(jumpPos);

              if(jumpSpace == null) continue;
              if(jumpSpace.piece == null || IsSpaceOccupiedByColour(jumpPos, enemyColour))
                {
                  piece.ValidMoves.add(jumpPos);
                }
            }


            break;
          case PieceType.bishop:

            List<List<int>> incrs = [[1, 1], [1, -1], [-1, 1],[-1, -1]];
            BoardPosition pos = BoardPosition(i, j);

            for(List<int> incr in incrs)
              {
                int m = 1;

                while(GetSpace(pos.move(incr[0]*m, incr[1]*m)) != null){
                  BoardPosition newPos = pos.move(incr[0]*m, incr[1]*m);
                  if(IsSpaceOccupiedByColour(newPos, piece.color))
                    {
                      continue;
                    }
                  else if(IsSpaceOccupiedByColour(newPos, enemyColour))
                    {
                      piece.ValidMoves.add(newPos);
                      continue;
                    }

                  piece.ValidMoves.add(newPos);
                  m++;
                }

              }

            break;
          case PieceType.queen:

            break;
          case PieceType.king:

            break;
          case PieceType.rook:

            break;
        }





      }
    }
  }

  bool DetectPromotion(Piece piece, BoardPosition pos) {
    if(piece.type != PieceType.pawn) return false;
    return(pos.row % 7 == 0);
  }


}

//class ChessActions{
//  static List<BoardPOsitions>[]
//}

class Space {
  Piece piece = null;
}

class Piece{
  Piece(this.color, this.currentPos);
  PieceType type;
  PieceColor color;
  BoardPosition currentPos;
  List<BoardPosition> ValidMoves = [];
  
}

class Pawn extends Piece{Pawn(PieceColor color, BoardPosition pos) : super(color, pos) {this.type = PieceType.pawn;
  bool hasMoved; }
}
class Knight extends Piece{Knight(PieceColor color, BoardPosition pos) : super(color, pos){this.type = PieceType.knight;}}
class Bishop extends Piece{Bishop(PieceColor color, BoardPosition pos) : super(color, pos){this.type = PieceType.bishop;}}
class King extends Piece{King(PieceColor color, BoardPosition pos) : super(color, pos){this.type = PieceType.king;}}
class Queen extends Piece{Queen(PieceColor color, BoardPosition pos) : super(color, pos){this.type = PieceType.queen;}}
class Rook extends Piece{Rook(PieceColor color, BoardPosition pos) : super(color, pos){this.type = PieceType.rook;}}

class BoardPosition {

  BoardPosition(this.row, this.col);

  int row;
  int col;

  @override
  bool Equals(BoardPosition pos) {return this.row == pos.row && this.col == pos.col; }

  BoardPosition move(int i, int j) {
    return BoardPosition(row + i, col + j);
  }
}