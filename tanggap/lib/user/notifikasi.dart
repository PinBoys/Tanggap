import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "Tandai semua dibaca",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // HARI INI
            const Text(
              "Hari ini",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 12),

            _buildNotifItem(
              icon: Icons.warning,
              iconColor: Colors.orange,
              title:
                  "Pengaduan #PGD-2026-00012 anda",
              subtitle: "sedang dalam Proses",
              time: "17:10",
            ),

            _buildNotifItem(
              icon: Icons.warning,
              iconColor: Colors.orange,
              title:
                  "Pengaduan #PGD-2026-00010 anda",
              subtitle: "sedang dalam Proses",
              time: "12:50",
            ),

            _buildNotifItem(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              title:
                  "Pengaduan #PGD-2026-00008 anda",
              subtitle:
                  "Telah Selesai ditindaklanjuti",
              time: "08:23",
            ),

            const Divider(height: 30),

            // KEMARIN
            const Text(
              "Kemarin",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 12),

            _buildNotifItem(
              icon: Icons.warning,
              iconColor: Colors.orange,
              title:
                  "Pengaduan #PGD-2026-00009 anda",
              subtitle: "sedang dalam Proses",
              time: "14:25",
            ),

            _buildNotifItem(
              icon: Icons.warning,
              iconColor: Colors.orange,
              title:
                  "Pengaduan #PGD-2026-00008 anda",
              subtitle: "sedang dalam Proses",
              time: "10:45",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          CircleAvatar(
            radius: 16,
            backgroundColor:
                iconColor.withOpacity(0.2),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}