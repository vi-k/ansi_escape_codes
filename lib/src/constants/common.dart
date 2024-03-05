const String bel = '\x07';
const String backspace = '\x08';
const String tab = '\x09';
const String lf = '\x0A'; // Line Feed
const String ff = '\x0C'; // Form Feed
const String cr = '\x0D'; // Carriage Return
const String esc = '\x1B';

const String osc = '$esc]'; // OSC (Operating System Command)
const String st = '$esc\\'; // ST (String Terminator)

const String saveCursor = '${esc}7'; // DEC Save Cursor
const String restoreCursor = '${esc}8'; // DEC Restore Cursor
