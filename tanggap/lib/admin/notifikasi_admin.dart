import 'package:flutter/material.dart';

class NotifikasiAdminPage extends StatelessWidget {
  const NotifikasiAdminPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),

        centerTitle: true,

        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: Colors.black,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // HARI INI
            const Text(
              "Hari ini",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            notifItem(
              icon: Icons.notifications,
              iconColor: Colors.brown,
              bgColor: Colors.orange.shade100,
              text:
                  "Pengaduan #PGD-2026-00012 tentang Infrastruktur jalan sedang dalam Proses",
              time: "17:10",
              textColor: Colors.black,
            ),

            notifItem(
              icon: Icons.notifications,
              iconColor: Colors.brown,
              bgColor: Colors.orange.shade100,
              text:
                  "Pengaduan #PGD-2026-00012 tentang Infrastruktur jalan dengan Prioritas Sedang",
              time: "12:50",
              textColor: Colors.orange,
            ),

            notifItem(
              icon: Icons.check,
              iconColor: Colors.white,
              bgColor: Colors.greenAccent,
              text:
                  "Pengaduan #PGD-2026-00008 tentang Penerangan Jalan telah Selesai",
              time: "08:23",
              textColor: Colors.black,
            ),

            const SizedBox(height: 25),

            // KEMARIN
            const Text(
              "Kemarin",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            notifItem(
              icon: Icons.notifications,
              iconColor: Colors.brown,
              bgColor: Colors.orange.shade100,
              text:
                  "Pengaduan #PGD-2026-00008 tentang Penerangan Jalan sedang dalam Proses",
              time: "14:30",
              textColor: Colors.black,
            ),

            notifItem(
              icon: Icons.notifications,
              iconColor: Colors.brown,
              bgColor: Colors.orange.shade100,
              text:
                  "Pengaduan #PGD-2026-00008 tentang Penerangan Jalan dengan Prioritas Tinggi",
              time: "10:45",
              textColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget notifItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String text,
    required String time,
    required Color textColor,
  }) {

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 20,
      ),

      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),

      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(
            width: 35,
            height: 35,

            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,

              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Text(
            time,

            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}