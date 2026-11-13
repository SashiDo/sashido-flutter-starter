import 'package:material_ui/material_ui.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onLogin});

  final void Function(ParseUser user) onLogin;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _signup = false;
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final user = ParseUser(_username.text.trim(), _password.text, null);
    try {
      // usernames only, like the other starters; add an email field and drop
      // allowWithoutEmail to offer password resets by email
      final response = _signup ? await user.signUp(allowWithoutEmail: true) : await user.login();
      if (!mounted) return;
      if (response.success) {
        widget.onLogin(user);
      } else {
        setState(() => _error = response.error?.message ?? 'Something went wrong.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_signup ? 'Sign up' : 'Log in', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('username'),
                    controller: _username,
                    decoration: const InputDecoration(labelText: 'Username'),
                    autocorrect: false,
                  ),
                  TextField(
                    key: const Key('password'),
                    controller: _password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('submit'),
                    onPressed: _busy ? null : _submit,
                    child: Text(_signup ? 'Create account' : 'Log in'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _signup = !_signup),
                    child: Text(_signup ? 'Have an account? Log in' : 'No account yet? Sign up'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
