import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/locale_provider.dart';
import 'app.dart';

void main() async {
  // 1. Tell Flutter "wait, I need to do some setup before showing anything"
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Connect to your Firebase project
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Enable Firestore offline persistence — data is cached on device
  //    so the app works even without internet for returning users
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // 4. Read the language the user chose last time (before showing anything)
  //    If it's their first launch, getSavedLocale() returns English by default
  final savedLocale = await LocaleProvider.getSavedLocale();

  // 5. Create the LocaleProvider and initialise it with the saved language
  final localeProvider = LocaleProvider()..init(savedLocale);

  // 6. Start the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: const KaamSathiApp(),
    ),
  );
}
