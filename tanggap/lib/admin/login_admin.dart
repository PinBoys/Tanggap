import 'package:flutter/material.dart';
import 'dashboard_admin.dart';
import 'lupa_pw_admin.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../helper/url_helper.dart';

class LoginAdminPage extends StatefulWidget {
  const LoginAdminPage({super.key});

  @override
  State<LoginAdminPage> createState() => _LoginAdminPageState();
}

class _LoginAdminPageState extends State<LoginAdminPage> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool isLoading = false;
  bool isPasswordHidden = true;

  final String apiUrl = UrlHelper.api('/api/admin/login');

  Future<void> loginAdmin() async {
    if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email dan Password wajib diisi"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),

        headers: {"Content-Type": "application/json", "Accept": "application/json",},

        body: jsonEncode({
          "email": emailCtrl.text.trim(),
          "password": passwordCtrl.text,
        }),
      );

      print(response.statusCode);
      print(response.body);

      if (response.body.startsWith("<!DOCTYPE")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Laravel mengembalikan HTML"),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardAdminPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Login gagal"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                const Icon(Icons.account_circle, size: 90, color: Colors.green),

                const SizedBox(height: 10),

                const Text(
                  "Login Admin",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Masuk Untuk Mengakses dashboard admin",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: emailCtrl,

                  decoration: InputDecoration(
                    hintText: "Masukkan Email admin",

                    filled: true,

                    fillColor: Colors.grey.shade200,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: passwordCtrl,

                  obscureText: isPasswordHidden,

                  decoration: InputDecoration(
                    hintText: "Masukkan Password",

                    filled: true,

                    fillColor: Colors.grey.shade200,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),

                      borderSide: BorderSide.none,
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
                  ),
                ),

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
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  height: 50,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),

                    onPressed: isLoading ? null : loginAdmin,

                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,

                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Masuk",

                            style: TextStyle(color: Colors.white),
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
