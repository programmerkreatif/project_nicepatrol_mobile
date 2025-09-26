import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatrolCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String distance;
  final String statusText;
  final Color statusColor;
    final VoidCallback? onTap; // <--- Tambahkan ini


  const PatrolCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.distance,
    required this.statusText,
    required this.statusColor,
        this.onTap, // <--- Tambahkan ini

  });

  @override
  Widget build(BuildContext context) {
    return 
    InkWell(
      onTap: onTap, // <--- Klik akan dipanggil di sini
      borderRadius: BorderRadius.circular(12),

    
    child : Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar
          // ClipRRect(
          //   borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          //   child: Image.network(
          //     imageUrl,
          //     height: 100,
          //     width: double.infinity,
          //     fit: BoxFit.cover,
          //   ),
          // ),

          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imageUrl, // tetap pakai imageUrl agar reusable
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Isi teks
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Status (sejajar)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Lokasi
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        distance,
                        style: GoogleFonts.manrope(
                          fontSize: 11.5,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
