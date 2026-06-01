import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_pengaduan.dart'; // <--- TAMBAHAN: Import halaman detail

class NotifikasiPage extends StatefulWidget {
  final String emailTarget; 
  
  const NotifikasiPage({super.key, this.emailTarget = "rya@gmail.com"});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  bool isLoading = true;
  List<dynamic> notifikasiList = [];

  @override
  void initState() {
    super.initState();
    fetchNotifikasi();
  }

  Future<void> fetchNotifikasi() async {
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:8000/api/pengaduan/riwayat/${widget.emailTarget}"));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          notifikasiList = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Notifikasi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "Tandai semua dibaca",
                style: TextStyle(color: Colors.blue, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
      
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifikasiList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text("Belum ada notifikasi", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pemberitahuan Terbaru",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      
                      ...notifikasiList.map((item) {
                        Color iconColor;
                        IconData icon;
                        String subtitleText;

                        if (item['status'] == "Menunggu") {
                          iconColor = Colors.orange;
                          icon = Icons.access_time_filled;
                          subtitleText = "Telah diterima sistem dan Menunggu antrean";
                        } else if (item['status'] == "Diproses") {
                          iconColor = Colors.blue;
                          icon = Icons.autorenew;
                          subtitleText = "Sedang dalam Proses tindak lanjut Admin";
                        } else {
                          iconColor = Colors.green;
                          icon = Icons.check_circle;
                          subtitleText = "Telah Selesai ditindaklanjuti. Terima kasih!";
                        }

                        return _buildNotifItem(
                          idPengaduan: item['id_pengaduan']?.toString() ?? "", // Mengambil ID untuk diklik
                          icon: icon,
                          iconColor: iconColor,
                          title: "Pengaduan #PGD-${item['id_pengaduan']} anda",
                          subtitle: subtitleText,
                          time: item['waktu'] ?? "00:00", 
                        );
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNotifItem({
    required String idPengaduan, // Parameter baru untuk ID
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return GestureDetector(
      onTap: () {
        // NAVIGASI KE HALAMAN DETAIL SAAT NOTIFIKASI DIKLIK
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPengaduanPage(idPengaduan: idPengaduan),
          ),
        );
      },
      child: Container(
        color: Colors.transparent, // Membuat seluruh area baris bisa diklik
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: iconColor.withOpacity(0.2),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}