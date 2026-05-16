import 'package:flutter/material.dart';
import 'logout_admin.dart';
import 'daftar_pengaduan_admin.dart';
import 'dashboard_admin.dart';
import 'laporan_admin.dart';
import 'pengaturan_admin.dart';

class DrawerAdmin extends StatelessWidget {
  const DrawerAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(

      child: Container(
        color: const Color(0xff004d40),

        child: Column(
          children: [

            DrawerHeader(
              child: Column(
                children: const [

                  CircleAvatar(
                    radius: 35,
                    child: Icon(
                      Icons.person,
                      size: 40,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Admin Desa",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  Text(
                    "admin@gmail.com",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
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
                    builder: (context) =>
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
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
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
                    builder: (context) =>
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
                    builder: (context) =>
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
                    builder: (context) =>
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