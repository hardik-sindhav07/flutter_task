import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';

final List<Map<String, String>> fluencyQuestions = [
  {
    'en': "What's your name and where are you from?",
    'hi': "आपका नाम क्या है और आप कहाँ से हैं?",
  },
  {
    'en': "Why do you want to improve your English?",
    'hi': "आप अपनी अंग्रेजी क्यों सुधारना चाहते हैं?",
  },
  {
    'en': "Describe your favorite hobby or activity.",
    'hi': "अपने पसंदीदा शौक या गतिविधि का वर्णन करें।",
  },
  {
    'en': "Tell me about a memorable day in your life.",
    'hi': "अपने जीवन के एक यादगार दिन के बारे में बताइए।",
  },
  {
    'en': "What do you do for work or study?",
    'hi': "आप क्या काम करते हैं या क्या पढ़ाई करते हैं?",
  },
  {
    'en': "Who is someone you admire and why?",
    'hi': "ऐसा कौन है जिसे आप पसंद करते हैं और क्यों?",
  },
  {
    'en': "What are your goals for the next year?",
    'hi': "अगले साल के लिए आपके क्या लक्ष्य हैं?",
  },
];

final questionProvider = StateNotifierProvider<QuestionNotifier, int>((ref) => QuestionNotifier());

class QuestionNotifier extends StateNotifier<int> {
  QuestionNotifier() : super(0);

  void nextQuestion() {
    if (state < fluencyQuestions.length - 1) {
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
            state = state.copyWith(isListening: false);
          }
        },
        onError: (error) {
          state = state.copyWith(isListening: false, error: error.errorMsg);
        },
      );
      if (available) {
        state = state.copyWith(isListening: true, error: '');
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
  }

  void cancelRecording() {
    _speech.cancel();
    state = state.copyWith(isListening: false, recognizedText: '');
  }

  void clearError() {
    state = state.copyWith(error: '');
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
