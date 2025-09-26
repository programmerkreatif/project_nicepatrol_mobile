import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatrolActivityScreen extends StatefulWidget {
  @override
  _PatrolActivityScreenState createState() => _PatrolActivityScreenState();
}

class _PatrolActivityScreenState extends State<PatrolActivityScreen> {
  String currentDate = "Hari Ini";

  List<Map<String, dynamic>> patrolData = [
    {
      'name': 'SELIBO',
      'status': 'Belum Cek',
      'color': Colors.red,
      'children': [],
    },
    {
      'name': 'LIDO',
      'status': 'Sedang Cek',
      'color': Colors.orange,
      'children': [
        {'name': 'Lido 01', 'status': 'Sudah Cek'},
        {'name': 'Lido 02', 'status': 'Sudah Cek'},
        {'name': 'Lido 03', 'status': 'Belum Cek'},
        {'name': 'Lido 04', 'status': 'Belum Cek'},
      ],
    },
    {
      'name': 'WADUK',
      'status': 'Belum Cek',
      'color': Colors.red,
      'children': [],
    },
    {
      'name': 'HITAM',
      'status': 'Sudah Cek',
      'color': Colors.green,
      'children': [],
    },
  ];

  Widget buildStatusChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.raleway(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Belum Cek':
        return Colors.red;
      case 'Sedang Cek':
        return Colors.orange;
      case 'Sudah Cek':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Aktivitas',
              style: GoogleFonts.raleway(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'Patrol',
                          style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Text(
                          'Patroli Mandiri',
                          style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Info Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktivitas $currentDate',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      currentDate = "Tanggal Diganti";
                    });
                  },
                  child: Text("Ganti Tanggal", style: GoogleFonts.raleway()),
                )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard(Icons.map, '4/8', 'Area'),
                _buildInfoCard(Icons.track_changes, '10/20', 'Rounds'),
                _buildInfoCard(Icons.qr_code, '25/50', 'Assets'),
              ],
            ),

            SizedBox(height: 24),

            Text(
              "Detail Patrol",
              style: GoogleFonts.raleway(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            SizedBox(height: 12),

            // Patrol List
            ...patrolData.map((item) {
              final children = item['children'] as List;
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['name'],
                          style: GoogleFonts.raleway(fontWeight: FontWeight.w600)),
                      buildStatusChip(item['status'], getStatusColor(item['status']))
                    ],
                  ),
                  children: children.map<Widget>((sub) {
                    return ListTile(
                      title: Text(
                        sub['name'],
                        style: GoogleFonts.raleway(),
                      ),
                      trailing: buildStatusChip(
                          sub['status'], getStatusColor(sub['status'])),
                    );
                  }).toList(),
                ),
              );
            }).toList()
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            SizedBox(height: 6),
            Text(value, style: GoogleFonts.raleway(fontWeight: FontWeight.bold)),
            Text(label,
                style: GoogleFonts.raleway(fontSize: 12, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
