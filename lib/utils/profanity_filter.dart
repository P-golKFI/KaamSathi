/// Lightweight client-side profanity filter.
///
/// Checks whether [text] contains any banned word.
/// Strips non-alphanumeric characters first to catch simple evasions
/// like "sh!t" or "f_ck".
bool containsProfanity(String text) {
  final cleaned = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '');
  return _bannedWords.any((word) => cleaned.contains(word));
}

/// Add or remove words here as needed.
/// Includes common English profanity and Hindi transliterations.
const Set<String> _bannedWords = {
  // English
  'fuck', 'fuk', 'fck', 'shit', 'shyt', 'bitch', 'btch',
  'asshole', 'ass', 'bastard', 'cunt', 'cock', 'dick', 'pussy',
  'whore', 'slut', 'nigger', 'nigga', 'faggot', 'fag',
  'motherfucker', 'mofo', 'piss', 'crap', 'damn', 'retard',
  'idiot', 'stupid', 'loser',

  // Hindi transliterations (Roman script)
  'chutiya', 'chutia', 'choot', 'bhosda', 'bhosdike', 'madarchod',
  'bhadwa', 'randi', 'harami', 'kamine', 'gaand', 'lund', 'lavda',
  'saala', 'sala', 'behen', 'maa', 'teri maa', 'bc', 'mc',
  'bhenchod', 'behenchod', 'gandu', 'hijra', 'kutte', 'kutta',
  'suar', 'ullu', 'bakwas',
};
