import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'drawer_admin.dart';
import 'detail_pengaduan_admin.dart';

import '../helper/url_helper.dart';

class DaftarPengaduanAdminPage extends StatefulWidget {
  const DaftarPengaduanAdminPage({super.key});

  @override
  State<DaftarPengaduanAdminPage> createState() => _DaftarPengaduanAdminPageState();
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
      final response = await http.get(Uri.parse(UrlHelper.api('/api/admin/complaints')));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pengaduanList = data['data'];
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  String statusIndonesia(String status) {
    switch (status) {
      case 'PENDING': return 'Menunggu';
      case 'DIPROSES': return 'Diproses';
      case 'SELESAI': return 'Selesai';
      default: return status;
    }
  }

  // Helper untuk Warna Status
  Color statusColor(String status) {
    switch (status) {
      case 'PENDING': return Colors.orange;
      case 'DIPROSES': return Colors.blue;
      case 'SELESAI': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    List filteredList = selectedFilter == "Semua" 
        ? pengaduanList 
        : pengaduanList.where((item) => statusIndonesia(item["status"]) == selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF4F7F6), // Warna background lebih modern
      drawer: const DrawerAdmin(),
      appBar: AppBar(
        backgroundColor: const Color(0xff004d43),
        title: const Text("Daftar Pengaduan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: const [Padding(padding: EdgeInsets.only(right: 15), child: Icon(Icons.search))],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ["Semua", "Menunggu", "Diproses", "Selesai"]
                  .map((f) => filterButton(f))
                  .toList(),
            ),
          ),
          
          // List Section
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPengaduanAdminPage(pengaduan: Map<String, dynamic>.from(item)))),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("#${item["id"].toString().substring(0, 8).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff004d43))),
                            Text(item["created_at"]?.split(' ')[0] ?? "-", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(item["title"] ?? "-", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Expanded(child: Text(item["address_note"] ?? "-", style: TextStyle(color: Colors.grey.shade600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                            const Spacer(),
                            // Status Chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor(item["status"]).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(statusIndonesia(item["status"]), style: TextStyle(color: statusColor(item["status"]), fontWeight: FontWeight.bold, fontSize: 11)),
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
    );
  }

  Widget filterButton(String text) {
    final isSelected = selectedFilter == text;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff004d43) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xff004d43) : Colors.grey.shade300),
        ),
        child: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}