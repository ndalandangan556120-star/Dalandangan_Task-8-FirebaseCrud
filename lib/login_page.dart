import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _message;
  bool _isError = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Enter your email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final user = await _authService.signInWithEmail(email, password);
      await user?.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser != null && !refreshedUser.emailVerified) {
        _showMessage('Verify your email before signing in.');
      }
    } on FirebaseAuthException catch (error) {
      _showMessage(_messageFor(error));
    } catch (error) {
      _showMessage('Could not sign in: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _authService.signInWithGoogle();
    } on FirebaseAuthException catch (error) {
      _showMessage(_messageFor(error));
    } catch (error) {
      _showMessage('Google sign-in failed: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter your email first.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });
    final error = await _authService.resetPassword(email);
    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        setState(() {
          _message = 'Password reset email sent.';
          _isError = false;
        });
      } else {
        _showMessage(error);
      }
    }
  }

  Future<void> _resendVerification() async {
    try {
      await _authService.resendVerificationEmail();
      if (mounted) {
        setState(() {
          _message = 'Verification email sent.';
          _isError = false;
        });
      }
    } on FirebaseAuthException catch (error) {
      _showMessage(_messageFor(error));
    } catch (error) {
      _showMessage('Could not send verification email: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _isError = true;
    });
  }

  String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase CRUD App')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _isLoading ? null : _signIn(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),
                if (_message != null) ...[
                  Text(
                    _message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isError
                          ? Theme.of(context).colorScheme.error
                          : Colors.green.shade700,
                    ),
                  ),
                  if (_message == 'Verify your email before signing in.')
                    TextButton(
                      onPressed: _isLoading ? null : _resendVerification,
                      child: const Text('Resend verification email'),
                    ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Sign in'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    child: const Text('Sign in with Google'),
                  ),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RegisterPage(),
                          ),
                        ),
                  child: const Text('Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
