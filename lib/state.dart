library chess3man.engine.state;

import "moats.dart";
import 'castling.dart';
import 'board.dart';
import 'colors.dart';
import 'epstore.dart';
export 'board.dart';

class PlayersAlive {
  final bool w;
  final bool g;
  final bool b;
  const PlayersAlive(this.w, this.g, this.b);
  static const PlayersAlive all = const PlayersAlive(true, true, true);
  static const PlayersAlive noone = const PlayersAlive(false, false, false);
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
    throw new ArgumentError.value(c.index, "PlayersAlive Color c", "bad Color");
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
      : this(new Board.clone(from.b), from.ms, from.mn, from.cas, from.ep,
            from.hmc, from.ac, from.fmn);
  State.newGame()
      : this(new Board.newGame(), MoatsState.noBridges, Color.white,
            Castling.all, EnPassantStore.empty, 0, PlayersAlive.all, 1);
  Board get b => board;
  MoatsState get ms => moatsstate;
  Color get mn => movesnext;
  Castling get cas => castling;
  EnPassantStore get ep => enpassant;
  int get hmc => halfmoveclock;
  int get fmn => fullmovenumber;
  PlayersAlive get ac => alivecolors;
  State setBoard(Board b) => new State(b, ms, mn, cas, ep, hmc, ac, fmn);
  State setMoatsState(MoatsState ms) =>
      new State(b, ms, mn, cas, ep, hmc, ac, fmn);
  State setMovesNext(Color mn) => new State(b, ms, mn, cas, ep, hmc, ac, fmn);
  State setCastling(Castling cas) =>
      new State(b, ms, mn, cas, ep, hmc, ac, fmn);
  State setEnPassant(EnPassantStore ep) =>
      new State(b, ms, mn, cas, ep, hmc, ac, fmn);
  State setHalfMoveClock(int hmc) =>
      new State(b, ms, mn, cas, ep, hmc, ac, fmn);
  State setAliveColors(PlayersAlive ac) =>
      new State(b, ms, mn, cas, ep, hmc, ac, fmn);
  State setFullMoveNumber(int fmn) =>
      new State(b, ms, mn, cas, ep, hmc, ac, fmn);
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
