import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  void _verifyOTP() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'OTP must be exactly 6 digits';
      });
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(otp)) {
      setState(() {
        _errorMessage = 'OTP must contain only digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Get phone number from previous screen
    final phoneNumber = ModalRoute.of(context)?.settings.arguments as String? ?? '';

    final user = await AuthService.verifyOTP(phoneNumber, otp);

    setState(() => _isLoading = false);

    if (user != null) {
      // Successfully authenticated
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter OTP', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'OTP',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              enabled: !_isLoading,
              onChanged: (value) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _verifyOTP,
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}