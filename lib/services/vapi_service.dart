import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vapi/vapi.dart';

enum HeraVoiceStatus {
  idle,
  connecting,
  listening,
  speaking,
  ended,
  error,
}

class VapiService extends ChangeNotifier {
  static const String publicKey = '39a7bfbe-4e8f-4e51-b7d8-ff1b96e57df0';
  static const String assistantId = '575504d6-a203-40e8-b75d-e47f15c68091';

  late final VapiClient _client;
  VapiCall? _call;

  StreamSubscription<VapiEvent>? _eventSubscription;

  HeraVoiceStatus _status = HeraVoiceStatus.idle;
  HeraVoiceStatus get status => _status;

  String _lastUserTranscript = '';
  String get lastUserTranscript => _lastUserTranscript;

  String _lastAssistantTranscript = '';
  String get lastAssistantTranscript => _lastAssistantTranscript;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _initialized = false;

  bool get isActive =>
      _status == HeraVoiceStatus.connecting ||
      _status == HeraVoiceStatus.listening ||
      _status == HeraVoiceStatus.speaking;

  Future<void> init() async {
    if (_initialized) return;

    _client = VapiClient(publicKey);
    _initialized = true;
    notifyListeners();
  }

  Future<void> start() async {
    try {
      if (!_initialized) {
        await init();
      }

      _status = HeraVoiceStatus.connecting;
      _errorMessage = '';
      notifyListeners();

      _call = await _client.start(assistantId: assistantId);

      await _eventSubscription?.cancel();
      _eventSubscription = _call!.onEvent.listen(_handleEvent);

      notifyListeners();
    } catch (e) {
      _status = HeraVoiceStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _handleEvent(VapiEvent event) {
    debugPrint('VAPI EVENT => ${event.label}');
    debugPrint('VAPI VALUE => ${event.value}');

    switch (event.label) {
      case 'call-start':
        _status = HeraVoiceStatus.listening;
        notifyListeners();
        return;

      case 'call-end':
        _status = HeraVoiceStatus.ended;
        notifyListeners();
        return;

      case 'speech-start':
        _status = HeraVoiceStatus.speaking;
        notifyListeners();
        return;

      case 'speech-end':
        _status = HeraVoiceStatus.listening;
        notifyListeners();
        return;

      case 'error':
        _status = HeraVoiceStatus.error;
        _errorMessage = event.value?.toString() ?? 'Erreur inconnue';
        notifyListeners();
        return;

      case 'message':
        _handleMessage(event.value);
        return;
    }
  }

  void _handleMessage(dynamic value) {
    try {
      if (value is! Map) return;

      final type = value['type']?.toString() ?? '';

      if (type == 'transcript') {
        final role = value['role']?.toString() ?? '';
        final transcript = value['transcript']?.toString() ?? '';

        if (transcript.trim().isEmpty) return;

        if (role == 'user') {
          _lastUserTranscript = transcript;
        } else if (role == 'assistant') {
          _lastAssistantTranscript = transcript;
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Transcript parse error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _call?.stop();
      _status = HeraVoiceStatus.ended;
      notifyListeners();
    } catch (e) {
      _status = HeraVoiceStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    if (isActive) {
      await stop();
    } else {
      await start();
    }
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty || _call == null) return;

    try {
      _lastUserTranscript = text.trim();
      notifyListeners();

      await _call!.send({
        'type': 'add-message',
        'message': {
          'role': 'user',
          'content': text.trim(),
        },
      });
    } catch (e) {
      _status = HeraVoiceStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void reset() {
    _status = HeraVoiceStatus.idle;
    _lastUserTranscript = '';
    _lastAssistantTranscript = '';
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _call?.dispose();
    _client.dispose();
    super.dispose();
  }
}
