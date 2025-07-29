
import 'package:b2v_admin_panel/pages/Navigation_page.dart';
import 'package:b2v_admin_panel/pages/regular_login_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import '../service/auth_service.dart';
import '../utils/contant.dart';
import '../utils/height_width.dart';
import 'home_page.dart';


class BioMetricOptionScreen extends StatefulWidget {
  const BioMetricOptionScreen({super.key});

  @override
  State<BioMetricOptionScreen> createState() => _BioMetricOptionScreenState();
}

class _BioMetricOptionScreenState extends State<BioMetricOptionScreen> {
  final Logger _logger = Logger();
  bool _isLoading = false;

  Future<void> _loginWithFaceId() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      _logger.i('Attempting Face ID authentication');
      final user = await authService.loginWithFaceId();

      if (user == null) {
        _logger.w('Face ID authentication failed - no user returned');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Biometric auth failed')),
        // );

        showSuccessDialog(context: context, message: 'Biometric Auth failed');
      } else {
        _logger.i('Face ID authentication successful for user: ${user.email}');
        await Provider.of<UserProvider>(context, listen: false).fetchCurrentUserData();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const NavigationScreen()),
              (route) => false,
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Face ID authentication error', error: e, stackTrace: stackTrace);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: appColor, // Blue background
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _LoginOptionIcon(
                      icon: Icons.face,
                      label: 'Face ID',
                      onTap: _isLoading ? null : _loginWithFaceId,
                    ),
                    _LoginOptionIcon(
                      icon: Icons.lock,
                      label: 'Password',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const RegularLoginPage()),
                        );
                      },
                    ),
                  ],
                ),
                const Spacer(),
                // _FooterLinks(),
              ],
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}



class _LoginOptionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _LoginOptionIcon({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: CircleAvatar(
            radius: SizeConfig.height(40),
            backgroundColor: Colors.white,
            child: Icon(icon, size: 40, color: appColor),
          ),
        ),
         SizedBox(height: SizeConfig.height(8)),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}


