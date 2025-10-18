import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/curve_painter.dart';
import '../providers/signup_provider.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final emailController = TextEditingController();
  
  final phoneController = TextEditingController();
  final fullnameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmVisible = false;  
  bool isFormValid = false;

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    fullnameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // validate form whenever fields change
    // TextEditingController.addListener expects a VoidCallback
    final VoidCallback listener = _validateForm;
    emailController.addListener(listener);
    phoneController.addListener(listener);
    fullnameController.addListener(listener);
    passwordController.addListener(listener);
    confirmPasswordController.addListener(listener);
  }

  void _validateForm() {
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final fullName = fullnameController.text.trim();
    final password = passwordController.text;
    final passwordOk = _passwordMeetsRequirements(password);
    final phoneOk = _phoneIsValid(phone);
    final fullNameOk = _fullNameIsValid(fullName);
    final confirmOk = password == confirmPasswordController.text;

    final valid = email.isNotEmpty && phoneOk && fullNameOk && passwordOk && confirmOk;
    if (valid != isFormValid) setState(() => isFormValid = valid);
  }

  bool _passwordMeetsRequirements(String p) {
    if (p.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(p)) return false;
    if (!RegExp(r'[a-z]').hasMatch(p)) return false;
    if (!RegExp(r'[0-9]').hasMatch(p)) return false;
    return true;
  }

  bool _phoneIsValid(String phone) {
    // consider only digits for validation
    final digits = RegExp(r'\d+').allMatches(phone).map((m) => m.group(0)).join();
    return digits.length == 11;
  }

  bool _fullNameIsValid(String fullName) {
    final parts = fullName.split(RegExp(r"\s+"));
    // require at least two non-empty words
    return parts.where((p) => p.trim().isNotEmpty).length >= 2;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final signupState = ref.watch(signupProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Background_Peach.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            top: size.height * 0.01,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
              child: Column(
                children: [
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(2, 2, 1),
                    child: Transform.translate(
                      offset: const Offset(10, 80),
                      child: SizedBox(
                        width: size.width,
                        height: size.height * 0.16,
                        child: CustomPaint(painter: RPSCustomPainter()),
                      ),
                    ),
                  ),

                  // Form container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            'Sign up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 130,
                            height: 2,
                            color: const Color(0xFFFF8383),
                          ),
                          const SizedBox(height: 46),

                          // (rest of the form widgets remain unchanged)
                          // Email
                          Text('Email', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          TextField(controller: emailController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(filled: true, fillColor: Colors.black, hintText: 'demo@email.com', hintStyle: TextStyle(color: Colors.white54), prefixIcon: Padding(padding: EdgeInsets.only(left: 0, right: 14), child: Icon(Icons.email_outlined, color: Colors.white54)), contentPadding: EdgeInsets.only(top: 12, bottom: 0), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF8383)))),),
                          const SizedBox(height: 25),

                          // Full Name
                          Text('Full Name', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          TextField(controller: fullnameController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(filled: true, fillColor: Colors.black, hintText: 'Alif Rashid', hintStyle: TextStyle(color: Colors.white54), prefixIcon: Padding(padding: EdgeInsets.only(left: 0, right: 14), child: Icon(Icons.person, color: Colors.white54)), contentPadding: EdgeInsets.only(top: 12, bottom: 0), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF8383)))),),
                          const SizedBox(height: 6),
                          // Full name requirement indicator
                          Builder(builder: (_) {
                            final ok = _fullNameIsValid(fullnameController.text.trim());
                            return Row(children: [Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: ok ? Colors.green : Colors.white54), const SizedBox(width: 8), Text('Enter first and last name', style: TextStyle(color: ok ? Colors.green : Colors.white54, fontSize: 12))]);
                          }),
                          const SizedBox(height: 19),

                          // Phone
                          Text('Phone no', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          TextField(controller: phoneController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(filled: true, fillColor: Colors.black, hintText: '+880***********', hintStyle: TextStyle(color: Colors.white54), prefixIcon: Padding(padding: EdgeInsets.only(left: 0, right: 14), child: Icon(Icons.phone, color: Colors.white54)), contentPadding: EdgeInsets.only(top: 12, bottom: 0), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF8383)))),),
                          const SizedBox(height: 6),
                          Builder(builder: (_) {
                            final ok = _phoneIsValid(phoneController.text.trim());
                            return Row(children: [Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: ok ? Colors.green : Colors.white54), const SizedBox(width: 8), Text('11 digits required', style: TextStyle(color: ok ? Colors.green : Colors.white54, fontSize: 12))]);
                          }),
                          const SizedBox(height: 19),

                          // Password
                          Text('Password', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          TextField(controller: passwordController, obscureText: !isPasswordVisible, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: Colors.black, hintText: 'Enter your password', hintStyle: const TextStyle(color: Colors.white54), contentPadding: const EdgeInsets.only(top: 12, bottom: 0), prefixIcon: const Padding(padding: EdgeInsets.only(left: 0, right: 14), child: Icon(Icons.lock_outline, color: Colors.white54)), suffixIcon: IconButton(icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white54), onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible)), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF8383)))),),
                          const SizedBox(height: 8),

                          // Password requirements
                          Builder(builder: (_) {
                            final p = passwordController.text;
                            final okLen = p.length >= 8;
                            final okCase = RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p);
                            final okNum = RegExp(r'[0-9]').hasMatch(p);
                            Widget req(bool ok, String t) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(children: [Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: ok ? Colors.green : Colors.white54), const SizedBox(width: 8), Text(t, style: TextStyle(color: ok ? Colors.green : Colors.white54, fontSize: 12))]),
                                );

                            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [req(okLen, 'At least 8 characters'), req(okCase, 'Uppercase and lowercase letters'), req(okNum, 'At least one number')]);
                          }),
                          const SizedBox(height: 25),

                          // Confirm password
                          Text('Confirm Password', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          TextField(controller: confirmPasswordController, obscureText: !isConfirmVisible, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: Colors.black, hintText: 'Confirm your password', hintStyle: const TextStyle(color: Colors.white54), contentPadding: const EdgeInsets.only(top: 12, bottom: 0), prefixIcon: const Padding(padding: EdgeInsets.only(left: 0, right: 14), child: Icon(Icons.lock_outline, color: Colors.white54)), suffixIcon: IconButton(icon: Icon(isConfirmVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white54), onPressed: () => setState(() => isConfirmVisible = !isConfirmVisible)), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF8383)))),),
                          const SizedBox(height: 6),
                          Builder(builder: (_) {
                            final ok = passwordController.text == confirmPasswordController.text && passwordController.text.isNotEmpty;
                            return Row(children: [Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: ok ? Colors.green : Colors.white54), const SizedBox(width: 8), Text('Passwords match', style: TextStyle(color: ok ? Colors.green : Colors.white54, fontSize: 12))]);
                          }),
                          const SizedBox(height: 34),

                          // Create Account
                          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: (!isFormValid || signupState.isLoading) ? null : () async {
                            final email = emailController.text.trim();
                            final phone = phoneController.text.trim();
                            final password = passwordController.text;
                            final confirmPassword = confirmPasswordController.text;
                            final fullName = fullnameController.text.trim();

                            if (password != confirmPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red));
                              return;
                            }

                            try {
                              await ref.read(signupProvider.notifier).signup(email: email, password: password, fullName: fullName, phone: phone);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created successfully!'), backgroundColor: Colors.green));
                                context.go('/login');
                              }
                            } catch (e) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup failed: ${e.toString()}'), backgroundColor: Colors.red));
                            }
                          }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8383), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: signupState.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))),

                          const SizedBox(height: 20),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Already have an Account? ", style: TextStyle(color: Colors.white54, fontSize: 13)), GestureDetector(onTap: () => context.go('/login'), child: const Text("Login", style: TextStyle(color: Color(0xFFFF8383), fontWeight: FontWeight.w600)))]),
                          
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}