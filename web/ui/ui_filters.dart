library doxblox.ui_filters;

import 'package:polymer_expressions/filter.dart';

/**
 * Trasnformer to convert an int to String and back.
 */
class IntToString extends Transformer<String, int> {
  final int radix;
  
  IntToString({this.radix: 10});
  
  String forward(int i) => '$i';
  int reverse(String s) => s == null ? null : int.parse(s, radix: radix, onError: (s) => null);
}

/**
 * Transforms an index to a corresponding letter.
 */
class IndexToLetter extends Transformer<String, int> {
  static final List<String> _letters = const ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 
                                 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 
                                 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'];
  
  String forward(int i) => _letters[i];
  int reverse(String s) => _letters.indexOf(s);
}