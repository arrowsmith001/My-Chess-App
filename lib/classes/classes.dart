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
  }

  ///  Sets the initial positions of the pieces
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
      // Indices are out of bounds
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

  /// Asks if a board position is within the valid moveset of a piece.
  bool IsValidMove(Piece piece, BoardPosition pos) {
    // Space space = board[pos.row][pos.col];
    return piece.ValidMoves.indexWhere((p) => p.Equals(pos)) != -1;
  }

  void SwitchTurns(){
    whitesTurn = !whitesTurn;
  }


  /// Calculates ALL valid moves for all pieces currently on the board. This should be called whenever a player's turn has been resolved, such as following a move or promotion.
  /// TODO: Check, Castling, En Passent
  void CalculateValidMoves() {

    for(int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {

        Piece piece = board[i][j].piece;
        if(piece == null) continue;

        piece.ValidMoves = [];
        if(whitesTurn && piece.color == PieceColor.black) continue;
        if(!whitesTurn && piece.color == PieceColor.white) continue;

        // This is clunky. Preferably would be able to invert colours easily.
        PieceColor enemyColour = piece.color == PieceColor.white ? PieceColor.black : PieceColor.white;

        switch(piece.type)
        {
          case PieceType.pawn:

            int forward = (piece.color == PieceColor.white ? -1 : 1);
            int startRow = (piece.color == PieceColor.white ? 6 : 1);

            // Space in front is valid, so long as it's not off the board (technically not necessary once promotion is taken into account) AND space is unoccupied
            BoardPosition positionInFront = BoardPosition(i + forward, j);
            if(GetSpace(positionInFront)!=null && !IsSpaceOccupied(positionInFront)) piece.ValidMoves.add(positionInFront);

            // Moving 2 spaces ahead is valid if this piece is on their start row (established above) AND space is unoccupied
            if(i==startRow)
            {
              BoardPosition twoSpacesAhead = BoardPosition(i + 2*forward, j);
              if(!IsSpaceOccupied(twoSpacesAhead)) piece.ValidMoves.add(twoSpacesAhead);
            }

            // Moving diagonally left valid if space is not off the board AND space is occupied by enemy
            BoardPosition frontLeft = BoardPosition(i + forward, j - 1);
            if(GetSpace(frontLeft) != null)
            {  if(IsSpaceOccupiedByColour(frontLeft, enemyColour)) piece.ValidMoves.add(frontLeft); }

            // Moving diagonally right valid if space is not off the board AND space is occupied by enemy
            BoardPosition frontRight = BoardPosition(i + forward, j + 1);
            if(GetSpace(frontRight) != null)
            {  if(IsSpaceOccupiedByColour(frontRight, enemyColour)) piece.ValidMoves.add(frontRight); }

            break;
          case PieceType.knight:

            AddRegularMoves(INCRS_KNIGHTJUMPS, 1, piece, i, j, enemyColour);

            break;
          case PieceType.bishop:

            AddRegularMoves(INCRS_DIAGONAL, MAX_MOVES, piece, i, j, enemyColour);

            break;
          case PieceType.queen:

            AddRegularMoves(INCRS_DIAGONAL + INCRS_LENGTHWAYS, MAX_MOVES, piece, i, j, enemyColour);

            break;
          case PieceType.king:

            AddRegularMoves(INCRS_DIAGONAL + INCRS_LENGTHWAYS, 1, piece, i, j, enemyColour);

            break;
          case PieceType.rook:

            AddRegularMoves(INCRS_LENGTHWAYS, MAX_MOVES, piece, i, j, enemyColour);

            break;
        }
      }
    }
  }

  bool DetectPromotion(Piece piece, BoardPosition pos) {
    if(piece.type != PieceType.pawn) return false;
    return(pos.row % 7 == 0);
  }

  /// Maximum number of moves a piece can move across the board at full length. Assumes a 8x8 board.
  final int MAX_MOVES = 7;

  // Sets of increments that a piece can move by. Generalised due to equivalence in calculation, and set overlap (i.e. queen = rook + bishop)
  List<List<int>> INCRS_DIAGONAL = [[1, 1], [1, -1], [-1, 1],[-1, -1]];
  List<List<int>> INCRS_LENGTHWAYS = [[0, 1], [1, 0], [-1, 0],[0, -1]];
  List<List<int>> INCRS_KNIGHTJUMPS = [[1, 2], [1, -2], [-1, 2],[-1, -2], [2,1], [2,-1], [-2, 1], [-2, -1]];

  /// Adds to a piece's moveset the 'regular' moves that can be described by sets of increments, constrained by a maximum distance, and regardless of direction are halted by team colour and may capture enemy colour (but then are halted).
  /// Generalised as they effectively describe the primary movement of all pieces except pawns.
  void AddRegularMoves(List<List<int>> incrs, int maxM, Piece piece, int i, int j, PieceColor enemyColour) {

    BoardPosition pos = BoardPosition(i, j);

    // For each increment in the given set...
    for(List<int> incr in incrs)
    {
      bool searchValid = true;

      /// Distance counter from piece's position
      int m = 1;

      // While search is valid AND distance does not exceed the maximum...
      while(searchValid && m <= maxM){

        // If space is off the board, search ends
        if(GetSpace(pos.move(incr[0]*m, incr[1]*m)) == null) searchValid = false;
        else {
          BoardPosition newPos = pos.move(incr[0] * m, incr[1] * m);

          // If a piece of this piece's colour is occupying the space, search ends
          if (IsSpaceOccupiedByColour(newPos, piece.color)) searchValid = false;

          // If a piece of the enemy's colour is occupying the space, capture move added AND THEN search ends
          else if (IsSpaceOccupiedByColour(newPos, enemyColour)) {
            piece.ValidMoves.add(newPos);
            searchValid = false;
          }

          // Any other case, the square exists and is empty and can be moved to, and search continues
          else {
            piece.ValidMoves.add(newPos);
            // searchValid is true by default
            // Increment the distance tracker
            m++;
          }
        }
      }
    }

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