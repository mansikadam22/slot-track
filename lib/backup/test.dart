import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:async';
import 'dart:math';

class HistoryReportsPage extends StatefulWidget {
  const HistoryReportsPage({super.key});

  @override
  State<HistoryReportsPage> createState() => _HistoryReportsPageState();
}

class _HistoryReportsPageState extends State<HistoryReportsPage> {
  Map<String, dynamic>? historyData;
  bool isLoading = true;
  bool hasError = false;

  // ⭐ ADDED: filter state
  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
  }

  Future<void> fetchHistoryData() async {
    try {
      final response = await ApiService.getHistoryReports();
      if (mounted) {
        setState(() {
          historyData = response;
          isLoading = false;
          hasError = response == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  final TextStyle sectionTitleStyle =
  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87);

  final double cardRadius = 18.0;

  @override
  Widget build(BuildContext context) {
    final Color softGray = const Color(0xFFF2F4F7);

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F4F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || historyData == null) {
      return Scaffold(
        backgroundColor: softGray,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            "History & Reports",
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: const Center(child: Text("Failed to load data")),
      );
    }

    final todaySummary = historyData!['todaySummary'] ?? {};
    final occupancyOverview =
        historyData!['occupancyOverview']?['bySlot'] as List? ?? <dynamic>[];
    final usageByHour = historyData!['usageByHour'] as List? ?? <dynamic>[];
    final slotAnalytics = historyData!['slotAnalytics'] as List? ?? <dynamic>[];
    final recentEvents = historyData!['recentEvents'] as List? ?? <dynamic>[];

    return Scaffold(
      backgroundColor: softGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "History & Reports",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Reports",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),

            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _summaryCard(
                    icon: Icons.access_time_outlined,
                    title: "Peak Usage\nHour",
                    value: (todaySummary['peakUsageHour'] ?? "N/A").toString(),
                    color: const Color(0xFFEAF6FF),
                  ),
                  const SizedBox(width: 12),
                  _summaryCard(
                    icon: Icons.place_outlined,
                    title: "Most\nOccupied",
                    value: todaySummary['mostOccupiedSlot']?['slotName']
                        ?.toString() ??
                        "N/A",
                    color: const Color(0xFFFFF2EA),
                  ),
                  const SizedBox(width: 12),
                  _summaryCard(
                    icon: Icons.calendar_today_outlined,
                    title: "Events\nToday",
                    value: (todaySummary['eventsToday'] ?? 0).toString(),
                    color: const Color(0xFFEFF9F1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 250,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  SizedBox(
                    width: 280,
                    child: _occupancyCard(occupancyOverview),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 280,
                    child: _usageCard(usageByHour),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text("Slot Analytics", style: sectionTitleStyle),
            const SizedBox(height: 12),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: slotAnalytics.map<Widget>((slot) {
                  final label = slot['label']?.toString() ?? "Balanced";
                  final slotName = slot['slotName']?.toString() ?? "";
                  final chipColor = _chipColorForLabel(label);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _analyticsChip(slotName, label, chipColor),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // ⭐ UPDATED SECTION
            _recentEventsSection(recentEvents),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------- summary card ----------------
  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        gradient: LinearGradient(
          colors: [Colors.white, color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: const Color(0xFF2F80ED)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ---------------- occupancy card ----------------
  Widget _occupancyCard(List occupancy) {
    final safeList = occupancy.cast<dynamic>();

    double total = safeList.fold<double>(
      0,
          (sum, slot) =>
      sum +
          (slot['value'] is num ? (slot['value'] as num).toDouble() : 0),
    );

    if (total == 0 && safeList.isNotEmpty) {
      total = safeList.length.toDouble();
    }

    final slices = safeList.map<PieSlice>((slot) {
      final value =
      (slot['value'] is num ? (slot['value'] as num).toDouble() : 0);
      final percent = total > 0
          ? (value / total) * 100
          : (100 / max(1, safeList.length));
      return PieSlice(
        percent: percent.toDouble(),
        color: _colorForSlotName(slot['slotName']?.toString() ?? ""),
        label: slot['slotName']?.toString() ?? "",
        rawValue: value.toDouble(),
      );
    }).toList();

    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFEFF8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Occupancy Overview",
              style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text("Slot-wise Occupancy",
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 150,
                height: 120,
                child: CustomPaint(
                  painter: DonutChartPainter(slices: slices),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: slices.map((s) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                  color: s.color,
                                  borderRadius:
                                  BorderRadius.circular(4))),
                          const SizedBox(width: 5),
                          Expanded(
                              child: Text(s.label,
                                  style: const TextStyle(
                                      fontSize: 14))),
                          Text((s.rawValue).toString(),
                              style:
                              const TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- usage card ----------------
  Widget _usageCard(List usageByHour) {
    final safeList = usageByHour.cast<dynamic>();

    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF1F8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Usage by Hour",
              style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          SizedBox(
            height: 150,
            child: safeList.isEmpty
                ? const Center(
              child: Text("No hourly data available",
                  style: TextStyle(color: Colors.black54)),
            )
                : UsageByHourChart(data: safeList),
          ),

          const SizedBox(height: 8),

          if (safeList.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: safeList.map<Widget>((h) {
                return Text(
                  h['label'].toString(),
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ---------------- slot analytics chip ----------------
  Widget _analyticsChip(String slot, String label, Color bg) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration:
              BoxDecoration(color: bg, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(slot,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }

  // ---------------- RECENT EVENTS (UPDATED) ----------------
  Widget _recentEventsSection(List events) {
    final ev = events.cast<dynamic>();

    // ⭐ APPLY FILTER
    final filteredList = ev.where((e) {
      if (selectedFilter == "All") return true;
      return e["direction"]?.toString() == selectedFilter;
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Events",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          // ⭐ FILTER CHIPS
          Wrap(
            spacing: 10,
            children: [
              _buildFilterChip("All"),
              _buildFilterChip("Free → Occupied"),
              _buildFilterChip("Occupied → Free"),
            ],
          ),

          const SizedBox(height: 14),

          if (filteredList.isEmpty)
            const Center(
                child: Text("No recent events",
                    style: TextStyle(color: Colors.black54)))
          else
            Column(
              children: filteredList.map<Widget>((e) {
                final timeString = e['time']?.toString() ?? "";
                DateTime? parsed;
                try {
                  parsed = DateTime.tryParse(timeString)?.toLocal();
                } catch (_) {
                  parsed = null;
                }

                final formattedTime = parsed != null
                    ? "${_formatHour(parsed)}"
                    : "--:--";

                final slotName = e['slotName']?.toString() ?? "";
                final direction =
                    e['direction']?.toString() ?? "";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(formattedTime,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 20),
                      Expanded(
                          child: Text("$slotName $direction")),
                    ],
                  ),
                );
              }).toList(),
            )
        ],
      ),
    );
  }

  // ⭐ FILTER CHIP WIDGET
  Widget _buildFilterChip(String label) {
    final bool selected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = label);
      },
      child: Chip(
        label: Text(label),
        backgroundColor:
        selected ? Colors.blue.shade100 : Colors.grey.shade200,
        labelStyle: TextStyle(
          color: selected ? Colors.blue : Colors.black,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  String _formatHour(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $suffix";
  }

  Color _colorForSlotName(String slotName) {
    switch (slotName) {
      case "P1":
        return const Color(0xFFEF9A9A);
      case "P2":
        return const Color(0xFF81C784);
      case "P3":
        return const Color(0xFFFFCC80);
      case "P4":
        return const Color(0xFF64B5F6);
      default:
        return Colors.grey;
    }
  }

  Color _chipColorForLabel(String label) {
    switch (label) {
      case "Most Occupied":
        return const Color(0xFFF28B82);
      case "Mostly Free":
        return const Color(0xFF81C784);
      case "Balanced":
        return const Color(0xFFFFD54F);
      default:
        return const Color(0xFF90CAF9);
    }
  }
}

// ---------------------------------------------
// DONUT + BAR CHART CODE (UNCHANGED)
// ---------------------------------------------

class PieSlice {
  final double percent;
  final Color color;
  final String label;
  final double rawValue;

  PieSlice({
    required this.percent,
    required this.color,
    required this.label,
    required this.rawValue,
  });
}

class DonutChartPainter extends CustomPainter {
  final List<PieSlice> slices;
  DonutChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height)

        / 2 - 6;
    final holeRadius = radius * 0.5;
    double startAngle = -pi / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    for (final slice in slices) {
      final sweep = (slice.percent / 100) * 2 * pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.36
        ..color = slice.color;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    final holePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, holeRadius, holePaint);

    final total = slices.fold<double>(0, (s, x) => s + x.rawValue);
    final textSpan = TextSpan(
      text: total.toStringAsFixed(0),
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87),
    );
    final tp = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class UsageByHourChart extends StatelessWidget {
  final List<dynamic> data;
  const UsageByHourChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text("No data"));

    final double maxY = data.fold<double>(
      0,
          (p, e) => max(p, (e["events"] as num).toDouble()),
    );

    final int ySteps = 4;
    final double interval = maxY == 0 ? 1 : (maxY / ySteps);

    return Container(
      height: 180,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(ySteps + 1, (i) {
                final value = (maxY - (i * interval));
                final v = value <= 0 ? 0 : value.round();
                return Text(
                  v.toString(),
                  style: const TextStyle(
                      fontSize: 11, color: Colors.black54),
                );
              }),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: LayoutBuilder(
              builder: (ctx, c) {
                final chartHeight = c.maxHeight - 30;

                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              ySteps + 1,
                                  (_) => Container(
                                height: 1,
                                width: double.infinity,
                                color: Colors.black12
                                    .withOpacity(0.2),
                              ),
                            ),
                          ),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: data.map((h) {
                              final events =
                              (h["events"] as num).toDouble();
                              final barHeight = maxY == 0
                                  ? 10
                                  : (events / maxY) *
                                  chartHeight;

                              return Column(
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 22,
                                    height: barHeight.toDouble(),
                                    decoration: BoxDecoration(
                                      color:
                                      const Color(0xFF2F80ED),
                                      borderRadius:
                                      BorderRadius.circular(
                                          4),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      children: data.map((h) {
                        return Text(
                          h["label"].toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
