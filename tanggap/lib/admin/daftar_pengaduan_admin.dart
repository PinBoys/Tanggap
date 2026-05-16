import 'package:flutter/material.dart';

import 'drawer_admin.dart';
import 'detail_pengaduan_admin.dart';

class DaftarPengaduanAdminPage extends StatefulWidget {
  const DaftarPengaduanAdminPage({super.key});

  @override
  State<DaftarPengaduanAdminPage> createState() =>
      _DaftarPengaduanAdminPageState();
}

class _DaftarPengaduanAdminPageState
    extends State<DaftarPengaduanAdminPage> {

  String selectedFilter = "Semua";

  final List<Map<String, dynamic>> pengaduanList = [

    {
      "kode": "# PGD-2026-00012",
      "judul": "Jalan rusak di depan balai desa",
      "lokasi": "Jl. Raya desa Buleleng",
      "tanggal": "20 mei 2026",
      "status": "Menunggu",
    },

    {
      "kode": "# PGD-2026-00011",
      "judul": "Lampu jalan mati",
      "lokasi": "Jl. Raya desa Melati",
      "tanggal": "19 mei 2026",
      "status": "Diproses",
    },

    {
      "kode": "# PGD-2026-00010",
      "judul": "Sampah menumpuk di TPS",
      "lokasi": "desa Bantargebang",
      "tanggal": "18 mei 2026",
      "status": "Diproses",
    },

    {
      "kode": "# PGD-2026-00009",
      "judul": "Saluran air tersumbat",
      "lokasi": "desa Bubug",
      "tanggal": "17 mei 2026",
      "status": "Selesai",
    },

    {
      "kode": "# PGD-2026-00008",
      "judul": "Posyandu butuh perbaikan atap",
      "lokasi": "Jl. Raya desa kesehatan",
      "tanggal": "16 mei 2026",
      "status": "Selesai",
    },
  ];

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> filteredList;

    if (selectedFilter == "Semua") {

      filteredList = pengaduanList;

    } else {

      filteredList = pengaduanList
          .where(
            (item) =>
                item["status"] ==
                selectedFilter,
          )
          .toList();
    }

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      // DRAWER ADMIN
      drawer: const DrawerAdmin(),

      appBar: AppBar(
        backgroundColor:
            const Color(0xff0B6E4F),

        title: const Text(
          "Daftar Pengaduan",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),

        actions: const [

          Padding(
            padding:
                EdgeInsets.only(right: 15),

            child: Icon(Icons.search),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [

            // FILTER
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                filterButton("Semua"),

                filterButton("Menunggu"),

                filterButton("Diproses"),

                filterButton("Selesai"),
              ],
            ),

            const SizedBox(height: 15),

            // LIST PENGADUAN
            Expanded(
              child: ListView.builder(
                itemCount:
                    filteredList.length,

                itemBuilder:
                    (context, index) {

                  final item =
                      filteredList[index];

                  return GestureDetector(

                    onTap: () {

                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const DetailPengaduanAdminPage(),
                        ),
                      );

                    },

                    child: Container(
                      margin:
                          const EdgeInsets.only(
                        bottom: 15,
                      ),

                      padding:
                          const EdgeInsets.all(15),

                      decoration:
                          BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                                12),

                        border: Border.all(
                          color:
                              Colors.grey.shade300,
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              Text(
                                item["kode"],

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              Text(
                                item["tanggal"],

                                style:
                                    TextStyle(
                                  color: Colors
                                      .grey.shade600,

                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 8),

                          Text(
                            item["judul"],

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                              height: 5),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              Text(
                                item["lokasi"],

                                style:
                                    TextStyle(
                                  color: Colors
                                      .grey.shade600,
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

                                  color:
                                      statusColor(
                                    item["status"],
                                  ),

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              20),
                                ),

                                child: Text(
                                  item["status"],

                                  style:
                                      TextStyle(
                                    color:
                                        statusTextColor(
                                      item["status"],
                                    ),

                                    fontWeight:
                                        FontWeight.bold,

                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterButton(String text) {

    final isSelected =
        selectedFilter == text;

    return GestureDetector(

      onTap: () {

        setState(() {

          selectedFilter = text;

        });
      },

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),

        decoration: BoxDecoration(

          color: isSelected
              ? Colors.blue
              : Colors.white,

          borderRadius:
              BorderRadius.circular(8),

          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),

        child: Text(
          text,

          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.black,

            fontWeight:
                FontWeight.bold,

            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Color statusColor(String status) {

    if (status == "Menunggu") {
      return Colors.orange.shade100;
    }

    if (status == "Diproses") {
      return Colors.orange.shade100;
    }

    return Colors.green.shade100;
  }

  Color statusTextColor(String status) {

    if (status == "Menunggu") {
      return Colors.orange.shade800;
    }

    if (status == "Diproses") {
      return Colors.orange.shade800;
    }

    return Colors.green;
  }
}