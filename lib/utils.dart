/// The two things a terminal will only tell or take in person.
///
/// `currentCursorPos` asks the terminal where the cursor is and reads the
/// answer back off stdin; `tabs` sets the tabulation stops. Both go through
/// `dart:io`, which is why they are here rather than in the main import: the
/// rest of this package is string work that runs wherever Dart does, and one
/// platform library in the umbrella would take the web and WebAssembly away
/// from all of it.
library;

export 'src/utils/current_cursor_pos.dart';
export 'src/utils/tabs.dart';
