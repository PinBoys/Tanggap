import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helper/image_helper.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:image_picker/image_picker.dart'; // Wajib install image_picker
import 'dart:typed_data'; // Untuk web image bytes

import 'daftar_pengaduan_admin.dart';

class TindakLanjutAdminPage extends StatefulWidget {
  final Map<String, dynamic> pengaduan;

  const TindakLanjutAdminPage({
    super.key,
    required this.pengaduan,
  });

  @override
  State<TindakLanjutAdminPage> createState() => _TindakLanjutAdminPageState();
}

class _TindakLanjutAdminPageState extends State<TindakLanjutAdminPage> {
  late String status;
  late String emailAdmin;
  bool isLoading = false;

  // Controller untuk menangkap isi teks Catatan
  final TextEditingController _catatanCtrl = TextEditingController();

  // Variabel untuk menampung foto yang dipilih
  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFiles = [];

  @override
  void initState() {
    super.initState();

    final rawStatus = widget.pengaduan["status"];

    if (rawStatus == null) {
      status = "PENDING";
    } else {
      status = rawStatus.toString().toUpperCase();
    }

    loadAdmin();
  }

  void loadAdmin() {
    emailAdmin = "admin@gmail.com";
  }

  String formatStatus(String status) {
    switch (status.toUpperCase()) {
      case "PENDING":
        return "Menunggu";
      case "DIPROSES":
        return "Diproses";
      case "SELESAI":
        return "Selesai";
      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case "PENDING":
        return Colors.orange;
      case "DIPROSES":
        return Colors.blue;
      case "SELESAI":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // FUNGSI UNTUK MEMILIH GAMBAR
  Future<void> _pickImages() async {
    if (_imageFiles.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maksimal 3 foto tindak lanjut!")),
      );
      return;
    }

    final List<XFile> selectedImages = await _picker.pickMultiImage(imageQuality: 100,);
    if (selectedImages.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(selectedImages);
        if (_imageFiles.length > 3) {
          _imageFiles = _imageFiles.sublist(0, 3);
        }
      });
    }
  }

  // FUNGSI UNTUK MENGIRIM DATA (STATUS, CATATAN, FOTO) KE LARAVEL
  Future<bool> updateStatus() async {
    // Validasi catatan tidak boleh kosong sesuai aturan database
    if (_catatanCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Catatan / Tindakan wajib diisi!")),
      );
      return false;
    }

    setState(() {
      isLoading = true;
    });

    try {
      debugPrint("===== DATA YANG DIKIRIM =====");
      debugPrint("ID: ${widget.pengaduan["id"]}");
      debugPrint("Status: $status");
      debugPrint("Notes: ${_catatanCtrl.text}");
      debugPrint("=============================");
      
      // Menggunakan rute baru khusus tindak lanjut (murni POST)
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse("http://10.0.2.2:8000/api/admin/pengaduan/${widget.pengaduan['id']}/tindak-lanjut")
      );

      // PERBAIKAN: Menambahkan Accept header agar Laravel tidak membalas dengan HTML Error
      request.headers['Accept'] = 'application/json';
      
      // Tambahkan text data sesuai field database baru
      request.fields['email_admin'] = emailAdmin; 
      request.fields['status'] = status;
      request.fields['notes'] = _catatanCtrl.text; 

      // Tambahkan foto 
      // ===============================
      // COMPRESS FOTO SEBELUM UPLOAD
      // ===============================

      for (var file in _imageFiles) {

        if (kIsWeb) {

          var bytes = await file.readAsBytes();

          request.files.add(
            http.MultipartFile.fromBytes(
              'foto_bukti[]',
              bytes,
              filename: file.name,
            ),
          );

        } else {

          File originalFile = File(file.path);

          File uploadFile;

          try {
            uploadFile = await ImageHelper.compress(originalFile);
          } catch (e) {
            uploadFile = originalFile;
          }

          request.files.add(
            await http.MultipartFile.fromPath(
              'foto_bukti[]',
              uploadFile.path,
            ),
          );
        }
      }

      // PERBAIKAN: Menambahkan timeout agar tidak hang saat upload foto
      var streamedResponse = await request
          .send()
          .timeout(const Duration(seconds: 60));

      var response = await http.Response.fromStream(streamedResponse);

      debugPrint("STATUS CODE : ${response.statusCode}");
      debugPrint("BODY : ${response.body}");

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["status"] == "success") {
        return true;
      }

      debugPrint("Gagal : ${response.body}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Terjadi kesalahan"),
        ),
      );

      return false;
    } catch (e) {
      debugPrint("Error Update: $e");
      return false;
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          "Tindak Lanjut",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ((widget.pengaduan["id"] ?? "-").toString().length >= 8)
                  ? (widget.pengaduan["id"] ?? "-").toString().substring(0, 8)
                  : (widget.pengaduan["id"] ?? "-").toString(),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor(
                      widget.pengaduan["status"]?.toString() ?? "PENDING",
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    formatStatus(
                      widget.pengaduan["status"]?.toString() ?? "PENDING",
                    ),
                    style: TextStyle(
                      color: statusColor(
                        widget.pengaduan["status"]?.toString() ?? "PENDING",
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            const Text(
              "Status",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: status,
              items: const [
                DropdownMenuItem(value: "PENDING", child: Text("Menunggu")),
                DropdownMenuItem(value: "DIPROSES", child: Text("Diproses")),
                DropdownMenuItem(value: "SELESAI", child: Text("Selesai")),
              ],
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
            const SizedBox(height: 25),
            const Text(
              "Catatan / Tindakan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _catatanCtrl, 
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Tulis tindak lanjut",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                const Text(
                  "Foto Tindak Lanjut",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                Text(
                  "(Opsional, Maks 3)", 
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)
                ),
              ],
            ),
            const SizedBox(height: 15),

            // AREA FOTO DINAMIS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // List foto yang sudah dipilih
                  ..._imageFiles.asMap().entries.map((entry) {
                    int index = entry.key;
                    XFile image = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildImagePreview(image, index),
                    );
                  }),

                  // Tombol Tambah Foto
                  GestureDetector(
                    onTap: _pickImages, // Panggil fungsi pilih gambar
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: isLoading ? null : () async {
                  bool berhasil = await updateStatus();
                  if (!mounted) return;
                  if (berhasil) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DaftarPengaduanAdminPage(),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: isLoading 
                    ? const SizedBox(
                        height: 20, width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        "Simpan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET UNTUK PREVIEW FOTO + TOMBOL HAPUS (Kompatiabel Web & Android)
  Widget _buildImagePreview(XFile image, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade300, 
          ),
          clipBehavior: Clip.hardEdge,
          child: kIsWeb
              ? Image.network(
                  image.path, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey),
                )
              : Image.file(
                  File(image.path), 
                  fit: BoxFit.cover,
                ),
        ),
        
        Positioned(
          top: -5,
          right: -5,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _imageFiles.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}