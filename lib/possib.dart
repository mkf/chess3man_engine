library chess3man.engine.possib;

import "board.dart";
import "pos.dart";

bool checkempties(Pos from, Board b, Vector v) {
  for (final Pos a in v.emptiesFrom(from)) if (b.nePos(a)) return false;
  return true;
}
