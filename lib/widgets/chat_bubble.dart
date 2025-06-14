import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_task/consts/assets.dart';
import '../utils/translate_api.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../state/speech_provider.dart';

class ChatBubble extends StatefulWidget {
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
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  String? text;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 200),
          () async {
        final translated = await translateToHindi(widget.translation ?? "");
        if (mounted) {
          setState(() {
            text = translated;
          });
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = BorderRadius.circular(20);
    final defaultBorderColor = widget.isUser
        ? AppColors.secondary.withOpacity(0.2)
        : AppColors.primary.withOpacity(0.15);
    final bgColor =
        widget.isUser ? AppColors.secondary.withOpacity(0.12) : AppColors.card;
    final textColor = widget.isUser ? AppColors.primary : AppColors.textPrimary;
    final align =
        widget.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final margin = widget.isUser
        ? const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8)
        : EdgeInsets.only(
            left: widget.avatar ? 8 : 66, right: 8, top: 8, bottom: 8);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (widget.avatar)
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
                borderRadius: widget.borderRadius ?? defaultBorderRadius,
                border: Border.all(
                    color: widget.borderColor ?? defaultBorderColor, width: 2),
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
                      widget.message,
                      style: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.translation != null) ...[
                      const SizedBox(height: 10),
                      const Divider(
                          color: AppColors.border, thickness: 1, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              text??"",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const _IconButton(icon: AppAssets.translateIcon),
                          const SizedBox(width: 8),
                          _SpeakerButton(
                              text: text??"",
                              id: widget.translation.hashCode.toString()),
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
  final String icon;
  const _IconButton({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent, width: 2)),
      child: SvgPicture.asset(icon),
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
        padding: const EdgeInsets.all(6),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent, width: 2)),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(6),
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                ),
              )
            : SvgPicture.asset(AppAssets.soundIcon),
      ),
    );
  }
}
