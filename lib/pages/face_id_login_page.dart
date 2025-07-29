import 'package:b2v_admin_panel/pages/regular_login_page.dart';
import 'package:b2v_admin_panel/utils/contant.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';

// class FaceIdLoginPage extends StatefulWidget {
//   const FaceIdLoginPage({super.key});
//
//   @override
//   State<FaceIdLoginPage> createState() => _FaceIdLoginPageState();
// }
//
// class _FaceIdLoginPageState extends State<FaceIdLoginPage> {
//   bool _isLoading = false;
//
//   final Logger _logger = Logger();
//
//   Future<void> _loginWithFaceId() async {
//     setState(() => _isLoading = true);
//     final authService = Provider.of<AuthService>(context, listen: false);
//
//     try {
//       _logger.i('Attempting Face ID authentication');
//       final user = await authService.loginWithFaceId();
//
//       if (user == null) {
//         _logger.w('Face ID authentication failed - no user returned');
//       } else {
//         _logger.i('Face ID authentication successful for user: ${user.email}');
//       }
//     } catch (e, stackTrace) {
//       _logger.e('Face ID authentication error',
//           error: e,
//           stackTrace: stackTrace);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Welcome Back',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.black),
//               ),
//               const SizedBox(height: 40),
//               if (_isLoading)
//                 const CircularProgressIndicator()
//               else
//                 ElevatedButton(
//                   onPressed: _loginWithFaceId,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: appColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                   ),
//                   child: const Text('Login with Biometrics',style: TextStyle(color: Colors.white,fontSize: 18),),
//                 ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }