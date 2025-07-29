import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final Logger _logger = Logger();

  FirebaseAuth get auth => _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> get hasBiometrics async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      _logger.i("Biometrics check error: $e");
      return false;
    }
  }



  Future<void> storeCredentials(String email, String password) async {
    await _secureStorage.write(key: 'email', value: email);
    await _secureStorage.write(key: 'password', value: password);
  }

  Future<Map<String, String>?> readStoredCredentials() async {
    final email = await _secureStorage.read(key: 'email');
    final password = await _secureStorage.read(key: 'password');

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  Future<void> clearStoredCredentials() async {
    await _secureStorage.delete(key: 'email');
    await _secureStorage.delete(key: 'password');
  }

  Future<bool> _authenticateWithBiometrics() async {
    try {

      final bool supported   = await _localAuth.isDeviceSupported();
      final bool hasHardware = await _localAuth.canCheckBiometrics;
      final biometrics       = await _localAuth.getAvailableBiometrics();

      _logger.d('Biometric supported:   $supported');
      _logger.d('Hardware available:    $hasHardware');
      _logger.d('Enrolled biometrics:   $biometrics');

      if (!supported || !hasHardware || biometrics.isEmpty) {
        _logger.w('No usable biometrics on this device / none enrolled');
        return false;           // => falls back to regular login UI
      }


      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to sign in',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e, st) {
      _logger.e('Biometric PlatformException • ${e.code} • ${e.message}',
          error: e, stackTrace: st);
      return false;
    } catch (e, st) {
      _logger.e('Unknown biometric error', error: e, stackTrace: st);
      return false;
    }
  }


  Future<User?> loginWithFaceId() async {
    try {
      final creds = await readStoredCredentials();
      if (creds == null) {
        _logger.w('No stored credentials found');
        return null;
      }

      final isAuthenticated = await _authenticateWithBiometrics();
      if (!isAuthenticated) {
        _logger.w('Biometric authentication failed');
        return null;
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: creds['email']!,
        password: creds['password']!,
      );

      _logger.i('Face ID login successful for user: ${userCredential.user?.email}');
      return userCredential.user;
    } catch (e) {
      _logger.i("Login with Face ID error: $e");
      return null;
    }
  }

  Future<bool> get canLoginWithFaceId async {
    final hasCreds = await readStoredCredentials();
    final hasBio = await hasBiometrics;
    return hasCreds != null && hasBio;
  }

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      _logger.i('Attempting email login for: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _logger.i('Login successful for user: ${userCredential.user?.email}');

      // Store credentials for Face ID login
      await storeCredentials(email, password);
      _logger.d('Email and password stored securely');

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error', error: e, stackTrace: StackTrace.current);

      if (e.code == 'user-not-found') {
        _logger.w('No user found for email: $email');
      } else if (e.code == 'wrong-password') {
        _logger.w('Incorrect password for email: $email');
      }

      return null;
    } catch (e, stackTrace) {
      _logger.e('Unexpected login error', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    // DO NOT clear credentials here to preserve Face ID login
    _logger.i('User logged out (credentials kept for biometric login)');
  }
}
