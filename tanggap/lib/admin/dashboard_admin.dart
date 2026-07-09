import 'package:flutter/material.dart';
import 'drawer_admin.dart';
import 'daftar_pengaduan_admin.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'notifikasi_admin.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {

  String namaAdmin = "loading...";

  int totalLaporan = 0;
  int selesai = 0;
  int diproses = 0;
  int menunggu = 0;

  List complaints = [];
  List grafikMingguan = [];
  

  @override
  void initState() {
    super.initState();
    getComplaints();
    getProfile();
  }

  Future<void> getComplaints() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/api/admin/complaints"),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
        
          complaints = data['data'];
      
          grafikMingguan = data['grafik_mingguan'] ?? [];
      
          totalLaporan = complaints.length;
      
          selesai =
              complaints.where((e) => e['status'] == 'SELESAI').length;
      
          diproses =
              complaints.where((e) => e['status'] == 'DIPROSES').length;
      
          menunggu =
              complaints.where((e) => e['status'] == 'PENDING').length;
      
        });
      }
    } catch (e) {
      print(e);
    }
  }

  String statusIndonesia(String status) {

  switch (status) {

    case 'PENDING':
      return 'Menunggu';

    case 'DIPROSES':
      return 'Diproses';

    case 'SELESAI':
      return 'Selesai';

    default:
      return status;

  }
}

Future<void> getProfile() async {

  try {

    final response = await http.get(
      Uri.parse(
        "http://10.0.2.2:8000/api/admin/profile",
      ),
    );

    final data =
        jsonDecode(response.body);

    if (data["status"] == "success") {

      setState(() {

        namaAdmin =
            data["data"]["full_name"] ??
            "Admin Desa";

      });
    }

  } catch (e) {

    print(e);

  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      drawer: const DrawerAdmin(),

      appBar: AppBar(
        backgroundColor: const Color(0xff0B6E4F),
        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotifikasiAdminPage(),
                ),
              );
            },
          ),

          const SizedBox(width: 5),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),

              border: Border.all(color: Colors.grey.shade300),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Selamat Datang,",
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),

                const SizedBox(height: 5),

                Text(
                  namaAdmin,
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Ringkasan pengaduan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _buildCard(
                        title: "Total Laporan",
                        value: totalLaporan.toString(),
                        bgColor: Colors.purple.shade100,
                        textColor: Colors.purple,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildCard(
                        title: "Selesai",
                        value: selesai.toString(),
                        bgColor: const Color(0xffDCEEE8),
                        textColor: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildCard(
                        title: "Diproses",
                        value: diproses.toString(),
                        bgColor: Colors.blue.shade100,
                        textColor: Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildCard(
                        title: "Menunggu",
                        value: menunggu.toString(),
                        bgColor: const Color(0xffF3E0D3),
                        textColor: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                const Text(
                  "Grafik Pengaduan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Column(
                  children: grafikMingguan.map((item) {
                    return _buildBar(
                      item["hari"],
                      (item["total"] as num).toDouble(),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

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
                            builder: (context) =>
                                const DaftarPengaduanAdminPage(),
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

                Container(
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),

                    border: Border.all(color: Colors.grey.shade300),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Expanded(
                        child: Text(
                          complaints.isNotEmpty
                              ? complaints[0]['title']
                              : 'Belum ada pengaduan',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color:
                              complaints.isNotEmpty &&
                                  complaints[0]['status'] == 'PENDING'
                              ? Colors.orange.shade100
                              : complaints.isNotEmpty &&
                                    complaints[0]['status'] == 'DIPROSES'
                              ? Colors.blue.shade100
                              : Colors.green.shade100,

                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: Text(
                          complaints.isNotEmpty
                              ? statusIndonesia(complaints[0]['status'])
                              : '-',

                          style: TextStyle(
                            color:
                                complaints.isNotEmpty &&
                                    complaints[0]['status'] == 'PENDING'
                                ? Colors.orange.shade800
                                : complaints.isNotEmpty &&
                                      complaints[0]['status'] == 'DIPROSES'
                                ? Colors.blue.shade800
                                : Colors.green.shade800,

                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildCard({
    required String title,
    required String value,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                FractionallySizedBox(
                  widthFactor: value == 0
                      ? 0
                      : (value / 10).clamp(0.0, 1.0),

                  child: Container(
                    height: 14,

                    decoration: BoxDecoration(
                      color: const Color(0xff0B6E4F),

                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(value.toInt().toString()),
        ],
      ),
    );
  }
}
