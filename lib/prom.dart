library chess3man.engine.prom;

import "board.dart";

class PawnPromVector extends PawnWalkVector {
  const PawnPromVector(FigType toft)
      : this.toft = toft,
        super(false);
  final FigType toft;
}
