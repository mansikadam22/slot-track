import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String phone;
  final String email;
  final String vehicle;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.vehicle,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController vehicleController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);
    emailController = TextEditingController(text: widget.email);
    vehicleController = TextEditingController(text: widget.vehicle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [

            // ---------------- PROFILE AVATAR ----------------
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlueAccent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 70, color: Colors.grey.shade600),
                    ),
                  ),

                  // ---- Small Edit Button ----
                  // Positioned(
                  //   right: 6,
                  //   bottom: 6,
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       color: Colors.blueAccent,
                  //     ),
                  //     padding: EdgeInsets.all(6),
                  //     child: Icon(Icons.edit, color: Colors.white, size: 16),
                  //   ),
                  // ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // ---------------- INPUT FIELDS ----------------
            _buildLabel("Full Name"),
            _buildInput(
              controller: nameController,
              icon: Icons.person,
            ),

            _buildLabel("Phone Number"),
            _buildInput(
              controller: phoneController,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            _buildLabel("Email Address"),
            _buildInput(
              controller: emailController,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),

            _buildLabel("Vehicle Number"),
            _buildInput(
              controller: vehicleController,
              icon: Icons.directions_car,
            ),

            SizedBox(height: 35),

            // ---------------- UPDATE BUTTON ----------------
            GestureDetector(
              onTap: () {
                Navigator.pop(context, {
                  "name": nameController.text,
                  "phone": phoneController.text,
                  "email": emailController.text,
                  "vehicle": vehicleController.text,
                });
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  "Update",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // ---------------- LABEL ----------------
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  // ---------------- INPUT FIELD ----------------
  Widget _buildInput({
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
