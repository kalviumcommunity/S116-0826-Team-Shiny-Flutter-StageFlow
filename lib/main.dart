import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stagesync/app.dart';
import 'package:stagesync/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseInitialized = false;
  String? initErrorMessage;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('StackTrace: $stackTrace');
    initErrorMessage = e.toString();
  }

  if (isFirebaseInitialized) {
    runApp(const StageSyncApp());
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
