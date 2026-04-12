import 'package:flutter/material.dart';
import '../data/rights_at_work_quiz_data.dart';
import '../l10n/app_localizations.dart';
import '../models/quiz_args.dart';
import '../theme/app_colors.dart';
import '../widgets/content_cards.dart';

class RightsAtWorkContentScreen extends StatelessWidget {
  const RightsAtWorkContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navyDark, AppColors.navyBlue],
              ),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined,
                            color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Your Rights at Work',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Videos and articles to help you know your rights',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                ContentSectionLabel(
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Video',
                ),
                SizedBox(height: 12),
                VideoCard(
                  videoId: 'QcVPILsV84Q',
                  title: 'Top 10 Labour Laws in India for Employees',
                  channelName: 'Labour Law Advisor',
                ),
                SizedBox(height: 24),
                ContentSectionLabel(
                  icon: Icons.article_outlined,
                  label: 'Articles',
                ),
                SizedBox(height: 12),
                ArticleCard(
                  source: 'News24 Hindi',
                  title:
                      'जानें अपने अधिकार — सरकारी और प्राइवेट कर्मचारियों के संवैधानिक अधिकार',
                  description:
                      'Public & private sector employee rights under the Indian Constitution',
                  url:
                      'https://hindi.news24online.com/india/know-your-rights-public-private-sector-employees-rights-according-to-indian-constitution/363707/',
                ),
                SizedBox(height: 12),
                const ArticleCard(
                  source: 'Drishti IAS',
                  title: 'श्रम के लिए सही संहिता',
                  description:
                      'Labour code reforms and what they mean for workers',
                  url:
                      'https://www.drishtiias.com/hindi/daily-updates/daily-news-editorials/right-code-for-labour',
                ),
                const SizedBox(height: 32),
                RetakeQuizButton(
                  quizArgs: QuizArgs(
                    categoryTitle: AppLocalizations.of(context)!.categoryRightsAtWork,
                    categoryIcon: Icons.shield_outlined,
                    questions: getRightsAtWorkQuestions(
                        Localizations.localeOf(context).languageCode),
                    prefsKey: 'quiz_completed_rights_at_work',
                    contentRoute: '/rights-at-work',
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
