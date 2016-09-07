library chess3man.engine.pos;

import "colors.dart";

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
  bool adjacentFile(Pos ano) => file + 12 % 24 == ano.file;
  bool sameOrAdjacentFile(Pos ano) => file % 12 == ano.file % 12;
  //bool shortDiagonal(Pos ano) => (ano.rank-rank)%6==(ano.file-file)%12;
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
