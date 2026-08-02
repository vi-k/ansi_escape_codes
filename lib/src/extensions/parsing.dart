import '../parsing/parser/parser.dart';

/// Shortcuts for the operations of [Parser] that take a string and give one
/// back.
///
/// Build a [Parser] instead when more than one of them is wanted from the same
/// string: each of these parses it anew.
extension StringParsingExtension on String {
  /// Returns the string with every escape code replaced by its identifier.
  ///
  /// ```dart
  /// print('${fgRed}ERROR$reset'.ansiShowControlFunctions());
  /// // [fgRed]ERROR[reset]
  /// ```
  ///
  /// [open] is the string to put before each identifier, [close] the one to
  /// put after it.
  ///
  /// See [Parser.showControlFunctions].
  String ansiShowControlFunctions({
    String open = '[',
    String close = ']',
  }) =>
      Parser(this).showControlFunctions(open: open, close: close);

  /// Returns the string with [text] inserted at the plain text [pos], in
  /// front of the escape codes standing there.
  ///
  /// ```dart
  /// print('${fgRed}Hello$reset world'.ansiInsertBefore(5, '!'));
  /// // '${fgRed}Hello!$reset world'
  /// ```
  ///
  /// See [Parser.insertBefore].
  String ansiInsertBefore(int pos, String text) =>
      Parser(this).insertBefore(pos, text);

  /// Returns the string with [text] inserted at the plain text [pos], behind
  /// the escape codes standing there.
  ///
  /// ```dart
  /// print('${fgRed}Hello$reset world'.ansiInsertAfter(5, '!'));
  /// // '${fgRed}Hello$reset! world'
  /// ```
  ///
  /// See [Parser.insertAfter].
  String ansiInsertAfter(int pos, String text) =>
      Parser(this).insertAfter(pos, text);

  /// Returns the string with the escape codes folded together.
  ///
  /// [close] is whether to end the string in the state it began in.
  ///
  /// See [Parser.optimize].
  String ansiOptimizeControlFunctions({bool close = true}) =>
      Parser(this).optimize(close: close);
}
