import 'dart:async';
import 'package:vapi/vapi.dart';
import 'package:e_team/core/config/app_secrets.dart';

enum HeraVoiceStatus { idle, connecting, listening, speaking, ended, error }

typedef VapiServiceListener = void Function();

class VapiService {
  static String get _publicKey => AppSecrets.vapiPublicKey;
  static String get _assistantId => AppSecrets.vapiAssistantId;

  late final VapiClient _client;
  VapiCall? _call;

  StreamSubscription<VapiEvent>? _eventSubscription;
  final List<VapiServiceListener> _listeners = [];

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

    _client = VapiClient(_publicKey);
    _initialized = true;
    _notifyListeners();
  }

  Future<void> start() async {
    try {
      if (!_initialized) {
        await init();
      }

      _status = HeraVoiceStatus.connecting;
      _errorMessage = '';
      _notifyListeners();

      _call = await _client.start(assistantId: _assistantId);

      await _eventSubscription?.cancel();
      _eventSubscription = _call!.onEvent.listen(_handleEvent);

      _notifyListeners();
    } catch (e) {
      _status = HeraVoiceStatus.error;
      _errorMessage = e.toString();
      _notifyListeners();
    }
  }

  void _handleEvent(VapiEvent event) {
    switch (event.label) {
      case 'call-start':
        _status = HeraVoiceStatus.listening;
        _notifyListeners();
        return;

      case 'call-end':
        _status = HeraVoiceStatus.ended;
        _notifyListeners();
        return;

      case 'speech-start':
        _status = HeraVoiceStatus.speaking;
        _notifyListeners();
        return;

      case 'speech-end':
        _status = HeraVoiceStatus.listening;
        _notifyListeners();
        return;

      case 'error':
        _status = HeraVoiceStatus.error;
        _errorMessage = event.value?.toString() ?? 'Erreur inconnue';
        _notifyListeners();
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

        _notifyListeners();
      }
    } catch (_) {
      return;
    }
  }

  Future<void> stop() async {
    try {
      await _call?.stop();
      _status = HeraVoiceStatus.ended;
      _notifyListeners();
    } catch (e) {
      _status = HeraVoiceStatus.error;
      _errorMessage = e.toString();
      _notifyListeners();
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
      _notifyListeners();

      await _call!.send({
        'type': 'add-message',
        'message': {'role': 'user', 'content': text.trim()},
      });
    } catch (e) {
      _status = HeraVoiceStatus.error;
      _errorMessage = e.toString();
      _notifyListeners();
    }
  }

  void reset() {
    _status = HeraVoiceStatus.idle;
    _lastUserTranscript = '';
    _lastAssistantTranscript = '';
    _errorMessage = '';
    _notifyListeners();
  }

  void addListener(VapiServiceListener listener) {
    if (_listeners.contains(listener)) return;
    _listeners.add(listener);
  }

  void removeListener(VapiServiceListener listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List<VapiServiceListener>.of(_listeners)) {
      listener();
    }
  }

  void dispose() {
    _eventSubscription?.cancel();
    _call?.dispose();
    _client.dispose();
    _listeners.clear();
  }
}
