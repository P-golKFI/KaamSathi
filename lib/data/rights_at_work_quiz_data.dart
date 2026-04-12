class QuizQuestion {
  final String question;
  final List<String> choices;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.choices,
    required this.correctIndex,
  });
}

// ── English ───────────────────────────────────────────────────────────────────

const _rightsAtWorkEn = <QuizQuestion>[
  QuizQuestion(
    question:
        'If you work in a factory, how many hours can your employer legally ask you to work in a day?',
    choices: ['8 hours', '12 hours', 'As many as they want', '10 hours'],
    correctIndex: 0,
  ),
  QuizQuestion(
    question:
        'If you get hurt while doing your job, who should pay for your treatment?',
    choices: [
      'You pay yourself',
      'Your employer pays',
      'Government pays',
      'Nobody pays',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'Can your employer fire you without any notice?',
    choices: [
      'Yes, anytime',
      'Only if you made a mistake',
      'No, they must give notice or pay',
      'Only on weekends',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question:
        'How much minimum wage should a worker get per day in India (approximately)?',
    choices: [
      '₹100',
      '₹50',
      'There is no minimum wage',
      '₹178 or more (depends on state)',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'Are women allowed to work night shifts in factories?',
    choices: [
      'Yes, with proper safety measures',
      'No, never',
      "Only with husband's permission",
      'Only in government factories',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'If your employer is not paying you on time, what can you do?',
    choices: [
      'Nothing, just wait',
      'Only ask politely',
      'Complain to Labour Commissioner',
      'Leave the job quietly',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question:
        'How many paid holidays (national holidays) must your employer give you in a year?',
    choices: [
      'None',
      'Only Sundays',
      '30 days',
      'At least 3–5 national holidays',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'Can a contractor/thekedar pay you less than the minimum wage?',
    choices: [
      'No, minimum wage applies to all workers',
      'Yes, contractors have different rules',
      'Only if you agreed to it',
      "Contractors don't have to follow rules",
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'What is BOCW Act related to?',
    choices: [
      'Bank workers',
      'Computer workers',
      "Construction workers' welfare",
      'Bus operators',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question:
        'If your workplace is unsafe (no helmet, no safety gear), what should you do?',
    choices: [
      'Just be careful yourself',
      'Report to factory inspector / labour officer',
      'Quit the job',
      'Wear your own safety gear',
    ],
    correctIndex: 1,
  ),
];

// ── Hindi ─────────────────────────────────────────────────────────────────────

const _rightsAtWorkHi = <QuizQuestion>[
  QuizQuestion(
    question:
        'अगर आप किसी कारखाने में काम करते हैं, तो मालिक एक दिन में कानूनी तौर पर कितने घंटे काम करवा सकता है?',
    choices: ['8 घंटे', '12 घंटे', 'जितना चाहे', '10 घंटे'],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'काम करते समय चोट लगने पर इलाज का खर्चा कौन उठाएगा?',
    choices: ['आप खुद', 'आपका मालिक', 'सरकार', 'कोई नहीं'],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'क्या मालिक बिना नोटिस के आपको नौकरी से निकाल सकता है?',
    choices: [
      'हाँ, कभी भी',
      'केवल गलती करने पर',
      'नहीं, नोटिस या मुआवज़ा देना होगा',
      'केवल छुट्टी के दिन',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question:
        'भारत में एक मजदूर को एक दिन में कम से कम कितनी मजदूरी मिलनी चाहिए (लगभग)?',
    choices: [
      '₹100',
      '₹50',
      'कोई न्यूनतम मजदूरी नहीं है',
      '₹178 या उससे ज़्यादा (राज्य के हिसाब से)',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'क्या महिलाएं कारखानों में रात की शिफ्ट में काम कर सकती हैं?',
    choices: [
      'हाँ, उचित सुरक्षा के साथ',
      'नहीं, कभी नहीं',
      'केवल पति की अनुमति से',
      'केवल सरकारी कारखानों में',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question:
        'अगर मालिक समय पर तनख्वाह नहीं दे रहा, तो आप क्या कर सकते हैं?',
    choices: [
      'कुछ नहीं, बस इंतज़ार करें',
      'केवल विनम्रता से पूछें',
      'लेबर कमिश्नर से शिकायत करें',
      'चुपचाप नौकरी छोड़ दें',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question:
        'एक साल में मालिक को कम से कम कितनी राष्ट्रीय छुट्टियाँ (paid) देनी चाहिए?',
    choices: [
      'एक भी नहीं',
      'केवल रविवार',
      '30 दिन',
      'कम से कम 3–5 राष्ट्रीय छुट्टियाँ',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'क्या कोई ठेकेदार आपको न्यूनतम मजदूरी से कम दे सकता है?',
    choices: [
      'नहीं, सभी मजदूरों पर न्यूनतम मजदूरी लागू होती है',
      'हाँ, ठेकेदारों के अलग नियम हैं',
      'केवल अगर आपने सहमति दी हो',
      'ठेकेदारों को नियम नहीं मानने पड़ते',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'BOCW Act किससे संबंधित है?',
    choices: [
      'बैंक कर्मचारी',
      'कंप्यूटर कर्मचारी',
      'निर्माण मजदूरों की भलाई',
      'बस चालक',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question:
        'अगर कार्यस्थल असुरक्षित है (हेलमेट नहीं, सुरक्षा उपकरण नहीं), तो क्या करना चाहिए?',
    choices: [
      'खुद ही सावधान रहें',
      'फैक्ट्री इंस्पेक्टर / लेबर ऑफिसर को रिपोर्ट करें',
      'नौकरी छोड़ दें',
      'खुद के सुरक्षा उपकरण पहनें',
    ],
    correctIndex: 1,
  ),
];

// ── Bengali ───────────────────────────────────────────────────────────────────

const _rightsAtWorkBn = <QuizQuestion>[
  QuizQuestion(
    question:
        'আপনি যদি কোনো কারখানায় কাজ করেন, তাহলে মালিক আইনত একদিনে কত ঘণ্টা কাজ করাতে পারেন?',
    choices: ['৮ ঘণ্টা', '১২ ঘণ্টা', 'যত খুশি', '১০ ঘণ্টা'],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'কাজ করতে গিয়ে আঘাত পেলে চিকিৎসার খরচ কে দেবে?',
    choices: ['আপনি নিজে', 'আপনার মালিক', 'সরকার', 'কেউ না'],
    correctIndex: 1,
  ),
  QuizQuestion(
    question:
        'মালিক কি কোনো নোটিশ ছাড়াই আপনাকে চাকরি থেকে বরখাস্ত করতে পারেন?',
    choices: [
      'হ্যাঁ, যেকোনো সময়',
      'শুধু ভুল করলে',
      'না, নোটিশ বা ক্ষতিপূরণ দিতে হবে',
      'শুধু ছুটির দিনে',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question:
        'ভারতে একজন শ্রমিকের প্রতিদিন কত ন্যূনতম মজুরি পাওয়া উচিত (আনুমানিক)?',
    choices: [
      '₹১০০',
      '₹৫০',
      'কোনো ন্যূনতম মজুরি নেই',
      '₹১৭৮ বা তার বেশি (রাজ্য অনুযায়ী)',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'মহিলারা কি কারখানায় রাতের শিফটে কাজ করতে পারেন?',
    choices: [
      'হ্যাঁ, যথাযথ নিরাপত্তার সাথে',
      'না, কখনোই না',
      'শুধু স্বামীর অনুমতিতে',
      'শুধু সরকারি কারখানায়',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'মালিক সময়মতো মজুরি না দিলে আপনি কী করতে পারেন?',
    choices: [
      'কিছুই না, অপেক্ষা করুন',
      'শুধু ভদ্রভাবে জিজ্ঞেস করুন',
      'লেবার কমিশনারের কাছে অভিযোগ করুন',
      'চুপচাপ চাকরি ছেড়ে দিন',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'বছরে মালিককে কমপক্ষে কতটি জাতীয় ছুটি (paid) দিতে হবে?',
    choices: [
      'কোনোটিই না',
      'শুধু রবিবার',
      '৩০ দিন',
      'কমপক্ষে ৩–৫টি জাতীয় ছুটি',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'কোনো ঠিকাদার কি আপনাকে ন্যূনতম মজুরির কম দিতে পারেন?',
    choices: [
      'না, সব শ্রমিকের জন্য ন্যূনতম মজুরি প্রযোজ্য',
      'হ্যাঁ, ঠিকাদারদের আলাদা নিয়ম আছে',
      'শুধু যদি আপনি রাজি হন',
      'ঠিকাদারদের নিয়ম মানতে হয় না',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'BOCW আইন কীসের সাথে সম্পর্কিত?',
    choices: [
      'ব্যাংক কর্মী',
      'কম্পিউটার কর্মী',
      'নির্মাণ শ্রমিকদের কল্যাণ',
      'বাস চালক',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question:
        'কর্মক্ষেত্র অনিরাপদ হলে (হেলমেট নেই, নিরাপত্তা সরঞ্জাম নেই) আপনি কী করবেন?',
    choices: [
      'নিজেই সাবধান থাকুন',
      'ফ্যাক্টরি ইন্সপেক্টর/লেবার অফিসারকে জানান',
      'চাকরি ছেড়ে দিন',
      'নিজের নিরাপত্তা সরঞ্জাম পরুন',
    ],
    correctIndex: 1,
  ),
];

// ── Nepali ────────────────────────────────────────────────────────────────────

const _rightsAtWorkNe = <QuizQuestion>[
  QuizQuestion(
    question:
        'यदि तपाईं कुनै कारखानामा काम गर्नुहुन्छ भने, मालिकले कानुनी रूपमा एक दिनमा कति घण्टा काम गराउन सक्छ?',
    choices: ['८ घण्टा', '१२ घण्टा', 'जति मन लागे', '१० घण्टा'],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'काम गर्दा चोट लागेमा उपचारको खर्च को उठाउँछ?',
    choices: ['तपाईं आफैं', 'तपाईंको मालिक', 'सरकार', 'कोही पनि होइन'],
    correctIndex: 1,
  ),
  QuizQuestion(
    question:
        'के मालिकले कुनै सूचना नदिई तपाईंलाई जागिरबाट निकाल्न सक्छ?',
    choices: [
      'हो, जुनसुकै बेला',
      'गल्ती गरेमा मात्र',
      'होइन, सूचना वा क्षतिपूर्ति दिनुपर्छ',
      'बिदाको दिन मात्र',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question:
        'भारतमा एक मजदुरले प्रतिदिन कम्तीमा कति ज्याला पाउनुपर्छ (लगभग)?',
    choices: [
      '₹१००',
      '₹५०',
      'न्यूनतम ज्याला छैन',
      '₹१७८ वा सोभन्दा बढी (राज्य अनुसार)',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'के महिलाहरू कारखानाहरूमा रातको सिफ्टमा काम गर्न सक्छन्?',
    choices: [
      'हो, उचित सुरक्षाका साथ',
      'होइन, कहिल्यै होइन',
      'पतिको अनुमतिमा मात्र',
      'सरकारी कारखानामा मात्र',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'मालिकले समयमा तलब नदिएमा तपाईंले के गर्न सक्नुहुन्छ?',
    choices: [
      'केही गर्न सकिँदैन, कुर्नुहोस्',
      'नम्रतापूर्वक मात्र सोध्नुहोस्',
      'श्रम आयुक्तमा उजुरी गर्नुहोस्',
      'चुपचाप जागिर छाड्नुहोस्',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question:
        'वर्षमा मालिकले कम्तीमा कति राष्ट्रिय बिदा (paid) दिनुपर्छ?',
    choices: [
      'एउटा पनि होइन',
      'आइतवार मात्र',
      '३० दिन',
      'कम्तीमा ३–५ राष्ट्रिय बिदा',
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question:
        'के कुनै ठेकेदारले तपाईंलाई न्यूनतम ज्यालाभन्दा कम दिन सक्छ?',
    choices: [
      'होइन, सबै मजदुरलाई न्यूनतम ज्याला लागू हुन्छ',
      'हो, ठेकेदारका फरक नियम छन्',
      'सहमति भएमा मात्र',
      'ठेकेदारलाई नियम मान्नु पर्दैन',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'BOCW ऐन कुन विषयसँग सम्बन्धित छ?',
    choices: [
      'बैंक कर्मचारी',
      'कम्प्युटर कर्मचारी',
      'निर्माण मजदुरको कल्याण',
      'बस चालक',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question:
        'कार्यस्थल असुरक्षित छ भने (हेल्मेट छैन, सुरक्षा उपकरण छैन) के गर्नुपर्छ?',
    choices: [
      'आफैं सावधान रहनुहोस्',
      'कारखाना निरीक्षक/श्रम अधिकारीलाई रिपोर्ट गर्नुहोस्',
      'जागिर छाड्नुहोस्',
      'आफ्नै सुरक्षा उपकरण लगाउनुहोस्',
    ],
    correctIndex: 1,
  ),
];

// ── Getter ────────────────────────────────────────────────────────────────────

List<QuizQuestion> getRightsAtWorkQuestions(String locale) {
  switch (locale) {
    case 'hi': return _rightsAtWorkHi;
    case 'bn': return _rightsAtWorkBn;
    case 'ne': return _rightsAtWorkNe;
    default:   return _rightsAtWorkEn;
  }
}
