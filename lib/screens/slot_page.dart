import 'package:flutter/material.dart';

class Slotpage extends StatefulWidget {
  const Slotpage({super.key});

  @override
  State<Slotpage> createState() => _SlotpageState();
}

class _SlotpageState extends State<Slotpage> {
  Map<String, bool> slots = {
    "P1": true,
    "P2": false,
    "P3": false,
    "P4": true,
  };

  @override
  Widget build(BuildContext context) {
    int total = slots.length;
    int available = slots.values.where((v) => v == true).length;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        title: const Text(
          "Live Map",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff1A1A1A),
          ),
        ),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusBox(available, total),

            const SizedBox(height: 25),

            const Text(
              "Live Structure Map",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff1A1A1A),
              ),
            ),

            const SizedBox(height: 20),

            _buildParkingMap(),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _legendDot(Colors.green, "Available"),
                _legendDot(Colors.red, "Occupied"),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _statusBox(int available, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$available / $total Slots Available",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Real-Time Parking Status",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_parking,
                size: 28, color: Colors.white),
          ),
        ],
      ),
    );
  }


  Widget _buildParkingMap() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        // color: Colors.white12,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.09),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),

      child: Column(
        children: [
          // building + trees
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildingBoxImproved(),
              const SizedBox(width: 20),
              Column(
                children: [
                  Row(
                    children: [
                      _trees(),
                      const SizedBox(height: 10),
                      _trees(),
                    ],
                  ),
                  Row(
                    children: [
                      _trees(),
                      const SizedBox(height: 10),
                      _trees(),
                    ],
                  ),

                ],
              )
            ],
          ),

          const SizedBox(height: 18), // Reduced from 35 → 18

          // FIRST SLOT ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _slotBox("P1"),
              _slotBox("P2"),
            ],
          ),

          const SizedBox(height: 10),

          // SECOND SLOT ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _slotBox("P3"),
              _slotBox("P4"),
            ],
          ),

          const SizedBox(height: 8),

          // ENTRY
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sensor_door,
                  size: 40, color: Colors.brown.shade500),
              const SizedBox(width: 8),
              Text(
                "ENTRY GATE",
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade700,
                ),
              )
            ],
          ),

          const SizedBox(height: 12),

          // BOTTOM ROAD
          Container(
            height: 42,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Container(
                height: 3,
                width: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildingBoxImproved() {
    return Container(
      height: 115,
      width: 165,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade600,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: const Center(
        child: Icon(Icons.apartment_rounded,
            size: 65, color: Colors.white70),
      ),
    );
  }

  Widget _trees() {
    return Icon(Icons.forest,
        size: 38, color: Colors.green.shade700);
  }

  Widget _slotBox(String slot) {
    bool isAvailable = slots[slot]!;

    return GestureDetector(
      onTap: () => _showSlotDetails(slot, isAvailable),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 80,
        width: 115,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAvailable ? Colors.green : Colors.red,
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isAvailable ? Colors.green : Colors.red)
                  .withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),

        child: Row(
          children: [
            Icon(Icons.directions_car_filled,
                size: 28,
                color: isAvailable ? Colors.green : Colors.red),
            const SizedBox(width: 10),
            Text(
              slot,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isAvailable ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // bottomsheet
  void _showSlotDetails(String slot, bool available) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Slot $slot",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Icon(
                    available ? Icons.check_circle : Icons.cancel,
                    color: available ? Colors.green : Colors.red,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    available ? "Available" : "Occupied",
                    style: TextStyle(
                      fontSize: 20,
                      color: available ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(radius: 8, backgroundColor: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
