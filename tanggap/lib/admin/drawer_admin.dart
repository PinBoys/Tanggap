import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dashboard_admin.dart';
import 'daftar_pengaduan_admin.dart';
import 'laporan_admin.dart';
import 'pengaturan_admin.dart';
import 'logout_admin.dart';

import '../helper/url_helper.dart';

class DrawerAdmin extends StatefulWidget {
  const DrawerAdmin({super.key});

  // Variabel statis ini akan bertahan di memori aplikasi
  // sehingga highlight tidak akan pernah stuck
  static int activeIndex = 0;

  @override
  State<DrawerAdmin> createState() => _DrawerAdminState();
}

class _DrawerAdminState extends State<DrawerAdmin> {
  String namaAdmin = "Memuat...";
  String emailAdmin = "";

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      final response = await http.get(Uri.parse(UrlHelper.api('/api/admin/profile')));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "success") {
          setState(() {
            namaAdmin = data["data"]["full_name"] ?? "Admin";
            emailAdmin = data["data"]["email"] ?? "";
          });
        }
      }
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    required Widget page,
  }) {
    // Cek apakah menu ini sedang aktif
    bool isSelected = DrawerAdmin.activeIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Material(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!isSelected) {
              setState(() {
                DrawerAdmin.activeIndex = index; // Update global state
              });
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
            }
          },
          child: ListTile(
            leading: Icon(
              icon, 
              color: isSelected ? const Color(0xff004d43) : Colors.white,
              size: 24,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xff004d43) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xff004d43),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(color: Color(0xff003d35)),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings, color: Color(0xff004d43), size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(namaAdmin, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(emailAdmin, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildMenuItem(index: 0, icon: Icons.dashboard_rounded, title: "Dashboard", page: const DashboardAdminPage()),
          _buildMenuItem(index: 1, icon: Icons.assignment_turned_in_rounded, title: "Pengaduan", page: const DaftarPengaduanAdminPage()),
          _buildMenuItem(index: 2, icon: Icons.analytics_rounded, title: "Laporan", page: const LaporanAdminPage()),
          _buildMenuItem(index: 3, icon: Icons.settings_rounded, title: "Pengaturan", page: const PengaturanAdminPage()),
          
          const Spacer(),
          
          const Divider(color: Colors.white24, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogoutAdminPage())),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.logout_rounded, color: Color(0xffff8a80)),
              title: const Text("Keluar", style: TextStyle(color: Color(0xffff8a80), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}