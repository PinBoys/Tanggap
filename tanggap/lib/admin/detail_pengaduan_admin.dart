import 'package:flutter/material.dart';
import 'tindak_lanjut_admin.dart';

class DetailPengaduanAdminPage extends StatelessWidget {
  final Map<String, dynamic> pengaduan;

  const DetailPengaduanAdminPage({super.key, required this.pengaduan});

  String statusIndonesia(String status) {
    switch (status) {
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

  Color statusColor(String status) {
    if (status == "PENDING") {
      return Colors.orange.shade100;
    }

    if (status == "DIPROSES") {
      return Colors.blue.shade100;
    }

    if (status == "SELESAI") {
      return Colors.green.shade100;
    }

    return Colors.grey.shade200;
  }

  Color statusTextColor(String status) {
    if (status == "PENDING") {
      return Colors.orange.shade800;
    }

    if (status == "DIPROSES") {
      return Colors.blue.shade800;
    }

    if (status == "SELESAI") {
      return Colors.green.shade800;
    }

    return Colors.black;
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
          "Detail Pengaduan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  pengaduan["id"].toString().substring(0, 8),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: statusColor(pengaduan["status"] ?? ""),

                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Text(
                    statusIndonesia(pengaduan["status"] ?? ""),
                    style: TextStyle(
                      color: statusTextColor(pengaduan["status"] ?? ""),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            _item("Judul Pengaduan", pengaduan["title"] ?? "-"),

            _item("Lokasi Kejadian", pengaduan["address_note"] ?? "-"),

            _item("Tanggal", pengaduan["created_at"] ?? "-"),

            _item("Keluhan/Deskripsi", pengaduan["description"] ?? "-"),

            _item("Tingkat Urgensi", "Sedang"),

            _item("Dampak Keselamatan", "Resiko Luka"),

            _item("Sensitivitas Waktu", "Cepat"),

            _item("Ketersediaan Alternatif", "Sulit"),

            _item("Cakupan Populasi", "Lingkungan"),

            const SizedBox(height: 20),

            const Text(
              "Foto Bukti",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                _image(),

                const SizedBox(width: 10),

                _image(),

                const SizedBox(width: 10),

                _image(),
              ],
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TindakLanjutAdminPage(pengaduan: pengaduan),
                    ),
                  );
                },

                child: const Text(
                  "Tindak lanjuti",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 130,

            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _image() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),

      child: Image.asset(
        "assets/images/jalanberlubang.jpeg",
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      ),
    );
  }
}
