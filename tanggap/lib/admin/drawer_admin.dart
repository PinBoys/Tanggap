import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dashboard_admin.dart';
import 'daftar_pengaduan_admin.dart';
import 'laporan_admin.dart';
import 'pengaturan_admin.dart';
import 'logout_admin.dart';

class DrawerAdmin extends StatefulWidget {
  const DrawerAdmin({super.key});

  @override
  State<DrawerAdmin> createState() => _DrawerAdminState();
}

class _DrawerAdminState extends State<DrawerAdmin> {
  String namaAdmin = "loading...";
  String emailAdmin = "";

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://127.0.0.1:8000/api/admin/profile",
        ),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        setState(() {
          namaAdmin = data["data"]["full_name"] ?? "";
          emailAdmin = data["data"]["email"] ?? "";
        });
      }
    } catch (e) {
      print("ERROR DRAWER = $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xff005b4f),
        child: Column(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              child: SingleChildScrollView(
                child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xffdcd0ff),
                    child: Icon(
                      Icons.person,
                      size: 45,
                      color: Color(0xff5a3ea1),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    namaAdmin,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    emailAdmin,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    height: 1,
                    color: Colors.white38,
                  ),
                ],
              ),
            ),
          ),

            ListTile(
              leading: const Icon(
                Icons.dashboard,
                color: Colors.white,
              ),
              title: const Text(
                "Dashboard",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const DashboardAdminPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.report,
                color: Colors.white,
              ),
              title: const Text(
                "Pengaduan",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const DaftarPengaduanAdminPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.bar_chart,
                color: Colors.white,
              ),
              title: const Text(
                "Laporan",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const LaporanAdminPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
              title: const Text(
                "Pengaturan",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PengaturanAdminPage(),
                  ),
                );
              },
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                "Keluar",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const LogoutAdminPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}