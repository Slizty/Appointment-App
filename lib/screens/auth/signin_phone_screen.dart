import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignInPhoneScreen extends StatefulWidget {
  const SignInPhoneScreen({super.key});

  @override
  State<SignInPhoneScreen> createState() => _SignInPhoneScreenState();
}

class _SignInPhoneScreenState extends State<SignInPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  void _sendOTP() async {
    final phone = _phoneController.text.trim();

    if (phone.length != 10) {
      setState(() {
        _errorMessage = 'Phone number must be exactly 10 digits';
      });
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      setState(() {
        _errorMessage = 'Phone number must contain only digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Check if it's a doctor code
    if (AuthService.isDoctorCode(phone)) {
      final user = await AuthService.doctorLogin(phone);
      setState(() => _isLoading = false);
      
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
      } else {
        setState(() {
          _errorMessage = 'Invalid doctor code. Please try again.';
        });
      }
      return;
    }

    // Regular patient login flow
    final success = await AuthService.signInWithPhone(phone);

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(
        context,
        '/otp',
        arguments: phone, // Pass phone number to OTP screen
      );
    } else {
      setState(() {
        _errorMessage = 'Failed to send OTP. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter Phone Number', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
                helperText: 'Enter your phone number',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
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
                    onPressed: _sendOTP,
                    child: const Text('Continue'),
                  ),
          ],
        ),
      ),
    );
  }
}
