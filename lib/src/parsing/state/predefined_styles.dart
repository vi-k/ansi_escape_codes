import '../colors/color.dart';
import 'state.dart';

/// The style that carries nothing: the terminal's own colours, and no
/// property switched on.
///
/// This is where a chain starts when it does not start at a colour:
///
/// ```dart
/// print(style.bold('Careful'));
/// print(style.bgRgb420.underline('Notice'));
/// ```
///
/// Every property and every colour of the table is a getter on it — see
/// [Style] and [StyleColors] — so this one name reaches all of them.
const Style style = Style.terminalColors;

/// The style with [color] as the colour of the text.
Style foreground(Color color) => Style(foreground: color);

/// The style with [color] as the colour behind the text.
Style background(Color color) => Style(background: color);

/// The style with [color] as the colour of the underline.
Style underlineColor(ExtendedColor color) => Style(underlineColor: color);

/// Black text.
const Style black = Style(foreground: Color256.black);

/// Red text.
const Style red = Style(foreground: Color256.red);

/// Green text.
const Style green = Style(foreground: Color256.green);

/// Yellow text.
const Style yellow = Style(foreground: Color256.yellow);

/// Blue text.
const Style blue = Style(foreground: Color256.blue);

/// Magenta text.
const Style magenta = Style(foreground: Color256.magenta);

/// Cyan text.
const Style cyan = Style(foreground: Color256.cyan);

/// White text.
const Style white = Style(foreground: Color256.white);

/// Black text, high intensity.
const Style highBlack = Style(foreground: Color256.highBlack);

/// Red text, high intensity.
const Style highRed = Style(foreground: Color256.highRed);

/// Green text, high intensity.
const Style highGreen = Style(foreground: Color256.highGreen);

/// Yellow text, high intensity.
const Style highYellow = Style(foreground: Color256.highYellow);

/// Blue text, high intensity.
const Style highBlue = Style(foreground: Color256.highBlue);

/// Magenta text, high intensity.
const Style highMagenta = Style(foreground: Color256.highMagenta);

/// Cyan text, high intensity.
const Style highCyan = Style(foreground: Color256.highCyan);

/// White text, high intensity.
const Style highWhite = Style(foreground: Color256.highWhite);
