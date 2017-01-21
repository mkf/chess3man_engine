library chess3man.engine.board;

import "dart:typed_data";
import "package:charcode/charcode.dart";
import "colors.dart";
import "pos.dart";
export "pos.dart";
import 'package:quiver/core.dart';

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
  static const List<String> stringMap = const <String>[
    't0',
    'tR',
    'tN',
    'tB',
    'tQ',
    'tK',
    'tP'
  ];
  String toString() {
    return stringMap[this.index];
  }
  bool operator ==(dynamic other) => other is FigType && other.index==index;
  int get hashCode => index.hashCode;
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

final Uint8List firstRankNewGameUInt8 = new Uint8List.fromList(
    new List<int>.from(firstRankNewGame.map((FigType ft) => ft.index)));

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
  int toRune() => runeMap[type.index][color.index];
  @override
  String toString() => new String.fromCharCode(toRune());
  //static const Color _w = Color.white;
  //static const Color _g = Color.gray;
  //static const Color _b = Color.black;
  //static const Color _z = Color.zeroColor;
  static const int _q = $question;
  static const int _t = $tilde;
  static const int _e = $equal;
  static const int _m = $minus;
  /*
  //static const Map<int, Map<Color, int>> runeMap = const <int, Map<Color, int>>{
  static const List<Map<Color, int>> runeMap = const <Map<Color, int>>[
    /*0 zero   :*/ const <Color, int>{_w: _e, _g: 0x2014, _b: _m, _z: _t},
    /*1 rook   :*/ const <Color, int>{_w: $R, _b: $r, _g: 0x2656, _z: _q},
    /*2 knight :*/ const <Color, int>{_w: $N, _b: $n, _g: 0x2658, _z: _q},
    /*3 bishop :*/ const <Color, int>{_w: $B, _b: $b, _g: 0x2657, _z: _q},
    /*4 queen  :*/ const <Color, int>{_w: $Q, _b: $q, _g: 0x2655, _z: _q},
    /*5 king   :*/ const <Color, int>{_w: $K, _b: $k, _g: 0x2654, _z: _q},
    /*6 pawn   :*/ const <Color, int>{_w: $P, _b: $p, _g: 0x2659, _z: _q}
  ]; //};
  */
  static const List<List<int>> runeMap = const <List<int>>[
    /*0 zero   :*/ const <int>[_t, _e, 0x2014, _m],
    /*1 rook   :*/ const <int>[_q, $R, 0x2656, $r],
    /*2 knight :*/ const <int>[_q, $N, 0x2658, $n],
    /*3 bishop :*/ const <int>[_q, $B, 0x2657, $b],
    /*4 queen  :*/ const <int>[_q, $Q, 0x2655, $q],
    /*5 king   :*/ const <int>[_q, $K, 0x2654, $k],
    /*6 pawn   :*/ const <int>[_q, $P, 0x2659, $p]
  ];
}

class Fig {
  final FigType type;
  final Color color;
  const Fig(this.type, this.color);
  const Fig.zero()
      : this.type = FigType.zeroFigType,
        this.color = Color.zeroColor;

  int toRune() => Piece.runeMap[type.index][color.index];
  Vector vec(Pos from, Pos to) => null;
  Iterable<Vector> vecs(Pos from, Pos to) sync* {
    Vector v = vec(from, to);
    if (v != null) yield v;
  }

  ///returns `[[ _ P C C C T T T ]]`
  int get sevenbit =>
      (this.pawnCenter?.toBool() == true ? 1 << 6 : 0) |
      (color.toInt() << 3) |
      type.toInt();
  int toJson() => sevenbit;
  bool operator ==(dynamic other) => other is Fig && type==other.type && color==other.color;
  int get hashCode => hash2(type, color);
  PawnCenter get pawnCenter => null;
  @override
  String toString() {
    int _toRune = toRune();
    if (_toRune == null) {
      throw this.color.index; // ignore: only_throw_errors
    }
    return new String.fromCharCodes(<int>[$space, toRune()]);
  }

  static Fig fromSevenbit(int sb) => sb > 0
      ? sub(sb & 7, new Color((sb >> 3) & 3), new PawnCenter((sb >> 6) != 0))
      : null;
  static Fig sub(int type, Color color, [PawnCenter pc = PawnCenter.didnt]) {
    switch (type) {
      case 1:
        return new Rook(color);
        break;
      case 2:
        return new Knight(color);
        break;
      case 3:
        return new Bishop(color);
        break;
      case 4:
        return new Queen(color);
        break;
      case 5:
        return new King(color);
        break;
      case 6:
        return new Pawn(color, pc);
        break;
      case 0:
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
  static Iterable<AxisVector> vectors(Pos from, Pos to) =>
      from.axisVectorsTo(to);
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
  Uint8List b = new Uint8List(6 * 24);
  Board();
  Board.withB(this.b);
  Board.fromB(List<int> b) : this.b = new Uint8List.fromList(b);
  Board.clone(Board orig) : this.fromB(orig.b);
  Board.fromInts(List<List<int>> li) {
    for (int i = 0; i < 6; i++) {
      b.setAll(i * 24, li[i]);
    }
  }
  Board.newGame() {
    for (final Color col in Color.colors) {
      for (int i = 0; i < 8; i++) {
        Pos ourz = new Pos.colorSegment(col, 0, i);
        Pos ourf = new Pos.colorSegment(col, 1, i);
        pFig(ourz, Fig.sub(firstRankNewGameUInt8[i], col));
        pFig(ourf, new Pawn(col));
      }
    }
  }
  List<Uint8List> splitArrMutable() {
    ByteBuffer buffer = b.buffer;
    return new List<Uint8List>.generate(
        6,
        (int ind) => new Uint8List.view(
            buffer,
            ind * 24 * Uint8List.BYTES_PER_ELEMENT,
            24 * Uint8List.BYTES_PER_ELEMENT));
  }

  List<List<int>> toJson() =>
      new List<List<int>>.from(splitArrMutable().map((Uint8List e) =>
          new List<int>.from(e.map((int eli) => eli == 0 ? null : eli))));
  String toString() {
    String main = "[";
    for (int i = 5; i >= 0; i--) {
      String sub = "[ ";
      for (int j = 0; j < 24; j++) {
        sub += (gPos_bycoor(i, j)?.toString() ?? "__") + " ";
      }
      if (i != 0) sub += "] \n ";
      main += sub;
    }
    main += "]]";
    return main;
  }

  int _ind(int rank, int file) => 24 * rank + file;
  void _pFig(int rank, int file, Fig fig) {
    b[_ind(rank, file)] = fig.sevenbit;
  }

  void pFig(Pos pos, Fig fig) {
    _pFig(pos.rank, pos.file, fig);
  }

  void _empt(int rank, int file) {
    b[_ind(rank, file)] = 0;
  }

  void empt(Pos pos) => _empt(pos.rank, pos.file);

  Fig gPos_bycoor(int rank, int file) => Fig.fromSevenbit(b[_ind(rank, file)]);
  Fig gPos(Pos pos) => gPos_bycoor(pos.rank, pos.file);
  bool nePos(Pos pos) => gPos(pos) != null;

  void mFig(Pos from, Pos to) {
    pFig(to, gPos(from));
    empt(from);
  }
}
