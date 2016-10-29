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

Future<Pos> threatChecking(
    Board b, Pos where, PlayersAlive pa, EnPassantStore ep) async {
  Color who = b.gPos(where).color;
  for (final Pos opos in AMFT.keys) {
    Square tjf = b.gPos(opos);
    if (tjf.notEmpty && tjf.color != who && pa.give(tjf.color)) {
      Iterable<Vector> vecs = tjf.fig.vecs_ns(opos, where);
      Iterable<Future<bool>> futbools = vecs.map((Vector vec) =>
          possib(opos, b, vec, new MoatsState.noBridges(), ep, Castling.off));
      Stream<bool> strofbools = new Stream<bool>.fromFutures(futbools);
      Future<bool> thebool = (strofbools.firstWhere((bool elem) => elem,
          defaultValue: () => false)) as Future<bool>; //TODO: avoid [as]
      if (await thebool) return opos;
    }
  }
  return null;
}
