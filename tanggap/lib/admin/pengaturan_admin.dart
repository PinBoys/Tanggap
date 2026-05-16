import 'package:flutter/material.dart';
import 'dashboard_admin.dart';

class PengaturanAdminPage extends StatefulWidget {
  const PengaturanAdminPage({super.key});

  @override
  State<PengaturanAdminPage> createState() =>
      _PengaturanAdminPageState();
}

class _PengaturanAdminPageState
    extends State<PengaturanAdminPage> {

  int selectedPage = 0;

  bool hide1 = true;
  bool hide2 = true;
  bool hide3 = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(

        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),

          onPressed: () {

            // HALAMAN UTAMA
            if (selectedPage == 0) {

               Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const DashboardAdminPage(),
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

        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),

        centerTitle: true,

        title: Text(

          selectedPage == 0
              ? "Pengaturan"
              : selectedPage == 1
                  ? "Akun Admin"
                  : "Keamanan",

          style: const TextStyle(
            color: Colors.black,
            fontWeight:
                FontWeight.bold,
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

    return Padding(
      padding:
          const EdgeInsets.all(20),

      child: Column(
        children: [

          const SizedBox(height: 20),

          const CircleAvatar(
            radius: 55,
            backgroundColor:
                Colors.black12,

            child: Icon(
              Icons.person_outline,
              size: 70,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Admin Desa",

            style: TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "admin@desamaju.id",

            style: TextStyle(
              color:
                  Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 40),

          // AKUN ADMIN
          ListTile(

            leading: Container(
              padding:
                  const EdgeInsets.all(
                      8),

              decoration: BoxDecoration(
                color:
                    Colors.green.shade100,

                borderRadius:
                    BorderRadius.circular(
                        8),
              ),

              child: const Icon(
                Icons.person,
                color: Colors.green,
              ),
            ),

            title: const Text(
              "Akun Admin",

              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            subtitle: const Text(
              "Ubah informasi akun admin",
            ),

            onTap: () {

              setState(() {

                selectedPage = 1;

              });

            },
          ),

          const SizedBox(height: 15),

          // KEAMANAN
          ListTile(

            leading: Container(
              padding:
                  const EdgeInsets.all(
                      8),

              decoration: BoxDecoration(
                color:
                    Colors.grey.shade300,

                borderRadius:
                    BorderRadius.circular(
                        8),
              ),

              child: const Icon(
                Icons.lock,
                color: Colors.black,
              ),
            ),

            title: const Text(
              "Keamanan",

              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            subtitle: const Text(
              "Ubah password akun",
            ),

            onTap: () {

              setState(() {

                selectedPage = 2;

              });

            },
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
      padding:
          const EdgeInsets.all(20),

      child: Column(
        children: [

          const SizedBox(height: 20),

          const CircleAvatar(
            radius: 55,
            backgroundColor:
                Colors.black12,

            child: Icon(
              Icons.person_outline,
              size: 70,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 40),

          textField(
            "Nama Lengkap",
            "Admin Desa",
          ),

          const SizedBox(height: 20),

          textField(
            "Email",
            "admin@desamaju.id",
          ),

          const SizedBox(height: 20),

          textField(
            "Nomor Telepon",
            "0812-3456-7890",
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 50,

            child: ElevatedButton(
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors.green,
              ),

              onPressed: () {

                setState(() {

                  selectedPage = 0;

                });

              },

              child: const Text(
                "Simpan Perubahan",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
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
      padding:
          const EdgeInsets.all(20),

      child: Column(
        children: [

          CircleAvatar(
            radius: 60,
            backgroundColor:
                Colors.green.shade200,

            child: const Icon(
              Icons.lock,
              size: 70,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Ubah Password",

            style: TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Pastikan akun anda menggunakan password yang kuat dan tidak mudah ditebak.",

            textAlign:
                TextAlign.center,

            style: TextStyle(
              color:
                  Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 40),

          passwordField(
            "Password lama",
            "Masukkan password lama",
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
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors.green,
              ),

              onPressed: () {

                setState(() {

                  selectedPage = 0;

                });

              },

              child: const Text(
                "Ubah Password",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
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

  Widget textField(
    String title,
    String hint,
  ) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          title,

          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          decoration: InputDecoration(
            hintText: hint,

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      8),
            ),
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
    bool hide,
    VoidCallback onTap,
  ) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          title,

          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          obscureText: hide,

          decoration: InputDecoration(
            hintText: hint,

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      8),
            ),

            suffixIcon: IconButton(
              icon: Icon(
                hide
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),

              onPressed: onTap,
            ),
          ),
        ),
      ],
    );
  }
}