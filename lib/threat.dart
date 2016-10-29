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

Future<Pos> whereIsKing(Board b, Color who) async {
  for (final Pos opos in AMFT.keys) {
    final Square sq = b.gPos(opos);
    if (sq.notEmpty && sq.color == who && sq.fig.type == FigType.king)
      return opos;
  }
  return null;
}

Future<bool> isThereAThreat(
    Board b, Pos where, Pos from, PlayersAlive pa, EnPassantStore ep,
    [Square alrtjf = null]) {
  Square tjf = alrtjf ?? b.gPos(from);
  Iterable<Vector> vecs = tjf.fig.vecs_ns(from, where);
  Iterable<Future<bool>> futbools = vecs.map((Vector vec) =>
      possib(from, b, vec, MoatsState.noBridges, ep, Castling.off));
  Stream<bool> strofbools = new Stream<bool>.fromFutures(futbools);
  return (strofbools.firstWhere((bool elem) => elem, defaultValue: () => false))
      as Future<bool>; //TODO: avoid [as]
}

Future<Pos> threatChecking(
    Board b, Pos where, PlayersAlive pa, EnPassantStore ep) async {
  Color who = b.gPos(where).color;
  for (final Pos opos in AMFT.keys) {
    Square tjf = b.gPos(opos);
    if (tjf.notEmpty && tjf.color != who && pa.give(tjf.color)) {
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

class FriendOrNot {
  final bool friend;
  final Pos pos;
  const FriendOrNot(this.friend, this.pos);
}

Iterable<FriendOrNot> friendsAndNot(Board b, Color who, PlayersAlive pa) sync* {
  if (pa.give(who))
    for (final Pos opos in AMFT.keys) {
      final Square tjf = b.gPos(opos);
      final bool friend = (tjf.color == who ? true : null) ??
          ((tjf.notEmpty && pa.give(tjf.color)) ? false : null);
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
        yield b.gPos(ich).fig.type;
        break;
      }
}

Stream<FigType> weAreThreatened(
    Board b, Color who, PlayersAlive pa, EnPassantStore ep) async* {
  yield* weAreThreateningTypes(b, who, pa, ep, noWeAreThreatened: true);
}
