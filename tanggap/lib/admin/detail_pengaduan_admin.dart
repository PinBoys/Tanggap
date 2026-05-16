import 'package:flutter/material.dart';
import 'tindak_lanjut_admin.dart';

class DetailPengaduanAdminPage
    extends StatelessWidget {

  const DetailPengaduanAdminPage({
    super.key,
  });

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
          "Detail Pengaduan",
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
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                const Text(
                  "# PGD-2026-00012",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),

                  decoration:
                      BoxDecoration(
                    color: Colors
                        .orange.shade100,

                    borderRadius:
                        BorderRadius
                            .circular(
                                10),
                  ),

                  child: Text(
                    "Menunggu",
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
                height: 30),

            _item(
              "Judul Pengaduan",
              "Infrastruktur Jalan",
            ),

            _item(
              "Lokasi Kejadian",
              "Jl. Raya Desa Buleleng",
            ),

            _item(
              "Tanggal",
              "20 Mei 2026, 12.25 WITA",
            ),

            _item(
              "Keluhan/Deskripsi",
              "Jalan di depan balai desa berlubang cukup dalam sehingga membahayakan pengguna jalan, terutama saat hujan.",
            ),

            _item(
              "Tingkat Urgensi",
              "Sedang",
            ),

            _item(
              "Dampak Keselamatan",
              "Resiko Luka",
            ),

            _item(
              "Sensitivitas Waktu",
              "Cepat",
            ),

            _item(
              "Ketersediaan Alternatif",
              "Sulit",
            ),

            _item(
              "Cakupan Populasi",
              "Lingkungan",
            ),

            const SizedBox(
                height: 20),

            const Text(
              "Foto Bukti",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
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

                _image(),
              ],
            ),

            const SizedBox(
                height: 35),

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

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const TindakLanjutAdminPage(),
                    ),
                  );

                },

                child: const Text(
                  "Tindak lanjuti",
                  style: TextStyle(
                    color:
                        Colors.white,
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

  Widget _item(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 20,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          SizedBox(
            width: 130,

            child: Text(
              title,
              style: TextStyle(
                color:
                    Colors.grey.shade700,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
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