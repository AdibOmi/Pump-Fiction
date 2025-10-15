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

          Align(
            alignment: Alignment.center,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(2, 1.8, 1),
              child: Transform.translate(
                offset: const Offset(10, 160),
                child: CustomPaint(
                  size: Size(size.width, size.height * 0.8),
                  painter: RPSCustomPainter(),
                ),
              ),
            ),
          ),

          Positioned(
            top: size.height * 0.15, 
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: const BoxDecoration(
                color: Colors.transparent, 
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
                child: Padding(
                  padding: const EdgeInsets.only(top: 18, bottom: 100),
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
                  
                      // Email field
                      Text(
                        'Email',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'demo@email.com',
                          hintStyle: TextStyle(color: Colors.white54),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 0, right: 14),
                            child: Icon(Icons.email_outlined, color: Colors.white54)
                          ),
                          contentPadding: EdgeInsets.only(top: 12, bottom: 0),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFF8383)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
              
                      Text(
                        'Full Name',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: fullnameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Alif Rashid',
                          hintStyle: TextStyle(color: Colors.white54),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 0, right: 14),
                            child: Icon(Icons.person, color: Colors.white54)
                          ),
                          contentPadding: EdgeInsets.only(top: 12, bottom: 0),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFF8383)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                  
                      // Phone number field
                      Text(
                        'Phone no',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: phoneController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: '+880***********',
                          hintStyle: TextStyle(color: Colors.white54),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 0, right: 14),
                            child: Icon(Icons.phone, color: Colors.white54)
                          ),
                          contentPadding: EdgeInsets.only(top: 12, bottom: 0),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFF8383)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                  
                      // Password
                      Text(
                        'Password',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(color: Colors.white54),
                          contentPadding: const EdgeInsets.only(top: 12, bottom: 0),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 0, right: 14),
                            child: Icon(Icons.lock_outline, color: Colors.white54)
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() => isPasswordVisible = !isPasswordVisible);
                            },
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFF8383)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                  
                      // Confirm Password
                      Text(
                        'Confirm Password',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: !isConfirmVisible,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Confirm your password',
                          hintStyle: const TextStyle(color: Colors.white54),
                          contentPadding: const EdgeInsets.only(top: 12, bottom: 0),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 0, right: 14),
                            child: Icon(Icons.lock_outline, color: Colors.white54)
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isConfirmVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() => isConfirmVisible = !isConfirmVisible);
                            },
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFF8383)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                  
                      // Create Account Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: signupState.isLoading ? null : () async {
                            final email = emailController.text.trim();
                            final phone = phoneController.text.trim();
                            final password = passwordController.text.trim();
                            final confirmPassword = confirmPasswordController.text.trim();
                            final fullName = fullnameController.text.trim();
              
                            if (password != confirmPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Passwords do not match"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill in all required fields"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
              
                            try {
                              await ref
                                .read(signupProvider.notifier)
                                .signup(
                                  email: email,
                                  password: password,
                                  fullName: fullName,
                                  phone: phone
                                );

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Account created successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                context.go('/login');
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Signup failed: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8383),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: signupState.isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Create Account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                  
                      // Already have account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an Account? ",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go('/login');
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: const Color(0xFFFF8383),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
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
}