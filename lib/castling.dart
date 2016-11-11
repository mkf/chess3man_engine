library chess3man.engine.castling;

import "colors.dart";

class ColorCastling {
  final bool q;
  final bool k;
  const ColorCastling(this.q, this.k);
  ColorCastling.wcqs(ColorCastling old, this.q) : this.k = old.k;
  ColorCastling.wcks(ColorCastling old, this.k) : this.q = old.q;
  ColorCastling.woffqs(ColorCastling old)
      : this.k = old.k,
        this.q = false;
  ColorCastling.woffks(ColorCastling old)
      : this.q = old.q,
        this.k = false;
  ColorCastling cqs(bool qs) => new ColorCastling.wcqs(this, qs);
  ColorCastling cks(bool ks) => new ColorCastling.wcks(this, ks);
  ColorCastling offqs() => this.k ? ko : off;
  ColorCastling offks() => this.q ? qo : off;
  static const ColorCastling off = const ColorCastling(false, false);
  static const ColorCastling all = const ColorCastling(true, true);
  static const ColorCastling qo = const ColorCastling(true, false);
  static const ColorCastling ko = const ColorCastling(false, true);
}

class Castling {
  final ColorCastling w;
  final ColorCastling g;
  final ColorCastling b;
  const Castling(this.w, this.g, this.b);
  Castling change(Color c, ColorCastling to) {
    switch (c) {
      case Color.white:
        return new Castling(to, g, b);
      case Color.gray:
        return new Castling(w, to, b);
      case Color.black:
        return new Castling(w, g, to);
    }
    return null;
  }

  ColorCastling give(Color c) {
    switch (c) {
      case Color.white:
        return w;
      case Color.gray:
        return g;
      case Color.black:
        return b;
    }
    return null;
  }

  static const Castling off =
      const Castling(ColorCastling.off, ColorCastling.off, ColorCastling.off);
  static const Castling all =
      const Castling(ColorCastling.all, ColorCastling.all, ColorCastling.all);
}
