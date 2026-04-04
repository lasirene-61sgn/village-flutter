import 'package:flutter/material.dart';
import 'package:village/screens/auth/login/notifier/login_notifier.dart';
import 'package:village/services/local_storage/shared_preference.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _mobileController = TextEditingController();
  final _passWordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? dToken;
  bool _obscurePassword = true;
  bool _validateFields = false;
  String _activeScenario = 'none';

  @override
  void dispose() {
    _mobileController.dispose();
    _passWordController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    setState(() { _activeScenario = 'continue'; _validateFields = true; });
    if (!_formKey.currentState!.validate()) return;
    await ref.read(loginProvider.notifier).login({
      "mobile": _mobileController.text.trim(),
      "password": _passWordController.text,
      "fcm_token":dToken ?? ''
    },mobile: _mobileController.text.trim());
  }

  Future<void> _handleFirstTimeUser() async {
    setState(() { _activeScenario = 'otp'; _validateFields = true; });
    if (!_formKey.currentState!.validate()) return;
    final mobile = _mobileController.text.trim();
    await ref.read(loginProvider.notifier).registerOtpRequest("api/customer/send-otp", {"mobile": mobile},mobile: mobile,isFirstTime: true);
  }

  Future<void> _handleForgetUser() async {
    setState(() { _activeScenario = 'otp'; _validateFields = true; });
    if (!_formKey.currentState!.validate()) return;
    final mobile = _mobileController.text.trim();
    await ref.read(loginProvider.notifier).forgotFlowRequest("api/customer/forgot-password-otp",
        {"mobile": mobile},mobile: mobile,isPasswordReset: true);
  }

  @override
  void initState() {
    super.initState();
    dToken =  SharedPreferencesHelper().getString("DToken");
  }
  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final view = View.of(context);
    final screenHeight = view.physicalSize.height / view.devicePixelRatio;
    final screenWidth = view.physicalSize.width / view.devicePixelRatio;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFD30000),

      // Use ResizeToAvoidBottomInset to prevent the keyboard from pushing the background
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Background Shape
          Positioned(
            bottom: 0,
            child: CustomPaint(
              size: Size(screenWidth, screenHeight * 0.4),
              painter: WhiteShapePainter(),
            ),
          ),

          // 2. Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _validateFields
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Image.asset(
                          'assets/icon/app_icon_removebg.png',
                          height: 160,
                          fit: BoxFit.contain,
                        )
                      ),
                      const SizedBox(height: 20),
                      const Text('Welcome to', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Colors.white)),
                      const SizedBox(height: 8),
                      const Text('SRJT Chennai', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),

                      const SizedBox(height: 40), // Replaced Spacer with fixed height

                      const Text('Enter your mobile number', style: TextStyle(fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: _buildInputDecoration('Mobile Number', Icons.phone),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter mobile number';
                          if (value.length != 10) return 'Mobile number must be 10 digits';
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      const Text('Enter your Password', style: TextStyle(fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _passWordController,
                        obscureText: _obscurePassword,
                        decoration: _buildInputDecoration('Password', Icons.password).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.textGrey),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (_activeScenario == 'continue') {
                            if (value == null || value.isEmpty) return 'Please enter password';
                            if (value.length < 6) return 'Password must be 6 digits above';
                          }
                          return null;
                        },
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: loginState.isLoading ? null : _handleForgetUser,
                          child: const Text('Forgot Password?', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                        ),
                      ),

                      const SizedBox(height: 10), // Added spacing before buttons

                      // Continue Button
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: loginState.isLoading ? null : _handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD30000),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: loginState.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: loginState.isLoading ? null : _handleFirstTimeUser,
                        child: const Text('First Time User? Register with OTP', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                      ),

                      // Add extra padding at bottom to ensure scrolling feels nice
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFD30000)),
      counterText: '',
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}

// Change 4: The Painter that creates the white diagonal background
class WhiteShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.1);
    path.lineTo(0, size.height * 0.6);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}