library chess3man.engine.possib;

import "board.dart";
import "pos.dart";
import "moats.dart";
import "castling.dart";
import 'epstore.dart';
import 'colors.dart';
import 'castlingcheck.dart';
import 'dart:async';

bool checkempties(Pos from, Board b, Vector v) {
  for (final Pos a in v.emptiesFrom(from)) if (b.nePos(a)) return false;
  return true;
}

Future<bool> possib(Pos from, Board b, Vector v, MoatsState m,
    EnPassantStore ep, Castling c) async {
  Square fromsq = b.gPos(from); //Square we are from
  Color ourcolor = fromsq.color; //Color of from
  Pos to = v.addTo(from); //our destination Pos
  Square tosq = b.gPos(to); //our destination Square
  Color tocol = fromsq.empty ? null : fromsq.color; //Color of dest Fig or null

  //As stated in Clif's email from Mon, 2 Nov 2015 11:32:54 -0500
  //Message-Id: <150c90b53b0-12f7-145cf@webprd-m97.mail.aol.com>
  //In-Reply-To: <20151102070250.GA6328@tichy>
  //which was In-Reply-To: <150c5fbe264-6425-13c7e@webprd-m75.mail.aol.com>
  //which was In-Reply-To: <20151101235348.GA32145@tichy>
  //which was In-Reply-To: <150c55f51d7-6425-13626@webprd-m75.mail.aol.com>
  //which was In-Reply-To: <20151031110645.GA25362@tichy>
  if (from == to) return false;

  //En passant capturing :
  if ((v is PawnCapVector) && (tosq.empty && (ep.match(to)))) return false;

  //Cannot capture our own piece
  if (tocol == ourcolor) return false;

  //If there are pieces in our way return false
  if (!checkempties(from, b, v)) return false;

  //Set of moats colliding
  Set<Color> moats = new Set<Color>.from(v.moats(from));

  //ColorCastling for the Color of the from piece
  ColorCastling colorCastling = c.give(ourcolor);

  //If we are Castling and colorCastling forbids us to do so :
  if (v is CastlingVector && !checkCastling(colorCastling, v)) return false;

  //If we are capturing thru moats
  if (moats.length > 0 && tosq.notEmpty) return false;

  //If some moat we are passing is not bridged
  for (final Color curmoat in moats)
    if (!m.isBridgedBetweenThisAndNext(curmoat)) return false;

  return true;
}
