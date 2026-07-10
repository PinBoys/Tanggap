import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'detail_pengaduan_admin.dart';

import '../helper/url_helper.dart';

class NotifikasiAdminPage extends StatefulWidget {
  const NotifikasiAdminPage({super.key});

  @override
  State<NotifikasiAdminPage> createState() => _NotifikasiAdminPageState();
}

class _NotifikasiAdminPageState extends State<NotifikasiAdminPage> {
  List notifikasi = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getNotifikasi();
  }

  Future<void> getNotifikasi() async {
    try {
      final response = await http.get(
        Uri.parse(UrlHelper.api('/api/admin/notifikasi')),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        setState(() {
          notifikasi = data["data"];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error notifikasi: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  String statusIndonesia(String status) {
    switch (status.toUpperCase()) {
      case "PENDING":
        return "Menunggu";

      case "DIPROSES":
        return "Diproses";

      case "SELESAI":
        return "Selesai";

      default:
        return status;
    }
  }

  String pesanNotifikasi(String judul, String status) {
    switch (status.toUpperCase()) {
      case "PENDING":
        return "Pengaduan $judul sedang menunggu tindak lanjut";

      case "DIPROSES":
        return "Pengaduan $judul sedang diproses petugas";

      case "SELESAI":
        return "Pengaduan $judul telah selesai ditangani";

      default:
        return judul;
    }
  }

  Color getUrgencyColor(String urgensi) {
    urgensi = urgensi.toUpperCase();

    switch (urgensi) {
      case "SANGAT TINGGI":
        return Colors.red;

      case "TINGGI":
        return Colors.red.shade700;

      case "SEDANG":
        return Colors.orange;

      case "RENDAH":
        return Colors.amber;

      case "SANGAT RENDAH":
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  IconData getUrgencyIcon(String urgensi) {
    urgensi = urgensi.toUpperCase();

    switch (urgensi) {
      case "SANGAT TINGGI":
        return Icons.warning_rounded;

      case "TINGGI":
        return Icons.priority_high;

      case "SEDANG":
        return Icons.notifications_active;

      case "RENDAH":
        return Icons.info_outline;

      case "SANGAT RENDAH":
        return Icons.check_circle;

      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.black),

        centerTitle: true,

        title: const Text(
          "Notifikasi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),

              itemCount: notifikasi.length,

              itemBuilder: (context, index) {
                final item = notifikasi[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(12),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPengaduanAdminPage(
                          pengaduan: item,
                        ),
                      ),
                    );
                  },

                  child: notifItem(
                    icon: getUrgencyIcon(
                      item["urgency_level"] ?? "SEDANG",
                    ),

                    iconColor: Colors.white,

                    bgColor: getUrgencyColor(
                      item["urgency_level"] ?? "SEDANG",
                    ),

                    text: pesanNotifikasi(
                      item["title"],
                      item["status"],
                    ),

                    time: item["created_at"]
                          .toString()
                          .substring(11, 16),

                    textColor: getUrgencyColor(
                      item["urgency_level"] ?? "SEDANG",
                    ),
                  ),
                );
              },
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
      margin: const EdgeInsets.only(bottom: 20),

      padding: const EdgeInsets.only(bottom: 15),

      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),

            child: Icon(icon, color: iconColor, size: 22),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(text, style: TextStyle(color: textColor, fontSize: 14)),
          ),

          const SizedBox(width: 10),

          Text(
            time,

            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
