import 'package:flutter/material.dart';

class DetailPengaduanPage extends StatelessWidget {
  const DetailPengaduanPage({super.key});

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
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Detail Pengaduan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Colors.orange.shade100,
                    borderRadius:
                        BorderRadius.circular(
                            6),
                  ),
                  child: const Text(
                    "Diproses",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const Text(
                  "#PGD-2026-00012",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Infrastruktur Jalan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "20 Mei 2026, 12.25 WITA",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Lokasi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Jl. Raya Desa Buleleng",
            ),

            const SizedBox(height: 18),

            const Text(
              "Deskripsi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Jalan di depan balai desa berlubang cukup dalam sehingga membahayakan pengguna jalan, terutama saat hujan.",
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Foto Bukti",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _buildImage(),
                const SizedBox(width: 10),
                _buildImage(),
                const SizedBox(width: 10),
                _buildImage(),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Riwayat Status",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _buildStatusItem(
              color: Colors.orange,
              title: "Menunggu",
              subtitle:
                  "20 Mei 2026, 12.25 WITA",
            ),

            _buildLine(),

            _buildStatusItem(
              color: Colors.orange,
              title: "Diproses",
              subtitle:
                  "20 Mei 2026, 14.25 WITA\nAdmin telah menindaklanjuti laporan Anda",
            ),

            _buildLine(),

            _buildStatusItem(
              color: Colors.grey.shade300,
              title: "Selesai",
              subtitle: "",
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Tutup",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 90,
      height: 70,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(10),
        image: const DecorationImage(
          image: AssetImage(
            'assets/images/jalanberlubang.jpeg',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildLine() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 7),
      child: Container(
        width: 2,
        height: 18,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildStatusItem({
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Container(
          width: 12,
          height: 12,
          margin:
              const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
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

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}