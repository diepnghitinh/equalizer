import 'dart:async';

import 'package:flutter/services.dart';

enum CONTENT_TYPE { MUSIC, MOVIE, GAME, VOICE }

class Equalizer {
  static const MethodChannel _channel = const MethodChannel('equalizer');

  static StreamController<String> _presetChangeListener;

  /// Listens to preset change events. This will fire when [setPreset] is invoked.
  static Stream<String> get onPresetChanged => _presetChangeListener.stream;

  /// Open's the device equalizer.
  ///
  /// - [audioSessionId] enable audio effects for the current session.
  /// - [contentType] optional parameter. Defaults to [CONTENT_TYPE.MUSIC]
  ///
  /// [android]:
  /// https://developer.android.com/reference/android/media/MediaPlayer#getAudioSessionId()
  static Future<void> open(int audioSessionId,
      [CONTENT_TYPE contentType = CONTENT_TYPE.MUSIC]) async {
    await _channel.invokeMethod(
      'open',
      {'audioSessionId': audioSessionId, 'contentType': contentType.index},
    );
  }

  /// Set [audioSessionId] for equalizer.
  ///
  /// [android]:
  /// https://developer.android.com/reference/android/media/MediaPlayer#getAudioSessionId()
  static Future<void> setAudioSessionId(int audioSessionId) async {
    await _channel.invokeMethod('setAudioSessionId', audioSessionId);
  }

  /// Remove current [audioSessionId] for equalizer.
  static Future<void> removeAudioSessionId(int audioSessionId) async {
    await _channel.invokeMethod('removeAudioSessionId', audioSessionId);
  }

  /// Initialize a custom equalizer.
  ///
  /// [audioSessionId] enable audio effects for the current session.
  static Future<void> init(int audioSessionId) async {
    _presetChangeListener = StreamController<String>.broadcast();
    await _channel.invokeMethod('init', audioSessionId);
  }

  /// Release the custom equalizer resources.
  static Future<void> release() async {
    _presetChangeListener?.close();
    await _channel.invokeMethod('release');
  }

  /// Enable/disable a custom equalizer.
  static Future<void> setEnabled(bool enabled) async {
    await _channel.invokeMethod('enable', enabled);
  }

  /// Returns the band level range in a list of integers represented in [dB].
  /// The first element is
  /// the lower limit of the range, the second element the upper limit.
  static Future<List<int>> getBandLevelRange() async {
    return (await _channel.invokeMethod('getBandLevelRange')).cast<int>();
  }

  /// Returns the band level in [dB].
  static Future<int> getBandLevel(int bandId) async {
    return await _channel.invokeMethod('getBandLevel', bandId);
  }

  /// Set the band level for a custom equalizer.
  ///
  /// - [bandId] can be retrieved from [getCenterBandFreqs]
  /// - [level] can be retrieved from [getBandLevel]
  static Future<void> setBandLevel(int bandId, int level) async {
    await _channel.invokeMethod(
      'setBandLevel',
      {'bandId': bandId, 'level': level},
    );
  }

  /// Returns the center band frequencies in milliHertz.
  static Future<List<int>> getCenterBandFreqs() async {
    return (await _channel.invokeMethod('getCenterBandFreqs')).cast<int>();
  }

  /// Returns the preset names.
  static Future<List<String>> getPresetNames() async {
    return (await _channel.invokeMethod('getPresetNames')).cast<String>();
  }

  /// Set the preset name.
  static Future<void> setPreset(String presetName) async {
    _channel.invokeMethod('setPreset', presetName);
    _presetChangeListener.add(presetName);
  }
}
