import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PilihLokasiPage extends StatefulWidget {
  final LatLng? lokasiAwal;

  const PilihLokasiPage({
    super.key,
    this.lokasiAwal,
  });

  @override
  State<PilihLokasiPage> createState() => _PilihLokasiPageState();
}

class _PilihLokasiPageState extends State<PilihLokasiPage> {
  late LatLng lokasiTerpilih;

  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();

    // Lokasi awal sementara: Jimbaran, Bali
    lokasiTerpilih =
        widget.lokasiAwal ?? LatLng(-8.7900, 115.1700);
  }

  void pilihTitik(LatLng titik) {
    setState(() {
      lokasiTerpilih = titik;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentukan Lokasi'),
        backgroundColor: const Color(0xFF176B45),
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Ketuk peta untuk menentukan titik lokasi kejadian.',
              style: TextStyle(fontSize: 14),
            ),
          ),

          // PETA
          Expanded(
            child: FlutterMap(
              mapController: mapController,

              options: MapOptions(
                initialCenter: lokasiTerpilih,
                initialZoom: 16,

                onTap: (tapPosition, point) {
                  pilihTitik(point);
                },
              ),

              children: [
                // CARTO VOYAGER MAP
                TileLayer(
                  urlTemplate:
                      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=cb1_52sm_1_9a64099fdf12a5f722bd7995',
                  userAgentPackageName: 'com.example.tanggap',
                  maxZoom: 20,
                ),

                // MARKER LOKASI
                MarkerLayer(
                  markers: [
                    Marker(
                      point: lokasiTerpilih,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 45,
                      ),
                    ),
                  ],
                ),

                // ATRIBUSI PETA
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      '© OpenStreetMap contributors',
                    ),
                    TextSourceAttribution('© CARTO'),
                  ],
                ),
              ],
            ),
          ),

          // INFORMASI KOORDINAT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Koordinat Lokasi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Latitude: ${lokasiTerpilih.latitude.toStringAsFixed(6)}',
                ),

                Text(
                  'Longitude: ${lokasiTerpilih.longitude.toStringAsFixed(6)}',
                ),

                const SizedBox(height: 16),

                // TOMBOL GUNAKAN LOKASI
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF176B45),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),

                    onPressed: () {
                      Navigator.pop(context, lokasiTerpilih);
                    },

                    child: const Text(
                      'Gunakan Lokasi Ini',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
