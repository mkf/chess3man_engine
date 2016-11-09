library chess3man.engine.amft;

import "board.dart";
import "package:built_collection/built_collection.dart";

BuiltMap<Pos, BuiltSet<Pos>> _amftinit() {
  MapBuilder<Pos, BuiltSet<Pos>> ourmain = new MapBuilder<Pos, BuiltSet<Pos>>();
  for (Pos from = new Pos.zero(); from != null; from = from.next()) {
    SetBuilder<Pos> ourslave = new SetBuilder<Pos>();
    for (Pos to = new Pos.zero(); to != null; to = to.next()) {
      if (from
                  .continousVectorsTo(to)
                  //.where((ContinousVector elem) => elem != null)
                  .length >
              0 ||
          from.knightVectorTo(to) != null) ourslave.add(to);
    }
    ourmain[from] = ourslave.build();
  }
  return ourmain.build();
}

///AMFT is a map AllPossiblePositionsFrom→PossibleTos(fromFrom)
final BuiltMap<Pos, BuiltSet<Pos>> AMFT = _amftinit();
