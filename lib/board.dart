library chess3man.engine.board;

import "package:charcode/charcode.dart";
import "colors.dart";
import "pos.dart";
export "pos.dart";

class FigType {
  final int index;
  const FigType(this.index);
  static const FigType zeroFigType = const FigType(0);
  static const FigType rook = const FigType(1);
  static const FigType knight = const FigType(2);
  static const FigType bishop = const FigType(3);
  static const FigType queen = const FigType(4);
  static const FigType king = const FigType(5);
  static const FigType pawn = const FigType(6);
  int toInt() => this.index;
}

const List<FigType> firstRankNewGame = const <FigType>[
  FigType.rook,
  FigType.knight,
  FigType.bishop,
  FigType.queen,
  FigType.king,
  FigType.bishop,
  FigType.knight,
  FigType.rook
];

class PawnCenter {
  final bool pc;
  const PawnCenter(this.pc);
  static const PawnCenter didnt = const PawnCenter(false);
  static const PawnCenter crossed = const PawnCenter(true);
  bool toBool() => this.pc;
  int interpunction() => pc ? $exclamation : $dot;
  @override
  String toString() => pc ? "Y" : "N";
}

class Piece {
  final FigType type;
  final Color color;
  Piece(this.type, this.color);
  int toRune() => runeMap[type][color];
  @override
  String toString() => new String.fromCharCode(toRune());
  static const Color _w = Color.white;
  static const Color _g = Color.gray;
  static const Color _b = Color.black;
  static const Color _z = Color.zeroColor;
  static const int _q = $question;
  static const int _t = $tilde;
  static const int _e = $equal;
  static const int _m = $minus;
  static const Map<FigType, Map<Color, int>> runeMap =
      const <FigType, Map<Color, int>>{
    FigType.zeroFigType: const <Color, int>{_w: _e, _g: 0x2014, _b: _m, _z: _t},
    FigType.pawn: const <Color, int>{_w: $P, _b: $p, _g: 0x2659, _z: _q},
    FigType.rook: const <Color, int>{_w: $R, _b: $r, _g: 0x2656, _z: _q},
    FigType.knight: const <Color, int>{_w: $N, _b: $n, _g: 0x2658, _z: _q},
    FigType.bishop: const <Color, int>{_w: $B, _b: $b, _g: 0x2657, _z: _q},
    FigType.queen: const <Color, int>{_w: $Q, _b: $q, _g: 0x2655, _z: _q},
    FigType.king: const <Color, int>{_w: $K, _b: $k, _g: 0x2654, _z: _q}
  };
}

class Fig {
  final FigType type;
  final Color color;
  const Fig(this.type, this.color);
  const Fig.zero()
      : this.type = FigType.zeroFigType,
        this.color = Color.zeroColor;

  int toRune() => Piece.runeMap[type][color];
  Vector vec(Pos from, Pos to) => null;
  Iterable<Vector> vecs(Pos from, Pos to) sync* {
    Vector v = vec(from, to);
    if(v!=null) yield v;
  }

  ///returns `[[ _ P C C C T T T ]]`
  int get sevenbit =>
      (this.pawnCenter?.toBool() == true ? 1 << 6 : 0) +
      (color.toInt() << 3) +
      type.toInt();
  int toJson() => sevenbit;
  PawnCenter get pawnCenter => null;
  @override
  String toString() => new String.fromCharCodes(<int>[$space, toRune()]);
  static Fig fromSevenbit(int sb) => sb>0?sub(new FigType(sb & 7),
      new Color((sb >> 3) & 7), new PawnCenter((sb >> 6) > 0)):null;
  static Fig sub(FigType type, Color color,
      [PawnCenter pc = PawnCenter.didnt]) {
    switch (type) {
      case FigType.rook:
        return new Rook(color);
        break;
      case FigType.knight:
        return new Knight(color);
        break;
      case FigType.bishop:
        return new Bishop(color);
        break;
      case FigType.queen:
        return new Queen(color);
        break;
      case FigType.king:
        return new King(color);
        break;
      case FigType.pawn:
        return new Pawn(color, pc);
        break;
      case FigType.zeroFigType:
        return new Fig.zero();
        break;
      default:
        return new Fig.zero();
    }
  }
}

class Rook extends Fig {
  const Rook(Color color) : super(FigType.rook, color);
  @override
  Iterable<AxisVector> vecs(Pos from, Pos to) => vectors(from, to);
  static Iterable<AxisVector> vectors(Pos from, Pos to) => from.axisVectorsTo(to);
}

class Knight extends Fig {
  const Knight(Color color) : super(FigType.knight, color);
  //@override
  static KnightVector vector(Pos from, Pos to) => from.knightVectorTo(to);
  @override
  KnightVector vec(Pos from, Pos to) => vector(from, to);
}

class Bishop extends Fig {
  const Bishop(Color color) : super(FigType.bishop, color);
  @override
  Iterable<DiagonalVector> vecs(Pos from, Pos to) => vectors(from, to);
  static Iterable<DiagonalVector> vectors(Pos from, Pos to) =>
      from.diagonalVectorsTo(to);
}

class Queen extends Fig {
  const Queen(Color color) : super(FigType.queen, color);
  @override
  Iterable<ContinousVector> vecs(Pos from, Pos to) => vectors(from, to);
  static Iterable<ContinousVector> vectors(Pos from, Pos to) =>
      from.continousVectorsTo(to);
}

class King extends Fig {
  const King(Color color) : super(FigType.king, color);
  static Vector vector(Pos from, Pos to) => from.kingVectorTo(to);
  @override
  Vector vec(Pos from, Pos to) => vector(from, to);
}

class Pawn extends Fig {
  @override
  final PawnCenter pawnCenter;
  const Pawn(Color color, [this.pawnCenter = PawnCenter.didnt])
      : super(FigType.pawn, color);
  @override
  Vector vec(Pos from, Pos to) => vector(from, to);
  static Vector vector(Pos from, Pos to) => from.pawnVectorTo(to);
}

/*
class Square {
  static const String _emptyourstr = "__";
  @override
  String toString() => notEmpty ? fig.toString() : _emptyourstr;
}
*/

class Board {
  List<List<Fig>> b = new List<List<Fig>>.generate(
      6, (_) => new List<Fig>(24));
  Board();
  Board.withB(this.b);
  Board.fromB(List<List<Fig>> b) : this.b = new List<List<Fig>>.from(b);
  Board.clone(Board orig) : this.fromB(orig.b);
  Board.fromInts(List<List<int>> li)
      : this.withB(new List<List<Fig>>.generate(
            6,
            (int ind) => new List<Fig>.generate(
                24, (int indf) => li[ind][indf]>0?Fig.fromSevenbit(li[ind][indf]):null)));
  Board.newGame() {
    for (final Color col in Color.colors) {
      for (int i = 0; i < 8; i++) {
        Pos ourz = new Pos.colorSegment(col, 0, i);
        Pos ourf = new Pos.colorSegment(col, 1, i);
        pFig(ourz, Fig.sub(firstRankNewGame[i], col));
        pFig(ourf, new Pawn(col));
      }
    }
  }
  List<List<Fig>> toJson() => b;
  void pFig(Pos pos, Fig fig) {
    b[pos.rank][pos.file] = fig;
  }

  void empt(Pos pos) {
    b[pos.rank][pos.file] = null;
  }

  Fig gPos(Pos pos) => b[pos.rank][pos.file];
  bool nePos(Pos pos) => b[pos.rank][pos.file]!=null;

  void mFig(Pos from, Pos to) {
    pFig(to, gPos(from));
    empt(from);
  }
}
