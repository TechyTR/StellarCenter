import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

class BenchmarkResult {
  final int singleCore;
  final int multiCore;
  final int ram;
  final int storage;
  final int graphics;
  final int mixed;
  final int total;

  const BenchmarkResult({
    required this.singleCore,
    required this.multiCore,
    required this.ram,
    required this.storage,
    required this.graphics,
    required this.mixed,
    required this.total,
  });
}

typedef BenchmarkProgressCallback = void Function(
  String status,
  double progress,
);

class BenchmarkService {
  BenchmarkService._();

  static bool _cancelled = false;
  static bool _running = false;

  static bool get isRunning => _running;

  static void cancel() {
    _cancelled = true;
  }

  static Future<BenchmarkResult?> run({
    BenchmarkProgressCallback? onProgress,
  }) async {
    if (_running) {
      return null;
    }

    _running = true;
    _cancelled = false;

    try {
      onProgress?.call(
        'Benchmark hazırlanıyor...',
        0.0,
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 150),
      );

      if (_cancelled) {
        return null;
      }

      // ------------------------------------------------------------
      // 1. CPU SINGLE-CORE
      // ------------------------------------------------------------

      onProgress?.call(
        'CPU Single-Core test ediliyor...',
        0.05,
      );

      final singleCore = await _runSingleCore();

      if (_cancelled) {
        return null;
      }

      onProgress?.call(
        'CPU Single-Core tamamlandı.',
        0.20,
      );

      // ------------------------------------------------------------
      // 2. CPU MULTI-CORE
      // ------------------------------------------------------------

      onProgress?.call(
        'CPU Multi-Core test ediliyor...',
        0.22,
      );

      final multiCore = await _runMultiCore();

      if (_cancelled) {
        return null;
      }

      onProgress?.call(
        'CPU Multi-Core tamamlandı.',
        0.40,
      );

      // ------------------------------------------------------------
      // 3. RAM
      // ------------------------------------------------------------

      onProgress?.call(
        'RAM performansı test ediliyor...',
        0.42,
      );

      final ram = await _runRamTest();

      if (_cancelled) {
        return null;
      }

      onProgress?.call(
        'RAM testi tamamlandı.',
        0.55,
      );

      // ------------------------------------------------------------
      // 4. STORAGE
      // ------------------------------------------------------------

      onProgress?.call(
        'Depolama performansı test ediliyor...',
        0.57,
      );

      final storage = await _runStorageTest();

      if (_cancelled) {
        return null;
      }

      onProgress?.call(
        'Depolama testi tamamlandı.',
        0.70,
      );

      // ------------------------------------------------------------
      // 5. GRAPHICS / UI
      // ------------------------------------------------------------

      onProgress?.call(
        'Graphics / UI testi yapılıyor...',
        0.72,
      );

      final graphics = await _runGraphicsTest();

      if (_cancelled) {
        return null;
      }

      onProgress?.call(
        'Graphics / UI testi tamamlandı.',
        0.84,
      );

      // ------------------------------------------------------------
      // 6. MIXED SYSTEM
      // ------------------------------------------------------------

      onProgress?.call(
        'Mixed System testi yapılıyor...',
        0.86,
      );

      final mixed = await _runMixedTest(
        singleCore: singleCore,
        multiCore: multiCore,
        ram: ram,
        storage: storage,
        graphics: graphics,
      );

      if (_cancelled) {
        return null;
      }

      onProgress?.call(
        'Sonuçlar hesaplanıyor...',
        0.96,
      );

      final total = _calculateTotal(
        singleCore: singleCore,
        multiCore: multiCore,
        ram: ram,
        storage: storage,
        graphics: graphics,
        mixed: mixed,
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 250),
      );

      if (_cancelled) {
        return null;
      }

      onProgress?.call(
        'Benchmark tamamlandı.',
        1.0,
      );

      return BenchmarkResult(
        singleCore: singleCore,
        multiCore: multiCore,
        ram: ram,
        storage: storage,
        graphics: graphics,
        mixed: mixed,
        total: total,
      );
    } finally {
      _running = false;
    }
  }

  // ==============================================================
  // CPU SINGLE CORE
  // ==============================================================

  static Future<int> _runSingleCore() async {
    final stopwatch = Stopwatch()..start();

    double value = 0.123456789;

    const int iterations = 700000;

    for (int i = 0; i < iterations; i++) {
      value += math.sin(i * 0.00031);
      value *= 1.0000001;
      value -= math.cos(i * 0.00017);

      if (i % 50000 == 0) {
        if (_cancelled) {
          return 0;
        }

        await Future<void>.delayed(
          Duration.zero,
        );
      }
    }

    stopwatch.stop();

    // Sonucun optimize edilip tamamen atılmasını
    // engellemek için değeri kullanıyoruz.
    final stability = value.abs() % 1.0;

    final elapsed = math.max(
      stopwatch.elapsedMicroseconds,
      1,
    );

    final rawScore =
        (iterations * 1000000) / elapsed;

    final score =
        (rawScore * (1.0 + stability * 0.05))
            .round();

    return _clamp(
      score,
      500,
      15000,
    );
  }

  // ==============================================================
  // CPU MULTI CORE
  // ==============================================================

  static Future<int> _runMultiCore() async {
    final stopwatch = Stopwatch()..start();

    double accumulator = 0.0;

    const int rounds = 4;
    const int iterationsPerRound = 450000;

    for (int round = 0; round < rounds; round++) {
      for (
        int i = 0;
        i < iterationsPerRound;
        i++
      ) {
        accumulator +=
            math.sin(
              (i + round) * 0.00019,
            );

        accumulator -=
            math.cos(
              (i + round) * 0.00011,
            );

        accumulator *= 1.00000003;

        if (i % 50000 == 0) {
          if (_cancelled) {
            return 0;
          }

          await Future<void>.delayed(
            Duration.zero,
          );
        }
      }
    }

    stopwatch.stop();

    final elapsed = math.max(
      stopwatch.elapsedMicroseconds,
      1,
    );

    final operations =
        rounds * iterationsPerRound;

    final stability =
        accumulator.abs() % 1.0;

    final rawScore =
        (operations * 1000000) / elapsed;

    final score =
        (rawScore *
                4.0 *
                (1.0 + stability * 0.05))
            .round();

    return _clamp(
      score,
      1000,
      30000,
    );
  }

  // ==============================================================
  // RAM
  // ==============================================================

  static Future<int> _runRamTest() async {
    const int size =
        8 * 1024 * 1024;

    final data = Uint8List(size);

    final stopwatch = Stopwatch()..start();

    int checksum = 0;

    for (
      int pass = 0;
      pass < 4;
      pass++
    ) {
      for (
        int i = 0;
        i < data.length;
        i += 64
      ) {
        data[i] =
            (i + pass * 17) & 0xff;

        checksum += data[i];

        if (i % (1024 * 512) == 0) {
          if (_cancelled) {
            return 0;
          }

          await Future<void>.delayed(
            Duration.zero,
          );
        }
      }
    }

    // Read pass
    for (
      int i = 0;
      i < data.length;
      i += 64
    ) {
      checksum += data[i];

      if (i % (1024 * 512) == 0) {
        if (_cancelled) {
          return 0;
        }

        await Future<void>.delayed(
          Duration.zero,
        );
      }
    }

    stopwatch.stop();

    final elapsed = math.max(
      stopwatch.elapsedMicroseconds,
      1,
    );

    final bytesProcessed =
        size * 5;

    final mbPerSecond =
        bytesProcessed /
        (elapsed / 1000000) /
        (1024 * 1024);

    final checksumFactor =
        1.0 + (checksum % 100) / 10000;

    final score =
        (mbPerSecond *
                5.0 *
                checksumFactor)
            .round();

    return _clamp(
      score,
      500,
      20000,
    );
  }

  // ==============================================================
  // STORAGE
  // ==============================================================

  static Future<int> _runStorageTest() async {
    final directory =
        Directory.systemTemp;

    final file = File(
      '${directory.path}/'
      'stellar_center_benchmark.tmp',
    );

    const int size =
        4 * 1024 * 1024;

    final data = Uint8List(size);

    for (int i = 0; i < size; i++) {
      data[i] =
          (i * 31 + 17) & 0xff;
    }

    try {
      // WRITE
      final writeTimer =
          Stopwatch()..start();

      await file.writeAsBytes(
        data,
        flush: true,
      );

      writeTimer.stop();

      if (_cancelled) {
        return 0;
      }

      // READ
      final readTimer =
          Stopwatch()..start();

      final readData =
          await file.readAsBytes();

      readTimer.stop();

      if (_cancelled) {
        return 0;
      }

      int checksum = 0;

      for (
        int i = 0;
        i < readData.length;
        i += 4096
      ) {
        checksum += readData[i];
      }

      final writeMicros =
          math.max(
        writeTimer.elapsedMicroseconds,
        1,
      );

      final readMicros =
          math.max(
        readTimer.elapsedMicroseconds,
        1,
      );

      final writeSpeed =
          size /
          (writeMicros / 1000000) /
          (1024 * 1024);

      final readSpeed =
          size /
          (readMicros / 1000000) /
          (1024 * 1024);

      final averageSpeed =
          (writeSpeed + readSpeed) /
          2.0;

      final checksumFactor =
          1.0 + (checksum % 50) / 10000;

      final score =
          (averageSpeed *
                  12.0 *
                  checksumFactor)
              .round();

      return _clamp(
        score,
        300,
        15000,
      );
    } finally {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Geçici benchmark dosyası
        // silinemese bile uygulamayı
        // başarısız saymıyoruz.
      }
    }
  }

  // ==============================================================
  // GRAPHICS / UI
  // ==============================================================

  static Future<int> _runGraphicsTest() async {
    final stopwatch = Stopwatch()..start();

    double x = 0.1;

    const int frames = 180;

    for (int frame = 0; frame < frames; frame++) {
      for (
        int i = 0;
        i < 12000;
        i++
      ) {
        final t =
            (frame * 12000 + i) *
            0.00008;

        x += math.sin(t) *
            math.cos(t * 0.71);

        x *= 0.999999;

        if (i % 3000 == 0) {
          if (_cancelled) {
            return 0;
          }
        }
      }

      // UI thread'i tamamen kilitlememek
      // için düzenli async yield.
      await Future<void>.delayed(
        Duration.zero,
      );
    }

    stopwatch.stop();

    final elapsed =
        math.max(
      stopwatch.elapsedMicroseconds,
      1,
    );

    final operations =
        frames * 12000;

    final operationsPerSecond =
        operations /
        (elapsed / 1000000);

    final stability =
        x.abs() % 1.0;

    final score =
        (operationsPerSecond *
                0.025 *
                (1.0 + stability * 0.05))
            .round();

    return _clamp(
      score,
      500,
      20000,
    );
  }

  // ==============================================================
  // MIXED SYSTEM
  // ==============================================================

  static Future<int> _runMixedTest({
    required int singleCore,
    required int multiCore,
    required int ram,
    required int storage,
    required int graphics,
  }) async {
    final stopwatch = Stopwatch()..start();

    double value = 0;

    const int iterations = 300000;

    for (int i = 0; i < iterations; i++) {
      value +=
          math.sin(i * 0.00041);

      value *= 0.9999997;

      if (i % 25000 == 0) {
        if (_cancelled) {
          return 0;
        }

        await Future<void>.delayed(
          Duration.zero,
        );
      }
    }

    stopwatch.stop();

    final calculationTime =
        math.max(
      stopwatch.elapsedMicroseconds,
      1,
    );

    final calculationScore =
        ((iterations * 1000000) /
                calculationTime *
                2.0)
            .round();

    final combined =
        (singleCore * 0.15 +
                multiCore * 0.25 +
                ram * 0.15 +
                storage * 0.15 +
                graphics * 0.20 +
                calculationScore * 0.10)
            .round();

    return _clamp(
      combined,
      500,
      25000,
    );
  }

  // ==============================================================
  // TOTAL SCORE
  // ==============================================================

  static int _calculateTotal({
    required int singleCore,
    required int multiCore,
    required int ram,
    required int storage,
    required int graphics,
    required int mixed,
  }) {
    final weighted =
        singleCore * 0.15 +
        multiCore * 0.25 +
        ram * 0.12 +
        storage * 0.13 +
        graphics * 0.15 +
        mixed * 0.20;

    return _clamp(
      weighted.round(),
      500,
      50000,
    );
  }

  // ==============================================================
  // HELPERS
  // ==============================================================

  static int _clamp(
    int value,
    int minimum,
    int maximum,
  ) {
    if (value < minimum) {
      return minimum;
    }

    if (value > maximum) {
      return maximum;
    }

    return value;
  }
}
