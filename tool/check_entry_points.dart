/// Proves every entry point of the package is closed under its own
/// public signatures.
///
/// An entry point is a library directly under `lib/`, and what it lets
/// through is its export namespace. The rule this script mechanises: if a
/// public signature reachable from that namespace names a declaration of
/// this package — as a return type, a parameter type, a type argument, a
/// type-parameter bound, or the type an extension extends — then that
/// declaration has to stand in the same namespace. Otherwise the entry
/// point hands out a shape whose name it never exported, and the caller
/// can hold the value but cannot write the type.
///
///     dart run tool/check_entry_points.dart
///
/// Signatures only, and shallow: bodies, initialisers, supertypes and
/// annotations are none of its business, and `dart:*` and other packages
/// are not its to close. The entry points are read off the directory
/// rather than listed here, so a new one is checked from the moment it
/// exists.
///
/// Written because a hand-written list of names cannot notice what is
/// missing from it: the parameter `{Set<ControlFunctionsC0> exclude}`
/// stood in `lib/extensions.dart` with the enum unexported, and every
/// test of that entry point passed.
library;

// The element model this walks is the analyzer's second one, and every
// door into it still carries @experimental. Naming them one by one would
// be five ignores for one decision, and the decision is the file's.
// ignore_for_file: experimental_member_use

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';

/// What separates the parts of a path here. Spelled out rather than
/// assumed to be `/`: the analyzer hands back paths in the platform's
/// own shape, and a prefix test that never matches would let every entry
/// point through as if it were closed.
final _sep = Platform.pathSeparator;

Future<void> main() async {
  final stopwatch = Stopwatch()..start();
  final root = _packageRoot();
  final libDir = Directory('$root${_sep}lib');
  if (!libDir.existsSync()) {
    stderr.writeln('no lib/ under $root');
    exit(2);
  }

  final entryPoints = libDir
      .listSync()
      .whereType<File>()
      .map((file) => file.path)
      .where((path) => path.endsWith('.dart'))
      .toList()
    ..sort();
  if (entryPoints.isEmpty) {
    stderr.writeln('no entry points under ${libDir.path}');
    exit(2);
  }

  final collection = AnalysisContextCollection(includedPaths: [libDir.path]);
  final failures = <_Failure>[];
  for (final entryPoint in entryPoints) {
    final session = collection.contextFor(entryPoint).currentSession;
    final resolved = await session.getResolvedLibrary(entryPoint);
    if (resolved is! ResolvedLibraryResult) {
      stderr.writeln('${_relative(root, entryPoint)}: $resolved');
      exit(2);
    }
    failures.addAll(
      _Closure(
        root: root,
        libPath: libDir.path,
        entryPoint: _relative(root, entryPoint),
        library: resolved.element2,
      ).check(),
    );
  }

  stopwatch.stop();
  final seconds = (stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1);
  if (failures.isEmpty) {
    print('${entryPoints.length} entry points, closed (${seconds}s)');
    return;
  }

  for (final failure in failures) {
    stderr.writeln('${failure.entryPoint}: ${failure.missing}');
    for (final site in failure.sites) {
      stderr.writeln('  $site');
    }
  }
  final count = failures.length;
  stderr
    ..writeln()
    ..writeln(
      '$count ${count == 1 ? 'name is' : 'names are'} reached by a public '
      'signature and left unexported (${seconds}s)',
    );
  exit(1);
}

/// One declaration of this package that an entry point reaches without
/// exporting, and every place its signatures reach it from.
class _Failure {
  _Failure({
    required this.entryPoint,
    required this.missing,
    required this.sites,
  });

  /// The entry point that fails to close, relative to the package root.
  final String entryPoint;

  /// How the unexported declaration reads, with the library declaring it.
  final String missing;

  /// The signatures that name it, in the order they were met.
  final List<String> sites;
}

/// The walk of one entry point's export namespace.
class _Closure {
  _Closure({
    required this.root,
    required this.libPath,
    required this.entryPoint,
    required this.library,
  });

  /// The package root, for shortening the paths it prints.
  final String root;

  /// The `lib/` directory: what lies under it is this package's to close.
  final String libPath;

  /// The entry point under check, relative to the package root.
  final String entryPoint;

  /// Its resolved library.
  final LibraryElement2 library;

  /// What the entry point exports; the set every reached declaration is
  /// answered against.
  final Set<Element2> _exported = Set.identity();

  /// The declarations already reported, each with the sites that reached
  /// them, so that a name met in four signatures is one failure of four
  /// lines rather than four failures.
  final Map<Element2, List<String>> _missing = Map.identity();

  /// The elements already walked, so that a cycle — a class whose method
  /// returns the class — ends.
  final Set<Element2> _walked = Set.identity();

  /// Walks the namespace and returns what it failed to close over.
  List<_Failure> check() {
    _exported.addAll(library.exportNamespace.definedNames2.values);
    for (final element in _exported) {
      if (_isOurs(element)) {
        _walk(element, _nameOf(element));
      }
    }

    return [
      for (final entry in _missing.entries)
        _Failure(
          entryPoint: entryPoint,
          missing: _describe(entry.key),
          sites: entry.value,
        ),
    ];
  }

  /// Walks the public signatures [element] declares, naming what it finds
  /// after [where].
  void _walk(Element2 element, String where) {
    if (!_walked.add(element)) {
      return;
    }

    switch (element) {
      case InstanceElement2():
        _bounds(element.typeParameters2, where);
        if (element is ExtensionElement2) {
          _type(element.extendedType, '$where, extended type');
        }
        for (final member in <Element2>[
          ...element.fields2,
          ...element.getters2,
          ...element.setters2,
          ...element.methods2,
          // An enum's generative constructor reads as public and is not:
          // only the constants inside the declaration may call it, so
          // what it takes is not a shape anyone outside can name.
          if (element is InterfaceElement2 && element is! EnumElement2)
            ...element.constructors2,
        ]) {
          // Synthetic members are the accessors a field induces and the
          // field an accessor induces: the same type read twice, and the
          // half that was written is in the list beside them.
          if (member.isPublic && !member.isSynthetic) {
            _walk(member, '$where.${_nameOf(member)}');
          }
        }
        // What a class hands out is wider than what it writes down: a
        // method it takes from a private base is one the caller reaches
        // and a signature the caller reads. Its interface holds those,
        // the accessors of inherited fields among them; the ones just
        // walked stand in it too and are left to the guard above.
        if (element is InterfaceElement2) {
          for (final member in element.interfaceMembers.values) {
            final owner = member.enclosingElement2;
            if (member.isPublic && owner != element) {
              final from = owner == null ? '' : ' from ${_nameOf(owner)}';
              _walk(member, '$where.${_nameOf(member)}$from');
            }
          }
        }
      case TypeAliasElement2():
        _bounds(element.typeParameters2, where);
        _type(element.aliasedType, '$where, aliased type');
      case ExecutableElement2():
        _bounds(element.typeParameters2, where);
        if (element is! ConstructorElement2) {
          _type(element.returnType, '$where, return type');
        }
        for (final parameter in element.formalParameters) {
          _type(parameter.type, "$where, parameter '${_nameOf(parameter)}'");
        }
      case VariableElement2():
        _type(element.type, '$where, type');
    }
  }

  /// Follows the bounds [typeParameters] carry.
  void _bounds(List<TypeParameterElement2> typeParameters, String where) {
    for (final typeParameter in typeParameters) {
      final bound = typeParameter.bound;
      if (bound != null) {
        _type(bound, "$where, bound of '${_nameOf(typeParameter)}'");
      }
    }
  }

  /// Answers every declaration [type] names — itself, what it aliases,
  /// its type arguments, and the pieces of a function or record type —
  /// against the namespace.
  ///
  /// A written type is a finite tree but for one edge: the bound a type
  /// parameter carries, which `class A<T extends A<T>>` sends back where
  /// it came from. [followed] holds the parameters whose bounds this
  /// site has already taken, which is what ends the walk.
  void _type(
    DartType type,
    String where, [
    Set<TypeParameterElement2>? followed,
  ]) {
    final bounds = followed ?? Set<TypeParameterElement2>.identity();

    final alias = type.alias;
    if (alias != null) {
      _answer(alias.element2, where);
      for (final argument in alias.typeArguments) {
        _type(argument, where, bounds);
      }
    }

    switch (type) {
      case InterfaceType():
        _answer(type.element3, where);
        for (final argument in type.typeArguments) {
          _type(argument, where, bounds);
        }
      case TypeParameterType():
        if (bounds.add(type.element3)) {
          _type(type.bound, where, bounds);
        }
      case FunctionType():
        _type(type.returnType, where, bounds);
        for (final parameter in type.formalParameters) {
          _type(parameter.type, where, bounds);
        }
        for (final typeParameter in type.typeParameters) {
          final bound = typeParameter.bound;
          if (bound != null && bounds.add(typeParameter)) {
            _type(bound, where, bounds);
          }
        }
      case RecordType():
        for (final field in [...type.positionalFields, ...type.namedFields]) {
          _type(field.type, where, bounds);
        }
    }
  }

  /// Records [element] as unexported unless the namespace holds it or it
  /// belongs to somebody else.
  void _answer(Element2 element, String where) {
    if (!_isOurs(element) || _exported.contains(element)) {
      return;
    }

    _missing.putIfAbsent(element, () => []).add(where);
  }

  /// Whether [element] is declared under this package's `lib/`.
  bool _isOurs(Element2 element) {
    final source = element.library2?.firstFragment.source;

    return source != null && source.fullName.startsWith('$libPath$_sep');
  }

  /// How a declaration reads in a failure: its name, its kind, and the
  /// file it stands in.
  String _describe(Element2 element) {
    final fragment = element.firstFragment;
    final libraryFragment = fragment.libraryFragment;
    final source = libraryFragment?.source;
    final where = source == null ? '?' : _relative(root, source.fullName);
    final offset = fragment.nameOffset2;
    final line = libraryFragment == null || offset == null
        ? ''
        : ':${libraryFragment.lineInfo.getLocation(offset).lineNumber}';

    return '${_nameOf(element)} (${element.kind.displayName}, $where$line)';
  }

  /// The name of [element], or a stand-in when it has none.
  String _nameOf(Element2 element) => element.name3 ?? '<unnamed>';
}

/// The package root: the directory holding the `tool/` this script runs
/// from, so that the check reads the same tree whatever the cwd.
String _packageRoot() {
  final script = File.fromUri(Platform.script).absolute.path;
  final tool = script.lastIndexOf('${_sep}tool$_sep');

  return tool == -1
      ? Directory.current.absolute.path
      : script.substring(0, tool);
}

/// [path] as it reads from [root].
String _relative(String root, String path) =>
    path.startsWith('$root$_sep') ? path.substring(root.length + 1) : path;
