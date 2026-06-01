import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPengaduanPage extends StatefulWidget {
  final String idPengaduan; // Wajib menerima ID saat halaman ini dipanggil
  
  const DetailPengaduanPage({super.key, required this.idPengaduan});

  @override
  State<DetailPengaduanPage> createState() => _DetailPengaduanPageState();
}

class _DetailPengaduanPageState extends State<DetailPengaduanPage> {
  Map<String, dynamic>? dataPengaduan;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:8000/api/pengaduan/detail/${widget.idPengaduan}"));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          dataPengaduan = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Color getStatusColor(String status) {

  status = status.trim().toUpperCase();

  if (status == "PENDING") {
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

  status = status.trim().toUpperCase();

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

  @override
  Widget build(BuildContext context) {
    // --- PELINDUNG NULL-SAFE (ANTI CRASH) ---
    // Kita tangkap datanya ke variabel lokal. Jika dari database hasilnya 'null', 
    // kita beri nilai cadangan (??) agar aplikasi tidak crash.
    final String statusText = dataPengaduan?['status']?.toString() ?? "Menunggu";
    final String idText = dataPengaduan?['id_pengaduan']?.toString() ?? "-";
    final String judulText = dataPengaduan?['judul']?.toString() ?? "Tanpa Judul";
    final String tanggalText = dataPengaduan?['tanggal']?.toString() ?? "-";
    final String lokasiText = dataPengaduan?['lokasi']?.toString() ?? "Lokasi tidak dicantumkan";
    final String deskripsiText = dataPengaduan?['deskripsi']?.toString() ?? "Tidak ada deskripsi";
    final List fotoList = dataPengaduan?['foto'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Detail Pengaduan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dataPengaduan == null
              ? const Center(child: Text("Data tidak ditemukan."))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(statusText).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusIndonesia(statusText),
                              style: TextStyle(
                                color: getStatusColor(statusText),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "#PGD-$idText",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        judulText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tanggalText,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Lokasi",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        lokasiText, // Menggunakan variabel aman
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        "Deskripsi",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        deskripsiText, // Menggunakan variabel aman
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        "Foto Bukti",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Menampilkan foto dari database (Aman dari null)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: fotoList.isEmpty 
                            ? [const Text("Tidak ada foto lampiran", style: TextStyle(color: Colors.grey, fontSize: 12))]
                            : fotoList.map((url) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _buildImage("http://10.0.2.2:8000$url"),
                                );
                              }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "Riwayat Status",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Logika Timeline Status
                      _buildStatusItem(
                        color: Colors.orange,
                        title: "Menunggu",
                        subtitle: "Laporan diterima sistem",
                      ),
                      _buildLine(),
                      _buildStatusItem(
                        color: (statusText == "DIPROSES" || statusText == "SELESAI") ? Colors.blue : Colors.grey.shade300,
                        title: "Diproses",
                        subtitle: (statusText == "DIPROSES" || statusText == "SELESAI") ? "Admin telah menindaklanjuti laporan Anda" : "",
                      ),
                      _buildLine(),
                      _buildStatusItem(
                        color: statusText == "SELESAI" ? Colors.green : Colors.grey.shade300,
                        title: "Selesai",
                        subtitle: statusText == "SELESAI" ? "Laporan telah diselesaikan" : "",
                      ),

                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Tutup",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Container(
      width: 90,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade200,
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 7),
      child: Container(
        width: 2,
        height: 18,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildStatusItem({
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle.isNotEmpty) const SizedBox(height: 3),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}