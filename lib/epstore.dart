library chess3man.engine.epstore;

import "pos.dart";

class EnPassantStore {
  final Pos prev; //you can capture next color
  final Pos last; //you can capture previous color
  const EnPassantStore(this.prev, this.last);
  EnPassantStore appeared(Pos p) => new EnPassantStore(last, p);
  EnPassantStore nothing() => new EnPassantStore(last, null);
  bool match(Pos p) => p.equal(last) || p.equal(prev);
  static const EnPassantStore empty = const EnPassantStore(null, null);
  List<Pos> toJson() => <Pos>[prev, last];
}
