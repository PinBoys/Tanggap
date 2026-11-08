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
  static const Color primaryBlue = Color(0xFF1769AA);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color pageBackground = Color(0xFFF3F7FC);

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
        Uri.parse(UrlHelper.api('api/profile/${widget.emailUser}')),
      );

      if (res.statusCode == 200) {
        final dataProfil = jsonDecode(res.body)['data'];
        if (mounted) {
          setState(() {
            String? rawFoto = dataProfil['foto_profil'];
            debugPrint("FOTO PROFILE RAW: $rawFoto");
            debugPrint("FOTO PROFILE URL: ${UrlHelper.getFullUrl(rawFoto)}");
            if (rawFoto != null && rawFoto.isNotEmpty && rawFoto != "null") {
              fotoSekarang =
                  "$rawFoto?v=${DateTime.now().millisecondsSinceEpoch}";
            } else {
              fotoSekarang = null;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal sync foto dashboard: $e");
    }
  }

  Future<void> getLiveProfile() async {
    try {
      final res = await http.get(
        Uri.parse(UrlHelper.api('api/profile/${widget.emailUser}')),
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
      debugPrint("Gagal sync nama: $e");
    }
  }

  Future<void> fetchPengaduanTerbaru() async {
    final String apiUrl =
        UrlHelper.api('/api/pengaduan/riwayat/${widget.emailUser}');

    try {
      if (mounted) setState(() => isLoading = true);

      final response = await http.get(Uri.parse(apiUrl));

      debugPrint("================ RESPONSE =================");
      debugPrint(response.body);
      debugPrint("===========================================");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        final List<dynamic> dataTerbaru =
            data.length > 5 ? data.take(5).toList() : data;

        if (mounted) {
          setState(() {
            pengaduanTerbaru = dataTerbaru.map((item) {
              String? rawFoto = item['bukti_pengaduan'];
              debugPrint("FOTO PENGADUAN RAW: $rawFoto");
              debugPrint("FOTO PENGADUAN URL: ${UrlHelper.getFullUrl(rawFoto)}");
              String? finalFoto;
              if (rawFoto != null && rawFoto.isNotEmpty && rawFoto != "null") {
                finalFoto =
                    "$rawFoto?v=${DateTime.now().millisecondsSinceEpoch}";
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
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("ERROR FETCH: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Color getStatusColor(String status) {
    status = status.toUpperCase();

    if (status == "PENDING" || status == "MENUNGGU") {
      return const Color(0xFFB76E00);
    }
    if (status == "DIPROSES") {
      return const Color(0xFF1769AA);
    }
    if (status == "SELESAI") {
      return const Color(0xFF16834A);
    }
    return Colors.grey;
  }

  Color getStatusBackground(String status) {
    status = status.toUpperCase();

    if (status == "PENDING" || status == "MENUNGGU") {
      return const Color(0xFFFFF1D6);
    }
    if (status == "DIPROSES") {
      return const Color(0xFFE4F1FF);
    }
    if (status == "SELESAI") {
      return const Color(0xFFE3F5E9);
    }
    return const Color(0xFFF0F1F2);
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

  void bukaBuatPengaduan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BuatPengaduanPage(emailTarget: widget.emailUser),
      ),
    ).then((value) async {
      if (value == true) {
        await fetchPengaduanTerbaru();
      }
    });
  }

  void bukaPengaduan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PengaduanPage(emailUser: widget.emailUser),
      ),
    );
  }

  void bukaAkun() {
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

  void bukaNotifikasi() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotifikasiPage(emailTarget: widget.emailUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: primaryBlue,
          onRefresh: () async {
            await Future.wait([
              fetchPengaduanTerbaru(),
              getLiveProfileFoto(),
              getLiveProfile(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    const SizedBox(height: 22),
                    _buildHeroBanner(),
                    const SizedBox(height: 27),
                    _buildComplaintHeader(),
                    const SizedBox(height: 13),
                    _buildComplaintList(),
                    const SizedBox(height: 28),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $namaSekarang",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202B25),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Selamat datang di",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF89948E),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Desa Maju Bersama",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: darkBlue,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: bukaAkun,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDCE7F3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 21,
              backgroundColor: const Color(0xFFE8F1FB),
              child: (fotoSekarang != null &&
                      fotoSekarang!.isNotEmpty &&
                      fotoSekarang != "null")
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: UrlHelper.getFullUrl(fotoSekarang ?? ""),
                        memCacheWidth: 300,
                        memCacheHeight: 200,
                        httpHeaders: const {"Connection": "keep-alive"},
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person_rounded,
                          color: primaryBlue,
                          size: 25,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      color: primaryBlue,
                      size: 25,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 224,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "assets/images/banner.jpg",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFB8D5F0),
                  child: const Icon(
                    Icons.landscape_rounded,
                    size: 70,
                    color: Colors.white,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.04),
                    darkBlue.withOpacity(0.78),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 17,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volunteer_activism_rounded,
                        color: primaryBlue, size: 15),
                    SizedBox(width: 6),
                    Text(
                      "Suara Warga, Kemajuan Desa",
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 19,
              right: 19,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sampaikan keluhan Anda",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    "Kami siap mendengar dan menindaklanjuti\naspirasi Anda untuk desa yang lebih baik.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: bukaBuatPengaduan,
                      icon: const Icon(Icons.add_rounded, size: 19),
                      label: const Text(
                        "Buat Pengaduan",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: darkBlue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pengaduan terbaru",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF202B25),
              ),
            ),
            SizedBox(height: 3),
            Text(
              "Pantau perkembangan laporan Anda",
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF8A9690),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: bukaPengaduan,
          style: TextButton.styleFrom(
            foregroundColor: primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          child: const Row(
            children: [
              Text(
                "Lihat Semua",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 3),
              Icon(Icons.arrow_forward_ios_rounded, size: 11),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintList() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: CircularProgressIndicator(color: primaryBlue),
        ),
      );
    }

    if (pengaduanTerbaru.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5ECF5)),
        ),
        child: const Column(
          children: [
            Icon(Icons.inbox_outlined, size: 38, color: Color(0xFF9AA9A0)),
            SizedBox(height: 9),
            Text(
              "Belum ada pengaduan",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF53645A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Pengaduan yang Anda kirim akan tampil di sini.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF98A39C)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: pengaduanTerbaru.map((item) {
        final String title = item["judul"]?.toString() ?? "Tanpa Judul";
        final String tanggal = item["tanggal"]?.toString() ?? "-";
        final String status = item["status"]?.toString() ?? "Menunggu";
        final String? foto = item["foto"]?.toString();

        return buildPengaduan(
          title,
          tanggal,
          status,
          getStatusColor(status),
          foto,
        );
      }).toList(),
    );
  }

  Widget buildPengaduan(
    String title,
    String tanggal,
    String status,
    Color color,
    String? fotoUrl,
  ) {
    final backgroundStatus = getStatusBackground(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE3EAF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF174B75).withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (fotoUrl != null &&
                    fotoUrl.isNotEmpty &&
                    fotoUrl != "null")
                ? CachedNetworkImage(
                    imageUrl: UrlHelper.getFullUrl(fotoUrl),
                    memCacheWidth: 300,
                    memCacheHeight: 200,
                    httpHeaders: const {"Connection": "keep-alive"},
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 58,
                      height: 58,
                      color: const Color(0xFFEEF4FA),
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF27342D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 10,
                      color: Color(0xFF9AA59E),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      tanggal,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF929D96),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: backgroundStatus,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              statusIndonesia(status),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 58,
      height: 58,
      color: const Color(0xFFEEF4FA),
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF9BAAA0),
        size: 25,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE5ECF5), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                icon: Icons.home_rounded,
                label: "Beranda",
                selected: true,
                onTap: () {},
              ),
              _navItem(
                icon: Icons.assignment_rounded,
                label: "Pengaduan",
                onTap: bukaPengaduan,
              ),
              GestureDetector(
                onTap: bukaBuatPengaduan,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              _navItem(
                icon: Icons.notifications_none_rounded,
                label: "Notifikasi",
                onTap: bukaNotifikasi,
              ),
              _navItem(
                icon: Icons.person_outline_rounded,
                label: "Akun",
                onTap: bukaAkun,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 67,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected ? primaryBlue : const Color(0xFF849088),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? primaryBlue : const Color(0xFF78847D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
