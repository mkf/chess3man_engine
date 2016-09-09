library chess3man.engine.pos;

import "colors.dart";

class CanIDiagonal {
  final bool short;
  final bool long;
  final bool positivesgn;
  const CanIDiagonal(this.short, this.long, this.positivesgn);
  const CanIDiagonal.no()
      : this.short = false,
        this.long = false,
        this.positivesgn = null;
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
  CanIDiagonal diagonal(Pos ano) {
    if (this == ano) {
      return new CanIDiagonal.no();
    }
    int shorttd = (ano.rank < rank ? rank - ano.rank : ano.rank - rank);
    int longtd = ano.rank + rank;
    bool short = false;
    bool positivesgn;
    if (ano.file == (file + shorttd) % 24) {
      positivesgn = true;
      short = true;
    } else if (ano.file == (file - shorttd + 24) % 24) {
      positivesgn = false;
      short = true;
    } else if (ano.file == (file + longtd) % 24) {
      positivesgn = true;
      short = false;
    } else if (ano.file == (file - longtd + 24) % 24) {
      positivesgn = false;
      short = false;
    } else {
      return new CanIDiagonal.no();
    }
    return new CanIDiagonal(
        short,
        !short ||
            (file + (positivesgn ? longtd : 24 - longtd) % 24 == ano.file),
        positivesgn);
  }

  static int wrappedFileVector(int from, int to, [longnotshort = false]) {
    int diff = to - from;
    int sgn = diff < 0 ? -1 : 1;
    return ((diff * sgn > 12) == longnotshort) ? diff : (diff - 24 * sgn);
  }
}

class Vector {
  final int rank;
  final int file;
  const Vector(this.rank, this.file);
  static int wrappedFileVector(int from, int to, [longnotshort = false]) {
    return (to - from) % 24;
  }

  Vector.fromPlaced(Pos from, Pos to, {longnotshort: false})
      : this.rank = (to.rank - from.rank) % 6,
        this.file = wrappedFileVector(from.file, to.file, longnotshort);
}
