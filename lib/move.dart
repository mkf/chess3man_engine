library chess3man.engine.move;

import 'pos.dart';
import 'state.dart';
import 'board.dart';
import 'possib.dart';
import 'dart:async';
import 'colors.dart';

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
  Future<bool> possible() async {
    //TODO: Pos.correct?
    if (fromsq.empty) throw new NothingHereAlreadyError(this);
    if (what.color != before.movesnext)
      throw new ThatColorDoesNotMoveNowError(this, what.color);
    if (!(await possib(
        from,
        before.board,
        vec,
        before.moatsstate,
        before.enpassant,
        before.castling))) throw new ImpossibleMoveError(this);
    return true;
  }
  Future<State> after() async {
    assert (await possible());
    //TODO
  }
}

abstract class IllegalMoveError extends StateError {
  final Move m;
  IllegalMoveError(this.m, String msg) : super(msg);
}

class NothingHereAlreadyError extends IllegalMoveError {
  NothingHereAlreadyError(Move m) : super(m, "How do you move that which does not exist?");
}

class ThatColorDoesNotMoveNowError extends IllegalMoveError {
  final Color c;
  ThatColorDoesNotMoveNowError(Move m, this.c) : super(m, "That is not "+m.what.color.toString()+"'s move, but "+m.before.movesnext.toString()+"'s");
}

class ImpossibleMoveError extends IllegalMoveError {
  ImpossibleMoveError(Move m) : super(m, "Illegal/impossible move");
}
