import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class SystemMonitorPage extends StatefulWidget {
  final AppThemeColor selectedTheme;
  final AppThemeStyle selectedStyle;

  final Future<void> Function(AppThemeColor) onThemeChanged;
  final Future<void> Function(AppThemeStyle) onStyleChanged;

  const SystemMonitorPage({
    super.key,
    required this.selectedTheme,
    required this.selectedStyle,
    required this.onThemeChanged,
    required this.onStyleChanged,
  });

  @override
  State<SystemMonitorPage> createState() => _SystemMonitorPageState();
}

class _SystemMonitorPageState extends State<SystemMonitorPage> {
  static const MethodChannel _channel =
      MethodChannel('org.test.thislinux/native');

  Timer? _timer;

  double _cpuUsage = 0;
  int _totalCpuCount = 0;
  int _onlineCpuCount = 0;

  List<String> _onlineCpus = [];
  List<double> _cpuFrequencies = [];

  double _ramTotal = 0;
  double _ramAvailable = 0;
  double _ramUsed = 0;

  int _batteryLevel = -1;
  String _batteryState = 'Bilinmiyor';
  String _batterySource = 'Bilinmiyor';
  double? _batteryTemperature;

  Map<String, double> _thermalZones = {};

  int _previousTotal = 0;
  int _previousIdle = 0;

  bool _loading = true;
  bool _refreshing = false;

  bool get _isLinux => Platform.isLinux;

  bool get _isAndroid => Platform.isAndroid;

  bool get _isGlass =>
      widget.selectedStyle == AppThemeStyle.liquidGlassLight ||
      widget.selectedStyle == AppThemeStyle.liquidGlassDark;

  bool get _isLightGlass =>
      widget.selectedStyle == AppThemeStyle.liquidGlassLight;

  @override
  void initState() {
    super.initState();

    _loadData();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _loadData(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      final snapshot = await _collectSnapshot();

      if (!mounted) return;

      setState(() {
        _cpuUsage = snapshot.cpuUsage;
        _totalCpuCount = snapshot.totalCpuCount;
        _onlineCpuCount = snapshot.onlineCpuCount;
        _onlineCpus = snapshot.onlineCpus;
        _cpuFrequencies = snapshot.cpuFrequencies;

        _ramTotal = snapshot.ramTotal;
        _ramAvailable = snapshot.ramAvailable;
        _ramUsed = snapshot.ramUsed;

        _batteryLevel = snapshot.batteryLevel;
        _batteryState = snapshot.batteryState;
        _batterySource = snapshot.batterySource;
        _batteryTemperature = snapshot.batteryTemperature;

        _thermalZones = snapshot.thermalZones;

        _loading = false;
        _refreshing = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _refreshing = false;
      });
    }
  }

  Future<_MonitorSnapshot> _collectSnapshot() async {
    if (_isLinux) {
      return _collectLinuxSnapshot();
    }

    if (_isAndroid) {
      return _collectAndroidSnapshot();
    }

    return _MonitorSnapshot.empty();
  }

  Future<_MonitorSnapshot> _collectLinuxSnapshot() async {
    final cpu = await _readLinuxCpu();
    final ram = await _readLinuxRam();
    final cpuInfo = await _readLinuxCpuInfo();
    final battery = await _readLinuxBattery();
    final thermal = await _readLinuxThermal();

    return _MonitorSnapshot(
      cpuUsage: cpu.usage,
      totalCpuCount: cpu.totalCount,
      onlineCpuCount: cpu.onlineCount,
      onlineCpus: cpu.onlineCpus,
      cpuFrequencies: cpuInfo,
      ramTotal: ram.total,
      ramAvailable: ram.available,
      ramUsed: ram.used,
      batteryLevel: battery.level,
      batteryState: battery.state,
      batterySource: battery.source,
      batteryTemperature: battery.temperature,
      thermalZones: thermal,
    );
  }

  Future<_MonitorSnapshot> _collectAndroidSnapshot() async {
    double cpuUsage = _cpuUsage;
    int totalCpuCount = _totalCpuCount;

    try {
      final cpu = await _readProcCpu();

      cpuUsage = cpu.usage;
      totalCpuCount = cpu.totalCount;
    } catch (_) {}

    final ram = await _readLinuxRam();

    int batteryLevel = _batteryLevel;
    String batteryState = _batteryState;
    String batterySource = _batterySource;
    double? batteryTemperature = _batteryTemperature;

    List<String> onlineCpus = _onlineCpus;
    List<double> frequencies = _cpuFrequencies;
    Map<String, double> thermal = _thermalZones;

    try {
      final result =
          await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getSystemMonitorDetails',
      );

      if (result != null) {
        final data = result.map(
          (key, value) => MapEntry(key.toString(), value),
        );

        onlineCpus = _parseOnlineCpus(
          data['online_cpus'],
        );

        frequencies = _parseFrequencies(
          data['cpu_frequencies'],
        );

        thermal = _parseThermalZones(
          data['thermal_zones'],
        );

        final level = data['battery_level'];

        if (level is num) {
          batteryLevel = level.toInt();
        }

        batteryState =
            data['battery_state']?.toString() ?? batteryState;

        batterySource =
            data['battery_source']?.toString() ?? batterySource;

        final temp = data['battery_temperature'];

        if (temp is num) {
          batteryTemperature = temp.toDouble();
        }
      }
    } catch (_) {
      try {
        final result =
            await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'getBatteryStatus',
        );

        if (result != null) {
          final level = result['level'];

          if (level is num) {
            batteryLevel = level.toInt();
          }

          batteryState =
              result['state']?.toString() ?? batteryState;

          batterySource =
              result['source']?.toString() ?? batterySource;

          final temp = result['temperature'];

          if (temp is num) {
            batteryTemperature = temp.toDouble();
          }
        }
      } catch (_) {}
    }

    return _MonitorSnapshot(
      cpuUsage: cpuUsage,
      totalCpuCount: totalCpuCount,
      onlineCpuCount:
          onlineCpus.isNotEmpty ? onlineCpus.length : totalCpuCount,
      onlineCpus: onlineCpus,
      cpuFrequencies: frequencies,
      ramTotal: ram.total,
      ramAvailable: ram.available,
      ramUsed: ram.used,
      batteryLevel: batteryLevel,
      batteryState: batteryState,
      batterySource: batterySource,
      batteryTemperature: batteryTemperature,
      thermalZones: thermal,
    );
  }

  Future<_CpuSnapshot> _readLinuxCpu() async {
    return _readProcCpu();
  }

  Future<_CpuSnapshot> _readProcCpu() async {
    try {
      final file = File('/proc/stat');

      if (!await file.exists()) {
        return _CpuSnapshot.empty();
      }

      final lines = await file.readAsLines();

      final cpuLine = lines.firstWhere(
        (line) => line.startsWith('cpu '),
        orElse: () => '',
      );

      if (cpuLine.isEmpty) {
        return _CpuSnapshot.empty();
      }

      final parts = cpuLine.trim().split(RegExp(r'\s+'));

      if (parts.length < 5) {
        return _CpuSnapshot.empty();
      }

      final values = parts
          .sublist(1)
          .take(8)
          .map((value) => int.tryParse(value) ?? 0)
          .toList();

      while (values.length < 8) {
        values.add(0);
      }

      final idle = values[3] + values[4];

      final total = values.fold<int>(
        0,
        (sum, value) => sum + value,
      );

      double usage = _cpuUsage;

      if (_previousTotal != 0) {
        final totalDelta = total - _previousTotal;
        final idleDelta = idle - _previousIdle;

        if (totalDelta > 0) {
          usage = ((1 - idleDelta / totalDelta) * 100)
              .clamp(0.0, 100.0)
              .toDouble();
        }
      }

      _previousTotal = total;
      _previousIdle = idle;

      final cpuLines = lines
          .where(
            (line) => RegExp(r'^cpu\d+\s').hasMatch(line),
          )
          .toList();

      final totalCount = cpuLines.length;

      final onlineFile = File(
        '/sys/devices/system/cpu/online',
      );

      List<String> online = [];

      if (await onlineFile.exists()) {
        final value = (await onlineFile.readAsString()).trim();
        online = _expandCpuList(value);
      }

      if (online.isEmpty) {
        online = List.generate(
          totalCount,
          (index) => '$index',
        );
      }

      return _CpuSnapshot(
        usage: usage,
        totalCount: totalCount,
        onlineCount: online.length,
        onlineCpus: online,
      );
    } catch (_) {
      return _CpuSnapshot.empty();
    }
  }

  Future<_RamSnapshot> _readLinuxRam() async {
    try {
      final file = File('/proc/meminfo');

      if (!await file.exists()) {
        return _RamSnapshot.empty();
      }

      final lines = await file.readAsLines();

      int totalKb = 0;
      int availableKb = 0;

      for (final line in lines) {
        if (line.startsWith('MemTotal:')) {
          totalKb = _extractKb(line);
        } else if (line.startsWith('MemAvailable:')) {
          availableKb = _extractKb(line);
        }
      }

      if (totalKb <= 0) {
        return _RamSnapshot.empty();
      }

      final total = totalKb / 1024 / 1024;
      final available = availableKb / 1024 / 1024;

      final used =
          (total - available).clamp(0.0, total).toDouble();

      return _RamSnapshot(
        total: total,
        available: available,
        used: used,
      );
    } catch (_) {
      return _RamSnapshot.empty();
    }
  }

  int _extractKb(String line) {
    final match = RegExp(r'\d+').firstMatch(line);

    return int.tryParse(match?.group(0) ?? '') ?? 0;
  }

  Future<List<double>> _readLinuxCpuInfo() async {
    final result = <double>[];

    try {
      final directory = Directory(
        '/sys/devices/system/cpu',
      );

      if (!await directory.exists()) {
        return result;
      }

      final entities = directory
          .listSync()
          .whereType<Directory>()
          .where(
            (directory) => RegExp(
              r'cpu\d+$',
            ).hasMatch(directory.path),
          )
          .toList();

      entities.sort(
        (a, b) => a.path.compareTo(b.path),
      );

      for (final cpu in entities) {
        final file = File(
          '${cpu.path}/cpufreq/scaling_cur_freq',
        );

        if (!await file.exists()) {
          continue;
        }

        final value = double.tryParse(
          (await file.readAsString()).trim(),
        );

        if (value != null) {
          result.add(value);
        }
      }
    } catch (_) {}

    return result;
  }

  Future<_BatterySnapshot> _readLinuxBattery() async {
    try {
      final root = Directory('/sys/class/power_supply');

      if (!await root.exists()) {
        return _BatterySnapshot.empty();
      }

      final entries = root
          .listSync()
          .whereType<Directory>()
          .where(
            (entry) => entry.path.split('/').last.startsWith('BAT'),
          )
          .toList();

      if (entries.isEmpty) {
        return _BatterySnapshot.empty();
      }

      final battery = entries.first;

      int level = -1;
      String state = 'Bilinmiyor';
      String source = 'Linux power_supply';
      double? temperature;

      final capacity = File(
        '${battery.path}/capacity',
      );

      if (await capacity.exists()) {
        level = int.tryParse(
              (await capacity.readAsString()).trim(),
            ) ??
            -1;
      }

      final status = File(
        '${battery.path}/status',
      );

      if (await status.exists()) {
        state = (await status.readAsString()).trim();
      }

      final temp = File(
        '${battery.path}/temp',
      );

      if (await temp.exists()) {
        final raw = double.tryParse(
          (await temp.readAsString()).trim(),
        );

        if (raw != null) {
          temperature = raw > 100 ? raw / 10 : raw;
        }
      }

      return _BatterySnapshot(
        level: level,
        state: state,
        source: source,
        temperature: temperature,
      );
    } catch (_) {
      return _BatterySnapshot.empty();
    }
  }

  Future<Map<String, double>> _readLinuxThermal() async {
    final result = <String, double>{};

    try {
      final root = Directory('/sys/class/thermal');

      if (!await root.exists()) {
        return result;
      }

      final zones = root
          .listSync()
          .whereType<Directory>()
          .where(
            (entry) => RegExp(
              r'thermal_zone\d+$',
            ).hasMatch(entry.path),
          )
          .toList();

      for (final zone in zones) {
        final tempFile = File(
          '${zone.path}/temp',
        );

        if (!await tempFile.exists()) {
          continue;
        }

        final raw = double.tryParse(
          (await tempFile.readAsString()).trim(),
        );

        if (raw == null) {
          continue;
        }

        final temperature =
            raw.abs() > 1000 ? raw / 1000 : raw;

        final typeFile = File(
          '${zone.path}/type',
        );

        String name =
            zone.path.split('/').last;

        if (await typeFile.exists()) {
          final type =
              (await typeFile.readAsString()).trim();

          if (type.isNotEmpty) {
            name = type;
          }
        }

        result[name] = temperature;
      }
    } catch (_) {}

    return result;
  }

  List<String> _expandCpuList(String input) {
    final result = <String>[];

    for (final part in input.split(',')) {
      final value = part.trim();

      if (value.isEmpty) continue;

      if (value.contains('-')) {
        final range = value.split('-');

        if (range.length == 2) {
          final start = int.tryParse(range[0]);
          final end = int.tryParse(range[1]);

          if (start != null && end != null) {
            for (var i = start; i <= end; i++) {
              result.add('$i');
            }
          }
        }
      } else {
        result.add(value);
      }
    }

    return result;
  }

  List<String> _parseOnlineCpus(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }

    if (raw == null) {
      return [];
    }

    return _expandCpuList(
      raw.toString(),
    );
  }

  List<double> _parseFrequencies(dynamic raw) {
    if (raw is! List) {
      return [];
    }

    return raw
        .map(
          (value) => double.tryParse(
            value.toString(),
          ),
        )
        .whereType<double>()
        .toList();
  }

  Map<String, double> _parseThermalZones(
    dynamic raw,
  ) {
    final result = <String, double>{};

    if (raw is! Map) {
      return result;
    }

    raw.forEach((key, value) {
      final temperature =
          double.tryParse(value.toString());

      if (temperature != null) {
        result[key.toString()] = temperature;
      }
    });

    return result;
  }

  Future<void> _refresh() async {
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
    });

    _previousTotal = 0;
    _previousIdle = 0;

    await _loadData();
  }

  String _ram(double value) {
    if (value <= 0) return '--';

    return '${value.toStringAsFixed(1)} GB';
  }

  String _frequency(double value) {
    if (value <= 0) return '--';

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)} GHz';
    }

    return '${(value / 1000).toStringAsFixed(0)} MHz';
  }

  String _temperature(double? value) {
    if (value == null) return '--';

    return '${value.toStringAsFixed(1)} °C';
  }

  Color _usageColor(
    BuildContext context,
    double value,
  ) {
    final scheme = Theme.of(context).colorScheme;

    if (value >= 90) {
      return scheme.error;
    }

    if (value >= 70) {
      return Colors.orange;
    }

    return scheme.primary;
  }

  Widget _card({
    required Widget child,
  }) {
    final scheme = Theme.of(context).colorScheme;

    if (!_isGlass) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: child,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 22,
            sigmaY: 22,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                _isLightGlass ? 0.14 : 0.055,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(
                  _isLightGlass ? 0.48 : 0.18,
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _title(
    String title,
    String subtitle,
    IconData icon,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _section(String title) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        4,
        8,
        4,
        10,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _cpuCard() {
    final color =
        _usageColor(context, _cpuUsage);

    return _card(
      child: Column(
        children: [
          _title(
            'CPU',
            'Gerçek zamanlı işlemci kullanımı',
            Icons.memory_rounded,
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                '${_cpuUsage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '$_onlineCpuCount / $_totalCpuCount çekirdek',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: (_cpuUsage / 100)
                  .clamp(0.0, 1.0),
              backgroundColor:
                  Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
              valueColor:
                  AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ramCard() {
    final percent = _ramTotal > 0
        ? (_ramUsed / _ramTotal)
            .clamp(0.0, 1.0)
        : 0.0;

    return _card(
      child: Column(
        children: [
          _title(
            'RAM',
            'Bellek kullanımı',
            Icons.developer_board_rounded,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                _ram(_ramUsed),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ ${_ram(_ramTotal)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${(_ramAvailable).toStringAsFixed(1)} GB boş',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: percent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _batteryCard() {
    final level =
        _batteryLevel.clamp(0, 100);

    return _card(
      child: Column(
        children: [
          _title(
            'Batarya',
            _batterySource,
            Icons.battery_charging_full_rounded,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                _batteryLevel >= 0
                    ? '$level%'
                    : '--',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                _batteryState,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (_batteryTemperature != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.thermostat_rounded,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  'Batarya sıcaklığı',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  _temperature(
                    _batteryTemperature,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _frequencyCard() {
    if (_cpuFrequencies.isEmpty) {
      return _card(
        child: _title(
          'CPU frekansları',
          'Frekans bilgisi kullanılamıyor',
          Icons.speed_rounded,
        ),
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _title(
            'CPU frekansları',
            'Çekirdek başına anlık frekans',
            Icons.speed_rounded,
          ),
          const SizedBox(height: 15),
          ...List.generate(
            _cpuFrequencies.length,
            (index) {
              final frequency =
                  _cpuFrequencies[index];

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'CPU $index',
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _frequency(frequency),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _thermalCard() {
    if (_thermalZones.isEmpty) {
      return _card(
        child: _title(
          'Sıcaklık',
          'Thermal zone bilgisi yok',
          Icons.thermostat_rounded,
        ),
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _title(
            'Sıcaklık',
            'Sistem thermal zone değerleri',
            Icons.thermostat_rounded,
          ),
          const SizedBox(height: 15),
          ..._thermalZones.entries.map(
            (entry) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 9,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _temperature(entry.value),
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _cpuListCard() {
    if (_onlineCpus.isEmpty) {
      return const SizedBox.shrink();
    }

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _title(
            'Aktif çekirdekler',
            'İşletim sisteminin aktif CPU listesi',
            Icons.grid_view_rounded,
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _onlineCpus.map(
              (cpu) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.10),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Text(
                    'CPU $cpu',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'System Monitor',
        ),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed:
                _refreshing ? null : _refresh,
            icon: _refreshing
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                  ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  30,
                ),
                children: [
                  _section('İşlemci'),
                  _cpuCard(),
                  _frequencyCard(),
                  _cpuListCard(),
                  _section('Bellek'),
                  _ramCard(),
                  _section('Batarya'),
                  _batteryCard(),
                  _section('Termal'),
                  _thermalCard(),
                ],
              ),
            ),
    );
  }
}

class _MonitorSnapshot {
  final double cpuUsage;
  final int totalCpuCount;
  final int onlineCpuCount;

  final List<String> onlineCpus;
  final List<double> cpuFrequencies;

  final double ramTotal;
  final double ramAvailable;
  final double ramUsed;

  final int batteryLevel;
  final String batteryState;
  final String batterySource;
  final double? batteryTemperature;

  final Map<String, double> thermalZones;

  const _MonitorSnapshot({
    required this.cpuUsage,
    required this.totalCpuCount,
    required this.onlineCpuCount,
    required this.onlineCpus,
    required this.cpuFrequencies,
    required this.ramTotal,
    required this.ramAvailable,
    required this.ramUsed,
    required this.batteryLevel,
    required this.batteryState,
    required this.batterySource,
    required this.batteryTemperature,
    required this.thermalZones,
  });

  factory _MonitorSnapshot.empty() {
    return const _MonitorSnapshot(
      cpuUsage: 0,
      totalCpuCount: 0,
      onlineCpuCount: 0,
      onlineCpus: [],
      cpuFrequencies: [],
      ramTotal: 0,
      ramAvailable: 0,
      ramUsed: 0,
      batteryLevel: -1,
      batteryState: 'Bilinmiyor',
      batterySource: 'Bilinmiyor',
      batteryTemperature: null,
      thermalZones: {},
    );
  }
}

class _CpuSnapshot {
  final double usage;
  final int totalCount;
  final int onlineCount;
  final List<String> onlineCpus;

  const _CpuSnapshot({
    required this.usage,
    required this.totalCount,
    required this.onlineCount,
    required this.onlineCpus,
  });

  factory _CpuSnapshot.empty() {
    return const _CpuSnapshot(
      usage: 0,
      totalCount: 0,
      onlineCount: 0,
      onlineCpus: [],
    );
  }
}

class _RamSnapshot {
  final double total;
  final double available;
  final double used;

  const _RamSnapshot({
    required this.total,
    required this.available,
    required this.used,
  });

  factory _RamSnapshot.empty() {
    return const _RamSnapshot(
      total: 0,
      available: 0,
      used: 0,
    );
  }
}

class _BatterySnapshot {
  final int level;
  final String state;
  final String source;
  final double? temperature;

  const _BatterySnapshot({
    required this.level,
    required this.state,
    required this.source,
    required this.temperature,
  });

  factory _BatterySnapshot.empty() {
    return const _BatterySnapshot(
      level: -1,
      state: 'Bilinmiyor',
      source: 'Bilinmiyor',
      temperature: null,
    );
  }
}
