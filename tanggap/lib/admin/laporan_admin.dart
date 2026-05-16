import 'package:flutter/material.dart';
import 'drawer_admin.dart';

class LaporanAdminPage extends StatefulWidget {
  const LaporanAdminPage({super.key});

  @override
  State<LaporanAdminPage> createState() =>
      _LaporanAdminPageState();
}

class _LaporanAdminPageState
    extends State<LaporanAdminPage> {

  String selectedFilter = "Bulan ini";

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      // DRAWER
      drawer: const DrawerAdmin(),

      appBar: AppBar(
        backgroundColor:
            const Color(0xff0B6E4F),

        elevation: 0,

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          "Laporan",
          style: TextStyle(
            color: Colors.white,
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

            // FILTER
            Align(
              alignment:
                  Alignment.centerRight,

              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                          8),

                  border: Border.all(
                    color:
                        Colors.grey.shade300,
                  ),
                ),

                child:
                    DropdownButtonHideUnderline(

                  child: DropdownButton(
                    value: selectedFilter,

                    items: const [

                      DropdownMenuItem(
                        value: "Hari ini",
                        child:
                            Text("Hari ini"),
                      ),

                      DropdownMenuItem(
                        value: "Minggu ini",
                        child:
                            Text("Minggu ini"),
                      ),

                      DropdownMenuItem(
                        value: "Bulan ini",
                        child:
                            Text("Bulan ini"),
                      ),

                      DropdownMenuItem(
                        value: "Tahun ini",
                        child:
                            Text("Tahun ini"),
                      ),
                    ],

                    onChanged: (value) {

                      setState(() {

                        selectedFilter =
                            value.toString();

                      });

                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CARD RINGKASAN
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),

              mainAxisSpacing: 10,
              crossAxisSpacing: 10,

              childAspectRatio: 1.5,

              children: [

                statistikCard(
                  "Total Laporan",
                  "123",
                  Colors.blue.shade100,
                  Colors.blue,
                ),

                statistikCard(
                  "Selesai",
                  "38",
                  Colors.green.shade100,
                  Colors.green.shade800,
                ),

                statistikCard(
                  "Diproses",
                  "55",
                  Colors.purple.shade100,
                  Colors.purple,
                ),

                statistikCard(
                  "Menunggu",
                  "20",
                  Colors.orange.shade100,
                  Colors.orange.shade800,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // GRAFIK
            const Text(
              "Grafik Pengaduan",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            grafikItem(
              "Dusun Graha",
              10,
            ),

            grafikItem(
              "Dusun Melati",
              25,
            ),

            grafikItem(
              "Dusun Mawar",
              15,
            ),

            grafikItem(
              "Dusun Sayur",
              20,
            ),

            grafikItem(
              "Dusun Marga",
              5,
            ),
          ],
        ),
      ),
    );
  }

  Widget statistikCard(
    String title,
    String total,
    Color bgColor,
    Color textColor,
  ) {

    return Container(
      padding:
          const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: bgColor,

        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Text(
            title,

            style: TextStyle(
              color: textColor,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            total,

            style: TextStyle(
              color: textColor,
              fontSize: 32,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget grafikItem(
    String title,
    double value,
  ) {

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),

      child: Row(
        children: [

          SizedBox(
            width: 90,

            child: Text(
              title,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Stack(
              children: [

                Container(
                  height: 18,

                  decoration:
                      BoxDecoration(
                    color: Colors
                        .grey.shade300,

                    borderRadius:
                        BorderRadius
                            .circular(10),
                  ),
                ),

                Container(
                  height: 18,
                  width: value * 8,

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.green,
                    borderRadius:
                        BorderRadius
                            .circular(10),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(value.toInt().toString()),
        ],
      ),
    );
  }
}