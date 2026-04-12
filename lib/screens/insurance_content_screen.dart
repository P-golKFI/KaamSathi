import 'package:flutter/material.dart';
import '../data/insurance_quiz_data.dart';
import '../l10n/app_localizations.dart';
import '../models/quiz_args.dart';
import '../theme/app_colors.dart';
import '../widgets/content_cards.dart';

class InsuranceContentScreen extends StatelessWidget {
  const InsuranceContentScreen({super.key});

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
                  AppColors.teal,
                  AppColors.teal.withValues(alpha: 0.72),
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
                        Icon(Icons.health_and_safety_outlined,
                            color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Insurance Made Simple',
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
                      'बीमा को समझें और अपने परिवार को सुरक्षित करें',
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
                  videoId: '75NOoijgjZE',
                  title: 'बीमा क्या है? Insurance की पूरी जानकारी',
                  channelName: 'Financial Literacy',
                ),
                const SizedBox(height: 16),
                const VideoCard(
                  videoId: 'hXS2l2R3jxo',
                  title: 'सरकारी बीमा योजनाएं: PMJJBY और PMSBY',
                  channelName: 'Government Schemes',
                ),
                const SizedBox(height: 24),
                const ContentSectionLabel(
                  icon: Icons.article_outlined,
                  label: 'Articles',
                ),
                const SizedBox(height: 12),
                const ArticleCard(
                  source: 'Aaj Tak',
                  title: 'PMJJBY और PMSBY: जानिए इन सरकारी बीमा योजनाओं के फायदे',
                  description:
                      'प्रधानमंत्री जीवन ज्योति बीमा योजना और प्रधानमंत्री सुरक्षा बीमा योजना के बारे में जानें',
                  url:
                      'https://www.aajtak.in/business/utility/story/pradhan-mantri-jeevan-jyoti-bima-yojana-pmjjby-pradhan-mantri-suraksha-bima-yojana-pmsby-benefits-details-tuta-2276329-2025-07-01',
                  language: 'हिंदी',
                ),
                const SizedBox(height: 12),
                const ArticleCard(
                  source: 'Josh Talks',
                  title: 'Insurance क्या है? बीमा की पूरी जानकारी हिंदी में',
                  description:
                      'बीमा के प्रकार, फायदे और अपने लिए सही बीमा चुनने का तरीका',
                  url:
                      'https://www.joshtalks.com/joshkosh/financial-literacy/insurance-in-hindi/',
                  language: 'हिंदी',
                ),
                const SizedBox(height: 32),
                RetakeQuizButton(
                  quizArgs: QuizArgs(
                    categoryTitle: AppLocalizations.of(context)!.categoryInsurance,
                    categoryIcon: Icons.health_and_safety_outlined,
                    questions: getInsuranceQuestions(
                        Localizations.localeOf(context).languageCode),
                    prefsKey: 'quiz_completed_insurance',
                    contentRoute: '/insurance',
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
