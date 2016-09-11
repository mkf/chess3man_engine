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
  ColorCastling offqs() => new ColorCastling.woffqs(this);
  ColorCastling offks() => new ColorCastling.woffks(this);
  static const ColorCastling off = const ColorCastling(false, false);
  static const ColorCastling all = const ColorCastling(true, true);
  static const ColorCastling qo = const ColorCastling(true, false);
  static const ColorCastling ko = const ColorCastling(false, true);
}

class Castling {}
