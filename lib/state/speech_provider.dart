import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../api/questions_api.dart';
import '../models/questions_model.dart';
import 'package:dio/dio.dart';

final questionProvider = StateNotifierProvider<QuestionNotifier, int>((ref) => QuestionNotifier());

class QuestionNotifier extends StateNotifier<int> {
  QuestionNotifier() : super(0);

  void nextQuestion(int maxIndex) {
    if (state < maxIndex - 1) {
      state++;
    }
  }

  void reset() {
    state = 0;
  }
}

final speechProvider = StateNotifierProvider<SpeechNotifier, SpeechState>(
    (ref) => SpeechNotifier());

class SpeechState {
  final bool isListening;
  final String recognizedText;
  final bool hasPermission;
  final String error;
  SpeechState({
    this.isListening = false,
    this.recognizedText = '',
    this.hasPermission = false,
    this.error = '',
  });

  SpeechState copyWith({
    bool? isListening,
    String? recognizedText,
    bool? hasPermission,
    String? error,
  }) =>
      SpeechState(
        isListening: isListening ?? this.isListening,
        recognizedText: recognizedText ?? this.recognizedText,
        hasPermission: hasPermission ?? this.hasPermission,
        error: error ?? this.error,
      );
}

class SpeechNotifier extends StateNotifier<SpeechState> {
  late stt.SpeechToText _speech;
  DateTime? _startTime;
  int lastDurationMs = 0;
  SpeechNotifier() : super(SpeechState()) {
    _speech = stt.SpeechToText();
    checkPermission();
  }

  Future<void> checkPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      state = state.copyWith(hasPermission: true);
    } else {
      final result = await Permission.microphone.request();
      state = state.copyWith(hasPermission: result.isGranted);
    }
  }

  Future<void> startRecording() async {
    await checkPermission();
    if (!state.hasPermission) {
      state = state.copyWith(error: 'Microphone permission denied');
      return;
    }
    if (!state.isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            stopRecording();
          }
        },
        onError: (error) {
          state = state.copyWith(isListening: false, error: error.errorMsg);
        },
      );
      if (available) {
        state = state.copyWith(isListening: true, error: '');
        _startTime = DateTime.now();
        _speech.listen(
          onResult: (result) {
            state = state.copyWith(recognizedText: result.recognizedWords);
          },
        );
      } else {
        state = state.copyWith(error: 'Speech recognition unavailable');
      }
    } else {
      stopRecording();
    }
  }

  void stopRecording() {
    _speech.stop();
    state = state.copyWith(isListening: false);
    if (_startTime != null) {
      lastDurationMs = DateTime.now().difference(_startTime!).inMilliseconds;
      _startTime = null;
    }
  }

  void cancelRecording() {
    _speech.cancel();
    state = state.copyWith(isListening: false, recognizedText: '');
  }

  void clearError() {
    state = state.copyWith(error: '');
  }

  void updateRecognizedText(String value) {
    state = state.copyWith(recognizedText: value);
  }
}

final ttsProvider = StateNotifierProvider<TtsNotifier, TtsState>((ref) => TtsNotifier());

class TtsState {
  final bool isSpeaking;
  final String? speakingId;
  TtsState({this.isSpeaking = false, this.speakingId});

  TtsState copyWith({bool? isSpeaking, String? speakingId}) => TtsState(
        isSpeaking: isSpeaking ?? this.isSpeaking,
        speakingId: speakingId ?? this.speakingId,
      );
}

class TtsNotifier extends StateNotifier<TtsState> {
  final FlutterTts _tts = FlutterTts();
  TtsNotifier() : super(TtsState()) {
    _tts.setCompletionHandler(() {
      state = state.copyWith(isSpeaking: false, speakingId: null);
    });
    _tts.setCancelHandler(() {
      state = state.copyWith(isSpeaking: false, speakingId: null);
    });
  }

  Future<void> speak(String text, {String language = 'hi-IN', String? id}) async {
    await _tts.setLanguage(language);
    state = state.copyWith(isSpeaking: true, speakingId: id);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    state = state.copyWith(isSpeaking: false, speakingId: null);
  }
}

class ChatMessage {
  final String text;
  final String? translation;
  final bool isUser;
  final bool avatar;
  final String? name;
  ChatMessage({
    required this.text,
    this.translation,
    this.isUser = false,
    this.avatar = false,
    this.name,
  });
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) => ChatNotifier());

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void clear() {
    state = [];
  }
}

final questionsFutureProvider = FutureProvider<QuestionsModel>((ref) async {
  final dio = Dio();
  final questionsApi = QuestionsApi(dio);
  return await questionsApi.fetchQuestions();
});

class EvaluationResult {
  final String level;
  final int vocabulary;
  final int speakingFlow;
  final int pronunciation;
  final int grammar;

  EvaluationResult({
    required this.level,
    required this.vocabulary,
    required this.speakingFlow,
    required this.pronunciation,
    required this.grammar,
  });

  factory EvaluationResult.fromJson(Map<String, dynamic> data) {
    return EvaluationResult(
      level: data['level'] ?? 'Intermediate',
      vocabulary: data['vocabulary'] ?? 60,
      speakingFlow: data['speaking_flow'] ?? 90,
      pronunciation: data['pronunciation'] ?? 70,
      grammar: data['grammar'] ?? 40,
    );
  }
}

class EvaluationResultsNotifier extends StateNotifier<List<EvaluationResult>> {
  EvaluationResultsNotifier() : super([]);

  void addResult(EvaluationResult result) {
    state = [...state, result];
  }

  void clear() {
    state = [];
  }
}

final evaluationResultsProvider =
    StateNotifierProvider<EvaluationResultsNotifier, List<EvaluationResult>>(
        (ref) => EvaluationResultsNotifier());

final languageProvider = StateProvider<String>((ref) => 'hi');
