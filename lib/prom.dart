library chess3man.engine.prom;

import "board.dart";

abstract class PawnPromVector extends PawnVector {
  FigType get toft;
}

class PawnPromWalkVector extends PawnWalkVector implements PawnPromVector {
  final FigType toft;
  const PawnPromWalkVector(this.toft) : super(false);
}

class PawnPromCapVector extends PawnCapVector implements PawnPromVector {
  final FigType toft;
  const PawnPromCapVector(bool plusfile, this.toft) : super(false, plusfile);
}
