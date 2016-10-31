library chess3man.engine.possib;

import "board.dart";
import "pos.dart";
import "moats.dart";
import "castling.dart";
import 'epstore.dart';
import 'colors.dart';
import 'castlingcheck.dart';
import 'dart:async';

Future<bool> checkempties(Pos from, Board b, Vector v) async {
  for (final Pos a in v.emptiesFrom(from)) if (b.nePos(a)) return false;
  return true;
}

Future<Impossibility> possib(Pos from, Board b, Vector v, MoatsState m,
    EnPassantStore ep, Castling c) async {
  Square fromsq = b.gPos(from); //Square we are from
  Color ourcolor = fromsq.color; //Color of from
  assert(ourcolor!=null);
  Pos to = v?.addTo(from); //our destination Pos
  Square tosq = b.gPos(to); //our destination Square
  Color tocol = fromsq.empty ? null : fromsq.color; //Color of dest Fig or null

  //As stated in Clif's email from Mon, 2 Nov 2015 11:32:54 -0500
  //Message-Id: <150c90b53b0-12f7-145cf@webprd-m97.mail.aol.com>
  //In-Reply-To: <20151102070250.GA6328@tichy>
  //which was In-Reply-To: <150c5fbe264-6425-13c7e@webprd-m75.mail.aol.com>
  //which was In-Reply-To: <20151101235348.GA32145@tichy>
  //which was In-Reply-To: <150c55f51d7-6425-13626@webprd-m75.mail.aol.com>
  //which was In-Reply-To: <20151031110645.GA25362@tichy>
  if (from == to) return new SameSquareImposs(from);

  //En passant capturing :
  if (v is PawnCapVector &&
      tosq.empty && //!ep.match(to))
      !(ep.last.equal(to) &&
          b.gPos(new Pos(3, ep.last.file)).color == ourcolor.previous) &&
      !(ep.prev.equal(to) &&
          b.gPos(new Pos(3, ep.prev.file)).color == ourcolor.next)) {
    return new CannotEnPassantImposs(to, ep);
  }

  //Cannot capture our own piece
  if (tosq.notEmpty && tocol == ourcolor)
    return new CannotCaptureSameColorImposs(ourcolor, to, tosq);

  //If there are pieces in our way return false
  if (!(await checkempties(from, b, v))) return new NotAllEmptiesImposs();

  //Set of moats colliding
  Set<Color> moats = new Set<Color>.from(v.moats(from));

  //ColorCastling for the Color of the from piece
  ColorCastling colorCastling = c.give(ourcolor);

  //If we are Castling and colorCastling forbids us to do so :
  if (v is CastlingVector && !checkCastling(colorCastling, v))
    return new ForbiddenCastlingImposs(colorCastling, v);

  //If we are capturing thru moats
  if (moats.length > 0 && tosq.notEmpty)
    return new CapturingThruMoatsImposs(moats, to, tosq);

  //If some moat we are passing is not bridged
  for (final Color curmoat in moats)
    if (!m.isBridgedBetweenThisAndNext(curmoat))
      return new PassingNonBridgedMoatImposs(curmoat, m, moats);

  return null;
}

abstract class Impossibility {
  String get msg;
  bool get canI;
}

class SameSquareImposs implements Impossibility {
  final Pos pos;
  const SameSquareImposs(this.pos);
  bool get canI => false;
  String get msg => "from==to==${this.pos.toString()}";
}

class CannotEnPassantImposs implements Impossibility {
  final Pos to;
  final EnPassantStore ep;
  const CannotEnPassantImposs(this.to, this.ep);
  bool get canI => false;
  String get msg =>
      "PawnCapV, tosq.empty, but cannot ep@${to.toString} cuz ${ep.toString()}";
  //TODO: Colors and diagnosis of the new extended, color-based "ep.match"
}

class CannotCaptureSameColorImposs implements Impossibility {
  final Pos to;
  final Square tosq;
  final Color ourcolor;
  const CannotCaptureSameColorImposs(this.ourcolor, this.to, this.tosq);
  bool get canI => false;
  String get msg =>
      "Cannot cap same col(${ourcolor.toString()}) on ${to.toString()}" +
      " as it is a ${tosq.toString()}";
}

class NotAllEmptiesImposs implements Impossibility {
  const NotAllEmptiesImposs();
  bool get canI => false;
  String get msg => "Not all empties";
}

class ForbiddenCastlingImposs implements Impossibility {
  final CastlingVector vec;
  final ColorCastling c;
  const ForbiddenCastlingImposs(this.c, this.vec);
  bool get canI => false;
  String get msg =>
      "ColorCastling ${c.toString()} forbids our castling ${vec.toString()}";
}

class CapturingThruMoatsImposs implements Impossibility {
  final Pos to;
  final Iterable<Color> moats;
  final Square tosq;
  const CapturingThruMoatsImposs(this.moats, this.to, this.tosq);
  bool get canI => moats.isEmpty;
  String get msg =>
      "Imposs cap thru moats(${moats.toString()}) to ${tosq.toString()}@${to.toString()}";
}

class PassingNonBridgedMoatImposs implements Impossibility {
  final MoatsState m;
  final Iterable<Color> moats;
  final Color curmoat;
  const PassingNonBridgedMoatImposs(this.curmoat, this.m, this.moats);
  bool get canI => false;
  String get msg =>
      "Passing non-bridged ${curmoat.toString()}: passing ${moats.toString()}, bridges ${m.toString()}";
}
