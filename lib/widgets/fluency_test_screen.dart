import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'chat_bubble.dart';
import 'speak_now_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/speech_provider.dart';
import 'fluency_header.dart';

class FluencyTestScreen extends ConsumerStatefulWidget {
  const FluencyTestScreen({super.key});

  @override
  ConsumerState<FluencyTestScreen> createState() => _FluencyTestScreenState();
}

class _FluencyTestScreenState extends ConsumerState<FluencyTestScreen> {
  bool _initialized = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      Future.microtask(() {
        final chatNotifier = ref.read(chatProvider.notifier);
        // Add the intro card only once
        chatNotifier.addMessage(ChatMessage(
          text: "Hey! I'm Ostello. Let get to know your fluency in English",
          translation:
              "नमस्ते?! मैं ओस्टेलो हूँ  चलिए आपकी इंग्लिश फ्लुएंसी को थोड़ा बेहतर जानते हैं",
          isUser: false,
          avatar: true,
          name: 'Ostello',
        ));
        // Add the first question only once
        final question = fluencyQuestions[0];
        chatNotifier.addMessage(ChatMessage(
          text: question['en']!,
          translation: question['hi'],
          isUser: false,
          avatar: false,
        ));
        _scrollToBottom();
      });
      _initialized = true;
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final speechState = ref.watch(speechProvider);
    final questionIndex = ref.watch(questionProvider);
    final chatHistory = ref.watch(chatProvider);
    final isLast = questionIndex == fluencyQuestions.length - 1;
    final chatNotifier = ref.read(chatProvider.notifier);

    // Scroll to bottom when chatHistory changes
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 0, right: 0),
              child: FluencyHeader(questionIndex: questionIndex),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemCount: chatHistory.length,
                  itemBuilder: (context, index) {
                    final msg = chatHistory[index];
                    return Align(
                      alignment: msg.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                          minWidth: 80,
                        ),
                        child: ChatBubble(
                          message: msg.text,
                          translation: msg.translation,
                          isUser: msg.isUser,
                          avatar: msg.avatar,
                          name: msg.name,
                          borderRadius: BorderRadius.circular(24),
                          borderColor: AppColors.primary.withOpacity(0.13),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            SpeakNowButton(
              onComplete: () {
                // Add user answer to chat
                if (speechState.recognizedText.isNotEmpty) {
                  chatNotifier.addMessage(ChatMessage(
                    text: speechState.recognizedText,
                    isUser: true,
                  ));
                }
                if (!isLast) {
                  // Add next question to chat
                  final nextIndex = questionIndex + 1;
                  if (nextIndex < fluencyQuestions.length) {
                    final nextQ = fluencyQuestions[nextIndex];
                    chatNotifier.addMessage(ChatMessage(
                      text: nextQ['en']!,
                      translation: nextQ['hi'],
                      isUser: false,
                      avatar: false,
                    ));
                  }
                  ref.read(questionProvider.notifier).nextQuestion();
                  ref.read(speechProvider.notifier).cancelRecording();
                }
                _scrollToBottom();
              },
            ),
            const SizedBox(height: 24),
            Text(
              speechState.isListening ? 'Speak Now' : 'Tap to Speak',
              style: AppTextStyles.heading.copyWith(color: AppColors.primary,fontFamily: 'Flamante'),
            ),
            const SizedBox(height: 8),
            Text(
              "Speak naturally. There's no right or wrong",
              style: AppTextStyles.body.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            Text(
              "स्वाभाविक रूप से बोलिए | इसमें सही या गलत कुछ नहीं है",
              style: AppTextStyles.body
                  .copyWith(color: AppColors.primary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
