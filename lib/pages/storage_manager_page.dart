import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

class StorageManagerPage extends StatefulWidget {
  const StorageManagerPage({super.key});

  @override
  State<StorageManagerPage> createState() =>
      _StorageManagerPageState();
}

class _StorageManagerPageState extends State<StorageManagerPage> {
  bool _loading = true;
  bool _scanning = false;

  int _fileCount = 0;
  double _totalBytes = 0;

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
    _scanStorage();
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

  Future<void> _scanStorage() async {
    if (_scanning) return;

    _scanning = true;

    if (mounted) {
      setState(() {
        _loading = true;
        _fileCount = 0;
        _totalBytes = 0;

        for (final key in _categories.keys) {
          _categories[key] = 0;
          _counts[key] = 0;
        }
      });
    }

    final categories = <String, double>{
      for (final key in _categories.keys) key: 0,
    };

    final counts = <String, int>{
      for (final key in _counts.keys) key: 0,
    };

    var totalBytes = 0.0;
    var fileCount = 0;

    try {
      final root = Directory(_rootPath);

      if (await root.exists()) {
        await _scanDirectory(
          root,
          categories,
          counts,
          (size) {
            totalBytes += size;
            fileCount++;
          },
        );
      }
    } catch (_) {}

    if (!mounted) {
      _scanning = false;
      return;
    }

    setState(() {
      _categories
        ..clear()
        ..addAll(categories);

      _counts
        ..clear()
        ..addAll(counts);

      _totalBytes = totalBytes;
      _fileCount = fileCount;
      _loading = false;
    });

    _scanning = false;
  }

  Future<void> _scanDirectory(
    Directory directory,
    Map<String, double> categories,
    Map<String, int> counts,
    void Function(double) onFile,
  ) async {
    try {
      await for (final entity in directory.list(
        followLinks: false,
      )) {
        try {
          if (entity is File) {
            final size = (await entity.length()).toDouble();
            final category = _categoryFor(entity.path);

            categories[category] =
                (categories[category] ?? 0) + size;

            counts[category] =
                (counts[category] ?? 0) + 1;

            onFile(size);
            continue;
          }

          if (entity is Directory) {
            final name = entity.path
                .split(Platform.pathSeparator)
                .last
                .toLowerCase();

            if (_shouldSkipDirectory(entity.path, name)) {
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

  bool _shouldSkipDirectory(
    String path,
    String name,
  ) {
    if (name == '.cache' ||
        name == '.cache' ||
        name == '.local' ||
        name == '.config' ||
        name == '.var' ||
        name == '.git' ||
        name == 'node_modules' ||
        name == '.dart_tool' ||
        name == 'build') {
      return true;
    }

    if (Platform.isAndroid) {
      if (name == 'android') return true;
      if (name == '.thumbnails') return true;
      if (name == '.trash') return true;
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
            onPressed: _scanning ? null : _scanStorage,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _scanStorage,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  _summaryCard(context),
                  const SizedBox(height: 20),
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
                        ? 'Linux kullanıcı dizini taranıyor: $_rootPath'
                        : 'Paylaşılan dahili depolama taranıyor.',
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

    final values = _categories.values.toList();

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
                  values: values,
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
                        _formatSize(_totalBytes),
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Taranan alan',
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
              '$_fileCount dosya',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _categoryWidgets(BuildContext context) {
    return _categories.entries.map((entry) {
      final size = entry.value;

      final percentage = _totalBytes <= 0
          ? 0.0
          : size / _totalBytes * 100;

      final color =
          _categoryColor(context, entry.key);

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
  void paint(
    Canvas canvas,
    Size size,
  ) {
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
    return oldDelegate.values != values ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.tertiaryColor != tertiaryColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
