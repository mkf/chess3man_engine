library chess3man.engine.move_test;

import 'package:chess3man_engine/move.dart';
import 'package:test/test.dart';

main() {
  test("simple gen no panic", () {
    State newState = new State.newGame();
    Pos from = new Pos(1, 0);
    Pos to = new Pos(3, 0);
    Iterable<Vector> vecs = newState.b.gPos(from).fig.vecs_ns(from, to);
    Move first = new Move(from, vecs.first, newState);
    expect(first.after(),isNotNull);
  });
}