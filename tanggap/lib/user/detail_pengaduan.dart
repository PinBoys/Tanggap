import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import '../helper/url_helper.dart';

class DetailPengaduanPage extends StatefulWidget {
  final String idPengaduan; // Wajib menerima ID saat halaman ini dipanggil

  const DetailPengaduanPage({super.key, required this.idPengaduan});

  @override
  State<DetailPengaduanPage> createState() => _DetailPengaduanPageState();
}

class _DetailPengaduanPageState extends State<DetailPengaduanPage> {
  Map<String, dynamic>? dataPengaduan;
  bool isLoading = true;

  // State untuk form rating
  int _userSelectedRating = 0;
  final TextEditingController _userCommentCtrl = TextEditingController();
  bool _isSendingReview = false;

  // Variabel untuk mencegah cache delay
  String _detailImageVersion = "1";

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final response = await http.get(
        Uri.parse(
          UrlHelper.api('/api/pengaduan/detail/${widget.idPengaduan}'),
        ),
      );

      debugPrint("STATUS CODE = ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];

        setState(() {
          dataPengaduan = data;
          // Update versi cache saat fetch berhasil
          _detailImageVersion = DateTime.now().millisecondsSinceEpoch.toString();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("ERROR DETAIL = $e");
      setState(() => isLoading = false);
    }
  }

  // FUNGSI UNTUK MENGIRIM RATING KE BACKEND
  Future<void> _submitUserReview() async {
    if (_userSelectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tolong pilih rating bintang terlebih dahulu!")),
      );
      return;
    }

    setState(() => _isSendingReview = true);

    try {
      final response = await http.post(
        Uri.parse(UrlHelper.api('/api/pengaduan/${dataPengaduan?['id']}/review')),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "rating": _userSelectedRating,
          "comment": _userCommentCtrl.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Penilaian Anda berhasil disimpan. Terima kasih!")),
        );
        fetchDetail(); // Tarik ulang data agar form hilang & ganti jadi rangkuman
      } else {
        final msg = json.decode(response.body)['message'] ?? "Gagal mengirim penilaian";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      debugPrint("ERROR SEND REVIEW = $e");
    } finally {
      setState(() => _isSendingReview = false);
    }
  }

  Color getStatusColor(String status) {
    status = status.trim().toUpperCase();
    if (status == "PENDING" || status == "MENUNGGU") return Colors.orange;
    if (status == "DIPROSES") return Colors.blue;
    if (status == "SELESAI") return Colors.green;
    return Colors.grey;
  }

  String statusIndonesia(String status) {
    status = status.trim().toUpperCase();
    switch (status) {
      case "PENDING": return "Menunggu";
      case "DIPROSES": return "Diproses";
      case "SELESAI": return "Selesai";
      default: return status;
    }
  }

  // PERBAIKAN: Memperbaiki logika pembentukan URL agar sesuai dengan struktur /storage/
  String _buildImageUrl(String url) {
    if (url == "null" || url.isEmpty) return "";
    
    // Jika sudah full URL, cukup ganti IP dan tambahkan versi
    if (url.startsWith("http")) {
      return "${url.replaceAll("127.0.0.1", "10.0.2.2")}?v=$_detailImageVersion";
    }

    // Jika path dari database dimulai dengan '/', hapus agar tidak double slash
    String cleanPath = url.startsWith('/') ? url.substring(1) : url;
    return UrlHelper.api('/$cleanPath?v=$_detailImageVersion');
  }

  @override
  Widget build(BuildContext context) {
    final String statusText = dataPengaduan?['status']?.toString() ?? "Menunggu";
    final String currentStatus = statusText.toUpperCase();
    final String rawId = dataPengaduan?['id']?.toString() ?? "";
    final String idText = rawId.length >= 5 ? rawId.substring(0, 5).toUpperCase() : rawId.toUpperCase();
    final String judulText = dataPengaduan?['judul']?.toString() ?? "Tanpa Judul";
    final String tanggalText = dataPengaduan?['tanggal']?.toString() ??
        dataPengaduan?['tanggal_pengaduan']?.toString() ??
        dataPengaduan?['created_at']?.toString() ?? "-";
    final String lokasiText = dataPengaduan?['lokasi']?.toString() ??
        dataPengaduan?['titik_lokasi']?.toString() ?? "Lokasi tidak dicantumkan";
    final String deskripsiText = dataPengaduan?['deskripsi']?.toString() ?? "Tidak ada deskripsi";
    
    final List fotoList = dataPengaduan?['foto'] ?? dataPengaduan?['attachments'] ?? [];
    
    // --- DATA BARU DARI BACKEND ---
    final List riwayatList = dataPengaduan?['riwayat_tindak_lanjut'] ?? [];
    final Map<String, dynamic>? reviewData = dataPengaduan?['review'];

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
          "Detail Pengaduan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      
      // FIXED BOTTOM BUTTON
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dataPengaduan == null
              ? const Center(child: Text("Data tidak ditemukan."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(statusText).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusIndonesia(statusText),
                              style: TextStyle(
                                color: getStatusColor(statusText),
                                fontSize: 11, fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text("#PGD-$idText", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(judulText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(tanggalText, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(height: 20),
                      
                      // --- LOKASI & DESKRIPSI ---
                      const Text("Lokasi", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(lokasiText),
                      const SizedBox(height: 18),
                      
                      const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(deskripsiText, style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
                      const SizedBox(height: 18),
                      
                      // --- FOTO DARI WARGA ---
                      const Text("Foto Lampiran", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: fotoList.isEmpty
                              ? [const Text("Tidak ada foto", style: TextStyle(color: Colors.grey, fontSize: 12))]
                              : fotoList.map((url) {
                                  // Menggunakan fungsi _buildImageUrl yang sudah diperbaiki
                                  String finalUrl = _buildImageUrl(url.toString());

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: UrlHelper.getFullUrl(finalUrl),
                                          width: 90, 
                                          height: 70, 
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            width: 90, 
                                            height: 70, 
                                            color: Colors.grey.shade200,
                                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            width: 90, 
                                            height: 70, 
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.broken_image, color: Colors.red),
                                          ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                        ),
                      ),

                      const SizedBox(height: 30),
                      const Divider(thickness: 1),
                      const SizedBox(height: 15),

                      // --- RIWAYAT TINDAK LANJUT ADMIN ---
                      const Text("Riwayat Penanganan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 15),

                      riwayatList.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.orange.shade100)
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_filled, color: Colors.orange.shade400),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Laporan Anda sedang menunggu antrean untuk ditindaklanjuti oleh petugas.",
                                      style: TextStyle(color: Colors.orange.shade800, fontSize: 13, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: riwayatList.map((tindakLanjut) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: getStatusColor(tindakLanjut['status']).withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              statusIndonesia(tindakLanjut['status']),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold, fontSize: 11,
                                                color: getStatusColor(tindakLanjut['status']),
                                              ),
                                            ),
                                          ),
                                          Text(tindakLanjut['tanggal']?.toString() ?? "-", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        tindakLanjut['catatan']?.toString() ?? "-",
                                        style: const TextStyle(fontSize: 13, height: 1.5),
                                      ),
                                      if (tindakLanjut['foto_bukti'] != null && (tindakLanjut['foto_bukti'] as List).isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: (tindakLanjut['foto_bukti'] as List).map((fotoUrl) {
                                              String finalUrl = _buildImageUrl(fotoUrl.toString());
                                              
                                              return Padding(
                                                padding: const EdgeInsets.only(right: 10),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: CachedNetworkImage(
                                                    imageUrl: UrlHelper.getFullUrl(finalUrl), 
                                                      width: 80, 
                                                      height: 80, 
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) => Container(
                                                        width: 80, 
                                                        height: 80, 
                                                        color: Colors.grey.shade200,
                                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                                      ),
                                                      errorWidget: (context, url, error) => Container(
                                                        width: 80, 
                                                        height: 80, 
                                                        color: Colors.grey.shade200,
                                                        child: const Icon(Icons.broken_image, color: Colors.red),
                                                      ),
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
                              }).toList(),
                            ),

                      const SizedBox(height: 20),
                      
                      // --- PENILAIAN / RATING KEPUASAN (MUNCUL JIKA SELESAI) ---
                      if (currentStatus == "SELESAI") ...[
                        const Divider(thickness: 1),
                        const SizedBox(height: 15),
                        const Text("Penilaian Anda", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 15),

                        reviewData == null
                            ? Container( // TAMPILAN FORM RATING
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Bagaimana kualitas penanganan laporan ini?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        return IconButton(
                                          onPressed: () {
                                            setState(() => _userSelectedRating = index + 1);
                                          },
                                          icon: Icon(
                                            index < _userSelectedRating ? Icons.star : Icons.star_border,
                                            color: Colors.amber, size: 36,
                                          ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _userCommentCtrl, maxLines: 2,
                                      decoration: InputDecoration(
                                        hintText: "Berikan tanggapan (Opsional)",
                                        fillColor: Colors.white, filled: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    SizedBox(
                                      width: double.infinity, height: 40,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: _isSendingReview ? null : _submitUserReview,
                                        child: _isSendingReview
                                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                            : const Text("Kirim Penilaian", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container( // TAMPILAN HASIL RATING
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50, borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: List.generate(5, (index) {
                                            int savedRating = int.tryParse(reviewData['rating']?.toString() ?? "0") ?? 0;
                                            return Icon(
                                              index < savedRating ? Icons.star : Icons.star_border,
                                              color: Colors.amber, size: 20,
                                            );
                                          }),
                                        ),
                                        Text(reviewData['created_at']?.toString() ?? "-", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      reviewData['comment'] != null && reviewData['comment'].toString().isNotEmpty
                                          ? '"${reviewData['comment']}"'
                                          : "Warga memberikan penilaian tanpa komentar.",
                                      style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey.shade800),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
    );
  }
}