import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/quiz_args.dart';
import '../theme/app_colors.dart';

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class ContentSectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const ContentSectionLabel({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.navyBlue),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.navyBlue,
          ),
        ),
      ],
    );
  }
}

class VideoCard extends StatelessWidget {
  final String videoId;
  final String title;
  final String channelName;
  final Widget? customThumbnailWidget;

  const VideoCard({
    super.key,
    required this.videoId,
    required this.title,
    required this.channelName,
    this.customThumbnailWidget,
  });

  String get _thumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  String get _videoUrl => 'https://www.youtube.com/watch?v=$videoId';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with play overlay
          GestureDetector(
            onTap: () => openUrl(_videoUrl),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (customThumbnailWidget != null)
                  customThumbnailWidget!
                else
                  Image.network(
                    _thumbnailUrl,
                    width: double.infinity,
                    height: 195,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 195,
                        color: AppColors.greyLight,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.teal,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 195,
                      color: AppColors.greyLight,
                      child: const Icon(Icons.play_circle_outline,
                          size: 48, color: AppColors.textGrey),
                    ),
                  ),
                Container(
                  width: double.infinity,
                  height: 195,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 34,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Info + button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyBlue,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.smart_display_outlined,
                        size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '$channelName  •  YouTube',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => openUrl(_videoUrl),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Watch on YouTube',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final String source;
  final String title;
  final String description;
  final String url;
  final String language;

  const ArticleCard({
    super.key,
    required this.source,
    required this.title,
    required this.description,
    required this.url,
    this.language = 'हिंदी',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  language,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.article_outlined,
                  size: 14, color: AppColors.textGrey),
              const SizedBox(width: 4),
              Text(
                source,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.navyBlue,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => openUrl(url),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.navyBlue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.navyBlue.withValues(alpha: 0.15),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Read Article',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyBlue,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                      size: 16, color: AppColors.navyBlue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RetakeQuizButton extends StatelessWidget {
  final QuizArgs quizArgs;
  const RetakeQuizButton({super.key, required this.quizArgs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(quizArgs.prefsKey, false);
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/self-help-quiz',
          arguments: quizArgs,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.navyBlue.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 16, color: AppColors.navyBlue),
            SizedBox(width: 8),
            Text(
              'Take the quiz again',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.navyBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
