import 'package:flutter/material.dart';
import 'package:tanggap/user/landingpage.dart';

class LogoutAdminPage extends StatelessWidget {
  const LogoutAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Keluar Aplikasi"),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              const Text(
                "Yakin ingin keluar?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Anda akan keluar dari aplikasi",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),

                  onPressed: () {                 
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const LandingPage(),
                      ),
                      (route) => false,
                    );
                  },

                  child: const Text(
                    "Keluar",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,

                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text("Batal"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}