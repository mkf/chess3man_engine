library chess3man.engine.moats;

import "colors.dart";

class MoatsState {
  bool bw;
  bool wg;
  bool gb;
  MoatsState(this.bw, this.wg, this.gb);
  MoatsState.allBridged()
      : this.bw = true,
        this.wg = true,
        this.gb = true;
  MoatsState.noBridges()
      : this.bw = false,
        this.wg = false,
        this.gb = false;
  bool isBridgedBetween(Color a, Color b) {
    Color bef = a.next() == b ? a : b.next() == a ? b : null;
    assert(bef != null);
    return isBridgedBetweenThisAndNext(bef);
  }

  bool isBridgedBetweenThisAndNext(Color col) {
    switch (col) {
      case Color.black:
        return bw;
      case Color.white:
        return wg;
      case Color.white:
        return gb;
      default:
        return null;
    }
  }

  bool isBridgedBetweenThisAndPrevious(Color col) {
    switch (col) {
      case Color.black:
        return gb;
      case Color.white:
        return bw;
      case Color.gray:
        return wg;
      default:
        return null;
    }
  }

  _ShortLong areBridgedBetweenThisAndPrevious(Color col) => new _ShortLong(
      isBridgedBetweenThisAndPrevious(col),
      isBridgedBetweenThisAndPrevious(col.previous()) &&
          isBridgedBetweenThisAndPrevious(col.next()));
  _ShortLong areBridgedBetweenThisAndNext(Color col) => new _ShortLong(
      isBridgedBetweenThisAndNext(col),
      isBridgedBetweenThisAndNext(col.previous()) &&
          isBridgedBetweenThisAndNext(col.next()));
}

class _ShortLong {
  final bool short;
  final bool long;
  const _ShortLong(this.short, this.long);
}
