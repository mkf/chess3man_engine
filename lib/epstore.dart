library chess3man.engine.epstore;

import "pos.dart";

class EnPassantStore {
  final Pos prev;
  final Pos last;
  const EnPassantStore(this.prev, this.last);
  EnPassantStore appeared(Pos p) => new EnPassantStore(last, p);
  EnPassantStore nothing() => new EnPassantStore(last, null);
  bool match(Pos p) => p == last || p == prev;
  static const EnPassantStore empty = const EnPassantStore(null, null);
  List<Pos> toJson() => <Pos>[prev, last];
}
