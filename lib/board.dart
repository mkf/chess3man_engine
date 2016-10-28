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
  static Vector vec(Pos from, Pos to) => null;
  static Iterable<Vector> vecs(Pos from, Pos to) sync* {
    yield vec(from, to);
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
  static Fig fromSevenbit(int sb) => sub(new FigType(sb & 7),
      new Color((sb >> 3) & 7), new PawnCenter((sb >> 6) > 0));
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
  //@override
  static Iterable<AxisVector> vecs(Pos from, Pos to) => from.axisVectorsTo(to);
}

class Knight extends Fig {
  const Knight(Color color) : super(FigType.knight, color);
  //@override
  static KnightVector vec(Pos from, Pos to) => from.knightVectorTo(to);
  //@override
  static Iterable<KnightVector> vecs(Pos from, Pos to) sync* {
    yield vec(from, to);
  }
}

class Bishop extends Fig {
  const Bishop(Color color) : super(FigType.bishop, color);
  //@override
  static Iterable<DiagonalVector> vecs(Pos from, Pos to) =>
      from.diagonalVectorsTo(to);
}

class Queen extends Fig {
  const Queen(Color color) : super(FigType.queen, color);
  //@override
  static Iterable<ContinousVector> vecs(Pos from, Pos to) =>
      from.continousVectorsTo(to);
}

class King extends Fig {
  const King(Color color) : super(FigType.king, color);
  //@override
  static Vector vec(Pos from, Pos to) => from.kingVectorTo(to);
}

class Pawn extends Fig {
  @override
  final PawnCenter pawnCenter;
  const Pawn(Color color, [this.pawnCenter = PawnCenter.didnt])
      : super(FigType.pawn, color);
  //@override
  static Vector vec(Pos from, Pos to) => from.pawnVectorTo(to);
}

class Square {
  final bool notEmpty;
  final Fig fig;
  const Square(this.fig) : notEmpty = true;
  const Square.zero()
      : notEmpty = false,
        fig = const Fig.zero();
  Square.fromSevenbit(int sb)
      : this.notEmpty = sb != 0,
        this.fig = Fig.fromSevenbit(sb);
  int get sevenbit => notEmpty ? fig.sevenbit : 0;
  int toJson() => sevenbit;
  bool get empty => !this.notEmpty;
  Color get color => this.fig.color;
  FigType get what => this.fig.type;
  static const String _emptyourstr = "__";
  @override
  String toString() => notEmpty ? fig.toString() : _emptyourstr;
}

class Board {
  List<List<Square>> b = new List<List<Square>>.generate(
      6, (_) => new List<Square>.generate(24, (_) => const Square.zero()),
      growable: false);
  Board();
  Board.withB(this.b);
  Board.fromB(List<List<Square>> b) : this.b = new List<List<Square>>.from(b);
  Board.clone(Board orig) : this.fromB(orig.b);
  Board.fromInts(List<List<int>> li)
      : this.withB(new List<List<Square>>.generate(
            6,
            (int ind) => new List<Square>.generate(
                24, (int indf) => new Square.fromSevenbit(li[ind][indf]))));
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
  List<List<Square>> toJson() => b;
  void pFig(Pos pos, Fig fig) {
    b[pos.rank][pos.file] = new Square(fig);
  }

  void empt(Pos pos) {
    b[pos.rank][pos.file] = new Square.zero();
  }

  Square gPos(Pos pos) => b[pos.rank][pos.file];
  bool nePos(Pos pos) => b[pos.rank][pos.file].notEmpty;
}
