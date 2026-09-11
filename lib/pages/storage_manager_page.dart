import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

class StorageManagerPage extends StatefulWidget {
  const StorageManagerPage({super.key});

  @override
  State<StorageManagerPage> createState() => _StorageManagerPageState();
}

class _StorageManagerPageState extends State<StorageManagerPage> {
  bool _loading = true;
  bool _scanning = false;

  int _fileCount = 0;
  double _totalBytes = 0;
  double _usedBytes = 0;
  double _freeBytes = 0;

  final Map<String, double> _categories = {
    'Görseller': 0,
    'Videolar': 0,
    'Ses': 0,
    'Belgeler': 0,
    'APK': 0,
    'Arşivler': 0,
    'Diğer': 0,
  };

  final Map<String, int> _counts = {
    'Görseller': 0,
    'Videolar': 0,
    'Ses': 0,
    'Belgeler': 0,
    'APK': 0,
    'Arşivler': 0,
    'Diğer': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  String get _rootPath {
    if (Platform.isLinux) {
      return Platform.environment['HOME'] ?? '/home';
    }

    if (Platform.isAndroid) {
      return '/storage/emulated/0';
    }

    return Directory.current.path;
  }

  Future<void> _loadStorage() async {
    if (_scanning) return;

    _scanning = true;

    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      await _readDiskUsage();
      await _scanImportantDirectories();
    } catch (_) {}

    if (!mounted) {
      _scanning = false;
      return;
    }

    setState(() {
      _loading = false;
    });

    _scanning = false;
  }

  Future<void> _readDiskUsage() async {
    try {
      if (Platform.isLinux) {
        final result = await Process.run(
          'df',
          ['-B1', _rootPath],
        );

        if (result.exitCode == 0) {
          final lines = result.stdout
              .toString()
              .trim()
              .split('\n');

          if (lines.length >= 2) {
            final parts = lines.last
                .trim()
                .split(RegExp(r'\s+'));

            if (parts.length >= 4) {
              final total = double.tryParse(parts[1]) ?? 0;
              final used = double.tryParse(parts[2]) ?? 0;
              final free = double.tryParse(parts[3]) ?? 0;

              if (mounted) {
                setState(() {
                  _totalBytes = total;
                  _usedBytes = used;
                  _freeBytes = free;
                });
              }

              return;
            }
          }
        }
      }

      final root = Directory(_rootPath);

      if (await root.exists()) {
        await _fallbackDirectorySize(root);
      }
    } catch (_) {}
  }

  Future<void> _fallbackDirectorySize(
    Directory root,
  ) async {
    var total = 0.0;

    try {
      await for (final entity in root.list(
        recursive: false,
        followLinks: false,
      )) {
        if (entity is File) {
          try {
            total += await entity.length();
          } catch (_) {}
        }
      }
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _usedBytes = total;
    });
  }

  Future<void> _scanImportantDirectories() async {
    final categories = <String, double>{
      for (final key in _categories.keys) key: 0,
    };

    final counts = <String, int>{
      for (final key in _counts.keys) key: 0,
    };

    var fileCount = 0;

    final directories = _directoriesToScan();

    for (final directory in directories) {
      if (!await directory.exists()) continue;

      try {
        await _scanDirectory(
          directory,
          categories,
          counts,
          (size, category) {
            categories[category] =
                (categories[category] ?? 0) + size;

            counts[category] =
                (counts[category] ?? 0) + 1;

            fileCount++;
          },
        );
      } catch (_) {}
    }

    if (!mounted) return;

    setState(() {
      _categories
        ..clear()
        ..addAll(categories);

      _counts
        ..clear()
        ..addAll(counts);

      _fileCount = fileCount;
    });
  }

  List<Directory> _directoriesToScan() {
    final root = Directory(_rootPath);

    if (Platform.isAndroid) {
      return [
        Directory('${root.path}/DCIM'),
        Directory('${root.path}/Pictures'),
        Directory('${root.path}/Movies'),
        Directory('${root.path}/Music'),
        Directory('${root.path}/Documents'),
        Directory('${root.path}/Download'),
        Directory('${root.path}/Downloads'),
      ];
    }

    if (Platform.isLinux) {
      return [
        Directory('${root.path}/Desktop'),
        Directory('${root.path}/Documents'),
        Directory('${root.path}/Downloads'),
        Directory('${root.path}/Music'),
        Directory('${root.path}/Pictures'),
        Directory('${root.path}/Videos'),
      ];
    }

    return [root];
  }

  Future<void> _scanDirectory(
    Directory directory,
    Map<String, double> categories,
    Map<String, int> counts,
    void Function(double size, String category) onFile,
  ) async {
    try {
      await for (final entity in directory.list(
        recursive: false,
        followLinks: false,
      )) {
        try {
          if (entity is File) {
            final size = (await entity.length()).toDouble();
            final category = _categoryFor(entity.path);

            onFile(size, category);
            continue;
          }

          if (entity is Directory) {
            final name = entity.path
                .split(Platform.pathSeparator)
                .last
                .toLowerCase();

            if (_shouldSkipDirectory(name)) {
              continue;
            }

            await _scanDirectory(
              entity,
              categories,
              counts,
              onFile,
            );
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  bool _shouldSkipDirectory(String name) {
    const commonSkips = {
      '.cache',
      '.local',
      '.config',
      '.var',
      '.git',
      '.dart_tool',
      'build',
      'node_modules',
      'cache',
      'caches',
      'temp',
      'tmp',
    };

    if (commonSkips.contains(name)) {
      return true;
    }

    if (Platform.isAndroid) {
      const androidSkips = {
        'android',
        '.thumbnails',
        '.trash',
        'android',
      };

      if (androidSkips.contains(name)) {
        return true;
      }
    }

    return false;
  }

  String _categoryFor(String path) {
    final lower = path.toLowerCase();

    if (RegExp(
      r'\.(jpg|jpeg|png|webp|gif|heic|heif|bmp|tiff|svg)$',
    ).hasMatch(lower)) {
      return 'Görseller';
    }

    if (RegExp(
      r'\.(mp4|mkv|avi|mov|webm|3gp|m4v|ts)$',
    ).hasMatch(lower)) {
      return 'Videolar';
    }

    if (RegExp(
      r'\.(mp3|wav|ogg|flac|m4a|aac|opus|amr)$',
    ).hasMatch(lower)) {
      return 'Ses';
    }

    if (lower.endsWith('.apk')) {
      return 'APK';
    }

    if (RegExp(
      r'\.(zip|rar|7z|tar|gz|bz2|xz|iso|img)$',
    ).hasMatch(lower)) {
      return 'Arşivler';
    }

    if (RegExp(
      r'\.(pdf|doc|docx|txt|xls|xlsx|ppt|pptx|csv|rtf|odt|ods|odp)$',
    ).hasMatch(lower)) {
      return 'Belgeler';
    }

    return 'Diğer';
  }

  String _formatSize(double bytes) {
    if (bytes <= 0) return '0 B';

    if (bytes >= 1024 * 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024 / 1024 / 1024).toStringAsFixed(2)} TB';
    }

    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
    }

    if (bytes >= 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }

    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${bytes.toStringAsFixed(0)} B';
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Görseller':
        return Icons.image_outlined;
      case 'Videolar':
        return Icons.video_library_outlined;
      case 'Ses':
        return Icons.audiotrack_outlined;
      case 'Belgeler':
        return Icons.description_outlined;
      case 'APK':
        return Icons.android_outlined;
      case 'Arşivler':
        return Icons.archive_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  Color _categoryColor(
    BuildContext context,
    String category,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (category) {
      case 'Görseller':
        return scheme.primary;
      case 'Videolar':
        return scheme.secondary;
      case 'Ses':
        return scheme.tertiary;
      case 'Belgeler':
        return Colors.orange;
      case 'APK':
        return Colors.green;
      case 'Arşivler':
        return Colors.blueGrey;
      default:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _scanning ? null : _loadStorage,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadStorage,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  _summaryCard(context),
                  const SizedBox(height: 20),
                  Text(
                    'Depolama kullanımı',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._storageStats(context),
                  const SizedBox(height: 18),
                  Text(
                    'Dosya kategorileri',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._categoryWidgets(context),
                  const SizedBox(height: 12),
                  Text(
                    Platform.isLinux
                        ? 'Linux: yalnızca kullanıcı dosyaları taranıyor.'
                        : 'Android: yaygın kullanıcı klasörleri taranıyor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 210,
              child: CustomPaint(
                painter: _StorageChartPainter(
                  values: _categories.values.toList(),
                  primaryColor: scheme.primary,
                  secondaryColor: scheme.secondary,
                  tertiaryColor: scheme.tertiary,
                  backgroundColor:
                      scheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatSize(_usedBytes),
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kullanılan',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _totalBytes > 0
                  ? '${_formatSize(_freeBytes)} boş / '
                      '${_formatSize(_totalBytes)} toplam'
                  : 'Depolama bilgisi alınamadı',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _storageStats(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return [
      Card(
        child: ListTile(
          leading: const Icon(Icons.storage_rounded),
          title: const Text('Toplam'),
          trailing: Text(
            _formatSize(_totalBytes),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      Card(
        child: ListTile(
          leading: Icon(
            Icons.folder_rounded,
            color: scheme.primary,
          ),
          title: const Text('Kullanılan'),
          trailing: Text(
            _formatSize(_usedBytes),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      Card(
        child: ListTile(
          leading: Icon(
            Icons.check_circle_outline_rounded,
            color: scheme.tertiary,
          ),
          title: const Text('Boş'),
          trailing: Text(
            _formatSize(_freeBytes),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      Card(
        child: ListTile(
          leading: const Icon(Icons.insert_drive_file_outlined),
          title: const Text('Taranan dosya'),
          trailing: Text(
            '$_fileCount',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _categoryWidgets(BuildContext context) {
    return _categories.entries.map((entry) {
      final size = entry.value;

      final percentage = _totalBytes <= 0
          ? 0.0
          : size / _totalBytes * 100;

      final color = _categoryColor(
        context,
        entry.key,
      );

      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _categoryIcon(entry.key),
              color: color,
            ),
          ),
          title: Text(
            entry.key,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${_counts[entry.key] ?? 0} dosya • '
            '${_formatSize(size)}',
          ),
          trailing: Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _StorageChartPainter extends CustomPainter {
  final List<double> values;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final Color backgroundColor;

  _StorageChartPainter({
    required this.values,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        min(size.width, size.height) / 2 - 15;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..color = backgroundColor;

    canvas.drawCircle(
      center,
      radius,
      trackPaint,
    );

    if (total <= 0) return;

    final colors = [
      primaryColor,
      secondaryColor,
      tertiaryColor,
      Colors.orange,
      Colors.green,
      Colors.blueGrey,
      backgroundColor,
    ];

    var startAngle = -pi / 2;

    for (var i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;

      final sweep =
          (values[i] / total) * pi * 2;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28
        ..strokeCap = StrokeCap.butt
        ..color = colors[
          i.clamp(0, colors.length - 1)
        ];

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        sweep,
        false,
        paint,
      );

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(
    covariant _StorageChartPainter oldDelegate,
  ) {
    return true;
  }
}

