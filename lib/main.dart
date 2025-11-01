import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to store the counter value in [SharedPreferences].
const String kStorageKey = 'persistent_counter_value';

/// Entry point of the Flutter application.
Future<void> main() async {
  // Ensure all Flutter bindings are initialised before we use platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // Load the saved counter value; default to zero if nothing is stored yet.
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final int storedCount = prefs.getInt(kStorageKey) ?? 0;

  runApp(CounterApp(
    prefs: prefs,
    initialCount: storedCount,
  ));
}

/// Root widget of the application.
class CounterApp extends StatefulWidget {
  const CounterApp({
    super.key,
    required this.prefs,
    required this.initialCount,
  });

  /// Shared preferences instance used to persist the counter.
  final SharedPreferences prefs;

  /// Counter value restored at launch time.
  final int initialCount;

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
  }

  /// Persist the new value and refresh the UI.
  Future<void> _updateCount(int newValue) async {
    setState(() => _count = newValue);
    await widget.prefs.setInt(kStorageKey, newValue);
  }

  Future<void> _increment() async {
    await _updateCount(_count + 1);
  }

  Future<void> _reset() async {
    await _updateCount(0);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF64FFDA), // Vibrant teal accent.
        brightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Persistent Counter',
      theme: baseTheme,
      home: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWideLayout = constraints.maxWidth > 600;
            final double counterFontSize = isWideLayout ? 112 : 80;
            final double buttonHorizontalPadding = isWideLayout ? 56 : 32;
            final double buttonVerticalPadding = isWideLayout ? 24 : 18;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Counter',
                      style: baseTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$_count',
                      textAlign: TextAlign.center,
                      style: baseTheme.textTheme.displayLarge?.copyWith(
                        fontSize: counterFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _increment,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: buttonHorizontalPadding,
                          vertical: buttonVerticalPadding,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        '+1',
                        style: baseTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _count == 0 ? null : _reset,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
