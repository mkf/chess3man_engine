library chess3man.engine.board;

import "package:charcode/charcode.dart";
import "colors.dart";
import "pos.dart";
export "pos.dart";

class FigType {
  final int index;
  const FigType(this.index);
  static const zeroFigType = const FigType(0);
  static const rook = const FigType(1);
  static const knight = const FigType(2);
  static const bishop = const FigType(3);
  static const queen = const FigType(4);
  static const king = const FigType(5);
  static const pawn = const FigType(6);
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
  String toString() => pc ? "Y" : "N";
}

class Piece {
  final FigType type;
  final Color color;
  Piece(this.type, this.color);
  int toRune() => runeMap[type][color];
  String toString() => new String.fromCharCode(toRune());
  static const _w = Color.white;
  static const _g = Color.gray;
  static const _b = Color.black;
  static const _z = Color.zeroColor;
  static const Map<FigType, Map<Color, int>> runeMap = const {
    FigType.zeroFigType: const {_w: $equal, _g: 0x2014, _b: $minus, _z: $tilde},
    FigType.pawn: const {_w: $P, _b: $p, _g: 0x2659, _z: $question},
    FigType.rook: const {_w: $R, _b: $r, _g: 0x2656, _z: $question},
    FigType.knight: const {_w: $N, _b: $n, _g: 0x2658, _z: $question},
    FigType.bishop: const {_w: $B, _b: $b, _g: 0x2657, _z: $question},
    FigType.queen: const {_w: $Q, _b: $q, _g: 0x2655, _z: $question},
    FigType.king: const {_w: $K, _b: $k, _g: 0x2654, _z: $question}
  };
}

class Fig {
  FigType type;
  Color color;
  Fig(this.type, this.color);
  Fig.zero()
      : type = FigType.zeroFigType,
        color = Color.zeroColor;
  int toRune() => Piece.runeMap[type][color];
  String toString() => new String.fromCharCodes([$space, toRune()]);
  static Fig sub(type, color, [PawnCenter pc = PawnCenter.didnt]) {
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
  Rook(Color color) : super(FigType.rook, color);
}

class Knight extends Fig {
  Knight(Color color) : super(FigType.knight, color);
}

class Bishop extends Fig {
  Bishop(Color color) : super(FigType.bishop, color);
}

class Queen extends Fig {
  Queen(Color color) : super(FigType.queen, color);
}

class King extends Fig {
  King(Color color) : super(FigType.king, color);
}

class Pawn extends Fig {
  PawnCenter pawnCenter;
  Pawn(Color color, [PawnCenter this.pawnCenter = PawnCenter.didnt])
      : super(FigType.pawn, color);
}

class Square {
  final bool notEmpty;
  final Fig fig;
  Square(this.fig) : notEmpty = true;
  Square.zero()
      : notEmpty = false,
        fig = new Fig.zero();
  bool get empty => !this.notEmpty;
  Color get color => this.fig.color;
  FigType get what => this.fig.type;
  static const String _emptyourstr = "__";
  String toString() => notEmpty ? fig.toString() : _emptyourstr;
}

class Board {
  List<List<Square>> b = new List<List<Square>>.generate(
      6, (_) => new List<Square>.generate(24, (_) => new Square.zero()),
      growable: false);
  Board();
  Board.withB(this.b);
  Board.fromB(List<List<Square>> b) : this.b = new List<List<Square>>.from(b);
  Board.clone(Board orig) : this.fromB(orig.b);
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
  void pFig(Pos pos, Fig fig) {
    b[pos.rank][pos.file] = new Square(fig);
  }

  void empt(Pos pos) {
    b[pos.rank][pos.file] = new Square.zero();
  }

  Square gPos(Pos pos) => b[pos.rank][pos.file];
  bool nePos(Pos pos) => b[pos.rank][pos.file].notEmpty;
}
