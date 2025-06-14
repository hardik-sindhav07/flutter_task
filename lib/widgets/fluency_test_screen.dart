import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_task/consts/assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'chat_bubble.dart';
import 'speak_now_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/speech_provider.dart';
import 'fluency_header.dart';
import '../api/evaluate_api.dart';
import '../pages/fluency_result_screen.dart';
import 'package:translator/translator.dart';
import 'package:dio/dio.dart';

class FluencyTestScreen extends ConsumerStatefulWidget {
  const FluencyTestScreen({super.key});

  @override
  ConsumerState<FluencyTestScreen> createState() => _FluencyTestScreenState();
}

class _FluencyTestScreenState extends ConsumerState<FluencyTestScreen> {
  bool _initialized = false;
  final ScrollController _scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialization will be handled after questions are loaded
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

  int bottomIndex = 0;
  @override
  Widget build(BuildContext context) {
    final speechState = ref.watch(speechProvider);
    final questionIndex = ref.watch(questionProvider);
    final chatHistory = ref.watch(chatProvider);
    final isLast = ref.watch(questionProvider) ==
        (ref
                .watch(questionsFutureProvider)
                .maybeWhen(data: (q) => q.data?.length ?? 0, orElse: () => 0) -
            1);
    final chatNotifier = ref.read(chatProvider.notifier);
    final questionsAsync = ref.watch(questionsFutureProvider);

    // Scroll to bottom when chatHistory changes
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return questionsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Failed to load questions: $e')),
      ),
      data: (questionsModel) {
        final questions = questionsModel.data ?? [];
        // Add intro and first question only once
        if (!_initialized && questions.isNotEmpty) {
          Future.microtask(() {
            chatNotifier.addMessage(ChatMessage(
              text: "Hey! I'm Ostello. Let get to know your fluency in English",
              translation:
                  "नमस्ते?! मैं ओस्टेलो हूँ  चलिए आपकी इंग्लिश फ्लुएंसी को थोड़ा बेहतर जानते हैं",
              isUser: false,
              avatar: true,
              name: 'Ostello',
            ));
            chatNotifier.addMessage(ChatMessage(
              text: questions[0].questionText ?? '',
              translation: questions[0].questionText ?? '',
              isUser: false,
              avatar: false,
            ));
          });
          _initialized = true;
        }
        return Scaffold(
          backgroundColor: AppColors.backgroundGrey,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 0, right: 0),
                  child: FluencyHeader(
                      questionIndex: questionIndex,
                      totalQuestions: questions.length),
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
                bottomIndex == 0
                    ? Card(
                        shadowColor: AppColors.accent,
                        color: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)),
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        bottomIndex = 2;
                                      });
                                    },
                                    child: Card(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          side: const BorderSide(
                                              width: 3,
                                              color: AppColors.accent,
                                              style: BorderStyle.solid)),
                                      child: SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                          child: SvgPicture.asset(
                                              AppAssets.keyboardIcon),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  SpeakNowButton(
                                    onComplete: () async {
                                      await Future.delayed(
                                          const Duration(milliseconds: 100));
                                      final latestText = ref
                                          .read(speechProvider)
                                          .recognizedText;
                                      if (latestText.isNotEmpty) {
                                        chatNotifier.addMessage(ChatMessage(
                                          text: latestText,
                                          isUser: true,
                                        ));
                                        final questionText =
                                            questions[questionIndex]
                                                    .questionText ??
                                                '';
                                        final responseText = latestText;
                                        final expectedResponseText =
                                            questions[questionIndex]
                                                    .suggestedResponseHint ??
                                                '';
                                        final durationMs = ref
                                            .read(speechProvider.notifier)
                                            .lastDurationMs;
                                        try {
                                          final dio = Dio();
                                          final evaluateApi = EvaluateApi(dio);
                                          final result = await evaluateApi.evaluate(
                                            EvaluateRequest(
                                              questionText: questionText,
                                              responseText: responseText,
                                              durationMs: durationMs,
                                              expectedResponseText:
                                                  expectedResponseText,
                                            ),
                                            "Bearer <your_token>",
                                          );
                                          final evalResult =
                                              EvaluationResult.fromJson(
                                                  result.data);
                                          ref
                                              .read(evaluationResultsProvider
                                                  .notifier)
                                              .addResult(evalResult);
                                          if (isLast) {
                                            final allResults = ref.read(
                                                evaluationResultsProvider);
                                            int avgVocabulary = (allResults
                                                        .map(
                                                            (e) => e.vocabulary)
                                                        .fold(0,
                                                            (a, b) => a + b) /
                                                    allResults.length)
                                                .round();
                                            int avgSpeakingFlow = (allResults
                                                        .map((e) =>
                                                            e.speakingFlow)
                                                        .fold(0,
                                                            (a, b) => a + b) /
                                                    allResults.length)
                                                .round();
                                            int avgPronunciation = (allResults
                                                        .map((e) =>
                                                            e.pronunciation)
                                                        .fold(0,
                                                            (a, b) => a + b) /
                                                    allResults.length)
                                                .round();
                                            int avgGrammar = (allResults
                                                        .map((e) => e.grammar)
                                                        .fold(0,
                                                            (a, b) => a + b) /
                                                    allResults.length)
                                                .round();
                                            String finalLevel =
                                                allResults.isNotEmpty
                                                    ? allResults.last.level
                                                    : 'Intermediate';
                                            await Future.delayed(const Duration(
                                                milliseconds: 300));
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LevelScreen(
                                                  level: finalLevel,
                                                  vocabulary: avgVocabulary,
                                                  speakingFlow: avgSpeakingFlow,
                                                  pronunciation:
                                                      avgPronunciation,
                                                  grammar: avgGrammar,
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          // ScaffoldMessenger.of(context).showSnackBar(
                                          //   SnackBar(content: Text('Evaluation: ' + result.data.toString())),
                                          // );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Evaluation failed: $e')),
                                          );
                                        }
                                      }
                                      if (!isLast) {
                                        // Add next question to chat
                                        final nextIndex = questionIndex + 1;
                                        if (nextIndex < questions.length) {
                                          final nextQ = questions[nextIndex];
                                          chatNotifier.addMessage(ChatMessage(
                                            text: nextQ.questionText ?? '',
                                            translation:
                                                nextQ.questionText ?? '',
                                            isUser: false,
                                            avatar: false,
                                          ));
                                        }
                                        ref
                                            .read(questionProvider.notifier)
                                            .nextQuestion(questions.length);
                                        ref
                                            .read(speechProvider.notifier)
                                            .cancelRecording();
                                      }
                                      _scrollToBottom();
                                    },
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        bottomIndex = 1;
                                      });
                                    },
                                    child: Card(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          side: const BorderSide(
                                              width: 3,
                                              color: AppColors.accent,
                                              style: BorderStyle.solid)),
                                      child: SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                          child: SvgPicture.asset(
                                              AppAssets.hintIcon),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                speechState.isListening
                                    ? 'Speak Now'
                                    : 'Tap to Speak',
                                style: AppTextStyles.heading.copyWith(
                                    color: AppColors.primary,
                                    fontFamily: 'Flamante'),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Speak naturally. There's no right or wrong",
                                style: AppTextStyles.body
                                    .copyWith(color: AppColors.primary),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "स्वाभाविक रूप से बोलिए | इसमें सही या गलत कुछ नहीं है",
                                style: AppTextStyles.body.copyWith(
                                    color: AppColors.primary, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      )
                    : bottomIndex == 1
                        ? Card(
                            shadowColor: AppColors.accent,
                            color: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30)),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    'Speak the below sentence',
                                    style: AppTextStyles.subheading.copyWith(
                                        color: AppColors.primary,
                                        fontFamily: 'Flamante'),
                                  ),
                                  const SizedBox(height: 10),
                                  Card(
                                    color: AppColors.background,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: const BorderSide(
                                            color: AppColors.accent, width: 2)),
                                    child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.2,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 16),
                                          child: FutureBuilder<String>(
                                            future: translateToLang(
                                              questions.last
                                                      .suggestedResponseHint ??
                                                  "",
                                              ref.read(languageProvider),
                                            ),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2)),
                                                );
                                              }
                                              if (snapshot.hasError) {
                                                return Text(
                                                  questions.last
                                                          .suggestedResponseHint ??
                                                      "",
                                                  style: AppTextStyles
                                                      .subheading
                                                      .copyWith(
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontFamily: 'Flamante',
                                                  ),
                                                );
                                              }
                                              return Column(
                                                children: [
                                                  Text(
                                                    questions.last
                                                            .suggestedResponseHint ??
                                                        "",
                                                    style: AppTextStyles
                                                        .subheading
                                                        .copyWith(
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontFamily: 'Flamante',
                                                    ),
                                                  ),
                                                  Text(
                                                    snapshot.data ?? "",
                                                    style: AppTextStyles
                                                        .progress
                                                        .copyWith(
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontFamily: 'Flamante',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        )),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Spacer(),
                                      FutureBuilder<String>(
                                          future: translateToLang(
                                            questions.last
                                                    .suggestedResponseHint ??
                                                "",
                                            ref.read(languageProvider),
                                          ),
                                          builder: (context, snapshot) {
                                            return GestureDetector(
                                              onTap: () async {
                                                ref
                                                    .read(ttsProvider.notifier)
                                                    .speak(
                                                      snapshot.data??"",
                                                      language: 'hi-IN',
                                                      id: '9999',
                                                    );
                                              },
                                              child: Card(
                                                color: AppColors.primary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                                child: SizedBox(
                                                  height: 40,
                                                  width: 40,
                                                  child: Center(
                                                    child: SvgPicture.asset(
                                                      AppAssets.soundIcon,
                                                      height: 22,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                      const Spacer(),
                                      SpeakNowButton(
                                        onComplete: () async {
                                          await Future.delayed(const Duration(
                                              milliseconds: 100));
                                          final latestText = ref
                                              .read(speechProvider)
                                              .recognizedText;
                                          if (latestText.isNotEmpty) {
                                            chatNotifier.addMessage(ChatMessage(
                                              text: latestText,
                                              isUser: true,
                                            ));
                                            final questionText =
                                                questions[questionIndex]
                                                        .questionText ??
                                                    '';
                                            final responseText = latestText;
                                            final expectedResponseText =
                                                questions[questionIndex]
                                                        .suggestedResponseHint ??
                                                    '';
                                            final durationMs = ref
                                                .read(speechProvider.notifier)
                                                .lastDurationMs;
                                            try {
                                              final dio = Dio();
                                              final evaluateApi = EvaluateApi(dio);
                                              final result = await evaluateApi.evaluate(
                                                EvaluateRequest(
                                                  questionText: questionText,
                                                  responseText: responseText,
                                                  durationMs: durationMs,
                                                  expectedResponseText:
                                                      expectedResponseText,
                                                ),
                                                "Bearer <your_token>",
                                              );
                                              final evalResult =
                                                  EvaluationResult.fromJson(
                                                      result.data);
                                              ref
                                                  .read(
                                                      evaluationResultsProvider
                                                          .notifier)
                                                  .addResult(evalResult);
                                              if (isLast) {
                                                final allResults = ref.read(
                                                    evaluationResultsProvider);
                                                int avgVocabulary = (allResults
                                                            .map((e) =>
                                                                e.vocabulary)
                                                            .fold(
                                                                0,
                                                                (a, b) =>
                                                                    a + b) /
                                                        allResults.length)
                                                    .round();
                                                int avgSpeakingFlow = (allResults
                                                            .map((e) =>
                                                                e.speakingFlow)
                                                            .fold(
                                                                0,
                                                                (a, b) =>
                                                                    a + b) /
                                                        allResults.length)
                                                    .round();
                                                int avgPronunciation = (allResults
                                                            .map((e) =>
                                                                e.pronunciation)
                                                            .fold(
                                                                0,
                                                                (a, b) =>
                                                                    a + b) /
                                                        allResults.length)
                                                    .round();
                                                int avgGrammar = (allResults
                                                            .map((e) =>
                                                                e.grammar)
                                                            .fold(
                                                                0,
                                                                (a, b) =>
                                                                    a + b) /
                                                        allResults.length)
                                                    .round();
                                                String finalLevel =
                                                    allResults.isNotEmpty
                                                        ? allResults.last.level
                                                        : 'Intermediate';
                                                await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 300));
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        LevelScreen(
                                                      level: finalLevel,
                                                      vocabulary: avgVocabulary,
                                                      speakingFlow:
                                                          avgSpeakingFlow,
                                                      pronunciation:
                                                          avgPronunciation,
                                                      grammar: avgGrammar,
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              // ScaffoldMessenger.of(context).showSnackBar(
                                              //   SnackBar(content: Text('Evaluation: ' + result.data.toString())),
                                              // );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Evaluation failed: $e')),
                                              );
                                            }
                                          }
                                          if (!isLast) {
                                            // Add next question to chat
                                            final nextIndex = questionIndex + 1;
                                            if (nextIndex < questions.length) {
                                              final nextQ =
                                                  questions[nextIndex];
                                              chatNotifier
                                                  .addMessage(ChatMessage(
                                                text: nextQ.questionText ?? '',
                                                translation:
                                                    nextQ.questionText ?? '',
                                                isUser: false,
                                                avatar: false,
                                              ));
                                            }
                                            ref
                                                .read(questionProvider.notifier)
                                                .nextQuestion(questions.length);
                                            ref
                                                .read(speechProvider.notifier)
                                                .cancelRecording();
                                          }
                                          _scrollToBottom();
                                        },
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            bottomIndex = 0;
                                          });
                                        },
                                        child: Card(
                                          color: Colors.grey,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: const SizedBox(
                                            height: 40,
                                            width: 40,
                                            child: Center(
                                              child: Icon(
                                                Icons.close_rounded,
                                                color: AppColors.background,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          )
                        : Card(
                            shadowColor: AppColors.accent,
                            color: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30)),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const SizedBox(width: 5),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            bottomIndex = 0;
                                          });
                                        },
                                        child: Card(
                                          color: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: SizedBox(
                                            height: 40,
                                            width: 40,
                                            child: Center(
                                              child: Image.asset(
                                                AppAssets.mic,
                                                height: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        color: AppColors.background,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            side: const BorderSide(
                                                color: AppColors.accent,
                                                width: 2)),
                                        child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.5,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                      horizontal: 10),
                                              child: TextField(
                                                controller:
                                                    textEditingController,
                                                decoration: null,
                                                onChanged: (value) {
                                                  ref
                                                      .read(speechProvider
                                                          .notifier)
                                                      .updateRecognizedText(
                                                          value);
                                                },
                                              ),
                                            )),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          if (speechState
                                              .recognizedText.isNotEmpty) {
                                            chatNotifier.addMessage(ChatMessage(
                                              text: speechState.recognizedText,
                                              isUser: true,
                                            ));
                                            final questionText =
                                                questions[questionIndex]
                                                        .questionText ??
                                                    '';
                                            final responseText =
                                                speechState.recognizedText;
                                            final expectedResponseText =
                                                questions[questionIndex]
                                                        .suggestedResponseHint ??
                                                    '';
                                            final durationMs = ref
                                                .read(speechProvider.notifier)
                                                .lastDurationMs;
                                            try {
                                              final dio = Dio();
                                              final evaluateApi = EvaluateApi(dio);
                                              final result = await evaluateApi.evaluate(
                                                EvaluateRequest(
                                                  questionText: questionText,
                                                  responseText: responseText,
                                                  durationMs: durationMs,
                                                  expectedResponseText:
                                                      expectedResponseText,
                                                ),
                                                "Bearer <your_token>", // Replace with your actual token
                                              );
                                              final evalResult =
                                                  EvaluationResult.fromJson(
                                                      result.data);
                                              ref
                                                  .read(
                                                      evaluationResultsProvider
                                                          .notifier)
                                                  .addResult(evalResult);
                                              if (isLast) {
                                                final allResults = ref.read(
                                                    evaluationResultsProvider);
                                                int avgVocabulary = (allResults
                                                            .map((e) =>
                                                                e.vocabulary)
                                                            .fold(
                                                                0,
                                                                (a, b) =>
                                                                    a + b) /
                                                        allResults.length)
                                                    .round();
                                                int avgSpeakingFlow = (allResults
                                                            .map((e) =>
                                                                e.speakingFlow)
                                                            .fold(
                                                                0,
                                                                (a, b) =>
                                                                    a + b) /
                                                        allResults.length)
                                                    .round();
                                                int avgPronunciation = (allResults
                                                            .map((e) =>
                                                                e.pronunciation)
                                                            .fold(
                                                                0,
                                                                (a, b) =>
                                                                    a + b) /
                                                        allResults.length)
                                                    .round();
                                                int avgGrammar = (allResults
                                                            .map((e) =>
                                                                e.grammar)
                                                            .fold(
                                                                0,
                                                                (a, b) =>
                                                                    a + b) /
                                                        allResults.length)
                                                    .round();
                                                String finalLevel =
                                                    allResults.isNotEmpty
                                                        ? allResults.last.level
                                                        : 'Intermediate';
                                                await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 300));
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        LevelScreen(
                                                      level: finalLevel,
                                                      vocabulary: avgVocabulary,
                                                      speakingFlow:
                                                          avgSpeakingFlow,
                                                      pronunciation:
                                                          avgPronunciation,
                                                      grammar: avgGrammar,
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              // ScaffoldMessenger.of(context).showSnackBar(
                                              //   SnackBar(content: Text('Evaluation: ' + result.data.toString())),
                                              // );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Evaluation failed: $e')),
                                              );
                                            }
                                          }
                                          if (!isLast) {
                                            // Add next question to chat
                                            final nextIndex = questionIndex + 1;
                                            if (nextIndex < questions.length) {
                                              final nextQ =
                                                  questions[nextIndex];
                                              chatNotifier
                                                  .addMessage(ChatMessage(
                                                text: nextQ.questionText ?? '',
                                                translation:
                                                    nextQ.questionText ?? '',
                                                isUser: false,
                                                avatar: false,
                                              ));
                                            }
                                            ref
                                                .read(questionProvider.notifier)
                                                .nextQuestion(questions.length);
                                            ref
                                                .read(speechProvider.notifier)
                                                .cancelRecording();
                                          }
                                          _scrollToBottom();
                                          setState(() {
                                            textEditingController.clear();
                                          });
                                        },
                                        child: Card(
                                          color:
                                              textEditingController.text.isEmpty
                                                  ? Colors.grey
                                                  : AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: SizedBox(
                                            height: 40,
                                            width: 40,
                                            child: Center(
                                              child: SvgPicture.asset(
                                                AppAssets.sendIcon,
                                                height: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<String> translateToLang(String text, String targetLang) async {
  final translator = GoogleTranslator();
  var translation =
      await translator.translate(text, from: 'en', to: targetLang);
  return translation.text;
}
