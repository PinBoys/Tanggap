import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'ganti_pw_admin.dart'; // Pastikan file ganti_password.dart sudah dibuat

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false; // Untuk menampilkan animasi putaran (loading)

  // Fungsi untuk mengecek email ke Backend Laravel
  Future<void> kirimLinkReset() async {
    // 1. Validasi kosong
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email atau Nomor HP tidak boleh kosong!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Sesuaikan URL ke Laravel di Android Emulator
    String apiUrl = 'http://10.0.2.2:8000/api/check-email';
    
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
            "Content-Type": "application/json",
            "Accept": "application/json" // <-- TAMBAHKAN BARIS INI
        },
        body: jsonEncode({"email": emailController.text.trim()}),
      ).timeout(const Duration(seconds: 10));

      // Dekode response dari Laravel
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        // Jika email ada di database, langsung pindah ke halaman Ganti Password!
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // Mengirimkan email ke halaman ganti_password agar tahu akun mana yang diubah
            builder: (context) => GantiPasswordPage(email: emailController.text.trim()),
          ),
        );
      } else {
        // Jika email tidak terdaftar
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${data['detail'] ?? 'Email tidak ditemukan'}")),
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
        SnackBar(content: Text("Terjadi error: $e")),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Icon Gembok dengan background bulat biru muda
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock,
                      size: 50,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Judul
                const Text(
                  "Lupa Password",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 15),

                // Subjudul (Deskripsi)
                const Text(
                  "Masukkan email atau nomor HP Anda,\nKami akan mengirimkan link untuk\nmereset password.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // Label Input
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email atau Nomor HP",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // TextField Input
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Masukkan email atau nomor HP",
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Tombol Kirim Link Reset
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isLoading ? null : kirimLinkReset,
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
                            "Kirim Link Reset",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                // Tombol Kembali ke Login
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                  },
                  child: const Text(
                    "Kembali ke login",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}