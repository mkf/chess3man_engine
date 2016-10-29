library chess3man.engine.state;

import "moats.dart";
import 'castling.dart';
import 'board.dart';
import 'colors.dart';
import 'epstore.dart';

class PlayersAlive {
  final bool w;
  final bool g;
  final bool b;
  const PlayersAlive(this.w, this.g, this.b);
  PlayersAlive change(Color c, bool what) {
    switch (c) {
      case Color.white:
        return new PlayersAlive(what, this.g, this.b);
      case Color.gray:
        return new PlayersAlive(this.w, what, this.b);
      case Color.black:
        return new PlayersAlive(this.w, this.b, what);
    }
    return null;
  }

  PlayersAlive die(Color c) => change(c, false);
  bool give(Color c) {
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
}

class State {
  final Board board; //MUTABLE
  final MoatsState moatsstate; //immutable
  final Color movesnext; //immutable
  final Castling castling; //immutable
  final EnPassantStore enpassant; //immutable
  final int halfmoveclock; //immutable
  final int fullmovenumber; //immutable
  final PlayersAlive alivecolors; //immutable
  //TODO: bool equal(State s) =>
  const State(
      this.board,
      this.moatsstate,
      this.movesnext,
      this.castling,
      this.enpassant,
      this.halfmoveclock,
      this.alivecolors,
      this.fullmovenumber);
  State.clone(State from)
      : this(
            new Board.clone(from.board),
            from.moatsstate,
            from.movesnext,
            from.castling,
            from.enpassant,
            from.halfmoveclock,
            from.alivecolors,
            from.fullmovenumber);
  String toString() =>
      board.toString() +
      moatsstate.toString() +
      movesnext.toString() +
      castling.toString() +
      enpassant.toString() +
      halfmoveclock.toString() +
      fullmovenumber.toString() +
      alivecolors.toString();
}
