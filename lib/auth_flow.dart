import 'package:b2v_admin_panel/pages/Navigation_page.dart';
import 'package:b2v_admin_panel/pages/biometric_or_manual_page.dart';
import 'package:b2v_admin_panel/pages/face_id_login_page.dart';
import 'package:b2v_admin_panel/pages/home_page.dart';
import 'package:b2v_admin_panel/pages/regular_login_page.dart';
import 'package:b2v_admin_panel/service/auth_service.dart';
import 'package:b2v_admin_panel/utils/contant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthFlow extends StatelessWidget {
  const AuthFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          if (user == null) {
            return FutureBuilder<bool>(
              future: authService.canLoginWithFaceId,
              builder: (context, faceIdSnapshot) {
                if (faceIdSnapshot.connectionState == ConnectionState.done) {
                  return faceIdSnapshot.data == true
                      ? const BioMetricOptionScreen()
                      : const RegularLoginPage();
                }
                return  Scaffold(
                  body: Center(child: CircularProgressIndicator(color: appColor,)),
                );
              },
            );
          }
          return const NavigationScreen();
        }
        return  Scaffold(
          body: Center(child: CircularProgressIndicator(color: appColor,)),
        );
      },
    );
  }
}