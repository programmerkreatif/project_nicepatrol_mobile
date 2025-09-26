import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class CheckpointScreen extends StatefulWidget {
  final Map<String, dynamic> checkpointData;

  const CheckpointScreen({super.key, required this.checkpointData});

  @override
  State<CheckpointScreen> createState() => _CheckpointScreenState();
}

class _CheckpointScreenState extends State<CheckpointScreen> {
  final List<String> checkpointTitles = [
    'Gembok',
    'Pintu Besi',
    'Solar Cell',
    'Pager Besi',
  ];

  final Map<String, bool> _status = {
    'Gembok': true,
    'Pintu Besi': false,
    'Solar Cell': true,
    'Pager Besi': true,
  };

  final Map<String, String> _conditions = {};
  final Map<String, String> _descriptions = {};

  @override
  void initState() {
    for (var title in checkpointTitles) {
      _conditions[title] = 'Pengrusakan';
      _descriptions[title] = '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Text(
                  'Checkpoint',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Patroli Area A',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Well Minas',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 12),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/photo_checpoint.png',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/photo_checpoint.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              ...checkpointTitles.map(buildCheckpointItem).toList(),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text('Cancel', style: GoogleFonts.poppins()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Send',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget buildCheckpointItem(String title) {
  //   final isSafe = _status[title] ?? true;

  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 20),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[50],
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.grey[300]!),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(title,
  //                       style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
  //                   const SizedBox(height: 2),
  //                   Text("Pastikan ${title.toLowerCase()} dalam kondisi terkunci",
  //                       style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
  //                 ],
  //               ),
  //             ),
  //             Row(
  //               children: [
  //                 Text('Aman', style: GoogleFonts.poppins(fontSize: 12)),
  //                 Switch.adaptive(
  //                   value: isSafe,
  //                   onChanged: (val) {
  //                     setState(() {
  //                       _status[title] = val;
  //                     });
  //                   },
  //                   activeColor: Colors.blue,
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //         if (!isSafe) ...[
  //           const SizedBox(height: 16),
  //           Text("Kondisi $title *", style: GoogleFonts.poppins(fontSize: 13)),
  //           const SizedBox(height: 6),
  //           DropdownButtonFormField<String>(
  //             value: _conditions[title],
  //             items: ['Pengrusakan', 'Terkunci', 'Terbuka'].map((val) {
  //               return DropdownMenuItem<String>(
  //                 value: val,
  //                 child: Text(val, style: GoogleFonts.poppins()),
  //               );
  //             }).toList(),
  //             onChanged: (val) {
  //               setState(() {
  //                 _conditions[title] = val!;
  //               });
  //             },
  //             decoration: InputDecoration(
  //               isDense: true,
  //               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           Text("Description", style: GoogleFonts.poppins(fontSize: 13)),
  //           const SizedBox(height: 6),
  //           TextFormField(
  //             initialValue: _descriptions[title],
  //             maxLines: 3,
  //             onChanged: (val) {
  //               _descriptions[title] = val;
  //             },
  //             decoration: InputDecoration(
  //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           ElevatedButton.icon(
  //             onPressed: () {},
  //             icon: const Icon(Icons.camera_alt_outlined),
  //             label: Text('Ambil Foto', style: GoogleFonts.poppins()),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFFE5F0FB),
  //               foregroundColor: Colors.black,
  //               minimumSize: const Size.fromHeight(45),
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           Row(
  //             children: List.generate(3, (index) {
  //               return Stack(
  //                 alignment: Alignment.topRight,
  //                 children: [
  //                   Container(
  //                     margin: const EdgeInsets.only(right: 10),
  //                     width: 90,
  //                     height: 90,
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(8),
  //                       image: const DecorationImage(
  //                         image: AssetImage('assets/insiden.png'),
  //                         fit: BoxFit.cover,
  //                       ),
  //                     ),
  //                   ),
  //                   const CircleAvatar(
  //                     radius: 10,
  //                     backgroundColor: Colors.white,
  //                     child: Icon(Icons.close, size: 14, color: Colors.black),
  //                   ),
  //                 ],
  //               );
  //             }),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

Widget buildCheckpointItem(String title) {
  final isSafe = _status[title] ?? true;

  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text("Pastikan ${title.toLowerCase()} dalam kondisi terkunci",
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _status[title] = !_status[title]!;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 90,
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: isSafe ? Colors.blue : Colors.red,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment:
                      isSafe ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isSafe ? 'Aman' : 'Tidak',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (!isSafe) ...[
          const SizedBox(height: 16),
          Text("Kondisi $title *", style: GoogleFonts.poppins(fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _conditions[title],
            items: ['Pengrusakan', 'Terkunci', 'Terbuka'].map((val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val, style: GoogleFonts.poppins()),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _conditions[title] = val!;
              });
            },
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          Text("Description", style: GoogleFonts.poppins(fontSize: 13)),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: _descriptions[title],
            maxLines: 3,
            onChanged: (val) {
              _descriptions[title] = val;
            },
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text('Ambil Foto', style: GoogleFonts.poppins()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5F0FB),
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(45),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (index) {
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: AssetImage('assets/insiden.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, size: 14, color: Colors.black),
                  ),
                ],
              );
            }),
          ),
        ],
      ],
    ),
  );
}

}
