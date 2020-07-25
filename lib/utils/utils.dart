import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:chess_app_example/classes/classes.dart';

Image getImageOfPiece(Piece piece) {

  if(piece == null) return null;
  return Image.asset(
    'assets/'
      + piece.type.toString().split('.').last
      + '_'
      + piece.color.toString().split('.').last
      + '.png');

}