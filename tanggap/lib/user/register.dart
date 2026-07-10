import 'package:flutter/material.dart';
import 'package:tanggap/user/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../helper/url_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isPasswordHidden = true;
  bool isConfirmHidden = true;
  bool isLoading = false; // Tambahan untuk animasi loading

  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController hpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  // --- FUNGSI REGISTER KE LARAVEL ---
  Future<void> registerAkun() async {
    // 1. Validasi jika ada kolom yang kosong
    if (namaController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua kolom wajib diisi!")),
      );
      return;
    }

    // 2. Validasi apakah password dan konfirmasi sama
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password dan Konfirmasi Password tidak cocok!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String apiUrl = UrlHelper.api('/api/register');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json", // Mencegah pesan error HTML
        },
        body: jsonEncode({
          "full_name": namaController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "phone": hpController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      // Cek apakah response sukses (Kode 201 artinya Created)
      if (response.statusCode == 201 && data['status'] == 'success') {
        if (!mounted) return;
        
        // Memunculkan Notifikasi Hijau
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi Berhasil! Silakan Login."),
            backgroundColor: Colors.green,
          ),
        );

        // Pindah otomatis ke halaman Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${data['message'] ?? 'Email sudah terdaftar'}")),
        );
      }
    } on TimeoutException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Koneksi Timeout! Pastikan server menyala.")),
      );
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
      //backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          //margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            //borderRadius: BorderRadius.circular(25),
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
                      horizontal: 25,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 10),

                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            const Icon(
                              Icons.account_circle,
                              size: 90,
                              color: Color(0xFF2F5FD0),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "Register User",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Buat akun baru sebagai masyarakat",
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),

                            const SizedBox(height: 30),

                            buildLabel("Nama Lengkap"),
                            buildTextField(
                              controller: namaController,
                              hint: "Masukkan Nama Lengkap",
                            ),

                            const SizedBox(height: 15),

                            buildLabel("Email"),
                            buildTextField(
                              controller: emailController,
                              hint: "Masukkan email",
                            ),

                            const SizedBox(height: 15),

                            buildLabel("Nomor HP"),
                            buildTextField(
                              controller: hpController,
                              hint: "Masukkan nomor HP",
                            ),

                            const SizedBox(height: 15),

                            buildLabel("Password"),

                            TextField(
                              controller: passwordController,
                              obscureText: isPasswordHidden,
                              decoration: InputDecoration(
                                hintText: "Buat Password",
                                filled: true,
                                fillColor: const Color(0xFFE0E0E0),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordHidden
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordHidden = !isPasswordHidden;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            buildLabel("Konfirmasi Password"),

                            TextField(
                              controller: confirmController,
                              obscureText: isConfirmHidden,
                              decoration: InputDecoration(
                                hintText: "Ulangi Password",
                                filled: true,
                                fillColor: const Color(0xFFE0E0E0),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isConfirmHidden
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isConfirmHidden = !isConfirmHidden;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                    text: "saya setuju dengan ",
                                  ),
                                  TextSpan(
                                    text: "Syarat dan Ketentuan",
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "\ndan ",
                                  ),
                                  TextSpan(
                                    text: "Kebijakan Privasi",
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

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
                                onPressed: isLoading ? null : registerAkun,
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
                                        "Daftar",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Sudah punya akun? ",
                                  style: TextStyle(fontSize: 11),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Masuk di sini",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  Widget buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String hint,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFE0E0E0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}