import 'package:material_ui/material_ui.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'auth_screen.dart';
import 'config.dart';
import 'todos_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Config.isSet) {
    runApp(const _MissingConfig());
    return;
  }
  // The Application ID and Client Key are public: ACLs and class-level
  // permissions protect the data. Never put the master key in an app.
  await Parse().initialize(
    Config.appId,
    Config.serverUrl,
    clientKey: Config.clientKey,
    liveQueryUrl: Config.liveQueries ? Config.liveQueryUrl : null,
    autoSendSessionId: true,
  );
  runApp(const StarterApp());
}

class StarterApp extends StatefulWidget {
  const StarterApp({super.key});

  @override
  State<StarterApp> createState() => _StarterAppState();
}

class _StarterAppState extends State<StarterApp> {
  ParseUser? _user;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    // the session saved on the device by a previous launch
    ParseUser.currentUser().then((user) {
      setState(() {
        _user = user as ParseUser?;
        _ready = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SashiDo Flutter starter',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF0092FF), useMaterial3: true),
      home: !_ready
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _user == null
              ? AuthScreen(onLogin: (user) => setState(() => _user = user))
              : TodosScreen(user: _user!, onLogout: () => setState(() => _user = null)),
    );
  }
}

class _MissingConfig extends StatelessWidget {
  const _MissingConfig();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Copy config.example.json to config.json, fill in your keys from '
              'App Settings › Security & Keys, and run:\n\n'
              'flutter run --dart-define-from-file=config.json',
            ),
          ),
        ),
      ),
    );
  }
}
