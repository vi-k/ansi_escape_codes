import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('EscCommon:', () {
    test('names the function its sequence stands for', () {
      final entity = Parser(resetTerminal).matches.first.entity;

      expect(entity, isA<EscCommon>());
      expect((entity as EscCommon).function, ControlFunctionsEscFs.RIS);
      expect(entity.id, 'ESC RIS');
    });

    test('a switch over the entity reaches it', () {
      final label = switch (Parser('\x1Bc').matches.first.entity) {
        EscCommon(:final function) => function.name,
        _ => 'other',
      };

      expect(label, 'RIS');
    });
  });
}
