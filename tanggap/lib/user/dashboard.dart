import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

import 'buat_pengaduan.dart';
import 'akun.dart';
import 'pengaduan.dart';
import 'notifikasi.dart';

import '../helper/url_helper.dart';

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
        Uri.parse("http://10.0.2.2:8000/api/profile/${widget.emailUser}"),
      );
      if (res.statusCode == 200) {
        final dataProfil = jsonDecode(res.body)['data'];
        if (mounted) {
          setState(() {
            // PERBAIKAN: Cache-buster disematkan di sini saat data berhasil diambil
            String? rawFoto = dataProfil['foto_profil'];
            if (rawFoto != null && rawFoto.isNotEmpty && rawFoto != "null") {
              fotoSekarang = "$rawFoto?v=${DateTime.now().millisecondsSinceEpoch}";
            } else {
              fotoSekarang = null;
            }
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
        Uri.parse("http://10.0.2.2:8000/api/profile/${widget.emailUser}"),
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
    final String apiUrl =
        "http://10.0.2.2:8000/api/pengaduan/riwayat/${widget.emailUser}";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("================ RESPONSE =================");
      print(response.body);
      print("===========================================");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        
        debugPrint("DATA DARI SERVER: " + response.body);

      final List<dynamic> dataTerbaru =
      data.length > 5 ? data.take(5).toList() : data;

        if (mounted) {
          setState(() {
            pengaduanTerbaru = dataTerbaru.map((item) {
              // PERBAIKAN: Tambahkan cache buster ke foto pengaduan agar selalu mutakhir
              String? rawFoto = item['bukti_pengaduan'];
              String? finalFoto;
              if (rawFoto != null && rawFoto.isNotEmpty && rawFoto != "null") {
                finalFoto = "$rawFoto?v=${DateTime.now().millisecondsSinceEpoch}";
              }

              return {
                "judul": item['judul'] ?? "Tanpa Judul",
                "tanggal": item['tanggal_pengaduan'] ?? "-",
                "status": item['status'] ?? "Menunggu",
                "foto": finalFoto ?? rawFoto,
              };
            }).toList();

            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      print("ERROR FETCH : $e");

      if (mounted) {
        setState(() => isLoading = false);
      }
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
              MaterialPageRoute(
                builder: (context) => PengaduanPage(emailUser: widget.emailUser),
              ),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuatPengaduanPage(emailTarget: widget.emailUser),
              ),
            ).then((_) {
              // REFRESH DATA SETELAH KEMBALI DARI HALAMAN BUAT PENGADUAN
              fetchPengaduanTerbaru();
            });
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotifikasiPage(emailTarget: widget.emailUser),
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
                    
                    // FOTO PROFIL
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.transparent,
                      child: (fotoSekarang != null && fotoSekarang!.isNotEmpty && fotoSekarang != "null")
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: UrlHelper.getFullUrl(fotoSekarang ?? ""),
                                memCacheWidth: 300,
                                memCacheHeight: 200,
                                httpHeaders: const {
                                  "Connection": "keep-alive",
                                },
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 36,
                                  height: 36,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image, color: Colors.red),
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
                Stack(
                  children: [
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/banner.jpg"),
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
                                  ).then((value) async {
                                    if (value == true) {
                                      await fetchPengaduanTerbaru();
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    }
                                  });
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
                            builder: (context) => PengaduanPage(
                              emailUser: widget.emailUser,
                            ),
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
                              String title = item["judul"]?.toString() ?? "Tanpa Judul";
                              String tanggal = item["tanggal"]?.toString() ?? "-";
                              String status = item["status"]?.toString() ?? "Menunggu";
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
            child: (fotoUrl != null && fotoUrl.isNotEmpty && fotoUrl != "null")
                ? CachedNetworkImage(
                    imageUrl: UrlHelper.getFullUrl(fotoUrl),
                    memCacheWidth: 300,
                    memCacheHeight: 200,
                    httpHeaders: const {
                      "Connection": "keep-alive",
                    },
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        debugPrint("DEBUG ERROR FOTO: $error");
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.red),
                        );
                      },
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