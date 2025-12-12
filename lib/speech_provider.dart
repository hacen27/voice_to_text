import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class StaticLocaleName {
  final String localeId;
  final String name;
  const StaticLocaleName(this.localeId, this.name);
}

class SpeechProvider with ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  StaticLocaleName? _selectedLocale;
  final List<StaticLocaleName> _locales = const [
    StaticLocaleName('en_US', 'English'),
    StaticLocaleName('fr_FR', 'Français'),
    StaticLocaleName('ar_SA', 'العربية'),
    StaticLocaleName('ru_RU', 'Русский'),
  ];
  bool _isListening = false;

  SpeechProvider() {
    _initSpeech();
  }

  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;
  StaticLocaleName? get selectedLocale => _selectedLocale;
  List<StaticLocaleName> get locales => _locales;
  bool get isListening => _isListening;

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) => log('Error initializing speech: $error'),
      onStatus: (status) => _handleStatusChange(status),
    );
    _selectedLocale = _locales.first;
    notifyListeners();
  }

  void startListening() {
    if (!_speechEnabled || _isListening) return;
    _lastWords = '';
    _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: _selectedLocale?.localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
    );
    _isListening = true;
    notifyListeners();
  }

  void stopListening() {
    if (!_speechEnabled || !_isListening) return;
    _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    notifyListeners();
  }

  void _handleStatusChange(String status) {
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      notifyListeners();
    }
  }

  void selectLocale(StaticLocaleName? locale) {
    if (locale != null) {
      _selectedLocale = locale;
      log('Langue sélectionnée: ${locale.localeId}');
      notifyListeners();
    }
  }

  void clearText() {
    _lastWords = '';
    notifyListeners();
  }
}
