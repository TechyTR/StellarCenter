import 'dart:io';

import 'package:flutter/material.dart';

import 'music_track.dart';

class StellarLyricsEditor {
  static Future<void> show(BuildContext context, StellarMusicTrack track) async {
    final path = track.lyricsPath ?? track.path.replaceFirst(RegExp(r'\.[^.]+, '.lrc');
    final file = File(path);
    String initial = '';
    try {
      if (await file.exists()) initial = await file.readAsString();
    } catch (_) {}
    if (!context.mounted) return;
    final controller = TextEditingController(text: initial);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF171D19),
        title: const Text('Şarkı sözlerini düzenle'),
        content: SizedBox(
          width: 620,
          child: TextField(
            controller: controller,
            minLines: 12,
            maxLines: 22,
            autofocus: true,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: const InputDecoration(
              hintText: '[00:12.00]Şarkı sözü satırı',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('İptal')),
          FilledButton(
            onPressed: () async {
              try {
                await file.parent.create(recursive: true);
                await file.writeAsString(controller.text, flush: true);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('LRC dosyası kaydedildi')));
              } catch (error) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Kaydedilemedi: $error')));
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}
), '.lrc');
    final file = File(path);
    String initial = '';
    try {
      if (await file.exists()) initial = await file.readAsString();
    } catch (_) {}
    if (!context.mounted) return;
    final controller = TextEditingController(text: initial);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF171D19),
        title: const Text('Şarkı sözlerini düzenle'),
        content: SizedBox(
          width: 620,
          child: TextField(
            controller: controller,
            minLines: 12,
            maxLines: 22,
            autofocus: true,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: const InputDecoration(
              hintText: '[00:12.00]Şarkı sözü satırı',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('İptal')),
          FilledButton(
            onPressed: () async {
              try {
                await file.parent.create(recursive: true);
                await file.writeAsString(controller.text, flush: true);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('LRC dosyası kaydedildi')));
              } catch (error) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Kaydedilemedi: $error')));
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}
