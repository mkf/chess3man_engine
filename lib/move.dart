library chess3man.engine.move;

import 'dart:async';

import 'afterboard.dart';
import 'board.dart';
import 'castling.dart';
import 'colors.dart';
import 'epstore.dart';
import 'moats.dart';
import 'pos.dart';
import 'possib.dart';
import 'prom.dart';
import 'state.dart';
import 'threat.dart';

export 'colors.dart';
export 'pos.dart';
export 'state.dart';

///Move is defined by the starting position, the vector and the preceding state
class Move {
  ///the starting square
  final Pos from;

  ///the move vector
  final Vector vec;

  ///the preceding state
  final State before;

  ///the simple constructor
  const Move(this.from, this.vec, this.before);

  String toString() =>
      "þ${from.toString()}»${vec.toString()}«\n${before.toString()}";

  ///[to] getter adds the [vec]tor to [from] (the starting pos)
  Pos get to => vec.addTo(from);

  ///[fromsq] returns [before]`.board.gPos(`[from]`) ([Board.gPos])
  Fig get fromsq => before.board.gPos(from);

  ///returns [fromsq] or throws [NothingHereAlreadyException] containing it if the square is empty
  Fig get what {
    print(before.board.toString());
    if (fromsq == null) throw new NothingHereAlreadyException(this, fromsq);
    return fromsq;
  }

  ///returns the color of [what]/[fromsq] throwing [NothingHereAlreadyException] as [what] does as it utilizes [what]
  Color get who => what.color;

  ///[tosq] returns `before.board.gPos([to])` ([Board.gPos])
  Fig get tosq => before.board.gPos(to);

  ///[alreadyThere](alias to [tosq]) returns `before.board.gPos([to])` ([Board.gPos])
  Fig get alreadyThere => tosq;

  ///[possible] checks whether
  /// * [fromsq] is not empty
  ///     [NothingHereAlreadyException]
  /// * the [Color] of [what] is equal to [before].[State.movesnext]
  ///     [ThatColorDoesNotMoveNowException]
  /// * the move is possible by the criteria of [possib]
  ///     [ImpossibleMoveException]
  /// * [PawnPromVector.toft] is not [FigType.zeroFigType]/[FigType.king]/[FigType.pawn],
  ///     [IllegalPromotionException]
  // ignore: conflicting_dart_import
  Future<IllegalMoveException> possible() async {
    //TODO: Pos.correct?
    if (fromsq == null) return new NothingHereAlreadyException(this, fromsq);
    if (what.color != before.movesnext)
      return new ThatColorDoesNotMoveNowException(this, what.color);
    Impossibility impos = await possib(from, before.board, vec,
        before.moatsstate, before.enpassant, before.castling);
    if (impos != null) return new ImpossibleMoveException(this, impos);
    if (vec is PawnPromVector) {
      FigType toft = (vec as PawnPromVector).toft;
      if ((const <FigType>[FigType.pawn, FigType.king, FigType.zeroFigType])
          .contains(toft)) return new IllegalPromotionException(this, toft);
    }
    return null;
  }

  static ColorCastling afterColorCastling(
      ColorCastling colorCastling, FigType whatype, Color who, Pos from) {
    if (whatype == FigType.king) return ColorCastling.off;
    if (whatype == FigType.rook && from.rank == 0)
      switch (from.file - (who.board * 8)) {
        case 0:
          return colorCastling.offqs();
        case 7:
          return colorCastling.offks();
      }
    return colorCastling;
  }

  static Castling afterCastling(
      Castling castling, FigType whatype, Color who, Pos from, Pos to) {
    castling = castling.change(
        who, afterColorCastling(castling.give(who), whatype, who, from));
    if (to.rank == 0) {
      switch (to.file % 8) {
        case 7:
          Color segmCol = to.colorSegm;
          return castling.change(segmCol, castling.give(segmCol).offks());
        case 0:
          Color segmCol = to.colorSegm;
          return castling.change(to.colorSegm, castling.give(segmCol).offqs());
        case CastlingVector.kfm:
          return castling.change(to.colorSegm, ColorCastling.off);
      }
    }
    return castling;
  }

  Future<MoatsState> afterMoatsState(Future<Board> fb) async {
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
          if ((await fb).gPos(new Pos(0, i)).color == curmoat)
            moatbridging = false;
        }
        if (moatbridging)
          moatsState = moatsState.bridgeBothSidesOfColor(curmoat);
      }
    }
    return moatsState;
  }

  Future<State> after({bool evaluateDeath: true}) async {
    IllegalMoveException illegal = await possible();
    if (illegal != null) throw illegal;

    if ((vec is PawnVector) &&
        (!(vec is PawnPromVector)) &&
        (vec as PawnVector).reqProm(from.rank))
      throw new NeedsToBePromotedException(this);

    Future<Board> fb = afterBoard(before.board, vec, from, before.enpassant);

    Future<MoatsState> fms = afterMoatsState(fb);

    EnPassantStore enPassantStore = (vec is PawnLongJumpVector)
        ? before.enpassant.appeared((vec as PawnLongJumpVector).enpfield(from))
        : before.enpassant.nothing();

    Board b = await fb;

    State next = new State(
        b,
        await fms,
        before.alivecolors.give(before.movesnext.next)
            ? before.movesnext.next
            : before.movesnext.previous,
        afterCastling(before.castling, what.type, who, from, to),
        enPassantStore,
        (what.type == FigType.pawn || (tosq != null))
            ? 0
            : before.halfmoveclock + 1,
        before.alivecolors,
        before.fullmovenumber + 1);

    Future<State> nextWithEvalD;
    if (evaluateDeath)
      nextWithEvalD = evaluateDeathThrowingCheck(next, what.color);

    if (vec.moats(from).isNotEmpty) {
      Function ctfvitat = (Color c) async {
        return await (isThereAThreat(b, await whereIsKing(b, c), to,
                next.alivecolors, enPassantStore)
            .then(CheckInitiatedThruMoatException._chk(this, c, next)));
      };
      Future<dynamic> ctfvprev = ctfvitat(what.color.previous);
      Future<dynamic> ctfvnext = ctfvitat(what.color.next);
      await ctfvprev;
      await ctfvnext;
    }

    return evaluateDeath ? await nextWithEvalD : next;
  }

  Future<State> evaluateDeathThrowingCheck(State next, Color whatColor) async {
    Future<PlayersAlive> evdDeath = evalDeath(next);
    await amIinCheck(next, whatColor).then(//should it be there
        (Pos heyitscheck) {
      if (heyitscheck != null)
        throw new WeInCheckException(this, heyitscheck, next);
    });
    return next.setAliveColors(await evdDeath);
  }
}

//typedef Future<void> ColorToFutureVoid(Color c);

class IllegalMoveException implements Exception {
  final Move m;
  final String msg;

  IllegalMoveException(this.m, this.msg);

  String toString() =>
      (msg ?? "IllegalMoveException") +
      " from${m.from.toString()} vec:${m.vec.toString()}";
}

class NothingHereAlreadyException extends IllegalMoveException {
  final Fig sq;

  NothingHereAlreadyException(Move m, Fig sq)
      : this.sq = sq,
        super(
            m, "How do you move that which does not exist (${sq.toString()})?");
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
