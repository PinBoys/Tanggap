import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'buat_pengaduan.dart';
import 'akun.dart';
import 'pengaduan.dart';
import 'notifikasi.dart';

class DashboardPage extends StatefulWidget {
  final String namaUser;
  final String emailUser;
  final String? fotoProfile;

  const DashboardPage({
    super.key,
    required this.namaUser,
    required this.emailUser,
    this.fotoProfile,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> pengaduanTerbaru = [];
  String? fotoSekarang;
  String namaSekarang = "";

  @override
  void initState() {
    super.initState();
    namaSekarang = widget.namaUser;
    fotoSekarang = widget.fotoProfile;
    fetchPengaduanTerbaru();
    getLiveProfileFoto();
    getLiveProfile();
  }

  Future<void> getLiveProfileFoto() async {
    try {
      final res = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/profile/${widget.emailUser}"),
      );
      if (res.statusCode == 200) {
        final dataProfil = json.decode(res.body)['data'];
        if (mounted) {
          setState(() {
            fotoSekarang = dataProfil['foto_profil'];
          });
        }
      }
    } catch (e) {
      print("Gagal sync foto dashboard: $e");
    }
  }

  Future<void> getLiveProfile() async {
    try {
      final res = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/profile/${widget.emailUser}"),
      );

      if (res.statusCode == 200) {
        final dataProfil = jsonDecode(res.body)["data"];

        if (mounted) {
          setState(() {
            namaSekarang = dataProfil["full_name"] ?? widget.namaUser;
          });
        }
      }
    } catch (e) {
      print("Gagal sync nama: $e");
    }
  }

  Future<void> fetchPengaduanTerbaru() async {
    // --- PERUBAHAN DI SINI ---
    // Menggunakan API riwayat berdasarkan email agar tidak campur dengan pengaduan orang lain
    final String apiUrl =
        "http://127.0.0.1:8000/api/pengaduan/riwayat/${widget.emailUser}";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        if (mounted) {
          setState(() {
            pengaduanTerbaru = data
                .map(
                  (item) => {
                    "judul": item['judul'] ?? "Tanpa Judul",
                    "tanggal": item['tanggal_pengaduan'] ?? "-",
                    "status": item['status'] ?? "Menunggu",
                    "foto": item['bukti_pengaduan'],
                  },
                )
                .toList();
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Color getStatusColor(String status) {
    status = status.toUpperCase();

    if (status == "PENDING" || status == "MENUNGGU") {
      return Colors.orange;
    }

    if (status == "DIPROSES") {
      return Colors.blue;
    }

    if (status == "SELESAI") {
      return Colors.green;
    }

    return Colors.grey;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        currentIndex: 0,
        onTap: (index) {
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AkunPage(emailTarget: widget.emailUser),
              ),
            ).then((_) {
              getLiveProfileFoto();

              getLiveProfile();
            });
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PengaduanPage()),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BuatPengaduanPage(emailTarget: widget.emailUser),
              ),
            );
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NotifikasiPage(emailTarget: widget.emailUser),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: "Pengaduan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 60, color: Colors.blue),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifikasi",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo, $namaSekarang",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "selamat datang di",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Desa Maju Bersama",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.transparent,
                      child: fotoSekarang != null && fotoSekarang!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                fotoSekarang!.startsWith('http')
                                    ? fotoSekarang!
                                    : "http://10.0.2.2:8000$fotoSekarang",
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.account_circle,
                                      size: 35,
                                      color: Colors.black,
                                    ),
                              ),
                            )
                          : const Icon(
                              Icons.account_circle,
                              size: 35,
                              color: Colors.black,
                            ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // BANNER
                Stack(
                  children: [
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: NetworkImage(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSUgZnChkoRJWVhaAgq4X48HJkou3kN5i23w&s",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 15,
                      left: 15,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Sampaikan keluhan Anda",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Kami siap mendengar dan menindaklanjuti",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              height: 35,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BuatPengaduanPage(
                                        emailTarget: widget.emailUser,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Buat Pengaduan",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // TITLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pengaduan terbaru",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PengaduanPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Lihat Semua",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : pengaduanTerbaru.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            "Belum ada pengaduan",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      )
                    : Column(
                        children: pengaduanTerbaru.map((item) {
                          String title =
                              item["judul"]?.toString() ?? "Tanpa Judul";
                          String tanggal = item["tanggal"]?.toString() ?? "-";
                          String status =
                              item["status"]?.toString() ?? "Menunggu";
                          String? foto = item["foto"]?.toString();

                          return buildPengaduan(
                            title,
                            tanggal,
                            status,
                            getStatusColor(status),
                            foto,
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPengaduan(
    String title,
    String tanggal,
    String status,
    Color color,
    String? fotoUrl,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: fotoUrl != null && fotoUrl.isNotEmpty
                ? Image.network(
                    "http://10.0.2.2:8000$fotoUrl",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  tanggal,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusIndonesia(status),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
