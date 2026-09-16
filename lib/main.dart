import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseInitialized = false;
  String? initErrorMessage;

  // Only initialize Firebase on Android/Native. Keep Web (Chrome) for pure UI testing.
  if (!kIsWeb) {
    try {
      // Assuming Android relies on google-services.json
      await Firebase.initializeApp();
      isFirebaseInitialized = true;
    } catch (e, stackTrace) {
      debugPrint('Firebase initialization failed on Android: $e');
      debugPrint('StackTrace: $stackTrace');
      initErrorMessage = e.toString();
    }
  } else {
    debugPrint('Web Mode detected: Bypassing Firebase to allow UI testing.');
  }

  if (isFirebaseInitialized || kIsWeb) {
    runApp(StageFlowApp(isFirebaseInitialized: isFirebaseInitialized));
  } else {
    runApp(FirebaseInitErrorApp(errorMessage: initErrorMessage));
  }
}

/// Fallback error app displayed if Firebase initialization fails,
/// providing clear diagnostics without letting the app crash silently.
class FirebaseInitErrorApp extends StatelessWidget {
  final String? errorMessage;

  const FirebaseInitErrorApp({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StageSync - Initialization Error',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Initialization Failed'),
          backgroundColor: Colors.red.shade100,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 36),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Unable to connect to Firebase',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please ensure your Firebase project is configured correctly by running `flutterfire configure`.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Error Details:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        errorMessage ?? 'Unknown error occurred.',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
