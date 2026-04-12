import 'package:flutter/material.dart';
import '../data/money_savings_quiz_data.dart';
import '../l10n/app_localizations.dart';
import '../models/quiz_args.dart';
import '../theme/app_colors.dart';
import '../widgets/content_cards.dart';

class MoneySavingsContentScreen extends StatelessWidget {
  const MoneySavingsContentScreen({super.key});

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
                  AppColors.orange,
                  AppColors.orange.withValues(alpha: 0.72),
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
                        Icon(Icons.savings_outlined,
                            color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Money & Savings',
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
                      'पैसे बचाने और समझदारी से खर्च करने के तरीके',
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
                  videoId: 'kywWhBXyFg0',
                  title: '9 Simple Ways to Save Money',
                  channelName: 'Finance Tips',
                ),
                const SizedBox(height: 16),
                const VideoCard(
                  videoId: '2zON7Xrl_fU',
                  title: 'UPI vs EMI',
                  channelName: 'Money Matters',
                ),
                const SizedBox(height: 16),
                VideoCard(
                  videoId: '51TM2IwzzIg',
                  title: 'How to Make UPI ID',
                  channelName: 'Digital Banking',
                  customThumbnailWidget: Container(
                    width: double.infinity,
                    height: 195,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.orange, AppColors.navyDark],
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_rounded,
                            size: 52, color: Colors.white),
                        SizedBox(height: 10),
                        Text(
                          'UPI ID बनाएं',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const ContentSectionLabel(
                  icon: Icons.article_outlined,
                  label: 'Articles',
                ),
                const SizedBox(height: 12),
                const ArticleCard(
                  source: 'Chegg India',
                  title: 'पैसे बचाने के 6 तरीके: कैसे करें अपने खर्चों को नियंत्रित?',
                  description:
                      '6 तरीके जो आपकी बचत बढ़ाने और खर्चों को नियंत्रित करने में मदद करेंगे',
                  url: 'https://www.cheggindia.com/hi/paise-bachane-ke-6-tarike/',
                  language: 'हिंदी',
                ),
                const SizedBox(height: 32),
                RetakeQuizButton(
                  quizArgs: QuizArgs(
                    categoryTitle: AppLocalizations.of(context)!.categoryMoneySavings,
                    categoryIcon: Icons.savings_outlined,
                    questions: getMoneySavingsQuestions(
                        Localizations.localeOf(context).languageCode),
                    prefsKey: 'quiz_completed_money_savings',
                    contentRoute: '/money-savings',
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
