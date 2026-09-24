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
      MethodChannel('com.nevruz.stellarcenter/native');

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

  Map<String, String> _staticInfo = {};

  int _previousTotal = 0;
  int _previousIdle = 0;

  bool _loading = true;
  bool _refreshing = false;
  bool _collecting = false;

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

    _loadStaticInfo();
    _loadData();

    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        if (!_collecting && mounted) {
          _loadData();
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStaticInfo() async {
    if (!_isAndroid) {
      return;
    }

    try {
      final result =
          await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getDeviceInfo',
      );

      if (result == null || !mounted) {
        return;
      }

      final info = <String, String>{};

      result.forEach((key, value) {
        final keyString = key.toString();
        final valueString =
            value?.toString().trim() ?? '';

        if (valueString.isNotEmpty &&
            valueString != 'null') {
          info[keyString] = valueString;
        }
      });

      setState(() {
        _staticInfo = info;
      });
    } catch (_) {}
  }

  Future<void> _loadData() async {
    if (!mounted || _collecting) {
      return;
    }

    _collecting = true;

    try {
      final snapshot = await _collectSnapshot();

      if (!mounted) {
        return;
      }

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
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _refreshing = false;
      });
    } finally {
      _collecting = false;
    }
  }

  Future<void> _manualRefresh() async {
    if (_refreshing || _collecting) {
      return;
    }

    setState(() {
      _refreshing = true;
    });

    await _loadStaticInfo();
    await _loadData();
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
      final cpu = await _readProcCpu(
        readOnlineCpus: false,
      );

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
            data['battery_state']?.toString() ??
                batteryState;

        batterySource =
            data['battery_source']?.toString() ??
                batterySource;

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
              result['state']?.toString() ??
                  batteryState;

          batterySource =
              result['source']?.toString() ??
                  batterySource;

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
          onlineCpus.isNotEmpty
              ? onlineCpus.length
              : totalCpuCount,
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

  Future<_CpuSnapshot> _readProcCpu({
    bool readOnlineCpus = true,
  }) async {
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

      final parts =
          cpuLine.trim().split(RegExp(r'\s+'));

      if (parts.length < 5) {
        return _CpuSnapshot.empty();
      }

      final values = parts
          .sublist(1)
          .take(8)
          .map(
            (value) =>
                int.tryParse(value) ?? 0,
          )
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
        final totalDelta =
            total - _previousTotal;

        final idleDelta =
            idle - _previousIdle;

        if (totalDelta > 0) {
          usage =
              ((1 - idleDelta / totalDelta) *
                      100)
                  .clamp(0.0, 100.0)
                  .toDouble();
        }
      }

      _previousTotal = total;
      _previousIdle = idle;

      final cpuLines = lines
          .where(
            (line) =>
                RegExp(r'^cpu\d+\s')
                    .hasMatch(line),
          )
          .toList();

      final totalCount = cpuLines.length;

      List<String> online = [];

      if (readOnlineCpus) {
        final onlineFile = File(
          '/sys/devices/system/cpu/online',
        );

        if (await onlineFile.exists()) {
          final value =
              (await onlineFile.readAsString())
                  .trim();

          online = _expandCpuList(value);
        }

        if (online.isEmpty) {
          online = List.generate(
            totalCount,
            (index) => '$index',
          );
        }
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
        } else if (line.startsWith(
          'MemAvailable:',
        )) {
          availableKb = _extractKb(line);
        }
      }

      if (totalKb <= 0) {
        return _RamSnapshot.empty();
      }

      final total =
          totalKb / 1024 / 1024;

      final available =
          availableKb / 1024 / 1024;

      final used =
          (total - available)
              .clamp(0.0, total)
              .toDouble();

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
    final match =
        RegExp(r'\d+').firstMatch(line);

    return int.tryParse(
          match?.group(0) ?? '',
        ) ??
        0;
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
      final root =
          Directory('/sys/class/power_supply');

      if (!await root.exists()) {
        return _BatterySnapshot.empty();
      }

      final entries = root
          .listSync()
          .whereType<Directory>()
          .where(
            (entry) => entry.path
                .split('/')
                .last
                .startsWith('BAT'),
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
              (await capacity.readAsString())
                  .trim(),
            ) ??
            -1;
      }

      final status = File(
        '${battery.path}/status',
      );

      if (await status.exists()) {
        state =
            (await status.readAsString()).trim();
      }

      final temp = File(
        '${battery.path}/temp',
      );

      if (await temp.exists()) {
        final raw = double.tryParse(
          (await temp.readAsString()).trim(),
        );

        if (raw != null) {
          temperature =
              raw > 100 ? raw / 10 : raw;
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

  Future<Map<String, double>>
      _readLinuxThermal() async {
    final result = <String, double>{};

    try {
      final root =
          Directory('/sys/class/thermal');

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

        final nameFile = File(
          '${zone.path}/type',
        );

        String name =
            zone.path.split('/').last;

        if (await nameFile.exists()) {
          final type =
              (await nameFile.readAsString())
                  .trim();

          if (type.isNotEmpty) {
            name = type;
          }
        }

        result[name] =
            raw.abs() > 1000
                ? raw / 1000
                : raw;
      }
    } catch (_) {}

    return result;
  }

  List<String> _expandCpuList(String value) {
    final result = <String>[];

    for (final part
        in value.split(',')) {
      final item = part.trim();

      if (item.isEmpty) {
        continue;
      }

      if (item.contains('-')) {
        final pieces =
            item.split('-');

        if (pieces.length == 2) {
          final start =
              int.tryParse(pieces[0]);

          final end =
              int.tryParse(pieces[1]);

          if (start != null &&
              end != null &&
              end >= start) {
            for (int i = start;
                i <= end;
                i++) {
              result.add('$i');
            }
          }
        }
      } else {
        result.add(item);
      }
    }

    return result;
  }

  List<String> _parseOnlineCpus(dynamic value) {
    if (value == null) {
      return [];
    }

    if (value is List) {
      return value
          .map((item) => item.toString())
          .toList();
    }

    return _expandCpuList(
      value.toString(),
    );
  }

  List<double> _parseFrequencies(dynamic value) {
    if (value == null) {
      return [];
    }

    if (value is List) {
      return value
          .whereType<num>()
          .map((item) => item.toDouble())
          .toList();
    }

    return [];
  }

  Map<String, double> _parseThermalZones(
    dynamic value,
  ) {
    final result = <String, double>{};

    if (value is Map) {
      value.forEach((key, rawValue) {
        if (rawValue is num) {
          result[key.toString()] =
              rawValue.toDouble();
        }
      });
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _manualRefresh,
      child: CustomScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              32,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _header(),

                  if (_isAndroid) ...[
                    const SizedBox(height: 18),
                    _section('Cihaz'),
                    _staticInfoCard(),
                  ],

                  const SizedBox(height: 18),
                  _section('İşlemci'),
                  _cpuCard(),

                  const SizedBox(height: 14),
                  _frequencyCard(),

                  const SizedBox(height: 14),
                  _cpuListCard(),

                  const SizedBox(height: 18),
                  _section('Bellek'),
                  _ramCard(),

                  const SizedBox(height: 18),
                  _section('Batarya'),
                  _batteryCard(),

                  const SizedBox(height: 18),
                  _section('Termal'),
                  _thermalCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final scheme =
        Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'System Monitor',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _isAndroid
                    ? 'Android sistem durumu'
                    : 'Linux sistem durumu',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed:
              _refreshing ? null : _manualRefresh,
          tooltip: 'Yenile',
          icon: _refreshing
              ? const SizedBox(
                  width: 21,
                  height: 21,
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
    );
  }

  Widget _section(
    String title,
  ) {
    final scheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: scheme.primary,
        ),
      ),
    );
  }

  Widget _staticInfoCard() {
    if (!_isAndroid ||
        _staticInfo.isEmpty) {
      return const SizedBox.shrink();
    }

    final labels = <String, String>{
      'device': 'Cihaz',
      'model': 'Model',
      'product': 'Ürün',
      'brand': 'Marka',
      'manufacturer': 'Üretici',
      'hardware': 'Hardware',
      'board': 'Board',
      'bootloader': 'Bootloader',
      'fingerprint': 'Build Fingerprint',
      'display': 'Build Display',
      'host': 'Build Host',
      'id': 'Build ID',
      'type': 'Build Type',
      'user': 'Build User',
      'cpu_abi': 'CPU ABI',
      'supported_abis':
          'Desteklenen ABI',
      'cpu_count': 'CPU Çekirdeği',
      'sdk_int': 'SDK',
      'release': 'Android Sürümü',
      'incremental': 'Build Incremental',
      'security_patch':
          'Güvenlik Yaması',
      'soc_manufacturer':
          'SoC Üreticisi',
      'soc_model': 'SoC Modeli',
      'screen_width':
          'Ekran Genişliği',
      'screen_height':
          'Ekran Yüksekliği',
      'density':
          'Ekran Yoğunluğu',
      'refresh_rate':
          'Ekran Yenileme',
      'total_ram':
          'Toplam RAM',
      'available_ram':
          'Boş RAM',
      'total_storage':
          'Toplam Depolama',
      'available_storage':
          'Boş Depolama',
    };

    final entries =
        <MapEntry<String, String>>[];

    for (final entry
        in labels.entries) {
      final value =
          _staticInfo[entry.key];

      if (value != null &&
          value.isNotEmpty &&
          value != 'null') {
        entries.add(
          MapEntry(
            entry.value,
            value,
          ),
        );
      }
    }

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _title(
            'Cihaz Bilgileri',
            'Statik bilgiler',
            Icons.info_outline_rounded,
          ),
          const SizedBox(height: 16),
          ...entries.map(
            (entry) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 11,
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 145,
                      child: Text(
                        entry.key,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .onSurfaceVariant,
                        ),
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

  Widget _cpuCard() {
    final scheme =
        Theme.of(context).colorScheme;

    final usage =
        _cpuUsage.clamp(0.0, 100.0);

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _title(
            'CPU Kullanımı',
            'Canlı kullanım',
            Icons.memory_rounded,
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                '${usage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: scheme.primary,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 7,
                ),
                child: Text(
                  'CPU',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme
                        .onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: usage / 100,
              backgroundColor:
                  scheme.primary
                      .withOpacity(0.10),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  'Toplam',
                  '$_totalCpuCount çekirdek',
                  Icons.developer_board_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniStat(
                  'Aktif',
                  '$_onlineCpuCount çekirdek',
                  Icons.bolt_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _frequencyCard() {
    if (_cpuFrequencies.isEmpty) {
      return const SizedBox.shrink();
    }

    final scheme =
        Theme.of(context).colorScheme;

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _title(
            'CPU Frekansları',
            'Anlık çekirdek frekansları',
            Icons.speed_rounded,
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: List.generate(
              _cpuFrequencies.length,
              (index) {
                final mhz =
                    _cpuFrequencies[index] /
                        1000;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary
                        .withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color: scheme.primary
                          .withOpacity(0.12),
                    ),
                  ),
                  child: Text(
                    'CPU$index  ${mhz.toStringAsFixed(0)} MHz',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
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
            'Aktif CPU Çekirdekleri',
            'Online çekirdekler',
            Icons.grid_view_rounded,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _onlineCpus.map(
              (cpu) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Text(
                    'CPU $cpu',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
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

  Widget _ramCard() {
    final scheme =
        Theme.of(context).colorScheme;

    final percent =
        _ramTotal > 0
            ? (_ramUsed / _ramTotal)
                .clamp(0.0, 1.0)
                .toDouble()
            : 0.0;

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _title(
            'RAM',
            'Canlı bellek kullanımı',
            Icons.memory_rounded,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_ramUsed.toStringAsFixed(2)} GB',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight:
                        FontWeight.w900,
                    color: scheme.primary,
                  ),
                ),
              ),
              Text(
                '${_ramTotal.toStringAsFixed(2)} GB',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      scheme.onSurfaceVariant,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: percent,
              backgroundColor:
                  scheme.primary
                      .withOpacity(0.10),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  'Kullanılan',
                  '${_ramUsed.toStringAsFixed(2)} GB',
                  Icons.data_usage_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniStat(
                  'Boş',
                  '${_ramAvailable.toStringAsFixed(2)} GB',
                  Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _batteryCard() {
    final scheme =
        Theme.of(context).colorScheme;

    final level =
        _batteryLevel.clamp(0, 100);

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _title(
            'Batarya',
            'Güç durumu',
            Icons.battery_full_rounded,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                level <= 15
                    ? Icons.battery_alert_rounded
                    : Icons.battery_full_rounded,
                size: 42,
                color: level <= 15
                    ? Colors.redAccent
                    : scheme.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _batteryLevel >= 0
                      ? '$level%'
                      : 'Bilinmiyor',
                  style: const TextStyle(
                    fontSize: 29,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _batteryState,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      scheme.onSurfaceVariant,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  'Kaynak',
                  _batterySource,
                  Icons.power_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniStat(
                  'Sıcaklık',
                  _batteryTemperature != null
                      ? '${_batteryTemperature!.toStringAsFixed(1)} °C'
                      : 'Bilinmiyor',
                  Icons.thermostat_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _thermalCard() {
    final scheme =
        Theme.of(context).colorScheme;

    if (_thermalZones.isEmpty) {
      return _card(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _title(
              'Termal Bölgeler',
              'Sıcaklık sensörleri',
              Icons.thermostat_rounded,
            ),
            const SizedBox(height: 15),
            Text(
              'Termal sensör verisi bulunamadı.',
              style: TextStyle(
                fontSize: 13,
                color:
                    scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final entries =
        _thermalZones.entries.toList();

    entries.sort(
      (a, b) => a.key.compareTo(b.key),
    );

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _title(
            'Termal Bölgeler',
            'Canlı sıcaklık sensörleri',
            Icons.thermostat_rounded,
          ),
          const SizedBox(height: 15),
          ...entries.map(
            (entry) {
              final temperature =
                  entry.value;

              final hot =
                  temperature >= 60;

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 11,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.thermostat_rounded,
                      size: 21,
                      color: hot
                          ? Colors.redAccent
                          : scheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.key,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${temperature.toStringAsFixed(1)} °C',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w800,
                        color: hot
                            ? Colors.redAccent
                            : scheme.onSurface,
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

  Widget _miniStat(
    String title,
    String value,
    IconData icon,
  ) {
    final scheme =
        Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primary
            .withOpacity(0.055),
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: scheme.primary
              .withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: scheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: scheme
                        .onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(
    String title,
    String subtitle,
    IconData icon,
  ) {
    final scheme =
        Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: scheme.primary
                .withOpacity(0.09),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 21,
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: scheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({
    required Widget child,
  }) {
    final scheme =
        Theme.of(context).colorScheme;

    if (!_isGlass) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius:
              BorderRadius.circular(22),
          border: Border.all(
            color: scheme.outline
                .withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.04),
              blurRadius: 18,
              offset:
                  const Offset(0, 7),
            ),
          ],
        ),
        child: child,
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white
                .withOpacity(
              _isLightGlass
                  ? 0.34
                  : 0.08,
            ),
            borderRadius:
                BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white
                  .withOpacity(
                _isLightGlass
                    ? 0.48
                    : 0.14,
              ),
            ),
          ),
          child: child,
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
