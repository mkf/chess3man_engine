library chess3man.engine.kingsearch;

import "board.dart";
import "amft.dart";
import "dart:async";
import "colors.dart";

Future<Pos> whereIsKing(Board b, Color who) async {
  for (final Pos opos in AMFT.keys) {
    final Square sq = b.gPos(opos);
    if(sq.notEmpty && sq.color==who && sq.fig.type==FigType.king) return opos;
  }
  return null;
}
