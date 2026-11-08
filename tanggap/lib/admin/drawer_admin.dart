
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dashboard_admin.dart';
import 'daftar_pengaduan_admin.dart';
import 'laporan_admin.dart';
import 'pengaturan_admin.dart';
import 'logout_admin.dart';
import 'analisis_ai_admin.dart';

import '../helper/url_helper.dart';

class DrawerAdmin extends StatefulWidget {
  const DrawerAdmin({super.key});

  static int activeIndex = 0;

  @override
  State<DrawerAdmin> createState() => _DrawerAdminState();
}

class _DrawerAdminState extends State<DrawerAdmin> {
  String namaAdmin = "Memuat...";
  String emailAdmin = "";

  static const Color primaryGreen = Color(0xFF086B50);
  static const Color darkGreen = Color(0xFF064E3B);
  static const Color backgroundGreen = Color(0xFF073B30);
  static const Color selectedBackground = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  // =====================================================
  // MENGAMBIL PROFIL ADMIN
  // =====================================================
  Future<void> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse(
          UrlHelper.api('/api/admin/profile'),
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "success") {
          if (!mounted) return;

          setState(() {
            namaAdmin = data["data"]["full_name"] ?? "Admin";
            emailAdmin = data["data"]["email"] ?? "";
          });
        }
      }
    } catch (e) {
      debugPrint("ERROR PROFILE ADMIN: $e");

      if (!mounted) return;

      setState(() {
        namaAdmin = "Admin";
      });
    }
  }

  // =====================================================
  // MENU ITEM
  // =====================================================
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    required Widget page,
  }) {
    final bool isSelected = DrawerAdmin.activeIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      child: Material(
        color: isSelected
            ? selectedBackground
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (isSelected) return;

            setState(() {
              DrawerAdmin.activeIndex = index;
            });

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => page,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 13,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: isSelected
                      ? darkGreen
                      : Colors.white,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? darkGreen
                          : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: darkGreen,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // HEADER PROFIL ADMIN
  // =====================================================
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        55,
        20,
        25,
      ),
      decoration: const BoxDecoration(
        color: backgroundGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: darkGreen,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaAdmin,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  emailAdmin.isEmpty
                      ? "Administrator Desa"
                      : emailAdmin,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // LABEL MENU
  // =====================================================
  Widget _buildMenuLabel(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        25,
        22,
        20,
        8,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // =====================================================
  // MENU KELUAR
  // =====================================================
  Widget _buildLogoutMenu() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        14,
        8,
        14,
        20,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LogoutAdminPage(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF7777),
                  size: 21,
                ),
                SizedBox(width: 14),
                Text(
                  "Keluar",
                  style: TextStyle(
                    color: Color(0xFFFF7777),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // BUILD DRAWER
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: primaryGreen,
      elevation: 10,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // HEADER PROFIL
            _buildProfileHeader(),

            const SizedBox(height: 15),

            // MENU UTAMA
            _buildMenuLabel("Menu Utama"),

            _buildMenuItem(
              index: 0,
              icon: Icons.dashboard_rounded,
              title: "Dashboard",
              page: const DashboardAdminPage(),
            ),

            _buildMenuItem(
              index: 1,
              icon: Icons.assignment_turned_in_rounded,
              title: "Pengaduan",
              page: const DaftarPengaduanAdminPage(),
            ),

            _buildMenuItem(
              index: 2,
              icon: Icons.analytics_rounded,
              title: "Laporan",
              page: const LaporanAdminPage(),
            ),

            _buildMenuItem(
              index: 3,
              icon: Icons.auto_awesome_rounded,
              title: "Analisis AI",
              page: const AnalisisAIAdminPage(),
            ),

            // PENGATURAN
            _buildMenuLabel("Preferensi"),

            _buildMenuItem(
              index: 4,
              icon: Icons.settings_rounded,
              title: "Pengaturan",
              page: const PengaturanAdminPage(),
            ),

            const Spacer(),

            // GARIS PEMBATAS
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Divider(
                color: Colors.white.withOpacity(0.15),
                thickness: 1,
              ),
            ),

            // LOGOUT
            _buildLogoutMenu(),
          ],
        ),
      ),
    );
  }
}
