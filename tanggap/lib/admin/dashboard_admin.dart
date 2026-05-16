import 'package:flutter/material.dart';
import 'drawer_admin.dart';
import 'daftar_pengaduan_admin.dart';
import 'notifikasi_admin.dart';

class DashboardAdminPage extends StatelessWidget {
  const DashboardAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      drawer: const DrawerAdmin(),

      appBar: AppBar(
        backgroundColor: const Color(0xff0B6E4F),
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),

        actions: [

          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const NotifikasiAdminPage(),
                ),
              );
            },
          ),

          const SizedBox(width: 5),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),

              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(
                  "Selamat Datang,",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Admin Desa",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Ringkasan pengaduan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [

                    Expanded(
                      child: _buildCard(
                        title: "Total Laporan",
                        value: "123",
                        bgColor:
                            const Color(0xffD6E9FF),
                        textColor: Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildCard(
                        title: "Selesai",
                        value: "38",
                        bgColor:
                            const Color(0xffDCEEE8),
                        textColor:
                            Colors.green.shade800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [

                    Expanded(
                      child: _buildCard(
                        title: "Diproses",
                        value: "55",
                        bgColor:
                            const Color(0xffEBD8FF),
                        textColor: Colors.purple,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildCard(
                        title: "Menunggu",
                        value: "20",
                        bgColor:
                            const Color(0xffF3E0D3),
                        textColor:
                            Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                const Text(
                  "Grafik Pengaduan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _buildBar(
                  "Dusun Graha",
                  10,
                ),

                _buildBar(
                  "Dusun Melati",
                  25,
                ),

                _buildBar(
                  "Dusun Mawar",
                  15,
                ),

                _buildBar(
                  "Dusun Sayur",
                  20,
                ),

                _buildBar(
                  "Dusun Marga",
                  5,
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    const Text(
                      "Pengaduan terbaru",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DaftarPengaduanAdminPage(),
                          ),
                        );
                      },

                      child: const Text(
                        "Lihat Semua",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Container(
                  padding:
                      const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                            14),

                    border: Border.all(
                      color:
                          Colors.grey.shade300,
                    ),
                  ),

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      const Expanded(
                        child: Text(
                          "Jalan rusak di depan Balai desa",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w500,
                          ),
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
                                .orange
                                .shade800,

                            fontWeight:
                                FontWeight
                                    .bold,

                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildCard({
    required String title,
    required String value,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: bgColor,
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildBar(
    String label,
    double value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 15),

      child: Row(
        children: [

          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Stack(
              children: [

                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color:
                        Colors.grey.shade300,
                    borderRadius:
                        BorderRadius
                            .circular(10),
                  ),
                ),

                FractionallySizedBox(
                  widthFactor: value / 30,

                  child: Container(
                    height: 14,

                    decoration:
                        BoxDecoration(
                      color: const Color(
                          0xff0B6E4F),

                      borderRadius:
                          BorderRadius
                              .circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(
            value.toInt().toString(),
          ),
        ],
      ),
    );
  }
}