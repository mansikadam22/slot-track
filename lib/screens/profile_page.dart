import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'edit_profile.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Loading...";
  String phone = "";
  String email = "";
  String vehicle = "";

  bool isGuest = false;
  bool loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
    _loadUserProfile();
  }

  // ---------------- LOAD USER STATUS ----------------
  void _loadUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isGuest = prefs.getBool('isGuest') ?? false;
    });
  }

  // ---------------- LOAD API PROFILE ----------------
  Future<void> _loadUserProfile() async {
    setState(() {
      loadingProfile = true;
    });

    try {
      final data = await ApiService.getUserProfile();

      if (!mounted) return;

      setState(() {
        if (data != null) {
          // Use backend keys
          name = data["name"] ?? "";
          phone = data["phone_no"] ?? "";
          email = data["email"] ?? "";
          vehicle = data["vehicle_no"] ?? "";
        } else {
          // No data returned (maybe token missing) — keep defaults
        }
        loadingProfile = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loadingProfile = false;
      });
      // Show an error so user knows
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  // ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          if (!isGuest)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () async {
                // Open edit screen and wait for returned updated data
                final updatedData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      name: name,
                      phone: phone,
                      email: email,
                      vehicle: vehicle,
                    ),
                  ),
                );

                // If edit returned updated values, update UI instantly
                if (updatedData != null && updatedData is Map<String, dynamic>) {
                  setState(() {
                    name = updatedData["name"] ?? name;
                    phone = updatedData["phone"] ?? phone;
                    email = updatedData["email"] ?? email;
                    vehicle = updatedData["vehicle"] ?? vehicle;
                  });

                  // Optionally show a small confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated')),
                  );
                }
              },
            )
        ],
      ),

      // SHOW LOADING
      body: loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : (isGuest
          ? _buildGuestView(context)
          : _buildUserProfileView(context)),
    );
  }

  // ---------------- GUEST VIEW ----------------
  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  size: 70, color: Colors.blueAccent),
            ),

            const SizedBox(height: 25),

            const Text(
              "Guest Mode",
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            const Text(
              "Login to view and update your profile details.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ---------------- USER PROFILE VIEW ----------------
  Widget _buildUserProfileView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 70, color: Colors.white),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          _buildProfileCard(),

          const SizedBox(height: 35),

          TextButton(
            onPressed: _showLogoutDialog,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Logout",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                SizedBox(width: 6),
                Icon(Icons.logout, color: Colors.red, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          _buildProfileDetail(Icons.phone, "Phone Number", phone),
          const Divider(height: 30),
          _buildProfileDetail(Icons.email, "Email", email),
          const Divider(height: 30),
          _buildProfileDetail(Icons.car_repair, "Vehicle Number", vehicle),
        ],
      ),
    );
  }

  Widget _buildProfileDetail(IconData icon, String title, String value) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blueAccent),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- LOGOUT DIALOG ----------------
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              SharedPreferences prefs =
              await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pop(context);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("Logout",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
