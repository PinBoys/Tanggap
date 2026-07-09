import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dashboard_admin.dart';
import 'logout_admin.dart';

class PengaturanAdminPage extends StatefulWidget {
  const PengaturanAdminPage({super.key});

  @override
  State<PengaturanAdminPage> createState() => _PengaturanAdminPageState();
}

class _PengaturanAdminPageState extends State<PengaturanAdminPage> {
  int selectedPage = 0;

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final teleponController = TextEditingController();

  //edit pw
  final passwordLamaController = TextEditingController();

  final passwordBaruController = TextEditingController();

  final konfirmasiController = TextEditingController();

  bool hide1 = true;
  bool hide2 = true;
  bool hide3 = true;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/api/admin/profile"),
      );

      print(response.body);

      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        namaController.text = data["data"]["full_name"] ?? "";

        emailController.text = data["data"]["email"] ?? "";

        teleponController.text = data["data"]["phone"] ?? "";

        setState(() {});
      }
    } catch (e) {
      print("ERROR PROFILE = $e");
    }
  }

  Future<void> updateProfile() async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/admin/profile/update"),

        body: {
          "full_name": namaController.text,

          "email": emailController.text,

          "phone": teleponController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui")),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> changePassword() async {
    if (passwordBaruController.text != konfirmasiController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi password tidak cocok")),
      );

      return;
    }

    final response = await http.post(
      Uri.parse("http://10.0.2.2:8000/api/admin/change-password"),

      body: {
        "old_password": passwordLamaController.text,

        "new_password": passwordBaruController.text,
      },
    );

    final data = jsonDecode(response.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data["message"])));

    if (data["status"] == "success") {
      passwordLamaController.clear();
      passwordBaruController.clear();
      konfirmasiController.clear();

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      setState(() {
        selectedPage = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        backgroundColor: const Color(0xffF5F6FA),
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),

          onPressed: () {
            // HALAMAN UTAMA
            if (selectedPage == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardAdminPage(),
                ),
              );
            }
            // HALAMAN AKUN / KEAMANAN
            else {
              setState(() {
                selectedPage = 0;
              });
            }
          },
        ),

        iconTheme: const IconThemeData(color: Colors.black),

        centerTitle: true,

        title: Text(
          selectedPage == 0
              ? "Pengaturan"
              : selectedPage == 1
              ? "Akun Admin"
              : "Keamanan",

          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: selectedPage == 0
          ? halamanPengaturan()
          : selectedPage == 1
          ? halamanAkun()
          : halamanKeamanan(),
    );
  }

  // =====================
  // HALAMAN PENGATURAN
  // =====================

  Widget halamanPengaturan() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //================ PROFILE CARD =================//
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xff0B6E4F),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.green.shade50,
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 55,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaController.text.isEmpty
                            ? "Loading..."
                            : namaController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        emailController.text,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.verified_user,
                              color: Colors.green,
                              size: 18,
                            ),

                            SizedBox(width: 6),

                            Text(
                              "Administrator",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),

          Row(
            children: const [
              Text(
                "AKUN",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(width: 10),

              Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.person, color: Colors.green),
                  ),

                  title: const Text(
                    "Akun Admin",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: const Text("Ubah informasi akun admin"),

                  trailing: const Icon(Icons.chevron_right),

                  onTap: () {
                    setState(() {
                      selectedPage = 1;
                    });
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.lock),
                  ),

                  title: const Text(
                    "Keamanan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: const Text("Ubah password akun"),

                  trailing: const Icon(Icons.chevron_right),

                  onTap: () {
                    setState(() {
                      selectedPage = 2;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),

          Row(
            children: const [
              Text(
                "LAINNYA",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(width: 10),

              Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.logout, color: Colors.red),
              ),

              title: const Text(
                "Keluar",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: const Text("Keluar dari akun admin"),

              trailing: const Icon(Icons.chevron_right),

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => const LogoutAdminPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  // =====================
  // HALAMAN AKUN
  // =====================

  Widget halamanAkun() {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          const SizedBox(height: 20),

          const CircleAvatar(
            radius: 55,
            backgroundColor: Colors.black12,

            child: Icon(Icons.person_outline, size: 70, color: Colors.black),
          ),

          const SizedBox(height: 40),

          textField("Nama Lengkap", namaController),

          const SizedBox(height: 20),

          textField("Email", emailController),

          const SizedBox(height: 20),

          textField("Nomor Telepon", teleponController),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 50,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

              onPressed: () async {
                await updateProfile();

                setState(() {
                  selectedPage = 0;
                });
              },

              child: const Text(
                "Simpan Perubahan",

                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================
  // HALAMAN KEAMANAN
  // =====================

  Widget halamanKeamanan() {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.green.shade200,

            child: const Icon(Icons.lock, size: 70, color: Colors.green),
          ),

          const SizedBox(height: 25),

          const Text(
            "Ubah Password",

            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            "Pastikan akun anda menggunakan password yang kuat dan tidak mudah ditebak.",

            textAlign: TextAlign.center,

            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 40),

          passwordField(
            "Password lama",
            "Masukkan password lama",
            passwordLamaController,
            hide1,
            () {
              setState(() {
                hide1 = !hide1;
              });
            },
          ),
          const SizedBox(height: 20),

          passwordField(
            "Password baru",
            "Masukkan password baru",
            passwordBaruController,
            hide2,
            () {
              setState(() {
                hide2 = !hide2;
              });
            },
          ),

          const SizedBox(height: 20),

          passwordField(
            "Konfirmasi password baru",
            "Masukkan lagi password baru",
            konfirmasiController,
            hide3,
            () {
              setState(() {
                hide3 = !hide3;
              });
            },
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 50,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

              onPressed: () async {
                await changePassword();
              },

              child: const Text(
                "Ubah Password",

                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================
  // TEXTFIELD
  // =====================

  Widget textField(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),

        TextField(
          controller: controller,

          readOnly: title == "Email",

          decoration: InputDecoration(
            filled: true,

            fillColor: title == "Email" ? Colors.grey.shade100 : Colors.white,

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  // =====================
  // PASSWORD FIELD
  // =====================

  Widget passwordField(
    String title,
    String hint,
    TextEditingController controller,
    bool hide,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),

        TextField(
          controller: controller,
          obscureText: hide,

          decoration: InputDecoration(
            hintText: hint,

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),

            suffixIcon: IconButton(
              icon: Icon(hide ? Icons.visibility_off : Icons.visibility),

              onPressed: onTap,
            ),
          ),
        ),
      ],
    );
  }
}
