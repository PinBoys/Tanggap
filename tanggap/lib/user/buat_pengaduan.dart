import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../helper/image_helper.dart';

class BuatPengaduanPage extends StatefulWidget {
  // Tambahkan email agar Laravel tahu ini pengaduan milik siapa
  final String emailTarget; 
  const BuatPengaduanPage({super.key, required this.emailTarget});

  @override
  State<BuatPengaduanPage> createState() => _BuatPengaduanPageState();
}

class _BuatPengaduanPageState extends State<BuatPengaduanPage> {
  final TextEditingController _judulCtrl = TextEditingController();
  final TextEditingController _lokasiCtrl = TextEditingController();
  final TextEditingController _deskripsiCtrl = TextEditingController();

  String? dampak;
  String? sensitivitas;
  String? alternatif;
  String? cakupan;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFiles = [];
  bool isLoading = false;

  final String apiUrl = "http://10.0.2.2:8000/api/pengaduan";

  Future<void> _pickImages() async {
    if (_imageFiles.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maksimal 5 foto bukti!")),
      );
      return;
    }

    final List<XFile> selectedImages = await _picker.pickMultiImage(imageQuality: 80,);
    if (selectedImages.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(selectedImages);
        if (_imageFiles.length > 5) {
          _imageFiles = _imageFiles.sublist(0, 5);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  Future<void> _submitPengaduan() async {
    if (_judulCtrl.text.isEmpty || _lokasiCtrl.text.isEmpty || _deskripsiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul, Lokasi, dan Deskripsi wajib diisi!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      
      // MENGIRIM SEMUA DATA YANG DIBUTUHKAN DATABASE
      request.fields['email'] = widget.emailTarget; // Email Pengirim
      request.fields['judul'] = _judulCtrl.text;
      request.fields['titik_lokasi'] = _lokasiCtrl.text;
      request.fields['deskripsi'] = _deskripsiCtrl.text;
      
      // Kirim data dropdown (Berikan default value jika user lupa milih)
      request.fields['dampak'] = dampak ?? 'Aman'; 
      request.fields['sensitivitas'] = sensitivitas ?? 'Stabil'; 
      request.fields['alternatif'] = alternatif ?? 'Banyak Pilihan'; 
      request.fields['cakupan'] = cakupan ?? 'Pribadi'; 

      // Mengisi Data Foto Bukti 
      // ==============================
      // COMPRESS FOTO SEBELUM UPLOAD
      // ==============================

      for (var file in _imageFiles) {

        File originalFile = File(file.path);

        File uploadFile;

        try {
          uploadFile = await ImageHelper.compress(originalFile);
        } catch (e) {
          // Jika compress gagal, upload file asli
          uploadFile = originalFile;
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'bukti[]',
            uploadFile.path,
          ),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pengaduan berhasil dikirim!"),
          backgroundColor: Colors.green,
        ),
      );

      // beri waktu Laravel menyelesaikan penyimpanan
      await Future.delayed(
        const Duration(seconds: 1),
      );

      Navigator.pop(context, true);

    } else {
        throw Exception(responseData);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
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
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Buat Pengaduan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // JUDUL
            const Text("Judul Pengaduan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTextField(hint: "Masukan Permasalahan", controller: _judulCtrl),
            const SizedBox(height: 18),

            // LOKASI
            const Text("Lokasi Kejadian", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTextField(hint: "Pilih lokasi atau tulis alamat", controller: _lokasiCtrl),
            const SizedBox(height: 18),

            // DESKRIPSI
            const Text("Keluhan / Deskripsi", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _deskripsiCtrl, 
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Tuliskan keluhan Anda secara detail...",
                  border: InputBorder.none,
                ),
                onChanged: (text) {
                  setState(() {}); 
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "${_deskripsiCtrl.text.length}/1000", 
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // DROPDOWN DAMPAK
            const Text("Tingkat Bahaya", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDropdown(
              value: dampak,
              hint: "Masukan dampak keselamatan",
              items: ["Aman", "Gangguan Kecil", "Resiko Luka", "Sangat Berbahaya", "Gawat Darurat"],
              onChanged: (value) => setState(() => dampak = value),
            ),
            const SizedBox(height: 18),

            // DROPDOWN SENSITIVITAS
            const Text("Sifat Mendesak", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDropdown(
              value: sensitivitas,
              hint: "Masukan sensitivitas waktu",
              items: ["Stabil", "Lambat", "Sedang", "Cepat", "Detik Ini"],
              onChanged: (value) => setState(() => sensitivitas = value),
            ),
            const SizedBox(height: 18),

            // DROPDOWN ALTERNATIF
            const Text("Adanya Jalan/Fasilitas Pengganti", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDropdown(
              value: alternatif,
              hint: "Masukan ketersediaan alternatif",
              items: ["Banyak Pilihan", "Ada Pilihan", "Sulit", "Hampir Buntu", "Total Terisolasi"],
              onChanged: (value) => setState(() => alternatif = value),
            ),
            const SizedBox(height: 18),

            // DROPDOWN CAKUPAN
            const Text("Jumlah Warga Terdampak", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDropdown(
              value: cakupan,
              hint: "Masukan cakupan lokasi",
              items: ["Pribadi", "Tetangga", "Lingkungan", "Wilayah Luas", "Sangat Luas"],
              onChanged: (value) => setState(() => cakupan = value),
            ),
            const SizedBox(height: 20),

            // FOTO SECTION
            Row(
              children: [
                const Text("Foto Bukti", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 5),
                Text("(Maks 5 foto)", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: const Color(0xffD9E9F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.blue, size: 28),
                          SizedBox(height: 3),
                          Text(
                            "Tambah\nFoto",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  ..._imageFiles.asMap().entries.map((entry) {
                    int index = entry.key;
                    XFile image = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildImagePreview(image, index),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // BUTTON KIRIM
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isLoading ? null : _submitPengaduan, 
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Kirim Pengaduan",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, required TextEditingController controller}) {
    return TextField(
      controller: controller, 
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildImagePreview(XFile image, int index) {
    return Stack(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: FileImage(File(image.path)), 
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => _removeImage(index), 
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}