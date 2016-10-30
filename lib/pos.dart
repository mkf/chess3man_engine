library chess3man.engine.pos;

import "colors.dart";

class CanIDiagonal {
  final bool short;
  final bool long;
  final bool positivesgn;
  const CanIDiagonal(this.short, this.long, this.positivesgn);
  const CanIDiagonal._no()
      : this.short = false,
        this.long = false,
        this.positivesgn = null;
  static const CanIDiagonal no = const CanIDiagonal._no();
  bool toBool() => short || long;
}

class Pos {
  final int rank;
  final int file;
  const Pos(this.rank, this.file);
  const Pos.zero()
      : this.rank = 0,
        this.file = 0;
  Pos.colorSegment(Color color, this.rank, int colorfile)
      : this.file = (color.board << 3) + colorfile;
  @override
  String toString() => "[$rank,$file]";
  Color get colorSegm => new Color.fromSegm(file ~/ 8);
  Pos next() => rank == 5 && file == 23
      ? null
      : new Pos(file == 23 ? rank + 1 : rank, file == 23 ? 0 : file + 1);
  bool sameRank(Pos ano) => rank == ano.rank;
  bool sameFile(Pos ano) => file == ano.file;
  bool equal(Pos ano) => file == ano.file && rank == ano.rank;
  bool adjacentFile(Pos ano) => file + 12 % 24 == ano.file;
  bool sameOrAdjacentFile(Pos ano) => file % 12 == ano.file % 12;
  bool diagonalsomehow(Pos ano) => canIDiagonal(ano).toBool();
  KnightVector knightVectorTo(Pos ano,
      {bool inward: null, bool plusfile: null, bool centeronecloser: null}) {
    if (inward == null) {
      return knightVectorTo(ano,
              inward: false,
              plusfile: plusfile,
              centeronecloser: centeronecloser) ??
          knightVectorTo(ano,
              inward: true,
              plusfile: plusfile,
              centeronecloser: centeronecloser);
    }
    if (plusfile == null) {
      return knightVectorTo(ano,
              inward: inward,
              plusfile: false,
              centeronecloser: centeronecloser) ??
          knightVectorTo(ano,
              inward: inward, plusfile: true, centeronecloser: centeronecloser);
    }
    if (centeronecloser == null) {
      return knightVectorTo(ano,
              inward: inward, plusfile: plusfile, centeronecloser: false) ??
          knightVectorTo(ano,
              inward: inward, plusfile: plusfile, centeronecloser: true);
    }
    KnightVector vec = new KnightVector(inward, plusfile, centeronecloser);
    return vec?.addTo(this)?.equal(ano) == true ? vec : null;
  }

  RankVector rankVectorTo(Pos ano) => sameOrAdjacentFile(ano)
      ? new RankVector(
          sameFile(ano) ? ano.rank - rank : 5 - rank + 5 - ano.rank)
      : null;
  FileVector fileVectorTo(Pos ano, {bool long: false}) => sameRank(ano)
      ? new FileVector(wrappedFileVector(file, ano.file, long))
      : null;
  Iterable<AxisVector> axisVectorsTo(Pos ano) sync* {
    RankVector rankVector = rankVectorTo(ano);
    if (rankVector is RankVector) yield rankVector;
    FileVector shortfileVector = fileVectorTo(ano);
    if (shortfileVector is FileVector) yield shortfileVector;
    FileVector longfileVector = fileVectorTo(ano, long: true);
    if (longfileVector is FileVector) yield longfileVector;
  }

  FileVector kingFileVectorTo(Pos ano) {
    FileVector tryin = new FileVector.unit(true);
    if (tryin.addTo(this).equal(ano)) return tryin;
    tryin = new FileVector.unit(false);
    if (tryin.addTo(this).equal(ano)) return tryin;
    return null;
  }

  RankVector kingRankVectorTo(Pos ano) {
    RankVector tryin = new RankVector.unit(true);
    if (tryin.addTo(this).equal(ano)) return tryin;
    tryin = new RankVector.unit(false);
    if (tryin.addTo(this).equal(ano)) return tryin;
    return null;
  }

  AxisVector kingAxisVectorTo(Pos ano) =>
      kingFileVectorTo(ano) ?? kingAxisVectorTo(ano);

  DiagonalVector kingDiagVectorTo(Pos ano) {
    return null;
  }

  ContinousVector kingContVectorTo(Pos ano) =>
      kingAxisVectorTo(ano) ?? kingDiagVectorTo(ano);

  Vector kingVectorTo(Pos ano) =>
      kingContVectorTo(ano) ?? castlingVectorTo(ano);

  PawnWalkVector pawnWalkVectorTo(Pos ano) {
    PawnWalkVector tryin = new PawnWalkVector(true);
    if (tryin.addTo(this).equal(ano)) return tryin;
    tryin = new PawnWalkVector(false);
    if (tryin.addTo(this).equal(ano)) return tryin;
    return null;
  }

  PawnLongJumpVector pawnLongJumpVectorTo(Pos ano) =>
      PawnLongJumpVector.c.addTo(this).equal(ano) ? PawnLongJumpVector.c : null;

  PawnCapVector pawnCapVectorTo(Pos ano) {
    PawnCapVector tryin = new PawnCapVector(false, false);
    if (tryin.addTo(this).equal(ano)) return tryin;
    tryin = new PawnCapVector(false, true);
    if (tryin.addTo(this).equal(ano)) return tryin;
    tryin = new PawnCapVector(true, false);
    if (tryin.addTo(this).equal(ano)) return tryin;
    tryin = new PawnCapVector(true, true);
    if (tryin.addTo(this).equal(ano)) return tryin;
    return null;
  }

  PawnVector pawnVectorTo(Pos ano) =>
      pawnLongJumpVectorTo(ano) ??
      pawnWalkVectorTo(ano) ??
      pawnCapVectorTo(ano);

  CastlingVector castlingVectorTo(Pos ano) {
    if (this.rank != 0 || ano.rank != 0 || this.file % 8 != CastlingVector.kfm)
      return null;
    switch (ano.file % 8) {
      case 2:
        return new QueensideCastlingVector();
      case 6:
        return new KingsideCastlingVector();
    }
    return null;
  }

  DiagonalVector shorterDiagonalVectorTo(Pos ano,
      {bool positivesgn: null, bool short: null, bool long: null}) {
    if (short != false && rank != ano.rank) {
      bool inward = ano.rank > rank;
      int shorttd = (!inward ? rank - ano.rank : ano.rank - rank);
      if ((positivesgn != false) && ano.file == (file + shorttd) % 24)
        return new DirectDiagonalVector(shorttd, inward, true);
      else if ((positivesgn != true) && ano.file == (file - shorttd) % 24)
        return new DirectDiagonalVector(shorttd, inward, false);
    } else if (long != false) {
      int ranksum = ano.rank + rank;
      if ((positivesgn != true) && ano.file == (file + ranksum) % 24)
        return new LongDiagonalVector(ranksum, false);
      else if ((positivesgn != false) && ano.file == (file - ranksum) % 24)
        return new LongDiagonalVector(ranksum, true);
    }
    return null;
  }

  DiagonalVector longerDiagonalVectorTo(Pos ano, DiagonalVector shorter) {
    if (shorter is DirectDiagonalVector) {
      int ranksum = ano.rank + rank;
      if (ano.file == (shorter.plusfile ? file - ranksum : file + ranksum) % 24)
        return new LongDiagonalVector(ranksum, shorter.plusfile);
    }
    return null;
  }

  CanIDiagonal canIDiagonal(Pos ano) {
    if (this == ano) {
      return CanIDiagonal.no;
    }
    int shorttd = (ano.rank < rank ? rank - ano.rank : ano.rank - rank);
    int longtd = ano.rank + rank;
    bool shortrnl;
    bool positivesgn;
    if (ano.file == (file + shorttd) % 24) {
      positivesgn = true;
      shortrnl = true;
    } else if (ano.file == (file - shorttd) % 24) {
      positivesgn = false;
      shortrnl = true;
    } else if (ano.file == (file + longtd) % 24) {
      positivesgn = true;
      shortrnl = false;
    } else if (ano.file == (file - longtd) % 24) {
      positivesgn = false;
      shortrnl = false;
    } else {
      return CanIDiagonal.no;
    }
    return new CanIDiagonal(
        shortrnl,
        !shortrnl || (file + (positivesgn ? longtd : -longtd) % 24 == ano.file),
        positivesgn);
  }

  Iterable<DiagonalVector> diagonalVectorsTo(Pos ano) sync* {
    //  CanIDiagonal cid = canIDiagonal(ano);
    //  if (cid.toBool()) {
    //    if (cid.short) {
    //      yield this.shorterDiagonalVectorTo(ano, positivesgn: cid.positivesgn);
    DiagonalVector shorter = shorterDiagonalVectorTo(ano);
    if (shorter != null) {
      yield shorter;
      LongDiagonalVector longer = longerDiagonalVectorTo(ano, shorter);
      if (longer != null) yield longer;
    }
  }

  Iterable<ContinousVector> continousVectorsTo(Pos ano) sync* {
    yield* this.axisVectorsTo(ano);
    yield* this.diagonalVectorsTo(ano);
  }

  static int wrappedFileVector(int from, int to, [bool long = false]) {
    int diff = to - from;
    int sgn = diff < 0 ? -1 : 1;
    return ((diff * sgn > 12) == long) ? diff : (diff - 24 * sgn);
  }
}

abstract class Vector {
  int get rank;
  int get file;
  Pos addTo(Pos from);
  bool toBool() => ((rank is int) && (file is int)) && (rank != 0 || file != 0);
  Iterable<Vector> units(int fromrank);
  Iterable<Pos> emptiesFrom(Pos from);
  Iterable<Color> moats(Pos from);
}

class ZeroVector implements Vector {
  const ZeroVector();
  int get rank => 0;
  int get file => 0;
  bool toBool() => false;
  Pos addTo(Pos from) => from;
  Iterable<Vector> units(_) sync* {}
  Iterable<Pos> emptiesFrom(_) sync* {}
  Iterable<Color> moats(_) sync* {}
}

abstract class JumpVector implements Vector {
  Iterable<Vector> units(_) sync* {
    yield this;
  }
}

abstract class CastlingVector implements JumpVector {
  const CastlingVector();
  Iterable<CastlingVector> units(int fromrank) sync* {
    yield fromrank == 0 ? this : null;
  }

  ///File numbers modulo Color for checking whether fields are empty
  static List<int> get empties => empties;

  bool toBool() => true;
  int get rank => 0;

  ///King's file modulo Color (mod 8)
  static const int kfm = 4;
  Pos addTo(Pos pos) =>
      pos.rank == 0 && pos.file % 8 == kfm ? new Pos(0, pos.file + file) : null;
  Iterable<Color> moats(_) sync* {}
  Iterable<Pos> emptiesFrom(Pos from) sync* {
    if (from.file % 8 == kfm) {
      int add = from.file - kfm;
      for (final int toempt in empties) {
        yield new Pos(0, add + toempt);
      }
    }
  }
}

class QueensideCastlingVector extends CastlingVector {
  int get file => -2;
  static const List<int> empties = const <int>[3, 2, 1];
}

class KingsideCastlingVector extends CastlingVector {
  int get file => 2;
  static const List<int> empties = const <int>[5, 6];
}

abstract class PawnVector implements JumpVector {
  ///Returns needed `PawnCenter` value
  bool get reqpc;
  bool reqProm(int rank);
}

class PawnLongJumpVector implements PawnVector {
  const PawnLongJumpVector();
  int get rank => 2;
  int get file => 0;
  bool get reqpc => false;
  bool toBool() => true;
  bool reqProm(_) => false;
  Pos addTo(Pos from) => from.rank == 1 ? new Pos(3, from.file) : null;
  Pos enpfield(Pos from) => from.rank == 1 ? new Pos(2, from.file) : null;
  static const PawnLongJumpVector c = const PawnLongJumpVector();
  Iterable<PawnLongJumpVector> units(_) sync* {
    yield c;
  }

  Iterable<Color> moats(_) sync* {}
  Iterable<Pos> emptiesFrom(Pos from) sync* {
    yield enpfield(from);
    yield addTo(from);
  }
}

class PawnWalkVector extends RankVector implements PawnVector {
  const PawnWalkVector(bool direc) : super.unit(direc);
  int get rank => t;
  int get t => direc ? 1 : -1;
  int get file => 0;
  bool get reqpc => !this.direc;
  bool toBool() => true;
  bool reqProm(int rank) => rank + t == 0;
  bool thruCenter(int fromrank) => direc && fromrank == 5;
  Iterable<Color> moats(_) sync* {}
  Pos addTo(Pos from) => thruCenter(from.rank)
      ? new Pos(5, (from.file + 12) % 24)
      : (from.rank == 0) != reqpc ? new Pos(from.rank + rank, from.file) : null;
  Iterable<Pos> emptiesFrom(_) sync* {}
}

class PawnCapVector extends DiagonalVector implements PawnVector {
  final bool inward;
  const PawnCapVector(this.inward, bool plusfile) : super.unit(plusfile);
  bool get reqpc => !this.inward;
  bool reqProm(int rank) => (!inward) && (rank == 1);
  bool thruCenter(int fromrank) => inward && fromrank == 5;
  Iterable<Color> moats(
      _) sync* {} //I guess PC pawns cannot capture thru bridged
  bool creek(Pos from) => from.rank >= 3
      ? false
      : plusfile
          ? (from.file % 8 == 7) ? true : false
          : (from.file % 8 == 0) ? true : false;

  Pos addTo(Pos pos) => creek(pos)
      ? null
      : thruCenter(pos.rank)
          ? new Pos(
              5, SolelyThruCenterDiagonalVector.addFile(pos.file, plusfile))
          : new Pos(pos.rank + (inward ? 1 : -1),
              (pos.file + (plusfile ? 1 : -1)) % 24);
  Iterable<PawnCapVector> units(_) sync* {
    yield this;
  }

  PawnCapVector get reversed => null;

  Iterable<Pos> emptiesFrom(_) sync* {}
}

class KnightVector implements JumpVector {
  ///Towards the center, i.e. inwards
  final bool inward;

  ///Positive file direction (switched upon mirroring)
  final bool plusfile;

  ///One rank closer to the center?
  ///(about that one more (twice instead of once) rank or file)
  final bool centeronecloser;
  const KnightVector(this.inward, this.plusfile, this.centeronecloser);

  ///Two times increment rank and once file?
  bool get morerank => centeronecloser == inward;

  ///Two times increment file and once rank?
  bool get morefile => !morerank;
  int get rank => (inward ? 1 : -2) + (centeronecloser ? 1 : 0);
  int get file => (morefile ? 2 : 1) * (plusfile ? 1 : -1);
  Pos addTo(Pos from) => (inward &&
          (centeronecloser && from.rank >= 4 || from.rank == 5))
      ? (centeronecloser
          ? new Pos(
              (5 + 4) - from.rank, (from.rank + (plusfile ? 1 : -1) + 12) % 24)
          : new Pos(5, (from.rank + (plusfile ? 2 : -2) + 12) % 24))
      : new Pos(from.rank + rank, (from.file + file) % 24);

  ///helper for [this.moat]
  bool _xoreq(Pos f, Pos t) {
    if (f.rank > 2 && t.rank > 2) return null;
    int w = _xrqnmv(f.file % 8, t.file % 8);
    return f.rank == 0 ? t.rank == w : f.rank == w ? t.rank == 0 : false;
  }

  ///helper map for [_xoreq]
  int _xrqnmv(int ffm, int tfm) => ffm == 6
      ? tfm == 0 ? 1 : null
      : ffm == 7
          ? tfm == 1 ? 1 : tfm == 0 ? 2 : null
          : ffm == 0
              ? tfm == 6 ? 1 : tfm == 7 ? 2 : null
              : ffm == 1 ? tfm == 7 ? 1 : null : null;

  ///Color of moat for this vector from [from] for use with `*BetweenThisAndNext`
  Color moat(Pos from) {
    Pos to = addTo(from);
    bool xoreq = _xoreq(from, to);
    return xoreq == true
        ? new Color.fromSegm(((from.file + 2) ~/ 8) % 3)
        : null;
  }

  ///Colors of moats for this vector from [from] for use with `*BetweenThisAndNext`
  Iterable<Color> moats(Pos from) sync* {
    yield moat(from);
  }

  bool toBool() =>
      inward != null && plusfile != null && centeronecloser != null;
  Iterable<KnightVector> units(_) sync* {
    yield this;
  }

  Iterable<Pos> emptiesFrom(_) sync* {}
  Iterable<Pos> emptiesBetween(_) sync* {}
}

abstract class ContinousVector implements Vector {
  final int abs;
  const ContinousVector(this.abs);
  const ContinousVector.unit() : this.abs = 1;
  @override
  bool toBool() => (abs is int) && abs != 0;
  Iterable<ContinousVector> units(int fromrank);
  Iterable<Pos> emptiesFrom(Pos from) => emptiesBetween(from);
  Iterable<Pos> emptiesBetween(Pos from) sync* {
    Pos pos = from;
    bool nofrom = false; //between
    for (final ContinousVector u in units(from.rank)) {
      if (nofrom)
        yield pos; //between
      else
        nofrom = true; //between
      pos = u.addTo(pos);
      //yield pos;          //incl. destination
    }
  }
}

abstract class AxisVector extends ContinousVector {
  final bool direc;
  const AxisVector(int t, [bool direc = null])
      : this.direc = (direc != null) ? !(t < 0) : direc,
        super(((direc != null) ? (t < 0 ? -t : t) : t));
  const AxisVector.unit(this.direc) : super.unit();
  int get t => direc ? abs : -abs;
}

class FileVector extends AxisVector {
  const FileVector(int file, [bool direc = null]) : super(file % 24, direc);
  const FileVector.unit(bool direc) : super.unit(direc);
  int get file => t;
  int get rank => 0;
  Iterable<FileVector> units(_) sync* {
    for (int i = abs; i > 0; i--) {
      yield new FileVector.unit(direc);
    }
  }

  Iterable<Color> moats(Pos from) sync* {
    if (from.rank == 0) {
      int left = from.file % 8;
      int tm = direc ? 8 - left : left;
      Color start = from.colorSegm;
      int moating = abs - tm;
      if (moating > 0) {
        yield direc ? start : start.previous;
        if (moating > 8) {
          yield start.next;
          if (moating > 16) yield direc ? start.previous : start;
        }
      }
    }
  }

  Pos addTo(Pos pos) => new Pos(pos.rank, (pos.file + this.file) % 24);
}

class RankVector extends AxisVector {
  const RankVector(int rank, [bool direc = null]) : super(rank, direc);
  const RankVector.unit(bool direc) : super.unit(direc);
  int get rank => t;
  int get file => 0;
  bool thruCenter(int fromrank) => direc && fromrank + this.rank > 5;
  Iterable<Color> moats(_) sync* {}
  Iterable<RankVector> units(_) sync* {
    for (int i = abs; i > 0; i--) {
      yield new RankVector.unit(direc);
    }
  }

  Pos addTo(Pos pos) {
    bool tc = thruCenter(pos.rank);
    return new Pos(tc ? 5 - (pos.rank + this.abs) : pos.rank + this.rank,
        tc ? (pos.file + 12) % 24 : pos.file);
  }
}

abstract class DiagonalVector extends ContinousVector {
  final bool plusfile;
  const DiagonalVector(int abs, this.plusfile) : super(abs);
  const DiagonalVector.unit(this.plusfile) : super.unit();
  bool get inward;
  int get rank => inward ? abs : -abs;
  int get file => plusfile ? abs : -abs;
  @override
  bool toBool() => (abs is int) && abs > 0;
  bool badNotInward() => (!inward) && abs > 5;
  bool thruCenter(int fromrank) => inward && (fromrank + abs > 5);
  bool thruCenterAndFurther(int fromrank) => inward && (fromrank + abs > 5);
  DirectDiagonalVector _shortToCenterAlmost(int fromrank) =>
      new DirectDiagonalVector(
          thruCenter(fromrank) ? 5 - fromrank : abs, inward, plusfile);
  DirectDiagonalVector shortToCenterAlmost(int fromrank) =>
      (this is DirectDiagonalVector) ? this : _shortToCenterAlmost(fromrank);
  DiagonalVector get reversed;
  Iterable<Color> moats(Pos from) sync* {
    yield moat(from);
  }

  Color moat(Pos from, [bool noreverse = false]) =>
      ((from.rank == 0)
          ? plusfile
              ? (from.file % 8 == 7) ? from.colorSegm : null
              : (from.file % 8 == 0) ? from.colorSegm.previous : null
          : null) ??
      (noreverse ? null : reversed.moat(addTo(from), true));
}

class DirectDiagonalVector extends DiagonalVector {
  final bool inward;
  const DirectDiagonalVector(int abs, this.inward, bool plusfile)
      : super(abs, plusfile);
  const DirectDiagonalVector.unit(this.inward, bool plusfile)
      : super.unit(plusfile);
  const DirectDiagonalVector.fromNumsVec(int rank, int file)
      : this.inward = rank > 0,
        super(
            ((rank < 0 ? -rank : rank) == (file < 0 ? -file : file))
                ? (rank < 0 ? -rank : rank)
                : null,
            file > 0);
  DirectDiagonalVector.fromVector(Vector vec)
      : this.fromNumsVec(vec.rank, vec.file);
  DirectDiagonalVector get reversed =>
      new DirectDiagonalVector(abs, !inward, !plusfile);
  Iterable<DirectDiagonalVector> units(_) sync* {
    for (int i = abs; i > 0; i--) {
      yield new DirectDiagonalVector.unit(inward, plusfile);
    }
  }

  Pos addTo(Pos pos) =>
      new Pos(pos.rank + this.rank, (pos.file + this.file) % 24);
}

class LongDiagonalVector extends DiagonalVector {
  const LongDiagonalVector(int abs, bool plusfile) : super(abs, plusfile);
  const LongDiagonalVector.unit(bool plusfile) : super.unit(plusfile);
  const LongDiagonalVector.fromNumsVec(int rank, int file)
      : super((rank == (file < 0 ? -file : file)) ? rank : null, file > 0);
  LongDiagonalVector.fromVector(Vector vec)
      : this.fromNumsVec(vec.rank, vec.file);
  bool get inward => true;
  LongDiagonalVector get reversed => new LongDiagonalVector(abs, !plusfile);
  DirectDiagonalVector shortFromCenter(int fromrank) =>
      new DirectDiagonalVector(abs - 5 + fromrank, false, !plusfile);
  SolelyThruCenterDiagonalVector solelyThruCenter() =>
      new SolelyThruCenterDiagonalVector(plusfile);
  Iterable<DiagonalVector> units(int fromrank) sync* {
    yield* this.shortToCenterAlmost(fromrank).units(fromrank);
    Iterable<DiagonalVector> ynnull;
    if ((ynnull = this.solelyThruCenter()?.units(fromrank))
        is Iterable<DiagonalVector>) yield* ynnull;
    if ((ynnull = this.shortFromCenter(fromrank)?.units(fromrank))
        is Iterable<DiagonalVector>) yield* ynnull;
  }

  Pos addWithUnitsTo(Pos pos) => shortFromCenter(pos.rank).addTo(
      solelyThruCenter().addTo(shortToCenterAlmost(pos.rank).addTo(pos)));
  Pos addTo(Pos pos) => addWithUnitsTo(pos);
}

class SolelyThruCenterDiagonalVector extends DiagonalVector {
  const SolelyThruCenterDiagonalVector(bool plusfile) : super.unit(plusfile);
  bool get inward => true;
  SolelyThruCenterDiagonalVector get reversed =>
      new SolelyThruCenterDiagonalVector(!plusfile);
  @override
  Iterable<Color> moats(_) sync* {}
  Iterable<SolelyThruCenterDiagonalVector> units(_) sync* {
    yield this;
  }

  Pos addTo(Pos pos) =>
      pos.rank == 5 ? new Pos(5, addFile(pos.file, plusfile)) : null;
  static int addFile(int posfile, bool plusfile) =>
      (posfile + (plusfile ? -10 : 10)) % 24;
}
