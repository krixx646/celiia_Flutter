import 'dart:io';

class HitMap {
  final String file;
  final Map<int, int> hitsByLine = {};
  int lf = 0;
  int lh = 0;

  HitMap(this.file);
}

void main(List<String> args) {
  final lcovPath = args.isNotEmpty ? args[0] : 'coverage/lcov.info';
  final fileFilter = args.length >= 2 ? args[1] : null; // substring match
  final showTop = args.length >= 3 ? int.tryParse(args[2]) ?? 20 : 20;

  final lcov = File(lcovPath);
  if (!lcov.existsSync()) {
    stderr.writeln('lcov not found: $lcovPath');
    exitCode = 2;
    return;
  }

  final maps = <String, HitMap>{};
  HitMap? current;

  for (final raw in lcov.readAsLinesSync()) {
    final line = raw.trim();
    if (line.startsWith('SF:')) {
      final path = line.substring(3);
      current = maps.putIfAbsent(path, () => HitMap(path));
    } else if (line.startsWith('DA:')) {
      if (current == null) continue;
      final rest = line.substring(3);
      final parts = rest.split(',');
      if (parts.length < 2) continue;
      final ln = int.tryParse(parts[0]);
      final hits = int.tryParse(parts[1]);
      if (ln == null || hits == null) continue;
      current.hitsByLine[ln] = hits;
    } else if (line.startsWith('LF:')) {
      if (current == null) continue;
      current.lf = int.tryParse(line.substring(3)) ?? current.lf;
    } else if (line.startsWith('LH:')) {
      if (current == null) continue;
      current.lh = int.tryParse(line.substring(3)) ?? current.lh;
    } else if (line == 'end_of_record') {
      current = null;
    }
  }

  final entries = maps.values.where((m) {
    if (fileFilter == null || fileFilter.isEmpty) return true;
    return m.file.contains(fileFilter);
  }).toList();

  if (entries.isEmpty) {
    stdout.writeln('No files matched filter: $fileFilter');
    return;
  }

  // If user provided a file filter and it matches exactly one, print uncovered lines.
  if (fileFilter != null && entries.length == 1) {
    final m = entries.single;
    final uncovered = m.hitsByLine.entries
        .where((e) => e.value == 0)
        .map((e) => e.key)
        .toList()
      ..sort();

    stdout.writeln(m.file);
    stdout.writeln('covered: ${m.lh}/${m.lf} = ${(m.lf == 0 ? 100.0 : 100.0 * m.lh / m.lf).toStringAsFixed(2)}%');
    stdout.writeln('uncovered lines: ${uncovered.length}');
    stdout.writeln(uncovered.join(','));
    return;
  }

  // Otherwise print top N files by most uncovered lines.
  entries.sort((a, b) {
    final au = a.lf - a.lh;
    final bu = b.lf - b.lh;
    return bu.compareTo(au);
  });

  stdout.writeln('Top files by uncovered lines (LF-LH):');
  for (final m in entries.take(showTop)) {
    final uncovered = m.lf - m.lh;
    stdout.writeln('${uncovered.toString().padLeft(5)}  ${(m.lf == 0 ? 100.0 : 100.0 * m.lh / m.lf).toStringAsFixed(2).padLeft(6)}%  ${m.file}');
  }
}

