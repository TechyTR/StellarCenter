import 'dart:io';
import 'dart:ui';

import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/app_version.dart';
import '../theme/app_theme.dart';

class SystemInfoPage extends StatefulWidget {
  final AppThemeColor selectedTheme;
  final AppThemeStyle selectedStyle;

  final Future<void> Function(AppThemeColor) onThemeChanged;
  final Future<void> Function(AppThemeStyle) onStyleChanged;

  const SystemInfoPage({
    super.key,
    required this.selectedTheme,
    required this.selectedStyle,
    required this.onThemeChanged,
    required this.onStyleChanged,
  });

  @override
  State<SystemInfoPage> createState() => _SystemInfoPageState();
}

class _SystemInfoPageState extends State<SystemInfoPage> {
  static const MethodChannel _channel =
      MethodChannel('org.test.thislinux/native');

  AndroidDeviceInfo? _androidInfo;
  Map<String, String> _linuxInfo = <String, String>{};

  int _batteryLevel = -1;
  BatteryState _batteryState = BatteryState.unknown;

  bool _loading = true;

  bool get _isLinux => Platform.isLinux;

  bool get _isGlass =>
      widget.selectedStyle == AppThemeStyle.liquidGlassLight ||
      widget.selectedStyle == AppThemeStyle.liquidGlassDark;

  bool get _isLightGlass =>
      widget.selectedStyle == AppThemeStyle.liquidGlassLight;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    if (_isLinux) {
      await _loadLinuxInfo();
    } else {
      await _loadAndroidInfo();
    }
  }

  Future<void> _loadAndroidInfo() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;

      int batteryLevel = -1;
      BatteryState batteryState = BatteryState.unknown;

      try {
        final battery = Battery();
        batteryLevel = await battery.batteryLevel;
        batteryState = await battery.batteryState;
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _androidInfo = info;
        _batteryLevel = batteryLevel;
        _batteryState = batteryState;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<String> _readFile(
    String path, {
    String fallback = 'Bilinmiyor',
  }) async {
    try {
      final file = File(path);

      if (!await file.exists()) {
        return fallback;
      }

      final value = (await file.readAsString()).trim();

      return value.isEmpty ? fallback : value;
    } catch (_) {
      return fallback;
    }
  }

  Future<String> _command(
    String command,
    List<String> arguments, {
    String fallback = 'Bilinmiyor',
  }) async {
    try {
      final result = await Process.run(command, arguments);

      if (result.exitCode != 0) {
        return fallback;
      }

      final output = result.stdout.toString().trim();

      return output.isEmpty ? fallback : output;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _loadLinuxInfo() async {
    final Map<String, String> info = <String, String>{};

    final osRelease = await _readFile('/etc/os-release');

    String osName = 'Linux';

    for (final line in osRelease.split('\n')) {
      if (line.startsWith('PRETTY_NAME=')) {
        osName = line
            .substring('PRETTY_NAME='.length)
            .replaceAll('"', '')
            .trim();
        break;
      }
    }

    final kernel = await _command('uname', ['-r']);
    final architecture = await _command('uname', ['-m']);
    final hostname = await _command('hostname');

    final cpuInfo = await _readFile('/proc/cpuinfo');

    String cpuModel = 'Bilinmiyor';

    for (final line in cpuInfo.split('\n')) {
      if (line.toLowerCase().startsWith('model name')) {
        final separator = line.indexOf(':');

        if (separator != -1) {
          cpuModel = line.substring(separator + 1).trim();
          break;
        }
      }

      if (line.toLowerCase().startsWith('hardware')) {
        final separator = line.indexOf(':');

        if (separator != -1) {
          cpuModel = line.substring(separator + 1).trim();
          break;
        }
      }
    }

    final cpuCount = await _command('nproc', []);

    final memInfo = await _readFile('/proc/meminfo');

    String totalRam = 'Bilinmiyor';
    String availableRam = 'Bilinmiyor';

    for (final line in memInfo.split('\n')) {
      if (line.startsWith('MemTotal:')) {
        final parts = line.split(RegExp(r'\s+'));

        if (parts.length >= 2) {
          final kb = double.tryParse(parts[1]);

          if (kb != null) {
            totalRam = _formatBytes(kb * 1024);
          }
        }
      }

      if (line.startsWith('MemAvailable:')) {
        final parts = line.split(RegExp(r'\s+'));

        if (parts.length >= 2) {
          final kb = double.tryParse(parts[1]);

          if (kb != null) {
            availableRam = _formatBytes(kb * 1024);
          }
        }
      }
    }

    String totalStorage = 'Bilinmiyor';
    String availableStorage = 'Bilinmiyor';

    try {
      final result = await Process.run(
        'df',
        ['-B1', '/'],
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
            final total = double.tryParse(parts[1]);
            final available = double.tryParse(parts[3]);

            if (total != null) {
              totalStorage = _formatBytes(total);
            }

            if (available != null) {
              availableStorage = _formatBytes(available);
            }
          }
        }
      }
    } catch (_) {}

    final uptimeRaw = await _readFile('/proc/uptime');

    String uptime = 'Bilinmiyor';

    final uptimeSeconds =
        double.tryParse(uptimeRaw.split(' ').first);

    if (uptimeSeconds != null) {
      uptime = _formatUptime(uptimeSeconds);
    }

    info['os'] = osName;
    info['kernel'] = kernel;
    info['architecture'] = architecture;
    info['hostname'] = hostname;
    info['cpu'] = cpuModel;
    info['cpu_count'] = cpuCount;
    info['total_ram'] = totalRam;
    info['available_ram'] = availableRam;
    info['total_storage'] = totalStorage;
    info['available_storage'] = availableStorage;
    info['uptime'] = uptime;

    if (!mounted) return;

    setState(() {
      _linuxInfo = info;
      _loading = false;
    });
  }

  String _formatBytes(double bytes) {
    if (bytes <= 0) {
      return 'Bilinmiyor';
    }

    const units = [
      'B',
      'KB',
      'MB',
      'GB',
      'TB',
    ];

    var value = bytes;
    var unit = 0;

    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }

    if (unit == 0) {
      return '${value.toStringAsFixed(0)} ${units[unit]}';
    }

    return '${value.toStringAsFixed(2)} ${units[unit]}';
  }

  String _formatUptime(double seconds) {
    var remaining = seconds.floor();

    final days = remaining ~/ 86400;
    remaining %= 86400;

    final hours = remaining ~/ 3600;
    remaining %= 3600;

    final minutes = remaining ~/ 60;

    if (days > 0) {
      return '${days}g ${hours}s ${minutes}dk';
    }

    if (hours > 0) {
      return '${hours}s ${minutes}dk';
    }

    return '${minutes}dk';
  }

  String _androidValue(
    dynamic value, {
    String fallback = 'Bilinmiyor',
  }) {
    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') {
      return fallback;
    }

    return text;
  }

  String _batteryStateText() {
    switch (_batteryState) {
      case BatteryState.charging:
        return 'Şarj oluyor';

      case BatteryState.discharging:
        return 'Şarj olmuyor';

      case BatteryState.full:
        return 'Dolu';

      case BatteryState.connectedNotCharging:
        return 'Bağlı, şarj olmuyor';

      case BatteryState.unknown:
        return 'Bilinmiyor';
    }
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double radius = 22,
  }) {
    if (!_isGlass) {
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding,
          child: child,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 24,
            sigmaY: 24,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: Colors.white.withOpacity(
                _isLightGlass ? 0.16 : 0.065,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(
                  _isLightGlass ? 0.58 : 0.19,
                ),
              ),
            ),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        top: 18,
        bottom: 10,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return _glassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(
                _isGlass ? 0.09 : 0.12,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: scheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    final scheme = Theme.of(context).colorScheme;

    final model = _isLinux
        ? (_linuxInfo['os'] ?? 'Linux')
        : _androidValue(_androidInfo?.model);

    final manufacturer = _isLinux
        ? (_linuxInfo['hostname'] ?? 'Linux')
        : _androidValue(_androidInfo?.manufacturer);

    final cpu = _isLinux
        ? (_linuxInfo['cpu'] ?? 'Bilinmiyor')
        : _androidValue(_androidInfo?.hardware);

    final cores = _isLinux
        ? (_linuxInfo['cpu_count'] ?? 'Bilinmiyor')
        : '${_androidInfo?.supportedAbis.length ?? 0} ABI';

    return _glassCard(
      padding: const EdgeInsets.all(20),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(
                    _isGlass ? 0.09 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _isLinux
                      ? Icons.computer_rounded
                      : Icons.smartphone_rounded,
                  size: 31,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      model,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      manufacturer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            cpu,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          _infoChip(
            Icons.memory_rounded,
            '$cores çekirdek',
          ),
        ],
      ),
    );
  }

  Widget _infoChip(
    IconData icon,
    String text,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(
          _isGlass ? 0.075 : 0.10,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: scheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _batteryCard() {
    if (_isLinux) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final level = _batteryLevel.clamp(0, 100);

    return _glassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.battery_6_bar_rounded,
                color: scheme.primary,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pil',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$level%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: level / 100,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _batteryStateText(),
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _androidContent() {
    final info = _androidInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Android'),

        _infoCard(
          icon: Icons.android_rounded,
          title: 'Android sürümü',
          value: _androidValue(info?.version.release),
        ),

        _infoCard(
          icon: Icons.build_rounded,
          title: 'Build',
          value: _androidValue(info?.id),
        ),

        _infoCard(
          icon: Icons.memory_rounded,
          title: 'Donanım',
          value: _androidValue(info?.hardware),
        ),

        _infoCard(
          icon: Icons.developer_board_rounded,
          title: 'Board',
          value: _androidValue(info?.board),
        ),

        _infoCard(
          icon: Icons.architecture_rounded,
          title: 'ABI',
          value: info?.supportedAbis.join(', ') ??
              'Bilinmiyor',
        ),

        _infoCard(
          icon: Icons.fingerprint_rounded,
          title: 'Device',
          value: _androidValue(info?.device),
        ),

        _infoCard(
          icon: Icons.settings_rounded,
          title: 'Product',
          value: _androidValue(info?.product),
        ),

        _batteryCard(),
      ],
    );
  }

  Widget _linuxContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Linux'),

        _infoCard(
          icon: Icons.laptop_rounded,
          title: 'Dağıtım',
          value: _linuxInfo['os'] ?? 'Bilinmiyor',
        ),

        _infoCard(
          icon: Icons.terminal_rounded,
          title: 'Kernel',
          value: _linuxInfo['kernel'] ?? 'Bilinmiyor',
        ),

        _infoCard(
          icon: Icons.computer_rounded,
          title: 'Mimari',
          value: _linuxInfo['architecture'] ??
              'Bilinmiyor',
        ),

        _infoCard(
          icon: Icons.dns_rounded,
          title: 'Hostname',
          value: _linuxInfo['hostname'] ??
              'Bilinmiyor',
        ),

        _infoCard(
          icon: Icons.memory_rounded,
          title: 'CPU',
          value: _linuxInfo['cpu'] ??
              'Bilinmiyor',
        ),

        _infoCard(
          icon: Icons.developer_board_rounded,
          title: 'CPU çekirdekleri',
          value: _linuxInfo['cpu_count'] ??
              'Bilinmiyor',
        ),

        _infoCard(
          icon: Icons.memory_outlined,
          title: 'RAM',
          value:
              '${_linuxInfo['total_ram'] ?? 'Bilinmiyor'} toplam\n'
              '${_linuxInfo['available_ram'] ?? 'Bilinmiyor'} kullanılabilir',
        ),

        _infoCard(
          icon: Icons.storage_rounded,
          title: 'Disk',
          value:
              '${_linuxInfo['total_storage'] ?? 'Bilinmiyor'} toplam\n'
              '${_linuxInfo['available_storage'] ?? 'Bilinmiyor'} kullanılabilir',
        ),

        _infoCard(
          icon: Icons.timer_outlined,
          title: 'Çalışma süresi',
          value: _linuxInfo['uptime'] ??
              'Bilinmiyor',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistem Bilgisi'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: _loading ? null : _loadAll,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadAll,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  32,
                ),
                children: [
                  _summaryCard(),
                  _isLinux
                      ? _linuxContent()
                      : _androidContent(),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Stellar Center ${AppVersion.current}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

