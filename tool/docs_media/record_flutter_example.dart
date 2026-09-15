// Records `example_flutter` on an iOS simulator and turns it into the README
// GIF (assets/example.gif) and still (assets/example.png).
//
// It runs `example_flutter/integration_test/docs_media_test.dart`, takes
// screenshots between its DOCS_MEDIA_START and DOCS_MEDIA_END markers, and
// frames every distinct screenshot in a phone shape on a purple background.
//
// Usage, from the repository root:
//   dart run tool/docs_media/record_flutter_example.dart [simulator-udid]
// Needs: Flutter and a booted iOS simulator. Close other apps on the simulator
// first, or iOS shows a "◀ previous app" breadcrumb in the status bar.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart';

const _phoneWidth = 390;
const _cornerRadius = 52;
const _padding = 44;
const _shadowOffset = 10;
const _lastFrameMs = 2000;

Future<void> main(List<String> args) async {
  final root = Directory.current.path;
  if (!File(join(root, 'pubspec.yaml'))
      .readAsStringSync()
      .contains('name: locale_gen')) {
    stderr.writeln('Run this from the root of the locale_gen repository.');
    exit(1);
  }
  final udid = args.isNotEmpty ? args.first : await _bootedSimulator();

  final framesDir = Directory.systemTemp.createTempSync('locale_gen_frames_');
  await _run('xcrun', [
    'simctl', 'status_bar', udid, 'override', //
    '--time', '9:41', '--batteryState', 'charged', '--batteryLevel', '100',
    '--wifiBars', '3', '--cellularBars', '4',
  ]);
  try {
    final screenshots =
        await _record(join(root, 'example_flutter'), udid, framesDir.path);
    _build(
      screenshots,
      gifPath: join(root, 'assets', 'example.gif'),
      pngPath: join(root, 'assets', 'example.png'),
    );
  } finally {
    await _run('xcrun', ['simctl', 'status_bar', udid, 'clear']);
    framesDir.deleteSync(recursive: true);
  }
}

class _Screenshot {
  final String path;
  final DateTime takenAt;

  _Screenshot(this.path, this.takenAt);
}

Future<String> _run(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);
  if (result.exitCode != 0) {
    throw StateError('${[executable, ...arguments].join(' ')} failed:\n'
        '${result.stdout}\n${result.stderr}');
  }
  return result.stdout as String;
}

Future<String> _bootedSimulator() async {
  final devices = await _run('xcrun', ['simctl', 'list', 'devices', 'booted']);
  final udid = RegExp(r'[0-9A-F-]{36}').firstMatch(devices)?[0];
  if (udid == null) {
    stderr.writeln('No booted simulator found. Boot one or pass its UDID.');
    exit(1);
  }
  return udid;
}

/// Runs the walkthrough test and screenshots the simulator while it runs.
Future<List<_Screenshot>> _record(
    String exampleDir, String udid, String framesDir) async {
  final test = await Process.start(
    'flutter',
    ['test', 'integration_test/docs_media_test.dart', '-d', udid],
    workingDirectory: exampleDir,
  );
  final log = StringBuffer();
  final started = Completer<void>();
  final ended = Completer<void>();
  void onLine(String line) {
    log.writeln(line);
    if (line.contains('DOCS_MEDIA_START') && !started.isCompleted) {
      started.complete();
    }
    if (line.contains('DOCS_MEDIA_END') && !ended.isCompleted) {
      ended.complete();
    }
  }

  for (final stream in [test.stdout, test.stderr]) {
    stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(onLine);
  }

  await Future.any<Object?>([started.future, test.exitCode]);
  if (!started.isCompleted) {
    stderr.write(log);
    throw StateError('flutter test stopped before the walkthrough started');
  }

  var recording = true;
  unawaited(Future.any<Object?>([ended.future, test.exitCode])
      .then((_) => recording = false));
  final screenshots = <_Screenshot>[];
  while (recording) {
    final path = join(framesDir, '${screenshots.length}.png');
    final takenAt = DateTime.now();
    await _run('xcrun', ['simctl', 'io', udid, 'screenshot', path]);
    screenshots.add(_Screenshot(path, takenAt));
  }

  if (await test.exitCode != 0) {
    stderr.write(log);
    throw StateError('flutter test failed');
  }
  return screenshots;
}

/// Frames every distinct screenshot and writes the GIF and the last frame.
void _build(List<_Screenshot> screenshots,
    {required String gifPath, required String pngPath}) {
  if (screenshots.isEmpty) throw StateError('no screenshots captured');

  final frames = <img.Image>[];
  for (var i = 0; i < screenshots.length; i++) {
    final screenshot =
        img.decodePng(File(screenshots[i].path).readAsBytesSync())!;
    final frame = _frame(screenshot);
    final duration = i + 1 < screenshots.length
        ? screenshots[i + 1]
            .takenAt
            .difference(screenshots[i].takenAt)
            .inMilliseconds
        : _lastFrameMs;
    // A screenshot identical to the previous one only extends that frame.
    if (frames.isNotEmpty && _samePixels(frames.last, frame)) {
      frames.last.frameDuration += duration;
      continue;
    }
    frames.add(frame..frameDuration = duration);
  }

  File(pngPath).writeAsBytesSync(img.encodePng(frames.last, level: 9));

  final animation = frames.first..frameType = img.FrameType.animation;
  for (final frame in frames.skip(1)) {
    animation.addFrame(frame);
  }
  File(gifPath).writeAsBytesSync(
    img.GifEncoder(dither: img.DitherKernel.none).encode(animation),
  );
  final seconds = frames.fold(0, (sum, f) => sum + f.frameDuration) / 1000;
  print('${relative(gifPath)}: ${frames.length} frames, '
      '${seconds.toStringAsFixed(1)}s');
}

bool _samePixels(img.Image a, img.Image b) {
  final aBytes = a.toUint8List();
  final bBytes = b.toUint8List();
  if (aBytes.length != bBytes.length) return false;
  for (var i = 0; i < aBytes.length; i++) {
    if (aBytes[i] != bBytes[i]) return false;
  }
  return true;
}

/// Puts [screenshot] in a rounded phone shape with a soft shadow.
img.Image _frame(img.Image screenshot) {
  final phoneHeight =
      (screenshot.height * _phoneWidth / screenshot.width).round();
  final phone = img.copyResize(
    screenshot,
    width: _phoneWidth,
    height: phoneHeight,
    interpolation: img.Interpolation.cubic,
  );

  const width = _phoneWidth + 2 * _padding;
  final height = phoneHeight + 2 * _padding;
  final canvas = img.Image(width: width, height: height);
  img.fill(canvas, color: img.ColorRgb8(123, 97, 255));

  final shadow = img.Image(width: width, height: height);
  img.fillRect(
    shadow,
    x1: _padding,
    y1: _padding + _shadowOffset,
    x2: _padding + _phoneWidth,
    y2: _padding + phoneHeight + _shadowOffset,
    color: img.ColorRgb8(110, 110, 110),
    radius: _cornerRadius,
  );
  img.gaussianBlur(shadow, radius: 16);
  img.fill(canvas, color: img.ColorRgb8(40, 20, 120), mask: shadow);

  // compositeImage samples the mask in canvas coordinates, so the mask is
  // canvas-sized with the rounded phone shape at the phone's position.
  final corners = img.Image(width: width, height: height);
  img.fillRect(
    corners,
    x1: _padding,
    y1: _padding,
    x2: _padding + _phoneWidth - 1,
    y2: _padding + phoneHeight - 1,
    color: img.ColorRgb8(255, 255, 255),
    radius: _cornerRadius,
  );
  img.compositeImage(canvas, phone,
      dstX: _padding, dstY: _padding, mask: corners);
  return canvas;
}
