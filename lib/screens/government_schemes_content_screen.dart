import 'package:flutter/material.dart';
import '../data/government_schemes_quiz_data.dart';
import '../l10n/app_localizations.dart';
import '../models/quiz_args.dart';
import '../theme/app_colors.dart';
import '../widgets/content_cards.dart';

class GovernmentSchemesContentScreen extends StatelessWidget {
  const GovernmentSchemesContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.navyBlue,
                  AppColors.navyBlue.withValues(alpha: 0.72),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(28)),
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
                        Icon(Icons.account_balance_outlined,
                            color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Government Schemes for You',
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
                      'सरकारी योजनाओं का लाभ उठाएं',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
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
                const ContentSectionLabel(
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Videos',
                ),
                const SizedBox(height: 12),
                const VideoCard(
                  videoId: 'SToefGBjhbM',
                  title: 'सरकारी योजनाएं',
                  channelName: 'Government Schemes',
                ),
                const SizedBox(height: 16),
                const VideoCard(
                  videoId: 'jgrsPMvH1fc',
                  title: 'सरकारी योजनाएं',
                  channelName: 'Government Schemes',
                ),
                const SizedBox(height: 16),
                const VideoCard(
                  videoId: 'J8oTuUxAnL0',
                  title: 'सरकारी योजनाएं',
                  channelName: 'Government Schemes',
                ),
                const SizedBox(height: 24),
                const ContentSectionLabel(
                  icon: Icons.article_outlined,
                  label: 'Articles',
                ),
                const SizedBox(height: 12),
                const ArticleCard(
                  source: 'Yojana Portal',
                  title: 'Ayushman Bharat Yojana — आयुष्मान भारत योजना',
                  description:
                      'आयुष्मान भारत प्रधानमंत्री जन आरोग्य योजना के तहत ₹5 लाख तक का मुफ्त इलाज',
                  url: 'https://www.yojnaportal.com/scheme/ayushman-bharat-yojana/',
                  language: 'हिंदी',
                ),
                const SizedBox(height: 12),
                const ArticleCard(
                  source: 'IIGA',
                  title: 'E-Shram Card 2025 — ई-श्रम कार्ड',
                  description:
                      'असंगठित क्षेत्र के मजदूरों के लिए ई-श्रम कार्ड के फायदे और आवेदन प्रक्रिया',
                  url: 'https://iiga.in/e-shram-card-2025/',
                  language: 'हिंदी',
                ),
                const SizedBox(height: 32),
                RetakeQuizButton(
                  quizArgs: QuizArgs(
                    categoryTitle: AppLocalizations.of(context)!.categoryGovernmentSchemes,
                    categoryIcon: Icons.account_balance_outlined,
                    questions: getGovernmentSchemesQuestions(
                        Localizations.localeOf(context).languageCode),
                    prefsKey: 'quiz_completed_government_schemes',
                    contentRoute: '/government-schemes',
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
