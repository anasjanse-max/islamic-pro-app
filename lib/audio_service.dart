import 'dart:isolate';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;
  static ReceivePort? _receivePort;

  static bool get isPlaying => _isPlaying;

  // Cross-Isolate Communication Listener
  static void initIsolateListener() {
    try {
      IsolateNameServer.removePortNameMapping('azan_control_port');
      _receivePort = ReceivePort();
      IsolateNameServer.registerPortWithName(
          _receivePort!.sendPort, 'azan_control_port');

      _receivePort!.listen((message) {
        if (message == 'stop_azan') {
          stopAzan();
        }
      });
      debugPrint('AUDIO ISOLATE LISTENER INITIALIZED');
    } catch (e) {
      debugPrint('Isolate listener init error: $e');
    }
  }

  static Future<void> playAzan() async {
    try {
      debugPrint('================================');
      debugPrint('AZAN PLAY STARTED VIA AUDIO SERVICE');
      debugPrint('================================');

      if (_receivePort == null) {
        initIsolateListener();
      }

      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);

      await _player.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.duckOthers},
          ),
        ),
      );

      _player.onPlayerComplete.listen((event) {
        _isPlaying = false;
        debugPrint('AZAN AUDIO COMPLETED');
      });

      await _player.play(AssetSource('audio/azan.mp3'));
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
      debugPrint('AZAN PLAY ERROR: $e');
    }
  }

  static Future<void> stopAzan() async {
    try {
      debugPrint('================================');
      debugPrint('STOPPING AZAN VIA AUDIO SERVICE');
      debugPrint('================================');

      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('AZAN STOP ERROR: $e');
    }
  }

  static Future<void> pauseAzan() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('AZAN PAUSE ERROR: $e');
    }
  }

  static Future<void> resumeAzan() async {
    try {
      await _player.resume();
      _isPlaying = true;
    } catch (e) {
      debugPrint('AZAN RESUME ERROR: $e');
    }
  }

  static Future<void> dispose() async {
    await _player.dispose();
    _isPlaying = false;
  }
}