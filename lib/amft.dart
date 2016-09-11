library chess3man.engine.amft;

import "board.dart";
import "package:built_collection/built_collection.dart";

BuiltMap<Pos, BuiltSet<Pos>> _amftinit() {
  MapBuilder ourmain = new MapBuilder();
  Board b = new Board();
  for (Pos from = new Pos.zero(); from != null; from = from.next()) {
    SetBuilder ourslave = new SetBuilder();
    for (Pos to = new Pos.zero(); to != null; to = to.next()) {
      if (from == new Pos(5, 10)) {
        // ↓↑ just senseless placeholders
        b.empt(new Pos(5, 10));
        ourslave.add(to);
      }
    }
    ourmain[from] = ourslave.build();
  }
  return ourmain.build();
}

final BuiltMap<Pos, BuiltSet<Pos>> AMFT = _amftinit();