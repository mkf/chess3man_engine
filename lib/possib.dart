library chess3man.engine.possib;

import "board.dart";
import "pos.dart";

bool continousemptyroute(Pos from, Pos to, Board b, ContinousVector v) {
  Pos a = from;
  for (final ContinousVector u in v.units(from.rank)) {
    a = u.addTo(a);
    if (a == to) return true;
    if (b.nePos(a)) return false;
  }
  throw new AssertionError();
}
