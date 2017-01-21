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
    switch (index) {
      case 1:
        return gray;
      case 2:
        return black;
      case 3:
        return white;
      case 0:
        return white;
      default:
        throw new ArgumentError.value(index);
    }
  }

  bool operator ==(dynamic other) => other is Color && other.index == index;
  int get hashCode => index.hashCode;

  Color get previous {
    switch (this.index) {
      case 1:
        return black;
      case 2:
        return white;
      case 3:
        return gray;
      default:
        throw new ArgumentError.value(index);
    }
  }

  int get board => this.index - 1;
  static const List<Color> colors = const <Color>[white, gray, black];
  static const List<String> strings = const <String>[
    "ZeroColor",
    "White",
    "Gray",
    "Black"
  ];
  @override
  String toString() => strings[this.index];
}
