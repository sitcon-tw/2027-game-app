import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sitcon_backend/game/game_service.dart';

class RecapShareService {
  /// Opens the system chooser; never selects a destination or publishes.
  static Future<void> share(
    GlobalKey boundaryKey, {
    required String title,
  }) async {
    await WidgetsBinding.instance.endOfFrame;
    final boundary = boundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary || !boundary.hasSize) {
      throw GameStateError(const GameMessage('shareNotReady'));
    }
    final image = await boundary.toImage(
      pixelRatio: 1080 / boundary.size.width,
    );
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw GameStateError(const GameMessage('shareFailed'));
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/sitcon-recap-${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      try {
        await SharePlus.instance.share(
          ShareParams(
            title: title,
            files: [XFile(file.path, mimeType: 'image/png')],
            sharePositionOrigin:
                boundary.localToGlobal(Offset.zero) & boundary.size,
          ),
        );
      } finally {
        if (await file.exists()) await file.delete();
      }
    } finally {
      image.dispose();
    }
  }
}
