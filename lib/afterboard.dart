library chess3man.engine.afterboard;

import 'pos.dart';
import 'board.dart';
import 'epstore.dart';
import 'colors.dart';
import 'dart:async';

Future<Board> afterBoard(
    Board oldb, Vector vec, Pos from, EnPassantStore ep) async {
  Board b = new Board.clone(oldb);
  if (vec is KingsideCastlingVector) {
    b.mFig(from, vec.addTo(from));
    b.mFig(new Pos(0, from.file + 3), new Pos(0, from.file + 1));
  } else if (vec is QueensideCastlingVector) {
    b.mFig(from, vec.addTo(from));
    b.mFig(new Pos(0, from.file - 4), new Pos(0, from.file - 1));
  } else if (vec is PawnCapVector) {
    Pos to = vec.addTo(from);
    b.mFig(from, to);
    Color ourcolor = oldb.gPos(from).color;
    if ((ep.last.equal(to) &&
            b.gPos(new Pos(3, ep.last.file)).color == ourcolor.previous) ||
        (ep.prev.equal(to) &&
            b.gPos(new Pos(3, ep.prev.file)).color == ourcolor.next))
      b.empt(new Pos(3, to.file));
  } else
    b.mFig(from, vec.addTo(from));
  return b;
}
