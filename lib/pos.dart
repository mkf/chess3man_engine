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
      : this.file = color.board << 3 + colorfile;
  String toString() => "[$rank,$file]";
  Color get colorSegm => new Color.fromSegm(file % 8);
  Pos next() => rank == 5 && file == 23
      ? null
      : new Pos(file == 23 ? rank + 1 : rank, file == 23 ? 0 : file + 1);
  bool sameRank(Pos ano) => rank == ano.rank;
  bool sameFile(Pos ano) => file == ano.file;
  bool equal(Pos ano) => file == ano.file && rank == ano.rank;
  bool adjacentFile(Pos ano) => file + 12 % 24 == ano.file;
  bool sameOrAdjacentFile(Pos ano) => file % 12 == ano.file % 12;
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

  @deprecated
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

  static int wrappedFileVector(int from, int to, [long = false]) {
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
}

class ZeroVector implements Vector {
  int get rank => 0;
  int get file => 0;
  int get mrank => 0;
  int get mfile => 0;
  bool toBool() => false;
  Pos addTo(Pos from) => from;
  const ZeroVector();
  Iterable<Vector> units(_) sync* {}
}

class KnightVector implements Vector {
  final bool inward;
  final bool plusfile;
  final bool centeronecloser;
  const KnightVector(this.inward, this.plusfile, this.centeronecloser);
  bool get morerank => centeronecloser == inward;
  bool get morefile => !morerank;
  int get rank => (inward ? 1 : -2) + (centeronecloser ? 1 : 0);
  int get file => (morefile ? 2 : 1) * (plusfile ? 1 : -1);
  Pos addTo(Pos from) => (inward &&
          (centeronecloser && from.rank >= 4 || from.rank == 5))
      ? (centeronecloser
          ? new Pos(
              (5 + 4) - from.rank, (from.rank + (plusfile ? 1 : -1) + 12) % 24)
          : new Pos(5, (from.rank + (plusfile ? 2 : -2) + 12) % 24))
      : null;

  bool toBool() =>
      inward != null && plusfile != null && centeronecloser != null;
  Iterable<KnightVector> units(_) sync* {
    yield this;
  }
}

abstract class ContinousVector implements Vector {
  final int abs;
  const ContinousVector(this.abs);
  const ContinousVector.unit() : this.abs = 1;
  @override
  bool toBool() => (abs is int) && abs != 0;
  Iterable<ContinousVector> units(int fromrank);
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
  int get file => t;
  int get rank => 0;
  const FileVector(int file, [bool direc = null]) : super(file % 24, direc);
  const FileVector.unit(bool direc) : super.unit(direc);
  Iterable<FileVector> units(_) sync* {
    for (int i = abs; i > 0; i--) {
      yield new FileVector.unit(direc);
    }
  }

  Pos addTo(Pos pos) => new Pos(pos.rank, (pos.file + this.file) % 24);
}

class RankVector extends AxisVector {
  int get rank => t;
  int get file => 0;
  const RankVector(int rank, [bool direc = null]) : super(rank, direc);
  const RankVector.unit(bool direc) : super.unit(direc);
  bool thruCenter(int fromrank) => direc && fromrank + this.rank > 5;
  Iterable<RankVector> units(_) sync* {
    for (int i = abs; i > 0; i--) {
      yield new RankVector.unit(direc);
    }
  }

  Pos addTo(Pos pos) {
    bool tC = thruCenter(pos.rank);
    return new Pos(
        tC ? 5 - (pos.rank + this.abs) : pos.rank + this.rank, pos.file);
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
  Iterable<DirectDiagonalVector> units(_) sync* {
    for (int i = abs; i > 0; i--) {
      yield new DirectDiagonalVector.unit(inward, plusfile);
    }
  }

  Pos addTo(Pos pos) =>
      new Pos(pos.rank + this.rank, (pos.file + this.file) % 24);
}

class LongDiagonalVector extends DiagonalVector {
  bool get inward => true;
  const LongDiagonalVector(int abs, bool plusfile) : super(abs, plusfile);
  const LongDiagonalVector.unit(bool plusfile) : super.unit(plusfile);
  const LongDiagonalVector.fromNumsVec(int rank, int file)
      : super((rank == (file < 0 ? -file : file)) ? rank : null, file > 0);
  LongDiagonalVector.fromVector(Vector vec)
      : this.fromNumsVec(vec.rank, vec.file);
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
  bool get inward => true;
  const SolelyThruCenterDiagonalVector(bool plusfile) : super.unit(plusfile);
  Iterable<SolelyThruCenterDiagonalVector> units(_) sync* {
    yield this;
  }

  Pos addTo(Pos pos) => pos.rank == 5
      ? new Pos(5, (pos.file + (plusfile ? -10 : 10)) % 24)
      : null;
}
