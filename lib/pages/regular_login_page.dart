import 'package:b2v_admin_panel/pages/Navigation_page.dart';
import 'package:b2v_admin_panel/utils/contant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import '../service/auth_service.dart';
import '../utils/height_width.dart';
import 'home_page.dart';

class RegularLoginPage extends StatefulWidget {
  const RegularLoginPage({super.key});

  @override
  State<RegularLoginPage> createState() => _RegularLoginPageState();
}

class _RegularLoginPageState extends State<RegularLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final Logger _logger = Logger();


  Future<void> _login() async {
    // 1. Validate form first
    if (!_formKey.currentState!.validate()) return;

    // 2. Show the spinner
    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();

    try {
      final user = await authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 3.  Only update UI *if* this widget is still on‑screen
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user == null) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Login failed')),
        // );
        showSuccessDialog(context: context, message: 'Login Failed');

      } else {
        // Go to HomePage
        await Provider.of<UserProvider>(context, listen: false).fetchCurrentUserData();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const NavigationScreen()),
              (route) => false,
        );
      }
    } catch (e, st) {
      // 4.  Log & show error
      _logger.e('Login error', error: e, stackTrace: st);
      if (mounted) {
        setState(() => _isLoading = false);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Error: $e')),
        // );

        showSuccessDialog(context: context, message: 'Error $e');
      }
    }
  }



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Image
                Image.asset(
                  'assets/images/bzv logo.png', // <-- Place your uploaded image here
                  height: 110,
                ),
                 SizedBox(height:SizeConfig.height(20)),
                // Title
                const Text(
                  'SIGN IN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                 SizedBox(height:  SizeConfig.height(8)),
                const Text(
                  'Welcome back !  Please enter your details',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),

                 SizedBox(height:  SizeConfig.height(30)),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter email ID',
                    prefixIcon:  Icon(Icons.email_outlined,color: appColor,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                 SizedBox(height:  SizeConfig.height(15)),

                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Your Password',
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline, color: appColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height:  SizeConfig.height(30)),
                // Login Button
                if (_isLoading)
                   CircularProgressIndicator(color: appColor,)
                else
                  SizedBox(
                    width: double.infinity,
                    height:  SizeConfig.height(50),
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                 SizedBox(height:  SizeConfig.height(16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

}