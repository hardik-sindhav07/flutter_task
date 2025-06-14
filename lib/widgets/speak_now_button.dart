import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../consts/assets.dart';
import '../theme/app_colors.dart';
import '../state/speech_provider.dart';

typedef VoidCallback = void Function();

class SpeakNowButton extends ConsumerWidget {
  final VoidCallback? onComplete;
  const SpeakNowButton({super.key, this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechState = ref.watch(speechProvider);
    ref.listen(speechProvider, (previous, next) {
      if (previous?.isListening == true &&
          next.isListening == false &&
          next.recognizedText.isNotEmpty) {
        onComplete?.call();
      }
    });
    return Center(
      child: GestureDetector(
        onTap: () => ref.read(speechProvider.notifier).startRecording(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: speechState.isListening
                ? AppColors.secondary
                : AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.mic.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: speechState.isListening
                  ? AppColors.primary
                  : AppColors.accent,
              width: 4,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              speechState.isListening
                  ? const SizedBox(
                      width: 40,
                      child: LoadingIndicator(
                        indicatorType: Indicator.lineScale,
                        colors: [Colors.white],
                        strokeWidth: 2,
                      ),
                    )
                  : Image.asset(
                      AppAssets.mic,
                      height: 60,
                      width: 60,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
