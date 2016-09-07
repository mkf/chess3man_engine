library chess3man.engine.colors;

class Color {
  final int index;
  const Color(this.index);
  const Color.fromSegm(int segm) : this.index = segm + 1;
  static const zeroColor = const Color(0);
  static const white = const Color(1);
  static const gray = const Color(2);
  static const black = const Color(3);
  int toInt() => this.index;
  Color next() => new Color(index % 3 + 1);
  Color previous() => new Color(index % 3 - 1 % 3);
  int get board => this.index - 1;
  static const List<Color> colors = const <Color>[white, gray, black];
  static const Map<Color, String> strings = const <Color, String>{
    white: "White",
    gray: "Gray",
    black: "Black",
    zeroColor: "ZeroColor"
  };
  String toString() => strings[this];
}
