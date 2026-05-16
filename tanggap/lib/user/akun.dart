import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'landingpage.dart';

class AkunPage extends StatefulWidget {
  final String emailTarget; 
  const AkunPage({super.key, this.emailTarget = "govin@gmail.com"});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  String namaLengkap = "Memuat...";
  String emailUser = "Memuat...";
  String noHp = "Memuat...";
  String alamat = "Memuat...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    String apiUrl = "http://10.0.2.2:8000/api/profile/${widget.emailTarget}";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          namaLengkap = data['full_name'] ?? "Tanpa Nama";
          emailUser = data['email'] ?? widget.emailTarget;
          noHp = data['phone'] ?? "Belum diatur";
          alamat = data['alamat'] ?? "Belum diatur";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background abu-abu super lembut
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Akun Saya", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
        ),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blue))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // KARTU PROFIL UTAMA (GRADIENT BIRU)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade800, Colors.blue.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey.shade200,
                          child: Icon(Icons.person, size: 40, color: Colors.blue.shade700),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              namaLengkap, 
                              style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 18
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              emailUser, 
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)
                            ),
                            const SizedBox(height: 2),
                            Text(
                              noHp, 
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // DAFTAR MENU DENGAN BAYANGAN (SHADOW)
                _menuTile(
                  context,
                  icon: Icons.person_outline,
                  color: Colors.blue,
                  title: "Profile Saya",
                  subtitle: "Lihat detail informasi akun",
                  page: ProfilePage(nama: namaLengkap, email: emailUser, hp: noHp, alamat: alamat),
                ),
                _menuTile(
                  context,
                  icon: Icons.lock_outline,
                  color: Colors.orange,
                  title: "Ubah Password",
                  subtitle: "Ganti kata sandi demi keamanan",
                  page: UbahPasswordPage(email: emailUser),
                ),
                _menuTile(
                  context,
                  icon: Icons.history,
                  color: Colors.purple,
                  title: "Riwayat Pengaduan",
                  subtitle: "Pantau status laporan Anda",
                  page: RiwayatPage(email: emailUser),
                ),
                _menuTile(
                  context,
                  icon: Icons.edit_outlined,
                  color: Colors.green,
                  title: "Edit Profil",
                  subtitle: "Perbarui nama dan nomor telepon",
                  page: EditProfilPage(email: emailUser, namaLengkap: namaLengkap, noHp: noHp),
                ),

                const SizedBox(height: 20),

                // TOMBOL LOGOUT MODERN
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.red.shade200, width: 1.5),
                      ),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LogoutPage())),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text("Keluar dari Akun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _menuTile(BuildContext context, {required IconData icon, required Color color, required String title, required String subtitle, required Widget page}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)).then((_) {
          fetchProfileData(); // Refresh data jika kembali dari halaman edit
        }),
      ),
    );
  }
}

// ================= PROFILE SAYA (DESAIN HEADER MELENGKUNG) =================
class ProfilePage extends StatelessWidget {
  final String nama;
  final String email;
  final String hp;
  final String alamat;

  const ProfilePage({super.key, required this.nama, required this.email, required this.hp, required this.alamat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER BACKGROUND MELENGKUNG
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade500]),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 60, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            Text(nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
              child: Text("Warga Desa Maju Bersama", style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
            ),

            const SizedBox(height: 30),

            // KARTU INFORMASI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.badge_outlined, "Nama Lengkap", nama),
                      const Divider(height: 25, thickness: 1, color: Color(0xFFF0F0F0)),
                      _buildInfoRow(Icons.email_outlined, "Email", email),
                      const Divider(height: 25, thickness: 1, color: Color(0xFFF0F0F0)),
                      _buildInfoRow(Icons.phone_outlined, "Nomor Telepon", hp),
                      const Divider(height: 25, thickness: 1, color: Color(0xFFF0F0F0)),
                      _buildInfoRow(Icons.location_on_outlined, "Alamat", alamat),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.blue.shade700, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

// ================= EDIT PROFIL =================
class EditProfilPage extends StatefulWidget {
  final String email;
  final String namaLengkap;
  final String noHp;
  const EditProfilPage({super.key, required this.email, required this.namaLengkap, required this.noHp});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  late TextEditingController namaController;
  late TextEditingController hpController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.namaLengkap == "Tanpa Nama" ? "" : widget.namaLengkap);
    hpController = TextEditingController(text: widget.noHp == "Belum diatur" ? "" : widget.noHp);
  }

  Future<void> simpanProfile() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/profile/update'),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"email": widget.email, "full_name": namaController.text, "phone": hpController.text}),
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil Berhasil Diperbarui!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const CircleAvatar(radius: 45, backgroundColor: Color(0xFFF0F0F0), child: Icon(Icons.edit, size: 40, color: Colors.blue)),
            const SizedBox(height: 30),
            _field("Nama Lengkap", Icons.person_outline, namaController),
            _fieldDisabled("Email (Tidak bisa diubah)", Icons.email_outlined, widget.email),
            _field("Nomor Telepon", Icons.phone_outlined, hpController),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: isLoading ? null : simpanProfile,
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String hint, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _fieldDisabled(String hint, IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: hint,
          hintText: value,
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

// ================= UBAH PASSWORD =================
class UbahPasswordPage extends StatefulWidget {
  final String email;
  const UbahPasswordPage({super.key, required this.email});

  @override
  State<UbahPasswordPage> createState() => _UbahPasswordPageState();
}

class _UbahPasswordPageState extends State<UbahPasswordPage> {
  final TextEditingController oldPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  bool isHidden = true;
  bool isLoading = false;

  Future<void> simpanPassword() async {
    if (newPassController.text != confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konfirmasi password baru tidak cocok!")));
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/profile/change-password'),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"email": widget.email, "old_password": oldPassController.text, "new_password": newPassController.text}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Berhasil Diubah!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${data['detail']}")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Ubah Password", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const CircleAvatar(radius: 45, backgroundColor: Color(0xFFFFF4E5), child: Icon(Icons.lock_outline, size: 40, color: Colors.orange)),
            const SizedBox(height: 30),
            _password("Password Lama", oldPassController),
            _password("Password Baru", newPassController),
            _password("Konfirmasi Password Baru", confirmPassController),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: isLoading ? null : simpanPassword,
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Simpan Password", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _password(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: isHidden,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: const Icon(Icons.key_outlined, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
            onPressed: () => setState(() => isHidden = !isHidden),
          ),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

// ================= RIWAYAT PRIBADI =================
class RiwayatPage extends StatefulWidget {
  final String email;
  const RiwayatPage({super.key, required this.email});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<dynamic> riwayat = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    try {
      final response = await http.get(Uri.parse("http://10.0.2.2:8000/api/pengaduan/riwayat/${widget.email}"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          riwayat = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Riwayat Pengaduan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blue))
        : riwayat.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text("Belum ada laporan", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: riwayat.length,
              itemBuilder: (context, index) {
                final item = riwayat[index];
                
                // Menentukan warna badge status
                Color statusColor = Colors.grey;
                if (item['status'] == 'Menunggu') statusColor = Colors.orange;
                if (item['status'] == 'Diproses') statusColor = Colors.blue;
                if (item['status'] == 'Selesai') statusColor = Colors.green;

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.assignment_outlined, color: Colors.blue.shade700),
                    ),
                    title: Text(item['judul'] ?? "Tanpa Judul", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(item['status'], style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    trailing: Text("#${item['id_pengaduan']}", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  ),
                );
              },
            ),
    );
  }
}

// ================= LOGOUT =================
class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 80),
              ),
              const SizedBox(height: 30),
              const Text("Yakin ingin keluar?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),
              Text(
                "Sesi Anda akan berakhir dan Anda harus masuk kembali untuk membuat laporan.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LandingPage()),
                      (route) => false,
                    );
                  },
                  child: const Text("Ya, Keluar Akun", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton(
                  style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal", style: TextStyle(color: Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}