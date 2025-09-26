import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patroli/request/RequestHelper.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  int selectedTab = 0;
  final tabs = ['Semua', 'Absensi', 'Tugas', 'Atensi'];


  Map<String, int> notifCounts = {
  'Semua': 0,
  'Absensi': 0,
  'Tugas': 0,
  'Atensi': 0,
};



  List<dynamic> allNotifications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() => isLoading = true);

    String? filter;
    if (selectedTab != 0) filter = tabs[selectedTab].toLowerCase();

    final result = await Requesthelper.fetchNotifications(filter: filter);

    if (result['success']) {
      setState(() {
        allNotifications = result['data'];

            setState(() {
      allNotifications = result['data'] ?? [];

      final count = result['count'] ?? {};
      notifCounts = {
        'Semua': count['semua'] ?? 0,
        'Absensi': count['absensi'] ?? 0,
        'Tugas': count['tugas'] ?? 0,
        'Atensi': count['atensi'] ?? 0,
      };
    });


      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ?? 'Gagal mengambil notifikasi')),
      );
    }
    setState(() => isLoading = false);
  }

  List<Map<String, dynamic>> get filteredNotifications {
    return allNotifications.map((notif) {
      return {
        'icon': getIconPath(notif['status']),
        'title': notif['status'] ?? '-',
        'desc': notif['text'] ?? '-',
        'time': formatTimeAgo(notif['created_at'] ?? ''),
        'category': notif['status'] ?? 'Unknown',
      };
    }).toList();
  }

  String getIconPath(String? status) {

    print("CHECK DATA : ");
    print(status);
    switch (status?.toLowerCase()) {
      case 'absensi':
        return 'assets/CalendarCheck.png';
      case 'tugas':
        return 'assets/Newspaper.png';
      case 'atensi':
        return 'assets/Megaphone.png';
      default:
        return 'assets/CalendarCheck.png';
    }
  }

  String formatTimeAgo(String timestamp) {
    try {
      final time = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final diff = now.difference(time);
      if (diff.inMinutes < 1) return '${diff.inSeconds}s lalu';
      if (diff.inHours < 1) return '${diff.inMinutes}m lalu';
      if (diff.inDays < 1) return '${diff.inHours} jam lalu';
      return '${diff.inDays} hari lalu';
    } catch (_) {
      return '-';
    }
  }

  int countByCategory(String category) {
    if (category == 'Semua') return allNotifications.length;
    return allNotifications
        .where((notif) =>
            (notif['status'] ?? '').toString().toLowerCase() ==
            category.toLowerCase())
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0071CE),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: Text('Notifikasi',
            style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = index == selectedTab;
                  final category = tabs[index];
                  final count = notifCounts[category] ?? 0;

                  // final count = countByCategory(category);
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedTab = index);
                      fetchNotifications();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD9EAF8)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0XFF0071CE)
                                  : const Color(0xFFAAAAAA),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$count',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? const Color(0XFF0071CE)
                                  : const Color(0xFF808080),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final notif = filteredNotifications[index];
                final isEven = index % 2 == 0;
                return Container(
                  color: isEven ? Colors.white : const Color(0xFFE6F1FA),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Image.asset(
                        notif['icon'],
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notif['title'] ?? '-',
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: const Color(0xff002848),
                                    ),
                                  ),
                                ),
                                Text(
                                  notif['time'] ?? '-',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notif['desc'] ?? '-',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: const Color(0xff002848),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
