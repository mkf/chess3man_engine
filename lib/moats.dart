library chess3man.engine.moats;

import "colors.dart";

class MoatsState {
  final bool bw;
  final bool wg;
  final bool gb;
  const MoatsState(this.bw, this.wg, this.gb);
  static const MoatsState allBridged = const MoatsState(true, true, true);
  static const MoatsState noBridges = const MoatsState(false, false, false);
  String toString() => "M${bw?"|":"-"}${wg?"|":"-"}${gb?"|":"-"}";
  bool isBridgedBetween(Color a, Color b) {
    Color bef = a.next == b ? a : b.next == a ? b : null;
    assert(bef != null);
    return isBridgedBetweenThisAndNext(bef);
  }

  bool isBridgedBetweenThisAndNext(Color col) {
    switch (col) {
      case Color.black:
        return bw;
      case Color.white:
        return wg;
      case Color.gray:
        return gb;
      default:
        return null;
    }
  }

  MoatsState changeBetweenThisAndNext(Color col, bool towhat) {
    switch (col) {
      case Color.black:
        return new MoatsState(towhat, wg, gb);
      case Color.white:
        return new MoatsState(bw, towhat, gb);
      case Color.gray:
        return new MoatsState(bw, wg, towhat);
      default:
        return null;
    }
  }

  MoatsState bridgeBetweenThisAndNext(Color col) =>
      changeBetweenThisAndNext(col, true);

  MoatsState bridgeBothSidesOfColor(Color col) =>
      bridgeBetweenThisAndPrevious(col).bridgeBetweenThisAndNext(col);

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

  MoatsState changeBetweenThisAndPrevious(Color col, bool towhat) {
    switch (col) {
      case Color.black:
        return new MoatsState(bw, wg, towhat);
      case Color.white:
        return new MoatsState(towhat, wg, gb);
      case Color.gray:
        return new MoatsState(bw, towhat, gb);
      default:
        return null;
    }
  }

  MoatsState bridgeBetweenThisAndPrevious(Color col) =>
      changeBetweenThisAndPrevious(col, true);

  _ShortLong areBridgedBetweenThisAndPrevious(Color col) => new _ShortLong(
      isBridgedBetweenThisAndPrevious(col),
      isBridgedBetweenThisAndPrevious(col.previous) &&
          isBridgedBetweenThisAndPrevious(col.next));
  _ShortLong areBridgedBetweenThisAndNext(Color col) => new _ShortLong(
      isBridgedBetweenThisAndNext(col),
      isBridgedBetweenThisAndNext(col.previous) &&
          isBridgedBetweenThisAndNext(col.next));
}

class _ShortLong {
  final bool short;
  final bool long;
  const _ShortLong(this.short, this.long);
}
