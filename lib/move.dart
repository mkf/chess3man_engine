library chess3man.engine.move;

import 'pos.dart';
import 'state.dart';
import 'board.dart';

class Move {
  final Pos from;
  final Vector vec;
  final State before;
  const Move(this.from, this.vec, this.before);
  Pos get to => vec.addTo(from);
  Square get fromsq => before.board.gPos(from);
  Fig get what => fromsq.fig;
  Square get tosq => before.board.gPos(to);
  Fig get alreadyThere => tosq.fig;
}
