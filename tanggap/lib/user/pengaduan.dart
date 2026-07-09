import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_pengaduan.dart';

class PengaduanPage extends StatefulWidget {
  final String emailUser;

  const PengaduanPage({
    super.key,
    required this.emailUser,
  });

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  int selectedIndex = 0;
  bool isLoading = true;

  final List<String> tabs = [
    "Semua",
    "Menunggu",
    "Diproses",
    "Selesai",
  ];

  List<Map<String, dynamic>> pengaduan = [];

  Color getStatusColor(String status) {

  status = status.trim().toLowerCase();

  if (
    status == "pending" ||
    status == "menunggu"
  ) {
    return Colors.orange;
  }

  if (
    status == "diproses"
  ) {
    return Colors.blue;
  }

  if (
    status == "selesai"
  ) {
    return Colors.green;
  }

  return Colors.grey;
}

  @override
  void initState() {
    super.initState();
    fetchDataPengaduan();
  }

  Future<void> fetchDataPengaduan() async {

  final String apiUrl = "http://10.0.2.2:8000/api/pengaduan/status/${widget.emailUser}";
  
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        
        setState(() {
          pengaduan = data.map((item) => {
            "id_pengaduan": item['id_pengaduan'],
            "kode": "#PGD-${item['id_pengaduan']}", 
            "judul": item['judul'] ?? "Tanpa Judul",
            "tanggal": item['tanggal_pengaduan'] ?? "-",
            "lokasi": item['titik_lokasi'] ?? "Lokasi belum ditentukan",
            "status": item['status'] ?? "Menunggu",
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = pengaduan.where((item) {
      if (selectedIndex == 0) {
        return true;
      }
      return statusIndonesia(
       item["status"],
     ) ==
     tabs[selectedIndex];
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(
          color: Colors.black,
        ),
        centerTitle: true,
        title: const Text(
          "Cek Status Pengaduan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  tabs.length,
                  (index) {
                    bool active = selectedIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.blue
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              color: active
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // LIST PENGADUAN
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item["kode"],
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: getStatusColor(item["status"]).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(statusIndonesia(
                                item["status"],),
                                style: TextStyle(
                                  color: getStatusColor(item["status"]),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item["judul"],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item["tanggal"],
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              item["lokasi"],
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // NAVIGATOR DENGAN PELINDUNG NULL (ANTI CRASH)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPengaduanPage(
                                  // toString() dan ?? "" mencegah lemparan data null
                                  idPengaduan: item["id_pengaduan"]?.toString() ?? "", 
                                ),
                              ),
                            );
                          },
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Lihat detail",
                              style: TextStyle(color: Colors.blue, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String statusIndonesia(String status) {

    status = status.trim().toUpperCase();

    switch (status) {

      case "PENDING":
      case "MENUNGGU":
        return "Menunggu";

      case "DIPROSES":
        return "Diproses";

      case "SELESAI":
        return "Selesai";

      default:
        return status;
    }
  }
}