import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task/consts/assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../state/speech_provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String? translation;
  final bool isUser;
  final bool avatar;
  final String? name;
  final BorderRadius? borderRadius;
  final Color? borderColor;

  const ChatBubble({
    super.key,
    required this.message,
    this.translation,
    this.isUser = false,
    this.avatar = false,
    this.name,
    this.borderRadius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = BorderRadius.circular(20);
    final defaultBorderColor = isUser
        ? AppColors.secondary.withOpacity(0.2)
        : AppColors.primary.withOpacity(0.15);
    final bgColor =
        isUser ? AppColors.secondary.withOpacity(0.12) : AppColors.card;
    final textColor = isUser ? AppColors.primary : AppColors.textPrimary;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final margin = isUser
        ? const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8)
        : EdgeInsets.only(left: avatar ? 8 : 66, right: 8, top: 8, bottom: 8);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (avatar)
          Padding(
            padding: const EdgeInsets.only(right: 0, top: 8, left: 8),
            child: Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  image: DecorationImage(image: AssetImage(AppAssets.logo))),
            ),
          ),
        Flexible(
          child: IntrinsicWidth(
            child: Container(
              margin: margin,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: borderRadius ?? defaultBorderRadius,
                border: Border.all(
                    color: borderColor ?? defaultBorderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: align,
                  children: [
                    // Main message
                    Text(
                      message,
                      style: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (translation != null) ...[
                      const SizedBox(height: 10),
                      const Divider(
                          color: AppColors.border, thickness: 1, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              translation!,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const _IconButton(icon: Icons.translate),
                          const SizedBox(width: 8),
                          _SpeakerButton(
                              text: translation!,
                              id: translation.hashCode.toString()),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  const _IconButton({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.progressBg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.secondary, size: 18),
    );
  }
}

class _SpeakerButton extends ConsumerWidget {
  final String text;
  final String id;
  const _SpeakerButton({required this.text, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsState = ref.watch(ttsProvider);
    final isLoading = ttsState.isSpeaking && ttsState.speakingId == id;
    return GestureDetector(
      onTap: () =>
          ref.read(ttsProvider.notifier).speak(text, language: 'hi-IN', id: id),
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.progressBg,
          shape: BoxShape.circle,
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(6),
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                ),
              )
            : const Icon(Icons.volume_up, color: AppColors.secondary, size: 18),
      ),
    );
  }
}
