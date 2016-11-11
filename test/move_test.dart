library chess3man.engine.move_test;

import 'package:chess3man_engine/move.dart';
import 'package:test/test.dart';
//import 'dart:async';

void main() {
  test("simple gen no panic", () async {
    State newState = new State.newGame();
    print(newState.b.toJson());
    Pos from = new Pos(1, 0);
    Pos to = new Pos(3, 0);
    Fig fsq = newState.b.gPos(from);
    expect(fsq.type, equals(FigType.pawn));
    expect(fsq, new isInstanceOf<Pawn>());
    expect((fsq is Pawn), isTrue);
    //Vector onevec = ffi._vec_ns(from, to);
    //expect(onevec, isNotNull);
    Iterable<Vector> vecs = fsq.vecs(from, to);
    expect(vecs, isNotEmpty);
    Vector vec = vecs.first;
    expect(vec, isNotNull);
    Move first = new Move(from, vec, newState);
    print("A");
    Fig realsq = newState.b.b[1][0];
    print(realsq.toString());
    Fig oursq = newState.b.gPos(new Pos(1, 0));
    print(oursq.toString());
    expect(oursq, equals(realsq));
    print("H");
    print(first.before.b.toJson());
    print("J");
    State fiaft = await first.after();
    print(first.before.b.toJson());
    expect(fiaft, isNotNull);
  });
}
