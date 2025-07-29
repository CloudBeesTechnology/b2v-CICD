import 'package:flutter/material.dart';


Color appColor = Color(0x2F91DE).withOpacity(1.0);
Color lightGrey = Color(0xF4F4F4).withOpacity(1.0);
Color borderGrey = Color(0xF3F3F3).withOpacity(1.0);
Color dull = Color(0xD9ECFB).withOpacity(1.0);


void showSuccessDialog({
  required BuildContext context,
  required String message,
  VoidCallback? onOkay,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismiss on outside tap
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (onOkay != null) onOkay(); // Optional callback
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appColor, // Blue
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Ok', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}
