part of 'parser.dart';

typedef _StyleProjection = Style Function(Style style);

Style _identityStyle(Style style) => style;

final class _SgrOperation {
  final String string;
  final SgrFunction? function;
  final Style state;

  const _SgrOperation({
    required this.string,
    required this.function,
    required this.state,
  });

  const _SgrOperation.opaque(this.string, this.state) : function = null;

  bool get isUnknown => function == null || _isUnknownSgrFunction(function!);
}

final class _SgrResidualRoot {
  final Style base;

  const _SgrResidualRoot(this.base);
}

final class _SgrResidual {
  final _SgrResidualRoot root;
  final _SgrResidual? previous;
  final _SgrOperation operation;
  final int depth;

  const _SgrResidual._(
    this.root,
    this.previous,
    this.operation,
    this.depth,
  );
}

bool _isUnknownSgrFunction(SgrFunction function) => switch (function) {
      SgrUnknownParamFunction() ||
      SgrUnknownParamsFunction() ||
      SgrUnknownColorFunctionFromParams() ||
      SgrUnknownColorFunctionFromValues() =>
        true,
      _ => false,
    };

bool _isFullSgrReset(SgrFunction? function) => switch (function) {
      SgrDefaultFunction() => true,
      SgrSimpleFunction(code: ControlFunctionsSGR.reset) => true,
      _ => false,
    };

_SgrResidual? _advanceSgrResidual(
  _SgrResidual? residual,
  Style before,
  _SgrOperation operation,
) {
  if (_isFullSgrReset(operation.function)) {
    return null;
  }

  if (residual == null) {
    if (!operation.isUnknown) {
      return null;
    }

    final root = _SgrResidualRoot(before);
    return _SgrResidual._(root, null, operation, 1);
  }

  return _SgrResidual._(
    residual.root,
    residual,
    operation,
    residual.depth + 1,
  );
}

/// Whether the rendition branch writes [entity], rather than the output
/// copying its bytes over as they came.
///
/// The parser answers this where it reads the sequence --- see
/// [CsiUnknown._opaqueSgr] --- and it is asked here rather than worked out
/// again, so that the two cannot disagree.
bool _isStatefulSgr(Entity entity) =>
    entity is Sgr || (entity is CsiUnknown && entity._opaqueSgr);

String _renditionTransit({
  required Style from,
  required _SgrResidual? fromResidual,
  required Style to,
  required _SgrResidual? toResidual,
  _StyleProjection project = _identityStyle,
  bool skipSet = false,
  bool skipReset = false,
}) {
  if (fromResidual == null && toResidual == null) {
    return from.transitToPart(to, skipSet: skipSet, skipReset: skipReset);
  }

  final suffix = fromResidual == null || toResidual == null
      ? null
      : _descendantSuffix(fromResidual, toResidual);
  if (suffix != null) {
    final buf = StringBuffer();
    final effective = _replaySgrOperations(buf, from, suffix, project);
    assert(effective == to, 'residual suffix must reach the target state');
    return buf.toString();
  }

  if (fromResidual == null) {
    final target = toResidual!;
    final buf = StringBuffer();
    var effective = project(target.root.base);
    buf.write(
      from.transitToPart(
        effective,
        skipSet: skipSet,
        skipReset: skipReset,
      ),
    );
    effective = _replaySgrOperations(
      buf,
      effective,
      _operationsFromRoot(target),
      project,
    );
    assert(effective == to, 'residual replay must reach the target state');
    return buf.toString();
  }

  final buf = StringBuffer(reset);
  var effective = Style.terminalColors;
  if (toResidual == null) {
    buf.write(
      effective.transitToPart(
        to,
        skipSet: skipSet,
        skipReset: true,
      ),
    );
    return buf.toString();
  }

  effective = project(toResidual.root.base);
  buf.write(
    Style.terminalColors.transitToPart(
      effective,
      skipSet: skipSet,
      skipReset: true,
    ),
  );
  effective = _replaySgrOperations(
    buf,
    effective,
    _operationsFromRoot(toResidual),
    project,
  );
  assert(effective == to, 'residual replay must reach the target state');
  return buf.toString();
}

List<_SgrOperation>? _descendantSuffix(
  _SgrResidual from,
  _SgrResidual to,
) {
  if (!identical(from.root, to.root) || to.depth < from.depth) {
    return null;
  }

  final reversed = <_SgrOperation>[];
  var cursor = to;
  while (cursor.depth > from.depth) {
    reversed.add(cursor.operation);
    cursor = cursor.previous!;
  }

  if (!identical(cursor, from)) {
    return null;
  }

  return reversed.reversed.toList(growable: false);
}

List<_SgrOperation> _operationsFromRoot(_SgrResidual tail) {
  final reversed = <_SgrOperation>[];
  for (_SgrResidual? cursor = tail; cursor != null; cursor = cursor.previous) {
    reversed.add(cursor.operation);
  }

  return reversed.reversed.toList(growable: false);
}

Style _replaySgrOperations(
  StringBuffer buf,
  Style effective,
  Iterable<_SgrOperation> operations,
  _StyleProjection project,
) {
  for (final operation in operations) {
    buf.write(operation.string);
    if (!operation.isUnknown) {
      final rawAfter = _applyKnownSgrFunction(effective, operation.function!);
      final desired = project(operation.state);
      final correction = rawAfter.transitTo(desired);
      assert(
        correction != reset,
        'a known residual operation must need at most a selective correction',
      );
      buf.write(correction);
      effective = desired;
    }
  }

  return effective;
}
