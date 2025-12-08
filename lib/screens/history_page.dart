import 'package:flutter/material.dart';

class HistoryReportsPage extends StatelessWidget {
  const HistoryReportsPage({super.key});

  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color softGray = const Color(0xFFF2F4F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "History & Reports",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Report",
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 18),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _summaryCard(Icons.access_time, "Peak Usage Hour", "11 AM"),
                  const SizedBox(width: 12),
                  _summaryCard(Icons.place, "Most Occupied", "P2"),
                  const SizedBox(width: 12),
                  _summaryCard(Icons.calendar_today, "Events\n Today", "32"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 260,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(width: 210, child: _occupancyCard()),
                  const SizedBox(width: 14),
                  SizedBox(width: 210, child: _usageCard()),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Slot Analytics",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _slotCard("P1", Colors.red, "Most Occupied"),
                  const SizedBox(width: 12),
                  _slotCard("P2", Colors.green, "Mostly Free"),
                  const SizedBox(width: 12),
                  _slotCard("P3", Colors.orange, "Balanced"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _recentEventsSection(),
          ],
        ),
      ),
    );
  }

  // SUMMARY CARD
  Widget _summaryCard(IconData icon, String title, String value) {
    return Container(
      height: 150,
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9F1FF), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.blueAccent),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 8),
          Text(value,
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }


  Widget _occupancyCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF2F5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),

      child: Column(
        children: [
          const Text(
            "Occupancy Overview",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: MultiPieChartPainter(
                slices: [
                  PieSlice(percentage: 40, color: Colors.red),    // P1
                  PieSlice(percentage: 20, color: Colors.green),  // P2
                  PieSlice(percentage: 20, color: Colors.orange), // P3
                  PieSlice(percentage: 20, color: Colors.blue),   // P4
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            "Slot-wise Occupancy",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.circle, size: 10, color: Colors.red),
              SizedBox(width: 5),
              Text("P1"),
              SizedBox(width: 10),

              Icon(Icons.circle, size: 10, color: Colors.green),
              SizedBox(width: 5),
              Text("P2"),
              SizedBox(width: 10),

              Icon(Icons.circle, size: 10, color: Colors.orange),
              SizedBox(width: 5),
              Text("P3"),
              SizedBox(width: 10),

              Icon(Icons.circle, size: 10, color: Colors.blue),
              SizedBox(width: 5),
              Text("P4"),
            ],
          )
        ],
      ),
    );
  }


  Widget _usageCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFE7F1FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Usage by Hour",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Container(
            height: 140,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _BarGraphPainter(),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("6AM", style: TextStyle(fontSize: 12)),
              Text("9AM", style: TextStyle(fontSize: 12)),
              Text("11AM", style: TextStyle(fontSize: 12)),
              Text("12PM", style: TextStyle(fontSize: 12)),
              Text("6PM", style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slotCard(String slot, Color color, String status) {
    return Container(
      width: 120,
      height: 70,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slot,
                    maxLines: 2,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 3),
                Text(status,
                    overflow: TextOverflow.ellipsis,
                    style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _recentEventsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Events",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            children: [
              Chip(label: const Text("All"), backgroundColor: Colors.blue.shade50),
              Chip(label: const Text("Free → Occupied"), backgroundColor: Colors.green.shade50),
              Chip(label: const Text("Occupied → Free"), backgroundColor: Colors.red.shade50),
            ],
          ),

          const SizedBox(height: 20),
          _eventRow("10:45 AM", "A1 became Occupied"),
          _eventRow("10:47 AM", "A3 became Free"),
          _eventRow("11:12 AM", "A1 became Free"),
          _eventRow("12:04 PM", "P3 became Occupied"),
          _eventRow("1:27 PM", "P2 became Free"),
        ],
      ),
    );
  }

  Widget _eventRow(String time, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(time)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}


class PieSlice {
  final double percentage;
  final Color color;

  PieSlice({required this.percentage, required this.color});
}

class MultiPieChartPainter extends CustomPainter {
  final List<PieSlice> slices;

  MultiPieChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    double startAngle = -90 * 3.1416 / 180;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    for (final slice in slices) {
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28;

      final sweep = (slice.percentage / 100) * 3.1416 * 2;

      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class _BarGraphPainter extends CustomPainter {
  final List<double> values = [40, 65, 80, 55, 30];

  @override
  void paint(Canvas canvas, Size size) {
    const double maxValue = 100;

    const double leftPadding = 28;
    const double bottomPadding = 20;

    final double chartWidth = size.width - leftPadding;
    final double chartHeight = size.height - bottomPadding;

    final barPaint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1;

    // Y-axis
    canvas.drawLine(
      Offset(leftPadding, 0),
      Offset(leftPadding, chartHeight),
      axisPaint,
    );

    const steps = [100, 75, 50, 25, 0];
    for (int i = 0; i < steps.length; i++) {
      double y = (1 - steps[i] / maxValue) * chartHeight;

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width, y),
        gridPaint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: steps[i].toString(),
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
          canvas, Offset(leftPadding - textPainter.width - 6, y - 6));
    }

    double spacing = chartWidth / values.length;
    double barWidth = spacing * 0.4;

    for (int i = 0; i < values.length; i++) {
      double barHeight = (values[i] / maxValue) * chartHeight;

      double xCenter = leftPadding + spacing * (i + 0.5);
      double topY = chartHeight - barHeight;

      Rect rect = Rect.fromLTWH(
        xCenter - barWidth / 2,
        topY,
        barWidth,
        barHeight,
      );

      canvas.drawRect(rect, barPaint);
    }

    canvas.drawLine(
      Offset(leftPadding, chartHeight),
      Offset(size.width, chartHeight),
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}