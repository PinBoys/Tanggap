import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'tindak_lanjut_admin.dart';
import '../helper/url_helper.dart';


class DetailPengaduanAdminPage extends StatefulWidget {
  final Map<String, dynamic> pengaduan;

  const DetailPengaduanAdminPage({super.key, required this.pengaduan});

  @override
  State<DetailPengaduanAdminPage> createState() =>
      _DetailPengaduanAdminPageState();
}

class _DetailPengaduanAdminPageState extends State<DetailPengaduanAdminPage> {
  Map<String, dynamic>? detailLengkap;
  bool isLoading = true;

  static const String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    _fetchDetailLengkap();
  }

  Future<void> _fetchDetailLengkap() async {
    try {
      final url = "$baseUrl/api/pengaduan/detail/${widget.pengaduan['id']}";

      debugPrint("REQUEST => $url");

      final response = await http.get(Uri.parse(url));

      debugPrint("STATUS => ${response.statusCode}");
      debugPrint("BODY => ${response.body}");

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        setState(() {
          detailLengkap = result["data"] ?? result;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("ERROR => $e");
      setState(() => isLoading = false);
    }
  }

  // LOGIKA GAMBAR DIPERBARUI: Menggunakan jalur bypass /api/view-image/
    String _formatImageUrl(String path) {
      if (path.isEmpty) return "";

      if (path.startsWith("http")) {
        return path.replaceAll("127.0.0.1", "10.0.2.2");
      }

      return "$baseUrl$path";
    }

  String getDampak(dynamic value) {
    switch (value.toString()) {
      case "1": return "Aman";
      case "2": return "Gangguan Kecil";
      case "3": return "Resiko Luka";
      case "4": return "Sangat Berbahaya";
      case "5": return "Gawat Darurat";
      default: return value?.toString() ?? "-";
    }
  }

  String getSensitivitas(dynamic value) {
    switch (value.toString()) {
      case "1": return "Stabil";
      case "2": return "Lambat";
      case "3": return "Sedang";
      case "4": return "Cepat";
      case "5": return "Detik Ini";
      default: return value?.toString() ?? "-";
    }
  }

  String getAlternatif(dynamic value) {
    switch (value.toString()) {
      case "1": return "Banyak Pilihan";
      case "2": return "Ada Pilihan";
      case "3": return "Sulit";
      case "4": return "Hampir Buntu";
      case "5": return "Total Terisolasi";
      default: return value?.toString() ?? "-";
    }
  }

  String getCakupan(dynamic value) {
    switch (value.toString()) {
      case "1": return "Pribadi";
      case "2": return "Tetangga";
      case "3": return "Lingkungan";
      case "4": return "Wilayah Luas";
      case "5": return "Sangat Luas";
      default: return value?.toString() ?? "-";
    }
  }

  Widget _item(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFotoList(Map<String, dynamic> data) {
    final attachments =
        data["attachments"] ?? data["lampiran"] ?? data["foto_bukti"] ?? [];

    if (attachments is! List || attachments.isEmpty) {
      return [
        const Text(
          "Tidak ada foto.",
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      ];
    }

    return attachments.map<Widget>((item) {
      String imageUrl = "";

      if (item is Map<String, dynamic>) {
        imageUrl = item["file_url"] ?? item["url"] ?? item["path"] ?? "";
      } else {
        imageUrl = item.toString();
      }

      imageUrl = _formatImageUrl(imageUrl);

      debugPrint("IMAGE URL = $imageUrl");

      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: UrlHelper.getFullUrl(imageUrl),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.red),
                ), 
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: UrlHelper.getFullUrl(imageUrl),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, color: Colors.red),
              ),
            ), 
          ),
        ),
      );
    }).toList();
  }

  // WIDGET BARU: Menampilkan Timeline Penanganan
  Widget _buildRiwayatPenanganan(Map<String, dynamic> data) {
    final List riwayatList = data['riwayat_tindak_lanjut'] ?? [];

    if (riwayatList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text(
          "Riwayat Tindakan Admin",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 15),
        ...riwayatList.map((tindakLanjut) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tindakLanjut['status'] ?? "-",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: tindakLanjut['status'] == 'SELESAI' ? Colors.green : Colors.blue,
                      ),
                    ),
                    Text(
                      tindakLanjut['tanggal'] ?? "-",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(tindakLanjut['catatan'] ?? "Tidak ada catatan"),
                
                // Menampilkan foto bukti tindak lanjut (jika ada)
                if (tindakLanjut['foto_bukti'] != null && (tindakLanjut['foto_bukti'] as List).isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: (tindakLanjut['foto_bukti'] as List).map((fotoUrl) {
                        String finalUrl = _formatImageUrl(fotoUrl.toString());
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: finalUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 60, height: 60, color: Colors.grey.shade200,
                              ),
                              errorWidget: (context, url, error) {
                                debugPrint("=========== ERROR FOTO TINDAK LANJUT ===========");
                                debugPrint("URL     : $url");
                                debugPrint("ERROR   : $error");

                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ]
              ],
            ),
          );
        }),
      ],
    );
  }

  // WIDGET BARU: Menampilkan Rating dari Warga
  Widget _buildPenilaianWarga(Map<String, dynamic> data) {
    final review = data['review'];

    if (review == null) {
      if (data['status'] == 'SELESAI') {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Warga belum memberikan penilaian kepuasan.",
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          ],
        );
      }
      return const SizedBox.shrink(); // Sembunyikan jika belum selesai
    }

    int rating = int.tryParse(review['rating']?.toString() ?? "0") ?? 0;
    String comment = review['comment']?.toString() ?? "";
    String date = review['created_at']?.toString() ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text(
          "Penilaian Kepuasan Warga",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber.shade700,
                        size: 24,
                      );
                    }),
                  ),
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              if (comment.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '"$comment"',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade800),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = detailLengkap ?? widget.pengaduan;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Detail Pengaduan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _item("Judul", data["judul"] ?? data["title"] ?? "-"),
                  _item("Status", data["status"] ?? "-"),
                  _item(
                    "Lokasi",
                    data["titik_lokasi"] ?? data["address_note"] ?? "-",
                  ),
                  _item("Tanggal", data["created_at"] ?? "-"),
                  _item(
                    "Deskripsi",
                    data["deskripsi"] ?? data["description"] ?? "-",
                  ),

                  const Divider(height: 30, thickness: 1),
                  
                  const Text("Analisis Prioritas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),

                  _item("Urgensi", data["urgensi"] ?? "-"),
                  _item(
                    "Dampak",
                    getDampak(data["dampak"] ?? data["impact"] ?? "-"),
                  ),
                  _item(
                    "Sensitivitas",
                    getSensitivitas(
                      data["sensitivitas"] ?? data["sensitivity"] ?? "-",
                    ),
                  ),
                  _item("Alternatif", getAlternatif(data["alternatif"] ?? "-")),
                  _item(
                    "Cakupan",
                    getCakupan(data["cakupan"] ?? data["scope"] ?? "-"),
                  ),
                  
                  const Divider(height: 30, thickness: 1),

                  const Text(
                    "Foto Bukti (Warga)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _buildFotoList(data),
                  ),

                  // Memanggil Riwayat Tindakan Admin (Jika Ada)
                  _buildRiwayatPenanganan(data),

                  // Memanggil Penilaian Rating Warga (Jika Ada)
                  _buildPenilaianWarga(data),

                  const SizedBox(height: 40),

                  // Tombol disembunyikan jika status sudah SELESAI
                  if (data["status"]?.toString().toUpperCase() != "SELESAI")
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TindakLanjutAdminPage(pengaduan: data),
                            ),
                          ).then((_) {
                            // Refresh data ketika kembali dari halaman tindak lanjut
                            setState(() {
                              isLoading = true;
                            });
                            _fetchDetailLengkap();
                          });
                        },
                        child: const Text(
                          "Tindak lanjuti Laporan",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}