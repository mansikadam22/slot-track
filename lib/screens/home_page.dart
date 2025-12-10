import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

import '../utils/auth_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.changeTab});
  final Function(int)? changeTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  List notifications = [];
  bool isLoadingNotifications = true;
  Timer? sliderTimer;
  String? role;
  bool isGuest = true;
  bool isProfileLoaded = false;

  final Color primaryBlue = const Color(0xFF1E88E5);
  final Color lightBlue = const Color(0xFF42A5F5);
  final Color bgSoft = const Color(0xFFF5F7FA);

  bool get isAdmin => role == "admin" && !isGuest;

  @override
  void initState() {
    super.initState();

    sliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        currentPage = (currentPage + 1) % 3;
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });

    fetchNotifications();
    loadUserProfile();
  }

  @override
  void dispose() {
    sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadUserProfile() async {
    final profile = await ApiService.getUserProfile();
    final guestStatus = await AuthStorage.isGuest();

    setState(() {
      isGuest = guestStatus;
      role = isGuest ? null : profile?['role']; // <-- ignore API role for guest
      isProfileLoaded = true;
    });

    print("Loaded user profile:");
    print("Role: $role");
    print("Is guest: $isGuest");
  }


  Future<void> fetchNotifications() async {
    final data = await ApiService.getNotifications();
    setState(() {
      notifications = data;
      isLoadingNotifications = false;
    });
  }

  void showAddNotificationDialog() {
    String name = '';
    String message = '';
    String startDate = DateTime.now().toIso8601String();
    String endDate = DateTime.now().add(const Duration(days: 1)).toIso8601String();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Notification"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Name"),
              onChanged: (val) => name = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Message"),
              onChanged: (val) => message = val,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final success = await ApiService.addNotification(
                name: name,
                message: message,
                createdBy: 1,
                startDate: startDate,
                endDate: endDate,
              );
              if (success) {
                fetchNotifications();
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void showUpdateNotificationDialog(Map item) {
    String message = item["message"] ?? "";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Update Notification"),
        content: TextField(
          decoration: const InputDecoration(labelText: "Message"),
          controller: TextEditingController(text: message),
          onChanged: (val) => message = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final success = await ApiService.updateNotification(item["id"], {"message": message});
              if (success) {
                fetchNotifications();
                Navigator.pop(ctx);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void deleteNotification(Map item) async {
    final success = await ApiService.deleteNotification(item["id"]);
    if (success) fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        title: const Text('Smart Parking'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopSlider(),
            const SizedBox(height: 10),
            _buildStatusRow(),
            const SizedBox(height: 20),
            _buildFeatureGrid(),
            const SizedBox(height: 20),
            _buildNotificationSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSlider() {
    return ClipPath(
      clipper: BottomCurveClipper(),
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryBlue, lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PageView(
                controller: _pageController,
                children: const [
                  SlideBox(
                    text: "Convenient Parking made simple and stress-free",
                    color: Colors.black,
                    image: "assets/car1.jpeg",
                  ),
                  SlideBox(
                    text: "Smart Parking Solutions for a smoother Journey",
                    color: Colors.deepOrange,
                    image: "assets/car2.jpg",
                  ),
                  SlideBox(
                    text: "Drive In, Park Smart, and Save Time",
                    color: Colors.blue,
                    image: "assets/car3.jpg",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const StatusTile(icon: Icons.circle, text: "Active: 3"),
          const StatusTile(icon: Icons.crop_square, text: "Total: 4"),
          const StatusTile(icon: Icons.directions_car, text: "Cars: 12"),
          StatusTile(
            icon: Icons.notifications,
            text: "Alerts: ${notifications.length}",
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          FeatureCard(
            title: "Find Parking",
            icon: Icons.local_parking,
            type: 1,
            screenType: 1,
            changeTab: widget.changeTab,
          ),
          FeatureCard(
            title: "Live Map",
            icon: Icons.map,
            type: 2,
            screenType: 2,
            changeTab: widget.changeTab,
          ),
          FeatureCard(
            title: "History & Reports",
            icon: Icons.bar_chart,
            type: 3,
            screenType: 3,
            changeTab: widget.changeTab,
          ),
          FeatureCard(
            title: "Profile",
            icon: Icons.person,
            type: 4,
            screenType: 4,
            changeTab: widget.changeTab,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    if (!isProfileLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                onPressed: showAddNotificationDialog,
                child: const Text("Add Notification"),
              ),
            ),
          isLoadingNotifications
              ? Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
              ],
            ),
            child: const Text(
              "Loading notifications...",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF003780)),
            ),
          )
              : notifications.isEmpty
              ? Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
              ],
            ),
            child: const Text(
              "No notifications available",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF003780)),
            ),
          )
              : Column(
            children: notifications.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info, color: primaryBlue, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item["message"] ?? "",
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF003780)),
                          ),
                        ),
                      ],
                    ),
                    if (isAdmin)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => showUpdateNotificationDialog(item), child: const Text("Edit")),
                          TextButton(onPressed: () => deleteNotification(item), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                        ],
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ------------------------ STATUS TILE ------------------------
class StatusTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const StatusTile({
    super.key,
    required this.icon,
    required this.text,
  });

  Color _getColor() {
    if (text.contains("Active")) return const Color(0xFF1E88E5);
    if (text.contains("Total")) return const Color(0xFF6D4C41);
    if (text.contains("Cars")) return const Color(0xFF2E7D32);
    if (text.contains("Alerts")) return const Color(0xFFD32F2F);
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ------------------------ FEATURE CARD ------------------------
class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int type;
  final int screenType;
  final Function(int)? changeTab;

  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.type,
    required this.screenType,
    this.changeTab,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color ic;

    if (type == 1) {
      bg = const Color(0xFFE3F2FD);
      ic = const Color(0xFF1565C0);
    } else if (type == 2) {
      bg = const Color(0xFFE8F5E9);
      ic = const Color(0xFF2E7D32);
    } else if (type == 3) {
      bg = const Color(0xFFFFF8E1);
      ic = const Color(0xFFF9A825);
    } else {
      bg = const Color(0xFFF3E5F5);
      ic = const Color(0xFF8E24AA);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        if (screenType == 1) {
          changeTab?.call(1);
        } else if (screenType == 2) {
          changeTab?.call(1);
        } else if (screenType == 3) {
          changeTab?.call(2);
        } else {
          changeTab?.call(3);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: ic),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------ SLIDE BOX ------------------------
class SlideBox extends StatelessWidget {
  final String text;
  final Color color;
  final String image;

  const SlideBox({
    super.key,
    required this.text,
    required this.color,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 330,
        height: 175,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                child: Stack(
                  children: [
                    Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.6),
                              Colors.transparent
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
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
      ),
    );
  }
}

// ---------------------- CURVE CLIPPER ----------------------
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 80,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
