// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../service/auth_service.dart';
//
// class BiometricPromptHandler extends StatefulWidget {
//   @override
//   _BiometricPromptHandlerState createState() => _BiometricPromptHandlerState();
// }
//
// class _BiometricPromptHandlerState extends State<BiometricPromptHandler> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(_handleBiometricPrompt);
//   }
//
//   Future<void> _handleBiometricPrompt() async {
//     final authService = context.read<AuthService>();
//
//     final enableBiometric = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: const Text('Enable Biometric Login?'),
//         content: const Text('Would you like to enable Face ID / Fingerprint login?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     );
//
//     if (enableBiometric == true) {
//       final success = await authService.authenticateWithBiometrics();
//       await authService.setBiometricPreference(success);
//     } else {
//       await authService.setBiometricPreference(false);
//     }
//
//     authService.setBiometricHandled(true); // ✅ mark it done
//
//     // Force rebuild AuthFlow
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }
