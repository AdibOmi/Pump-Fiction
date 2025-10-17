import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController emailController =
      TextEditingController(text: 'rashid@gmail.com');
  final TextEditingController ageController = TextEditingController(text: '25');
  final TextEditingController phoneController =
      TextEditingController(text: '01333444555');
  final TextEditingController bodyWeightController =
      TextEditingController(text: '54 kg');
  final TextEditingController goalWeightController =
      TextEditingController(text: '60 kg');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background_Peach.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsetsGeometry.all(17),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // 🔹 Profile container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 70, left: 20, right: 20, bottom:0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildProfileField(
                        label: 'Email',
                        icon: Icons.email_outlined,
                        controller: emailController,
                        editable: false,
                      ),
                      const SizedBox(height: 25),
                      buildProfileField(
                        label: 'Age',
                        icon: Icons.calendar_today_outlined,
                        controller: ageController,
                      ),
                      const SizedBox(height: 25),
                      buildProfileField(
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        controller: phoneController,
                      ),
                      const SizedBox(height: 25),
                      buildProfileField(
                        label: 'Body Weight',
                        icon: Icons.fitness_center_outlined,
                        controller: bodyWeightController,
                      ),
                      const SizedBox(height: 25),
                      buildProfileField(
                        label: 'Goal Weight',
                        icon: Icons.flag_outlined,
                        controller: goalWeightController,
                      ),
                      const SizedBox(height: 50),

                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFFF8383), // pink accent
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              // handle form submission logic
                            },
                            child: Text(
                              'Submit',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40,)
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Profile image with edit icon
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        AssetImage('assets/images/default.jpg'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // handle image picker logic
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF8383),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
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

  Widget buildProfileField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool editable = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFFE88283),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: editable,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(icon, color: Colors.white70, size: 20),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pinkAccent),
                  ),
                  disabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                ),
              ),
            ),

          
            // if (editable)
            //   IconButton(
            //     icon: const Icon(Icons.edit_outlined,
            //         color: Colors.white70, size: 20),
            //     onPressed: () {
            //       // toggle edit mode or update field logic
            //     },
            //   ),
          ],
        ),
      ],
    );
  }
}
