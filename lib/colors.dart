library chess3man.engine.colors;

class Color {
  final int index;
  const Color(this.index);
  const Color.fromSegm(int segm) : this.index = segm + 1;
  static const Color zeroColor = const Color(0);
  static const Color white = const Color(1);
  static const Color gray = const Color(2);
  static const Color black = const Color(3);
  int toInt() => this.index;
  Color get next {
    switch (this) {
      case white:
        return gray;
      case gray:
        return black;
      case black:
        return white;
      case zeroColor:
        return white;
      default:
        throw new ArgumentError.value(index);
    }
  }

  Color get previous {
    switch (this) {
      case white:
        return black;
      case gray:
        return white;
      case black:
        return gray;
      default:
        throw new ArgumentError.value(index);
    }
  }

  int get board => this.index - 1;
  static const List<Color> colors = const <Color>[white, gray, black];
  static const Map<Color, String> strings = const <Color, String>{
    white: "White",
    gray: "Gray",
    black: "Black",
    zeroColor: "ZeroColor"
  };
  @override
  String toString() => strings[this];
}
