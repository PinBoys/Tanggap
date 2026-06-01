import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'drawer_admin.dart';
import 'detail_pengaduan_admin.dart';

class DaftarPengaduanAdminPage extends StatefulWidget {
  const DaftarPengaduanAdminPage({super.key});

  @override
  State<DaftarPengaduanAdminPage> createState() =>
      _DaftarPengaduanAdminPageState();
}

class _DaftarPengaduanAdminPageState extends State<DaftarPengaduanAdminPage> {
  String selectedFilter = "Semua";

  List<dynamic> pengaduanList = [];

  @override
  void initState() {
    super.initState();
    getPengaduan();
  }

  Future<void> getPengaduan() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/admin/complaints"),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          pengaduanList = data['data'];
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

  @override
  Widget build(BuildContext context) {
    List filteredList;

    if (selectedFilter == "Semua") {
      filteredList = pengaduanList;
    } else {
      filteredList = pengaduanList
          .where((item) => statusIndonesia(item["status"]) == selectedFilter)
          .toList();
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // DRAWER ADMIN
      drawer: const DrawerAdmin(),

      appBar: AppBar(
        backgroundColor: const Color(0xff0B6E4F),

        title: const Text(
          "Daftar Pengaduan",
          style: TextStyle(color: Colors.white),
        ),

        iconTheme: const IconThemeData(color: Colors.white),

        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),

            child: Icon(Icons.search),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [
            // FILTER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                filterButton("Semua"),

                filterButton("Menunggu"),

                filterButton("Diproses"),

                filterButton("Selesai"),
              ],
            ),

            const SizedBox(height: 15),

            // LIST PENGADUAN
            Expanded(
              child: ListView.builder(
                itemCount: filteredList.length,

                itemBuilder: (context, index) {
                  final item = filteredList[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) => DetailPengaduanAdminPage(
                            pengaduan: Map<String, dynamic>.from(item),
                          ),
                        ),
                      );
                    },

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),

                      padding: const EdgeInsets.all(15),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(color: Colors.grey.shade300),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Text(
                                item["id"].toString().substring(0, 8),

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                item["created_at"] ?? "-",

                                style: TextStyle(
                                  color: Colors.grey.shade600,

                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            item["title"] ?? "-",

                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 5),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Text(
                                item["address_note"] ?? "-",

                                style: TextStyle(color: Colors.grey.shade600),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),

                                decoration: BoxDecoration(
                                  color: statusColor(item["status"]),

                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Text(
                                  statusIndonesia(item["status"]),

                                  style: TextStyle(
                                    color: statusTextColor(item["status"]),

                                    fontWeight: FontWeight.bold,

                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget filterButton(String text) {
    final isSelected = selectedFilter == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,

          borderRadius: BorderRadius.circular(8),

          border: Border.all(color: Colors.grey.shade300),
        ),

        child: Text(
          text,

          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,

            fontWeight: FontWeight.bold,

            fontSize: 12,
          ),
        ),
      ),
    );
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
}
