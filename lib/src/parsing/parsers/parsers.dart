import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../../values/csi.dart';
import '../../values/sgr/colors_24bit/bg_rgb.dart';
import '../../values/sgr/colors_24bit/fg_rgb.dart';
import '../../values/sgr/colors_24bit/underline_rgb.dart';
import '../../values/sgr/colors_4bit/standart_colors.dart';
import '../../values/sgr/colors_8bit/bg256.dart';
import '../../values/sgr/colors_8bit/fg256.dart';
import '../../values/sgr/colors_8bit/underline256.dart';
import '../../values/sgr/sgr.dart';
import '../enums/ansi_colors_256.dart';
import '../extensions/show_control_codes.dart';
import '../extensions/show_escape_codes.dart';
import '../patterns/patterns.dart';

part 'common/ansi_iterator.dart';
part 'common/ansi_match.dart';
part 'common/ansi_matches.dart';
part 'common/ansi_matches_result.dart';
part 'common/ansi_state.dart';
part 'entities/ansi_background_color.dart';
part 'entities/ansi_csi.dart';
part 'entities/ansi_entity.dart';
part 'entities/ansi_esc.dart';
part 'entities/ansi_foreground_color.dart';
part 'entities/ansi_osc.dart';
part 'entities/ansi_sgr.dart';
part 'entities/ansi_underline_color.dart';
part 'plain_parser/ansi_matches_v1.dart';
part 'plain_parser/ansi_parser.dart';
part 'plain_parser/ansi_plain_state.dart';
part 'stacked_parser/ansi_matches_v2.dart';
part 'stacked_parser/ansi_stacked_parser.dart';
part 'stacked_parser/ansi_stacked_state.dart';
