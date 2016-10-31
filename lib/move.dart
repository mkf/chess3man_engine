library chess3man.engine.move;

import 'pos.dart';
import 'state.dart';
import 'board.dart';
import 'possib.dart';
import 'dart:async';
import 'colors.dart';
import 'castling.dart';
import 'epstore.dart';
import 'prom.dart';
import 'moats.dart';
import 'afterboard.dart';
import 'threat.dart';
export 'state.dart';
export 'pos.dart';
export 'colors.dart';

class Move {
  final Pos from;
  final Vector vec;
  final State before;
  const Move(this.from, this.vec, this.before);
  Pos get to => vec.addTo(from);
  Fig get fromsq => before.board.gPos(from);
  Fig get what {
    if(fromsq==null) throw new NothingHereAlreadyException(this);
    return fromsq;
  }
  Color get who => what.color;
  Fig get tosq => before.board.gPos(to);
  Fig get alreadyThere => tosq;
  Future<bool> possible() async {
    //TODO: Pos.correct?
    if (fromsq==null) throw new NothingHereAlreadyException(this);
    if (what.color != before.movesnext)
      throw new ThatColorDoesNotMoveNowException(this, what.color);
    Impossibility impos = await possib(
        from,
        before.board,
        vec,
        before.moatsstate,
        before.enpassant,
        before.castling);
    if(impos!=null) throw new ImpossibleMoveException(this, impos);
    if (vec is PawnPromVector) {
      FigType toft = (vec as PawnPromVector).toft;
      switch (toft) {
        case FigType.zeroFigType:
        case FigType.king:
        case FigType.pawn:
          throw new IllegalPromotionException(this, toft);
      }
    }
    return true;
  }

  Future<State> after({bool evaluateDeath: true}) async {
    await possible();
    ColorCastling colorCastling = before.castling.give(who);
    if (what.type == FigType.king) colorCastling = ColorCastling.off;
    if (what.type == FigType.rook && from.rank == 0) {
      if (from.file == who.board * 8) colorCastling = colorCastling.offqs();
      if (from.file == who.board * 8 + 7) colorCastling = colorCastling.offks();
    }
    Castling castling = before.castling.change(who, colorCastling);
    if (to.rank == 0) {
      if (to.file % 8 == 7) {
        Color segmCol = to.colorSegm;
        castling.change(segmCol, castling.give(segmCol).offks());
      } else if (to.file % 8 == 0) {
        Color segmCol = to.colorSegm;
        castling.change(segmCol, castling.give(segmCol).offqs());
      } else if (to.file % 8 == CastlingVector.kfm)
        castling.change(to.colorSegm, ColorCastling.off);
    }
    int halfMoveClock = (what.type == FigType.pawn || (tosq!=null))
        ? 0
        : before.halfmoveclock + 1;
    EnPassantStore enPassantStore = before.enpassant;
    if (vec is PawnLongJumpVector)
      enPassantStore = //TODO: avoid [as]
          enPassantStore.appeared((vec as PawnLongJumpVector).enpfield(from));
    else
      enPassantStore = enPassantStore.nothing();
    if ((vec is PawnVector) &&
        (!(vec is PawnPromVector)) &&
        (vec as PawnVector).reqProm(from.rank))
      throw new NeedsToBePromotedException(this);
    Board b = await afterBoard(before.board, vec, from, before.enpassant);
    MoatsState moatsState = before.moatsstate;
    if ((!(vec is CastlingVector)) &&
        ((!(vec is PawnVector)) || (vec is PawnPromVector))) {
      for (final Color curmoat in Color.colors) {
        if (moatsState.isBridgedBetweenThisAndPrevious(curmoat) &&
            moatsState.isBridgedBetweenThisAndNext(curmoat)) break;
        if (!before.alivecolors.give(curmoat)) {
          moatsState = moatsState.bridgeBothSidesOfColor(curmoat);
          break;
        }
        bool moatbridging = true;
        for (int i = curmoat.board * 8;
            moatbridging && i < (curmoat.board + 1) * 8;
            i++) {
          if (b.gPos(new Pos(0, i)).color == curmoat) moatbridging = false;
        }
        if (moatbridging)
          moatsState = moatsState.bridgeBothSidesOfColor(curmoat);
      }
    }
    State next = new State(
        b,
        moatsState,
        before.alivecolors.give(before.movesnext.next)
            ? before.movesnext.next
            : before.movesnext.previous,
        castling,
        enPassantStore,
        halfMoveClock,
        before.alivecolors,
        before.fullmovenumber + 1);
    Future<PlayersAlive> evdDeath;
    if (evaluateDeath) evdDeath = evalDeath(next);
    Pos heyitscheck = await amIinCheck(next, what.color);
    if (heyitscheck != null)
      throw new WeInCheckException(this, heyitscheck, next);
    if (vec.moats(from).isNotEmpty) {
      Function ctfvitat = (Color c) async {
        return (isThereAThreat(b, await whereIsKing(b, c), to, next.alivecolors,
                enPassantStore)
            .then(CheckInitiatedThruMoatException._chk(this, c, next)));
      };
      Future<Future> ctfvprev = ctfvitat(what.color.previous);
      Future<Future> ctfvnext = ctfvitat(what.color.next);
      await await ctfvprev;
      await await ctfvnext;
    }
    return evaluateDeath ? next.setAliveColors(await evdDeath) : next;
  }
}

//typedef Future<void> ColorToFutureVoid(Color c);

class IllegalMoveException implements Exception {
  final Move m;
  final String msg;
  IllegalMoveException(this.m, this.msg);
  String toString() =>
      (msg ?? "IllegalMoveException") +
      " ${m.from.toString()} ${m.vec.toString()}";
}

class NothingHereAlreadyException extends IllegalMoveException {
  NothingHereAlreadyException(Move m)
      : super(m, "How do you move that which does not exist?");
}

class ThatColorDoesNotMoveNowException extends IllegalMoveException {
  final Color c;
  ThatColorDoesNotMoveNowException(Move m, this.c)
      : super(
            m,
            "That is not " +
                m.what.color.toString() +
                "'s move, but " +
                m.before.movesnext.toString() +
                "'s");
}

class ImpossibleMoveException extends IllegalMoveException {
  final Impossibility impos;
  ImpossibleMoveException(Move m, Impossibility impos)
      : this.impos = impos,
        super(m, "Illegal/impossible move " + impos.msg);
}

class IllegalPromotionException extends IllegalMoveException {
  final FigType to;
  IllegalPromotionException(Move m, FigType to)
      : this.to = to,
        super(m, "Illegal promotion to " + to.toString() + "!");
}

class NeedsToBePromotedException extends IllegalMoveException {
  NeedsToBePromotedException(Move m) : super(m, "Promotion is obligatory!");
}

class WeInCheckException extends IllegalMoveException {
  final Pos from;
  final State next;
  WeInCheckException(Move m, Pos from, this.next)
      : this.from = from,
        super(m, "We would be in check! (checking " + from.toString() + ")");
}

typedef void _CheckToCheckInitiatedThruMoatException(bool b);

class CheckInitiatedThruMoatException extends IllegalMoveException {
  final Color to;
  final State next;
  CheckInitiatedThruMoatException(Move m, Color to, this.next)
      : this.to = to,
        super(m, "Our piece initiated a check thru moat to " + to.toString());
  static _CheckToCheckInitiatedThruMoatException _chk(
      Move m, Color to, State next) {
    return (bool b) {
      if (b) throw new CheckInitiatedThruMoatException(m, to, next);
    };
  }
}
