import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register.dart';
import 'dashboard.dart';
import 'lupa_password.dart';

import '../helper/url_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isHidden = true;
  bool isLoading = false; // Animasi loading

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // --- FUNGSI UNTUK LOGIN (VERSI LARAVEL) ---
  Future<void> loginAkun() async {
    // Validasi kosong
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password tidak boleh kosong!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Sesuaikan URL ke Laravel di Emulator
    String apiUrl = UrlHelper.api('/api/login');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
            "Content-Type": "application/json",
            "Accept": "application/json" 
        },
        body: jsonEncode({
          // Laravel meminta 'username', bukan 'email'
          "username": emailController.text.trim(), 
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      // Cek status "success" dari Laravel
      if (response.statusCode == 200 && data['status'] == 'success') {
        if (!mounted) return;
        
        // 1. Ambil nama lengkap dari response
        String namaLengkap = data['data']['full_name'];
        
        // 2. Ambil path foto profil dari response (Bisa null jika belum upload)
        // Catatan: Sesuaikan 'foto_profil' dengan nama variabel/kolom yang dikirim oleh API Login Laravel-mu
        String? fotoProfil = data['data']['foto_profil']; 

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Berhasil!")),
        );
        
        String emailLogin = emailController.text.trim();
        // 3. Arahkan ke Dashboard dengan membawa nama DAN FOTO
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(
              namaUser: namaLengkap,
              emailUser: emailController.text.trim(), // <--- KIRIM EMAIL AKTIF SEKARANG KE DASHBOARD
              fotoProfile: fotoProfil, 
            ),
          ),
        );
      } else {
        // Jika gagal
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${data['detail'] ?? 'Email atau Password salah'}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi error koneksi: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 10),

                            const Icon(
                              Icons.account_circle,
                              size: 90,
                              color: Color(0xFF2F5FD0),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "Login User",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Masuk Untuk Melanjutkan",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 40),

                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Email / Nomor HP",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: "Masukkan Email / Nomor HP",
                                filled: true,
                                fillColor: const Color(0xFFE0E0E0),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            TextField(
                              controller: passwordController,
                              obscureText: isHidden,
                              decoration: InputDecoration(
                                hintText: "Masukkan Password",
                                filled: true,
                                fillColor: const Color(0xFFE0E0E0),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isHidden
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isHidden = !isHidden;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LupaPasswordPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Lupa Password?",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isLoading ? null : loginAkun,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Text(
                                        "Masuk",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Belum punya akun? ",
                                  style: TextStyle(fontSize: 12),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Daftar sekarang",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Banner Informasi Bawah
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(top: 30),
                          decoration: BoxDecoration(
                            color: const Color(0xFFAFC7F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue[700],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Text(
                                  "Laporkan keluhan anda dengan mudah dan pantau status pengaduan secara real-time.",
                                  style: TextStyle(
                                    fontSize: 16,
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
              );
            },
          ),
        ),
      ),
    );
  }
}