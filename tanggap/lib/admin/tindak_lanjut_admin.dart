import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'daftar_pengaduan_admin.dart';

class TindakLanjutAdminPage extends StatefulWidget {
  final Map<String, dynamic> pengaduan;

  const TindakLanjutAdminPage({
    super.key,
    required this.pengaduan,
  });

  @override
  State<TindakLanjutAdminPage> createState() =>
      _TindakLanjutAdminPageState();
}

class _TindakLanjutAdminPageState
    extends State<TindakLanjutAdminPage> {

  late String status;

  @override
  void initState() {
    super.initState();

    status =
        widget.pengaduan["status"] ??
        "Menunggu";
  }

Future<bool> updateStatus() async {

  final response = await http.put(

    Uri.parse(
      "http://127.0.0.1:8000/api/admin/pengaduan/${widget.pengaduan['id']}/status",
    ),

    headers: {
      "Content-Type": "application/json",
    },

    body: jsonEncode({
      "status": status,
    }),
  );

  print("STATUS CODE: ${response.statusCode}");
  print("BODY: ${response.body}");

  return response.statusCode == 200;
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),

        centerTitle: true,

        title: const Text(
          "Tindak Lanjut",
          style: TextStyle(
            color: Colors.black,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                Text(
                  widget.pengaduan["id"]
                      .toString()
                      .substring(0, 8),

                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),

                  decoration:
                      BoxDecoration(
                    color: Colors
                        .orange.shade100,

                    borderRadius:
                        BorderRadius.circular(
                            10),
                  ),

                  child: Text(
                    widget.pengaduan["status"] ??
                        "-",

                    style: TextStyle(
                      color: Colors
                          .orange.shade800,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
                height: 35),

            const Text(
              "Status",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 10),

            DropdownButtonFormField<String>(
              value: status,

              items: const [

                DropdownMenuItem(
                  value: "PENDING",
                  child: Text("Menunggu"),
                ),

                DropdownMenuItem(
                  value: "DIPROSES",
                  child: Text("Diproses"),
                ),

                DropdownMenuItem(
                  value: "SELESAI",
                  child: Text("Selesai"),
                ),

              ],

              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),

            const SizedBox(
                height: 25),

            const Text(
              "Catatan / Tindakan",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 10),

            TextField(
              maxLines: 5,

              decoration:
                  InputDecoration(
                hintText:
                    "Tulis tindak lanjut",

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          10),
                ),
              ),
            ),

            const SizedBox(
                height: 25),

            const Text(
              "Foto Tindak Lanjut (Opsional)",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 15),

            Row(
              children: [

                _image(),

                const SizedBox(
                    width: 10),

                _image(),

                const SizedBox(
                    width: 10),

                Container(
                  width: 90,
                  height: 90,

                  decoration:
                      BoxDecoration(
                    color: Colors
                        .blue.shade50,

                    borderRadius:
                        BorderRadius.circular(
                            10),
                  ),

                  child: const Icon(
                    Icons.add,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),

              ],
            ),

            const SizedBox(
                height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                ),

                onPressed: () async {

                  bool berhasil =
                      await updateStatus();

                  if (berhasil) {

                    Navigator.pushAndRemoveUntil(
                      context,

                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const DaftarPengaduanAdminPage(),
                      ),

                      (route) => false,
                    );

                  } else {

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(

                      const SnackBar(
                        content: Text(
                          "Gagal update status",
                        ),
                      ),

                    );

                  }

                },

                child: const Text(
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

  Widget _image() {

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(10),

      child: Image.asset(
        "assets/images/jalanberlubang.jpeg",
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      ),
    );

  }
}