import 'dart:io';

class FileCoverage {
  final String path;
  int lf = 0;
  int lh = 0;

  FileCoverage(this.path);

  double get pct => lf == 0 ? 100.0 : (100.0 * lh / lf);
}

void main(List<String> args) {
  final lcovPath = args.isNotEmpty ? args[0] : 'coverage/lcov.info';
  final file = File(lcovPath);
  if (!file.existsSync()) {
    stderr.writeln('lcov not found: $lcovPath');
    exitCode = 2;
    return;
  }

  final coverages = <String, FileCoverage>{};
  FileCoverage? current;

  for (final raw in file.readAsLinesSync()) {
    final line = raw.trim();
    if (line.startsWith('SF:')) {
      final path = line.substring(3);
      current = coverages.putIfAbsent(path, () => FileCoverage(path));
    } else if (line.startsWith('LF:')) {
      if (current != null) {
        current.lf = int.tryParse(line.substring(3)) ?? current.lf;
      }
    } else if (line.startsWith('LH:')) {
      if (current != null) {
        current.lh = int.tryParse(line.substring(3)) ?? current.lh;
      }
    } else if (line == 'end_of_record') {
      current = null;
    }
  }

  final entries = coverages.values.toList();

  int totalLf = 0;
  int totalLh = 0;
  for (final e in entries) {
    totalLf += e.lf;
    totalLh += e.lh;
  }

  entries.sort((a, b) => a.pct.compareTo(b.pct));

  stdout.writeln('Coverage summary for $lcovPath');
  stdout.writeln(
    'Overall: $totalLh/$totalLf = ${totalLf == 0 ? '100.00' : (100 * totalLh / totalLf).toStringAsFixed(2)}%',
  );
  stdout.writeln('');
  stdout.writeln('Lowest covered files:');

  for (final e in entries.take(30)) {
    stdout.writeln(
      '${e.pct.toStringAsFixed(2).padLeft(6)}%  ${e.lh.toString().padLeft(5)}/${e.lf.toString().padRight(5)}  ${e.path}',
    );
  }
}
