library chess3man.engine.kingsearch;

import "board.dart";
import "amft.dart";
import "dart:async";
import "colors.dart";
import "state.dart";
import "epstore.dart";
import 'possib.dart';
import 'moats.dart';
import 'castling.dart';
import 'move.dart';
import 'prom.dart';

Future<Pos> whereIsKing(Board b, Color who) async {
  for (final Pos opos in AMFT.keys) {
    final Fig sq = b.gPos(opos);
    if (sq != null && sq.color == who && sq.type == FigType.king) return opos;
  }
  return null;
}

Future<bool> isThereAThreat(
    Board b, Pos where, Pos from, PlayersAlive pa, EnPassantStore ep,
    [Fig alrtjf = null]) {
  Fig tjf = alrtjf ?? b.gPos(from);
  Iterable<Vector> vecs = tjf.vecs(from, where);
  Iterable<Future<Impossibility>> futbools = vecs.map((Vector vec) =>
      possib(from, b, vec, MoatsState.noBridges, ep, Castling.off));
  Stream<Impossibility> strofbools =
      new Stream<Impossibility>.fromFutures(futbools);
  return (strofbools.firstWhere((Impossibility elem) => elem?.canI ?? true,
      defaultValue: () => false)) as Future<bool>; //TODO: avoid [as]
}

Future<Pos> threatChecking(
    Board b, Pos where, PlayersAlive pa, EnPassantStore ep) async {
  Color who = b.gPos(where).color;
  for (final Pos opos in AMFT.keys) {
    Fig tjf = b.gPos(opos);
    if (tjf != null && tjf.color != who && pa.give(tjf.color)) {
      if (await isThereAThreat(b, where, opos, pa, ep, tjf)) return opos;
    }
  }
  return null;
}

Future<Pos> checkChecking(Board b, Color who, PlayersAlive pa) async {
  assert(pa.give(who));
  Pos wking = await whereIsKing(b, who);
  assert(wking != null);
  return await threatChecking(b, wking, pa, EnPassantStore.empty);
}

Future<Pos> amIinCheck(State s, Color who) =>
    checkChecking(s.board, who, s.alivecolors);

class FriendOrNot {
  final bool friend;
  final Pos pos;
  const FriendOrNot(this.friend, this.pos);
}

Iterable<FriendOrNot> friendsAndNot(Board b, Color who, PlayersAlive pa) sync* {
  if (pa.give(who))
    for (final Pos opos in AMFT.keys) {
      final Fig tjf = b.gPos(opos);
      final bool friend = (tjf.color == who ? true : null) ??
          ((tjf != null && pa.give(tjf.color)) ? false : null);
      if (friend != null) yield new FriendOrNot(friend, opos);
    }
}

bool _tfriend(FriendOrNot elem) => elem.friend;
bool _ffriend(FriendOrNot elem) => !elem.friend;

Stream<FigType> weAreThreateningTypes(
    Board b, Color who, PlayersAlive pa, EnPassantStore ep,
    {bool noWeAreThreatened: false}) async* {
  Iterable<FriendOrNot> myioni = friendsAndNot(b, who, pa);
  Iterable<Pos> my = myioni
      .where(noWeAreThreatened ? _ffriend : _tfriend)
      .map((FriendOrNot fon) => fon.pos);
  Iterable<Pos> oni = myioni
      .where(noWeAreThreatened ? _tfriend : _ffriend)
      .map((FriendOrNot elem) => elem.pos);
  for (final Pos ich in oni)
    for (final Pos nasz in my)
      if (await isThereAThreat(b, ich, nasz, pa, ep)) {
        yield b.gPos(ich).type;
        break;
      }
}

Stream<FigType> weAreThreatened(
    Board b, Color who, PlayersAlive pa, EnPassantStore ep) async* {
  yield* weAreThreateningTypes(b, who, pa, ep, noWeAreThreatened: true);
}

Future<bool> canIMoveWOCheck(State os, Color who) async {
  State s = new State(
      new Board.clone(os.board),
      os.moatsstate,
      who,
      os.castling,
      os.enpassant,
      os.halfmoveclock,
      os.alivecolors,
      os.fullmovenumber);
  for (final Pos oac
      in AMFT.keys.where((Pos pos) => (s.board.gPos(pos)?.color == who)))
    for (final Pos oacp in AMFT[oac])
      for (final Vector vec in s.board.gPos(oac).vecs(oac, oacp)) {
        Move m = new Move(
            oac,
            vec is PawnVector && vec.reqProm(oac.rank)
                ? PawnPromVector.fromPV(vec, FigType.queen)
                : vec,
            s);
        try {
          if (await m.after(evaluateDeath: false) != null) return true;
        } on IllegalMoveException {
          continue;
        } on RangeError {
          print(vec.toString());
          print(m.toString());
          print(oac.toString());
          print(oacp.toString());
          rethrow;
        }
      }
  return false;
}

Future<PlayersAlive> evalDeath(State s) async {
  bool testCheckmate = true;
  Color player = s.movesnext;
  PlayersAlive pa = s.alivecolors;
  for (int indit = 0; indit < 3; indit++) {
    if (pa.give(player)) {
      if (testCheckmate &&
          (whereIsKing(s.board, player) == null ||
              !(await canIMoveWOCheck(s, player))))
        pa = pa.die(player);
      else {
        if (whereIsKing(s.board, player) == null) pa = pa.die(player);
        testCheckmate = false;
      }
    }
    player = player.next;
  }
  return pa;
}
