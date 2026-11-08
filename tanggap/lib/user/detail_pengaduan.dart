import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../helper/url_helper.dart';

class DetailPengaduanPage extends StatefulWidget {
  final String idPengaduan;

  const DetailPengaduanPage({
    super.key,
    required this.idPengaduan,
  });

  @override
  State<DetailPengaduanPage> createState() => _DetailPengaduanPageState();
}

class _DetailPengaduanPageState extends State<DetailPengaduanPage> {
  Map<String, dynamic>? dataPengaduan;
  bool isLoading = true;

  int _userSelectedRating = 0;
  final TextEditingController _userCommentCtrl = TextEditingController();
  bool _isSendingReview = false;


  // Warna tema biru aplikasi TANGGAP
  static const Color primaryBlue = Color(0xFF1769AA);
  static const Color darkBlue = Color(0xFF17324D);
  static const Color pageBackground = Color(0xFFF3F7FC);
  static const Color softBlue = Color(0xFFEAF3FC);
  static const Color borderBlue = Color(0xFFD5E6F7);

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  @override
  void dispose() {
    _userCommentCtrl.dispose();
    super.dispose();
  }

  // =========================================================
  // MENGAMBIL DETAIL PENGADUAN DARI BACKEND
  // =========================================================
  Future<void> fetchDetail() async {
    try {
      final response = await http.get(
        Uri.parse(
          UrlHelper.api('/api/pengaduan/detail/${widget.idPengaduan}'),
        ),
      );

      debugPrint("STATUS CODE = ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'];

        if (!mounted) return;

        setState(() {
          dataPengaduan = data;
          isLoading = false;
        });
      } else {
        debugPrint("GAGAL MENGAMBIL DETAIL: ${response.body}");

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ERROR DETAIL = $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================================================
  // MENGIRIM PENILAIAN KE BACKEND
  // =========================================================
  Future<void> _submitUserReview() async {
    if (_userSelectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Tolong pilih rating bintang terlebih dahulu!",
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSendingReview = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          UrlHelper.api(
            '/api/pengaduan/${dataPengaduan?['id']}/review',
          ),
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "rating": _userSelectedRating,
          "comment": _userCommentCtrl.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Penilaian Anda berhasil disimpan. Terima kasih!",
            ),
          ),
        );

        await fetchDetail();
      } else {
        String message = "Gagal mengirim penilaian";

        try {
          final responseData = json.decode(response.body);
          message = responseData['message'] ?? message;
        } catch (_) {
          // Menggunakan pesan default jika respons bukan JSON.
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      debugPrint("ERROR SEND REVIEW = $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan saat mengirim penilaian."),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingReview = false;
        });
      }
    }
  }

  // =========================================================
  // WARNA STATUS PENGADUAN
  // =========================================================
  Color getStatusColor(String? status) {
    final normalizedStatus = (status ?? "").trim().toUpperCase();

    if (normalizedStatus == "PENDING" ||
        normalizedStatus == "MENUNGGU") {
      return Colors.orange;
    }

    if (normalizedStatus == "DIPROSES") {
      return Colors.blue;
    }

    if (normalizedStatus == "SELESAI") {
      return Colors.green;
    }

    return Colors.grey;
  }

  // =========================================================
  // KONVERSI STATUS KE BAHASA INDONESIA
  // =========================================================
  String statusIndonesia(String? status) {
    final normalizedStatus = (status ?? "").trim().toUpperCase();

    switch (normalizedStatus) {
      case "PENDING":
        return "Menunggu";
      case "DIPROSES":
        return "Diproses";
      case "SELESAI":
        return "Selesai";
      default:
        return normalizedStatus.isEmpty
            ? "Tidak diketahui"
            : normalizedStatus;
    }
  }

  // =========================================================
  // MEMBENTUK URL FOTO
  // =========================================================
  // URL Supabase bertanda tangan (signed URL) harus dipakai persis
  // seperti yang dikirim backend. Jangan menambahkan ?v= atau parameter
  // lain karena dapat membuat tanda tangannya tidak valid.
  String _buildImageUrl(String? rawUrl) {
    if (rawUrl == null) return "";

    final url = rawUrl.trim();

    if (url.isEmpty || url == "null") {
      return "";
    }

    // Pertahankan URL lengkap, terutama signed URL Supabase.
    if (url.startsWith("https://") || url.startsWith("http://")) {
      return url;
    }

    // Untuk path relatif, bentuk URL menggunakan base URL backend.
    final cleanPath = url.replaceFirst(RegExp(r"^/+"), "");
    return UrlHelper.api(cleanPath);
  }

  // =========================================================
  // KOMPONEN JUDUL BAGIAN
  // =========================================================
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: darkBlue,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // =========================================================
  // KOMPONEN KARTU INFORMASI
  // =========================================================
  Widget _buildInfoCard({
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2EAF3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: primaryBlue,
          ),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  // =========================================================
  // KOMPONEN FOTO
  // =========================================================
  Widget _buildImageItem({
    required String imageUrl,
    required double width,
    required double height,
    double radius = 10,
  }) {
    final finalUrl = _buildImageUrl(imageUrl);

    debugPrint("========== DEBUG FOTO DETAIL ==========");
    debugPrint("PATH FOTO: $imageUrl");
    debugPrint("URL FOTO: $finalUrl");
    debugPrint("========================================");

    if (finalUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: const Icon(
          Icons.broken_image_outlined,
          color: Colors.grey,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        // Jangan proses ulang URL yang sudah lengkap dari Supabase.
        imageUrl: finalUrl,
        memCacheWidth: 900,
        memCacheHeight: 900,
        maxWidthDiskCache: 1200,
        maxHeightDiskCache: 1200,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) {
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFEAF0F6),
            child: const Center(
              child: CircularProgressIndicator(
                color: primaryBlue,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorWidget: (context, url, error) {
          debugPrint("GAGAL MEMUAT FOTO DETAIL: $error");
          debugPrint("URL YANG GAGAL: $url");
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFEAF0F6),
            child: const Icon(
              Icons.broken_image_outlined,
              color: Colors.redAccent,
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // KOMPONEN STATUS
  // =========================================================
  Widget _buildStatusBadge(String? status) {
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Text(
        statusIndonesia(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // =========================================================
  // TAMPILAN FOTO LAMPIRAN WARGA
  // =========================================================
  Widget _buildAttachmentSection(List fotoList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("Foto Lampiran"),
        const SizedBox(height: 10),
        if (fotoList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2EAF3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  "Tidak ada foto lampiran",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: fotoList.map<Widget>((item) {
                String imagePath;

                if (item is Map) {
                  imagePath = (
                    item['url'] ??
                    item['path'] ??
                    item['file_path'] ??
                    ''
                  ).toString();
                } else {
                  imagePath = item.toString();
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildImageItem(
                    imageUrl: imagePath,
                    width: 110,
                    height: 90,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // =========================================================
  // TAMPILAN RIWAYAT PENANGANAN
  // =========================================================
  Widget _buildHistorySection(List riwayatList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("Riwayat Penanganan"),
        const SizedBox(height: 14),

        if (riwayatList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.shade100,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.access_time_filled,
                  color: Colors.orange.shade400,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Laporan Anda sedang menunggu antrean untuk "
                    "ditindaklanjuti oleh petugas.",
                    style: TextStyle(
                      color: Color(0xFF9A5B00),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: riwayatList.map<Widget>((item) {
              final String status =
                  item['status']?.toString() ?? "";

              final String tanggal =
                  item['tanggal']?.toString() ?? "-";

              final String catatan =
                  item['catatan']?.toString() ?? "-";

              final List fotoBukti =
                  item['foto_bukti'] is List
                      ? item['foto_bukti']
                      : [];

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE2EAF3),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusBadge(status),
                        Flexible(
                          child: Text(
                            tanggal,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      catatan,
                      style: const TextStyle(
                        color: Color(0xFF34495E),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    if (fotoBukti.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        "Foto Bukti Penanganan",
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: fotoBukti.map<Widget>((foto) {
                            String imagePath;

                            if (foto is Map) {
                              imagePath = (
                                foto['url'] ??
                                foto['path'] ??
                                foto['file_path'] ??
                                ''
                              ).toString();
                            } else {
                              imagePath = foto.toString();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(
                                right: 10,
                              ),
                              child: _buildImageItem(
                                imageUrl: imagePath,
                                width: 90,
                                height: 90,
                                radius: 8,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // =========================================================
  // FORM PENILAIAN
  // =========================================================
  Widget _buildReviewSection(
    String currentStatus,
    Map<String, dynamic>? reviewData,
  ) {
    if (currentStatus != "SELESAI") {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 30),
        _buildSectionLabel("Penilaian Anda"),
        const SizedBox(height: 14),

        if (reviewData == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderBlue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bagaimana kualitas penanganan laporan ini?",
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _userSelectedRating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < _userSelectedRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 36,
                      ),
                    );
                  }),
                ),

                Center(
                  child: Text(
                    _userSelectedRating == 0
                        ? "Pilih jumlah bintang"
                        : "$_userSelectedRating dari 5 bintang",
                    style: const TextStyle(
                      color: Color(0xFF60758A),
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: _userCommentCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Berikan tanggapan (Opsional)",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: borderBlue,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: borderBlue,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: primaryBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      disabledBackgroundColor:
                          primaryBlue.withOpacity(0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isSendingReview
                        ? null
                        : _submitUserReview,
                    child: _isSendingReview
                        ? const SizedBox(
                            height: 19,
                            width: 19,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Kirim Penilaian",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderBlue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        final int savedRating =
                            int.tryParse(
                                  reviewData['rating']?.toString() ??
                                      "0",
                                ) ??
                                0;

                        return Icon(
                          index < savedRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 21,
                        );
                      }),
                    ),
                    Flexible(
                      child: Text(
                        reviewData['created_at']?.toString() ?? "-",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  reviewData['comment'] != null &&
                          reviewData['comment']
                              .toString()
                              .isNotEmpty
                      ? '"${reviewData['comment']}"'
                      : "Warga memberikan penilaian tanpa komentar.",
                  style: const TextStyle(
                    color: Color(0xFF526579),
                    fontSize: 13,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // =========================================================
  // BUILD HALAMAN
  // =========================================================
  @override
  Widget build(BuildContext context) {
    final String statusText =
        dataPengaduan?['status']?.toString() ?? "Menunggu";

    final String currentStatus = statusText.toUpperCase();

    final String rawId =
        dataPengaduan?['id']?.toString() ?? "";

    final String idText = rawId.length >= 5
        ? rawId.substring(0, 5).toUpperCase()
        : rawId.toUpperCase();

    final String judulText =
        dataPengaduan?['judul']?.toString() ?? "Tanpa Judul";

    final String tanggalText =
        dataPengaduan?['tanggal']?.toString() ??
        dataPengaduan?['tanggal_pengaduan']?.toString() ??
        dataPengaduan?['created_at']?.toString() ??
        "-";

    final String lokasiText =
        dataPengaduan?['lokasi']?.toString() ??
        dataPengaduan?['titik_lokasi']?.toString() ??
        "Lokasi tidak dicantumkan";

    final String deskripsiText =
        dataPengaduan?['deskripsi']?.toString() ??
        "Tidak ada deskripsi";

    final dynamic rawFotoList =
        dataPengaduan?['foto'] ?? dataPengaduan?['attachments'];

    final List fotoList = rawFotoList is List ? rawFotoList : [];

    final List riwayatList =
        dataPengaduan?['riwayat_tindak_lanjut'] ?? [];

    final Map<String, dynamic>? reviewData =
        dataPengaduan?['review'];

    return Scaffold(
      backgroundColor: pageBackground,

      // =====================================================
      // APP BAR
      // =====================================================
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: darkBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Detail Pengaduan",
          style: TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),

      // =====================================================
      // TOMBOL TUTUP DI BAGIAN BAWAH
      // =====================================================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tutup",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryBlue,
              ),
            )
          : dataPengaduan == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          size: 52,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Data pengaduan tidak ditemukan",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: darkBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Periksa koneksi internet Anda lalu coba kembali.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            fetchDetail();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("Coba Lagi"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: primaryBlue,
                  onRefresh: fetchDetail,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =====================================
                        // HEADER STATUS DAN ID
                        // =====================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE2EAF3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatusBadge(statusText),
                                  Text(
                                    "#PGD-$idText",
                                    style: const TextStyle(
                                      color: Color(0xFF8091A3),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                judulText,
                                style: const TextStyle(
                                  color: darkBlue,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: Color(0xFF8091A3),
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      tanggalText,
                                      style: const TextStyle(
                                        color: Color(0xFF8091A3),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // =====================================
                        // LOKASI
                        // =====================================
                        _buildSectionLabel("Lokasi"),
                        const SizedBox(height: 8),
                        _buildInfoCard(
                          icon: Icons.location_on_outlined,
                          child: Text(
                            lokasiText,
                            style: const TextStyle(
                              color: Color(0xFF34495E),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // =====================================
                        // DESKRIPSI
                        // =====================================
                        _buildSectionLabel("Deskripsi"),
                        const SizedBox(height: 8),
                        _buildInfoCard(
                          icon: Icons.description_outlined,
                          child: Text(
                            deskripsiText,
                            style: const TextStyle(
                              color: Color(0xFF34495E),
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // =====================================
                        // FOTO LAMPIRAN
                        // =====================================
                        _buildAttachmentSection(fotoList),

                        const SizedBox(height: 25),
                        const Divider(
                          color: Color(0xFFE2EAF3),
                          thickness: 1,
                        ),
                        const SizedBox(height: 15),

                        // =====================================
                        // RIWAYAT PENANGANAN
                        // =====================================
                        _buildHistorySection(riwayatList),

                        const SizedBox(height: 15),

                        // =====================================
                        // PENILAIAN
                        // =====================================
                        _buildReviewSection(
                          currentStatus,
                          reviewData,
                        ),

                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
    );
  }
}