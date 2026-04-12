import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/government_schemes_quiz_data.dart';
import '../data/insurance_quiz_data.dart';
import '../data/money_savings_quiz_data.dart';
import '../data/rights_at_work_quiz_data.dart';
import '../models/quiz_args.dart';
import '../models/self_help_category.dart';
import '../l10n/app_localizations.dart';

class SelfHelpScreen extends StatelessWidget {
  const SelfHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A3A5C), // navy
              Color(0xFF1A5C6B), // navy-teal blend
              Color(0xFF00897B), // teal-green
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
        children: [
          // Header (transparent — inherits background gradient)
          Container(
            width: double.infinity,
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
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.selfHelp,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.selfHelpSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
                children: selfHelpCategories
                    .map((cat) => _SelfHelpCategoryCard(category: cat))
                    .toList(),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _SelfHelpCategoryCard extends StatelessWidget {
  final SelfHelpCategory category;

  const _SelfHelpCategoryCard({required this.category});

  String _localizedTitle(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (category.id) {
      case 'rights_at_work':     return l.categoryRightsAtWork;
      case 'money_savings':      return l.categoryMoneySavings;
      case 'insurance':          return l.categoryInsurance;
      case 'government_schemes': return l.categoryGovernmentSchemes;
      default:                   return category.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          if (!context.mounted) return;

          final l = AppLocalizations.of(context)!;
          final locale = Localizations.localeOf(context).languageCode;

          if (category.id == 'rights_at_work') {
            final done =
                prefs.getBool('quiz_completed_rights_at_work') ?? false;
            if (done) {
              Navigator.pushNamed(context, '/rights-at-work');
            } else {
              Navigator.pushNamed(
                context,
                '/self-help-quiz',
                arguments: QuizArgs(
                  categoryTitle: l.categoryRightsAtWork,
                  categoryIcon: Icons.shield_outlined,
                  questions: getRightsAtWorkQuestions(locale),
                  prefsKey: 'quiz_completed_rights_at_work',
                  contentRoute: '/rights-at-work',
                ),
              );
            }
          } else if (category.id == 'money_savings') {
            final done =
                prefs.getBool('quiz_completed_money_savings') ?? false;
            if (done) {
              Navigator.pushNamed(context, '/money-savings');
            } else {
              Navigator.pushNamed(
                context,
                '/self-help-quiz',
                arguments: QuizArgs(
                  categoryTitle: l.categoryMoneySavings,
                  categoryIcon: Icons.savings_outlined,
                  questions: getMoneySavingsQuestions(locale),
                  prefsKey: 'quiz_completed_money_savings',
                  contentRoute: '/money-savings',
                ),
              );
            }
          } else if (category.id == 'insurance') {
            final done =
                prefs.getBool('quiz_completed_insurance') ?? false;
            if (done) {
              Navigator.pushNamed(context, '/insurance');
            } else {
              Navigator.pushNamed(
                context,
                '/self-help-quiz',
                arguments: QuizArgs(
                  categoryTitle: l.categoryInsurance,
                  categoryIcon: Icons.health_and_safety_outlined,
                  questions: getInsuranceQuestions(locale),
                  prefsKey: 'quiz_completed_insurance',
                  contentRoute: '/insurance',
                ),
              );
            }
          } else if (category.id == 'government_schemes') {
            final done =
                prefs.getBool('quiz_completed_government_schemes') ?? false;
            if (done) {
              Navigator.pushNamed(context, '/government-schemes');
            } else {
              Navigator.pushNamed(
                context,
                '/self-help-quiz',
                arguments: QuizArgs(
                  categoryTitle: l.categoryGovernmentSchemes,
                  categoryIcon: Icons.account_balance_outlined,
                  questions: getGovernmentSchemesQuestions(locale),
                  prefsKey: 'quiz_completed_government_schemes',
                  contentRoute: '/government-schemes',
                ),
              );
            }
          } else {
            Navigator.pushNamed(
              context,
              '/self-help-detail',
              arguments: category,
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category.color,
                category.color.withValues(alpha: 0.72),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: category.color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  category.icon,
                  size: 32,
                  color: Colors.white,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _localizedTitle(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
