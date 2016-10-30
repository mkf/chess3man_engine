library chess3man.engine.prom;

import "board.dart";

abstract class PawnPromVector extends PawnVector {
  FigType get toft;
  static PawnPromVector fromPV(PawnVector pv, FigType toft) =>
      (pv is PawnPromVector)
          ? pv
          : (pv is PawnLongJumpVector)
              ? null
              : (pv is PawnWalkVector)
                  ? new PawnPromWalkVector(toft)
                  : (pv is PawnCapVector)
                      ? new PawnPromCapVector.from(pv, toft)
                      : null;
}

class PawnPromWalkVector extends PawnWalkVector implements PawnPromVector {
  final FigType toft;
  const PawnPromWalkVector(this.toft) : super(false);
}

class PawnPromCapVector extends PawnCapVector implements PawnPromVector {
  final FigType toft;
  const PawnPromCapVector(bool plusfile, this.toft) : super(false, plusfile);
  PawnPromCapVector.from(PawnCapVector pv, FigType toft)
      : this(pv.plusfile, toft);
}
