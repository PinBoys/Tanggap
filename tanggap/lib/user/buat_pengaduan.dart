
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

import '../helper/image_helper.dart';
import '../helper/url_helper.dart';
import 'package:latlong2/latlong.dart';
import '../pages/pilih_lokasi_page.dart';

class BuatPengaduanPage extends StatefulWidget {
  // Tambahkan email agar Laravel tahu ini pengaduan milik siapa
  final String emailTarget;

  const BuatPengaduanPage({
    super.key,
    required this.emailTarget,
  });

  @override
  State<BuatPengaduanPage> createState() => _BuatPengaduanPageState();
}

class _BuatPengaduanPageState extends State<BuatPengaduanPage> {
  final TextEditingController _lokasiCtrl = TextEditingController();
  final TextEditingController _deskripsiCtrl = TextEditingController();

  String? dampak;
  String? sensitivitas;
  String? alternatif;
  String? cakupan;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFiles = [];
  bool isLoading = false;

  // Data kategori yang diambil dari API Laravel
  List<Map<String, dynamic>> _daftarKategori = [];
  String? _kategoriTerpilihId;
  bool _isLoadingKategori = true;
  String? _errorKategori;

  final String apiUrl = UrlHelper.api('/api/pengaduan');

  // Menyimpan koordinat lokasi yang dipilih pengguna
  LatLng? _koordinatTerpilih;

  @override
  void initState() {
    super.initState();
    _ambilKategori();
  }

  @override
  void dispose() {
    _lokasiCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  // Mengambil daftar kategori dari backend Laravel
  Future<void> _ambilKategori() async {
    setState(() {
      _isLoadingKategori = true;
      _errorKategori = null;
    });

    try {
      final response = await http.get(
        Uri.parse(UrlHelper.api('/api/pengaduan/kategori')),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil kategori (${response.statusCode})');
      }

      final hasil = jsonDecode(response.body);
      if (hasil['status'] != 'success' || hasil['data'] is! List) {
        throw Exception('Format data kategori dari server tidak sesuai.');
      }

      final kategori = List<Map<String, dynamic>>.from(
        (hasil['data'] as List).map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );

      if (!mounted) return;
      setState(() {
        _daftarKategori = kategori;
        _isLoadingKategori = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorKategori = e.toString();
        _isLoadingKategori = false;
      });
    }
  }

  // Membuka halaman pemilihan lokasi
  Future<void> _pilihLokasi() async {
    final LatLng? hasil = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => PilihLokasiPage(
          lokasiAwal: _koordinatTerpilih,
        ),
      ),
    );

    if (hasil != null && mounted) {
      setState(() {
        _koordinatTerpilih = hasil;
      });
    }
  }

  Future<void> _pickImages() async {
    if (_imageFiles.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maksimal 5 foto bukti!"),
        ),
      );
      return;
    }

    final List<XFile> selectedImages =
        await _picker.pickMultiImage(imageQuality: 80);

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
    if (_kategoriTerpilihId == null ||
        _lokasiCtrl.text.isEmpty ||
        _deskripsiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Kategori, Lokasi, dan Deskripsi wajib diisi!",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(apiUrl),
      );

      // MENGIRIM SEMUA DATA YANG DIBUTUHKAN DATABASE
      request.fields['email'] = widget.emailTarget;
      request.fields['category_id'] = _kategoriTerpilihId!;
      request.fields['titik_lokasi'] = _lokasiCtrl.text;
      request.fields['deskripsi'] = _deskripsiCtrl.text;

      // Kirim data dropdown
      request.fields['dampak'] = dampak ?? 'Aman';
      request.fields['sensitivitas'] = sensitivitas ?? 'Stabil';
      request.fields['alternatif'] = alternatif ?? 'Banyak Pilihan';
      request.fields['cakupan'] = cakupan ?? 'Pribadi';

      // Kirim koordinat jika pengguna sudah memilih titik pada peta
      if (_koordinatTerpilih != null) {
        request.fields['latitude'] =
            _koordinatTerpilih!.latitude.toString();

        request.fields['longitude'] =
            _koordinatTerpilih!.longitude.toString();
      }

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

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pengaduan berhasil dikirim!"),
            backgroundColor: Colors.green,
          ),
        );

        // Beri waktu Laravel menyelesaikan penyimpanan
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
        SnackBar(
          content: Text("Gagal: $e"),
          backgroundColor: Colors.red,
        ),
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
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
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
            // KATEGORI PENGADUAN
            const Text(
              "Kategori Pengaduan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _kategoriTerpilihId,
                  isExpanded: true,
                  hint: Text(
                    _isLoadingKategori
                        ? "Memuat kategori..."
                        : _errorKategori != null
                            ? "Gagal memuat kategori"
                            : "Pilih kategori pengaduan",
                  ),
                  items: _daftarKategori.map((kategori) {
                    return DropdownMenuItem<String>(
                      value: kategori['id'].toString(),
                      child: Text(kategori['name'].toString()),
                    );
                  }).toList(),
                  onChanged: _isLoadingKategori || _daftarKategori.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            _kategoriTerpilihId = value;
                          });
                        },
                ),
              ),
            ),
            if (_errorKategori != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Kategori gagal dimuat. Periksa koneksi internet.",
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _ambilKategori,
                    child: const Text("Coba lagi"),
                  ),
                ],
              ),
            ],
            if (!_isLoadingKategori &&
                _errorKategori == null &&
                _daftarKategori.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "Belum ada kategori tersedia.",
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 18),

            // LOKASI
            const Text(
              "Lokasi Kejadian",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              hint: "Pilih lokasi atau tulis alamat",
              controller: _lokasiCtrl,
            ),

            const SizedBox(height: 12),

            // KARTU PEMILIHAN TITIK LOKASI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffEAF5EF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xffC9E4D3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.map_outlined,
                        color: Color(0xff176B45),
                        size: 23,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Titik Lokasi pada Peta",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xff176B45),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Tentukan titik lokasi kejadian agar petugas "
                    "lebih mudah menemukan lokasi pengaduan.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (_koordinatTerpilih == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xffD5E6DB),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.location_searching,
                            color: Color(0xff176B45),
                            size: 34,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Belum ada titik lokasi dipilih",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xff219653),
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Lokasi berhasil dipilih",
                                style: TextStyle(
                                  color: Color(0xff176B45),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Latitude: ${_koordinatTerpilih!.latitude.toStringAsFixed(6)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Longitude: ${_koordinatTerpilih!.longitude.toStringAsFixed(6)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _pilihLokasi,
                      icon: const Icon(
                        Icons.pin_drop_outlined,
                        size: 19,
                      ),
                      label: Text(
                        _koordinatTerpilih == null
                            ? "Tentukan Titik pada Peta"
                            : "Ubah Titik Lokasi",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff176B45),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // DESKRIPSI
            const Text(
              "Keluhan / Deskripsi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // DROPDOWN DAMPAK
            const Text(
              "Tingkat Bahaya",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDropdown(
              value: dampak,
              hint: "Masukan dampak keselamatan",
              items: [
                "Aman",
                "Gangguan Kecil",
                "Resiko Luka",
                "Sangat Berbahaya",
                "Gawat Darurat"
              ],
              onChanged: (value) => setState(() => dampak = value),
            ),

            const SizedBox(height: 18),

            // DROPDOWN SENSITIVITAS
            const Text(
              "Sifat Mendesak",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDropdown(
              value: sensitivitas,
              hint: "Masukan sensitivitas waktu",
              items: [
                "Stabil",
                "Lambat",
                "Sedang",
                "Cepat",
                "Detik Ini"
              ],
              onChanged: (value) =>
                  setState(() => sensitivitas = value),
            ),

            const SizedBox(height: 18),

            // DROPDOWN ALTERNATIF
            const Text(
              "Adanya Jalan/Fasilitas Pengganti",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDropdown(
              value: alternatif,
              hint: "Masukan ketersediaan alternatif",
              items: [
                "Banyak Pilihan",
                "Ada Pilihan",
                "Sulit",
                "Hampir Buntu",
                "Total Terisolasi"
              ],
              onChanged: (value) =>
                  setState(() => alternatif = value),
            ),

            const SizedBox(height: 18),

            // DROPDOWN CAKUPAN
            const Text(
              "Jumlah Warga Terdampak",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDropdown(
              value: cakupan,
              hint: "Masukan cakupan lokasi",
              items: [
                "Pribadi",
                "Tetangga",
                "Lingkungan",
                "Wilayah Luas",
                "Sangat Luas"
              ],
              onChanged: (value) =>
                  setState(() => cakupan = value),
            ),

            const SizedBox(height: 20),

            // FOTO SECTION
            Row(
              children: [
                const Text(
                  "Foto Bukti",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                Text(
                  "(Maks 5 foto)",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
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
                          Icon(
                            Icons.add,
                            color: Colors.blue,
                            size: 28,
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Tambah\nFoto",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoading ? null : _submitPengaduan,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Kirim Pengaduan",
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

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
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
              child: const Icon(
                Icons.close,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
