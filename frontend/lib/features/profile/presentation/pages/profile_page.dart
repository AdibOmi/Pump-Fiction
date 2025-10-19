import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/user_profile_model.dart';
import '../providers/profile_providers.dart';
import '../../../../core/widgets/custom_app_bar.dart';


class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController trainingFrequencyController = TextEditingController();

  Gender? selectedGender;
  FitnessGoal? selectedFitnessGoal;
  ExperienceLevel? selectedExperienceLevel;
  NutritionGoal? selectedNutritionGoal;

  bool isLoading = false;
  bool _isDataLoaded = false; // Track if data has been loaded
  String? _lastLoadedProfileId; // Track which profile was loaded
  bool _isEditMode = false; // Track edit mode

  @override
  void dispose() {
    emailController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    weightController.dispose();
    heightController.dispose();
    trainingFrequencyController.dispose();
    super.dispose();
  }

  void _loadProfileData(UserProfileModel? profile) {
    if (profile == null) return;
    
    // Only reload if this is a different profile or first load
    if (_isDataLoaded && _lastLoadedProfileId == profile.id) return;

    print('🔄 Loading profile data into UI...');
    print('   Email: ${profile.email}');
    print('   Full Name: ${profile.fullName}');
    print('   Phone: ${profile.phoneNumber}');

    setState(() {
      emailController.text = profile.email;
      fullNameController.text = profile.fullName ?? '';
      phoneController.text = profile.phoneNumber ?? '';
      weightController.text = profile.weightKg?.toString() ?? '';
      heightController.text = profile.heightCm?.toString() ?? '';
      trainingFrequencyController.text = profile.trainingFrequency?.toString() ?? '';

      selectedGender = profile.gender;
      selectedFitnessGoal = profile.fitnessGoal;
      selectedExperienceLevel = profile.experienceLevel;
      selectedNutritionGoal = profile.nutritionGoal;
      
      _isDataLoaded = true; // Mark data as loaded
      _lastLoadedProfileId = profile.id; // Track which profile
      print('✅ Profile data loaded into UI successfully');
    });
  }

  Future<void> _saveProfile() async {
    setState(() => isLoading = true);

    try {
      // Create partial update data
      final Map<String, dynamic> updateData = {};

      if (fullNameController.text.isNotEmpty) {
        updateData['full_name'] = fullNameController.text;
      }
      if (phoneController.text.isNotEmpty) {
        updateData['phone_number'] = phoneController.text;
      }
      if (weightController.text.isNotEmpty) {
        updateData['weight_kg'] = double.tryParse(weightController.text);
      }
      if (heightController.text.isNotEmpty) {
        updateData['height_cm'] = double.tryParse(heightController.text);
      }
      if (trainingFrequencyController.text.isNotEmpty) {
        updateData['training_frequency'] = int.tryParse(trainingFrequencyController.text);
      }
      if (selectedGender != null) {
        updateData['gender'] = selectedGender!.name;
      }
      if (selectedFitnessGoal != null) {
        updateData['fitness_goal'] = selectedFitnessGoal!.name == 'muscleGain' ? 'muscle_gain' :
                                       selectedFitnessGoal!.name == 'fatLoss' ? 'fat_loss' :
                                       selectedFitnessGoal!.name == 'generalFitness' ? 'general_fitness' :
                                       selectedFitnessGoal!.name;
      }
      if (selectedExperienceLevel != null) {
        updateData['experience_level'] = selectedExperienceLevel!.name;
      }
      if (selectedNutritionGoal != null) {
        updateData['nutrition_goal'] = selectedNutritionGoal!.name;
      }

      await ref.read(userProfileProvider.notifier).updateProfilePartial(updateData);

      if (mounted) {
        setState(() => _isEditMode = false); // Exit edit mode after saving
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFFFF8383),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      //appBar: CustomAppBar(),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background_Peach.png',
              fit: BoxFit.cover,
            ),
          ),

          // Back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(17),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
              ),
            ),
          ),

          // Profile container
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
              child: profileAsync.when(
                data: (profile) {
                  // Load profile data when it becomes available
                  if (profile != null && !_isDataLoaded) {
                    // Use Future.microtask to avoid calling setState during build
                    Future.microtask(() => _loadProfileData(profile));
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 70, left: 20, right: 20, bottom: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email (read-only)
                          buildProfileField(
                            label: 'Email',
                            icon: Icons.email_outlined,
                            controller: emailController,
                            editable: false,
                          ),
                          const SizedBox(height: 25),

                          // Full Name
                          buildProfileField(
                            label: 'Full Name',
                            icon: Icons.person_outlined,
                            controller: fullNameController,
                          ),
                          const SizedBox(height: 25),

                          // Phone Number
                          buildProfileField(
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 25),

                          // Gender Dropdown
                          buildDropdownField<Gender>(
                            label: 'Gender',
                            icon: Icons.wc_outlined,
                            value: selectedGender,
                            items: Gender.values,
                            onChanged: (value) => setState(() => selectedGender = value),
                            displayName: (gender) => gender.displayName,
                          ),
                          const SizedBox(height: 25),

                          // Weight
                          buildProfileField(
                            label: 'Weight (kg)',
                            icon: Icons.fitness_center_outlined,
                            controller: weightController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 25),

                          // Height
                          buildProfileField(
                            label: 'Height (cm)',
                            icon: Icons.height_outlined,
                            controller: heightController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 25),

                          // Fitness Goal Dropdown
                          buildDropdownField<FitnessGoal>(
                            label: 'Fitness Goal',
                            icon: Icons.flag_outlined,
                            value: selectedFitnessGoal,
                            items: FitnessGoal.values,
                            onChanged: (value) => setState(() => selectedFitnessGoal = value),
                            displayName: (goal) => goal.displayName,
                          ),
                          const SizedBox(height: 25),

                          // Experience Level Dropdown
                          buildDropdownField<ExperienceLevel>(
                            label: 'Experience Level',
                            icon: Icons.star_outline,
                            value: selectedExperienceLevel,
                            items: ExperienceLevel.values,
                            onChanged: (value) => setState(() => selectedExperienceLevel = value),
                            displayName: (level) => level.displayName,
                          ),
                          const SizedBox(height: 25),

                          // Training Frequency
                          buildProfileField(
                            label: 'Training Frequency (days per week)',
                            icon: Icons.calendar_today_outlined,
                            controller: trainingFrequencyController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 25),

                          // Nutrition Goal Dropdown
                          buildDropdownField<NutritionGoal>(
                            label: 'Nutrition Goal',
                            icon: Icons.restaurant_outlined,
                            value: selectedNutritionGoal,
                            items: NutritionGoal.values,
                            onChanged: (value) => setState(() => selectedNutritionGoal = value),
                            displayName: (goal) => goal.displayName,
                          ),
                          const SizedBox(height: 50),

                          // Edit/Save Button
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF8383),
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: isLoading ? null : () {
                                  if (_isEditMode) {
                                    _saveProfile();
                                  } else {
                                    setState(() => _isEditMode = true);
                                  }
                                },
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _isEditMode ? 'Save Profile' : 'Edit Profile',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF8383),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load profile',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(userProfileProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8383),
                          ),
                          child: Text(
                            'Retry',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Profile image with edit icon
          Positioned(
            top: MediaQuery.of(context).size.height * 0.10,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey,
                    backgroundImage: AssetImage('assets/images/default.jpg'),
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
    TextInputType keyboardType = TextInputType.text,
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
        TextField(
          controller: controller,
          enabled: editable && _isEditMode,
          keyboardType: keyboardType,
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
      ],
    );
  }

  Widget buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) displayName,
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
        DropdownButtonFormField<T>(
          value: value,
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
          dropdownColor: const Color(0xFF1A1A1A),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
          ),
          disabledHint: value != null
              ? Text(
                  displayName(value),
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                )
              : null,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(displayName(item)),
            );
          }).toList(),
          onChanged: _isEditMode ? onChanged : null,
          hint: Text(
            'Select $label',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
