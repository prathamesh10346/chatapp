import 'package:chatapp/screens/home_screen.dart';
import 'package:chatapp/screens/profile_details_screen.dart';
import 'package:chatapp/screens/register_screen.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/services/google_auth_service.dart';
import 'package:chatapp/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _googleAuthService = GoogleAuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _prefsService = SharedPrefsService();
  bool _isLoading = false;
  bool _rememberMe = false;
  @override
  void initState() {
    super.initState();
    _checkSavedCredentials();
  }

  Future<void> _checkSavedCredentials() async {
    final userData = await _prefsService.getUserData();
    if (userData != null) {
      _emailController.text = userData.email;
      setState(() => _rememberMe = true);
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (user != null) {
          if (_rememberMe) {
            await _prefsService.saveUserData(user);
          } else {
            await _prefsService.clearUserData();
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter email' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter password' : null,
              ),
              SizedBox(height: 24),
              CheckboxListTile(
                title: Text('Remember Me'),
                value: _rememberMe,
                onChanged: (value) {
                  setState(() => _rememberMe = value!);
                },
              ),
              SizedBox(height: 12),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text('Login'),
                    ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                icon: Image.asset('assets/google.png', height: 24),
                label: Text('Sign in with Google'),
                onPressed: () async {
                  setState(() => _isLoading = true);
                  try {
                    final user = await _googleAuthService.signInWithGoogle();
                    if (user == null) {
                      // New user - navigate to profile details
                      final currentUser = _authService.currentUser;
                      if (currentUser != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileDetailsScreen(
                              email: currentUser.email!,
                              uid: currentUser.uid,
                            ),
                          ),
                        );
                      }
                    } else {
                      // Existing user - navigate to home
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Google Sign-In failed: ${e.toString()}')),
                    );
                  }
                  setState(() => _isLoading = false);
                },
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                ),
                child: Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
