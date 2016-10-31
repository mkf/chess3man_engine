library chess3man.engine.move_test;

import 'package:chess3man_engine/move.dart';
import 'package:test/test.dart';
import 'dart:async';

void main() {
  test("simple gen no panic", () async {
    State newState = new State.newGame();
    print(newState.b.toJson());
    Pos from = new Pos(1, 0);
    Pos to = new Pos(3, 0);
    Square fsq = newState.b.gPos(from);
    Fig ffi = fsq.fig;
    expect(ffi.type, equals(FigType.pawn));
    expect(ffi, new isInstanceOf<Pawn>());
    expect((ffi is Pawn), isTrue);
    //Vector onevec = ffi._vec_ns(from, to);
    //expect(onevec, isNotNull);
    Iterable<Vector> vecs = ffi.vecs(from, to);
    expect(vecs, isNotEmpty);
    Vector vec = vecs.first;
    expect(vec, isNotNull);
    Move first = new Move(from, vec, newState);
    expect(await first.after(),isNotNull);
  });
}