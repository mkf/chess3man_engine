library chess3man.engine.castlingcheck;

import "castling.dart";
import 'pos.dart';
//import 'colors.dart';

bool checkCastling(ColorCastling c, CastlingVector v) {
  if (v is QueensideCastlingVector) return c.q;
  if (v is KingsideCastlingVector) return c.k;
  throw new AssertionError();
}