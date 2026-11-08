import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'detail_pengaduan.dart';
import '../helper/url_helper.dart';

class PengaduanPage extends StatefulWidget {
  final String emailUser;

  const PengaduanPage({
    super.key,
    required this.emailUser,
  });

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  static const Color primaryBlue = Color(0xFF1769AA);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color pageBackground = Color(0xFFF3F7FC);

  int selectedIndex = 0;
  bool isLoading = true;
  bool isError = false;

  final List<String> tabs = const [
    'Semua',
    'Menunggu',
    'Diproses',
    'Selesai',
  ];

  List<Map<String, dynamic>> pengaduan = [];

  @override
  void initState() {
    super.initState();
    fetchDataPengaduan();
  }

  Future<void> fetchDataPengaduan() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        isError = false;
      });
    }

    final String apiUrl = UrlHelper.api(
      '/api/pengaduan/status/${widget.emailUser}',
    );

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final dynamic data = decoded['data'];

        if (!mounted) return;

        setState(() {
          pengaduan = (data is List ? data : []).map<Map<String, dynamic>>((item) {
            final id = item['id_pengaduan'];
            return {
              'id_pengaduan': id,
              'kode': '#PGD-${id ?? '-'}',
              'judul': item['judul'] ?? 'Tanpa Judul',
              'tanggal': item['tanggal_pengaduan'] ?? '-',
              'lokasi': item['titik_lokasi'] ?? 'Lokasi belum ditentukan',
              'status': item['status'] ?? 'Menunggu',
            };
          }).toList();
          isLoading = false;
          isError = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      debugPrint('Gagal mengambil data pengaduan: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  String statusIndonesia(String status) {
    final normalized = status.trim().toUpperCase();

    switch (normalized) {
      case 'PENDING':
      case 'MENUNGGU':
        return 'Menunggu';
      case 'DIPROSES':
      case 'PROCESS':
      case 'IN_PROGRESS':
        return 'Diproses';
      case 'SELESAI':
      case 'COMPLETED':
      case 'DONE':
        return 'Selesai';
      default:
        return status.trim().isEmpty ? 'Tidak diketahui' : status;
    }
  }

  Color getStatusColor(String status) {
    switch (statusIndonesia(status)) {
      case 'Menunggu':
        return const Color(0xFFB87508);
      case 'Diproses':
        return const Color(0xFF2169A6);
      case 'Selesai':
        return const Color(0xFF16834A);
      default:
        return const Color(0xFF66736B);
    }
  }

  Color getStatusBackground(String status) {
    switch (statusIndonesia(status)) {
      case 'Menunggu':
        return const Color(0xFFFFF2D9);
      case 'Diproses':
        return const Color(0xFFE7F2FF);
      case 'Selesai':
        return const Color(0xFFE5F5EA);
      default:
        return const Color(0xFFF0F2F1);
    }
  }

  IconData getStatusIcon(String status) {
    switch (statusIndonesia(status)) {
      case 'Menunggu':
        return Icons.schedule_rounded;
      case 'Diproses':
        return Icons.autorenew_rounded;
      case 'Selesai':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  List<Map<String, dynamic>> get filteredPengaduan {
    if (selectedIndex == 0) return pengaduan;

    return pengaduan.where((item) {
      return statusIndonesia(item['status'].toString()) == tabs[selectedIndex];
    }).toList();
  }

  int _countFor(String status) {
    if (status == 'Semua') return pengaduan.length;

    return pengaduan.where((item) {
      return statusIndonesia(item['status'].toString()) == status;
    }).length;
  }

  void _openDetail(Map<String, dynamic> item) {
    final id = item['id_pengaduan']?.toString() ?? '';

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID pengaduan tidak tersedia.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPengaduanPage(idPengaduan: id),
      ),
    ).then((_) => fetchDataPengaduan());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF24332B),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Pengaduan Saya',
          style: TextStyle(
            color: Color(0xFF202B25),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: primaryBlue,
        onRefresh: fetchDataPengaduan,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading && pengaduan.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: primaryBlue),
      );
    }

    if (isError && pengaduan.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        children: [
          const SizedBox(height: 145),
          const Icon(
            Icons.wifi_off_rounded,
            size: 58,
            color: Color(0xFF9AA79F),
          ),
          const SizedBox(height: 14),
          const Text(
            'Gagal memuat pengaduan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF34443A),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Periksa koneksi internet Anda, lalu coba muat ulang.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF89958E),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: OutlinedButton.icon(
              onPressed: fetchDataPengaduan,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                side: const BorderSide(color: primaryBlue),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 22),
        const Text(
          'Filter Status',
          style: TextStyle(
            color: Color(0xFF26352D),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 11),
        _buildStatusTabs(),
        const SizedBox(height: 19),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Daftar Pengaduan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF25342B),
                ),
              ),
            ),
            Text(
              '${filteredPengaduan.length} laporan',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF89958E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filteredPengaduan.isEmpty)
          _buildEmptyFilter()
        else
          ...filteredPengaduan.map(_buildComplaintCard),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final waiting = _countFor('Menunggu');
    final processing = _countFor('Diproses');
    final completed = _countFor('Selesai');

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1769AA), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.17),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(width: 9),
              Text(
                'Ringkasan Pengaduan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: _buildSummaryValue(
                  pengaduan.length.toString(),
                  'Total laporan',
                ),
              ),
              _summaryDivider(),
              Expanded(
                child: _buildSummaryValue(
                  waiting.toString(),
                  'Menunggu',
                ),
              ),
              _summaryDivider(),
              Expanded(
                child: _buildSummaryValue(
                  processing.toString(),
                  'Diproses',
                ),
              ),
              _summaryDivider(),
              Expanded(
                child: _buildSummaryValue(
                  completed.toString(),
                  'Selesai',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryValue(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFE4EFFB),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _summaryDivider() {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      color: Colors.white.withOpacity(0.23),
    );
  }

  Widget _buildStatusTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final active = selectedIndex == index;
          final count = _countFor(tabs[index]);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: active ? primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: active
                          ? primaryBlue
                          : const Color(0xFFDCE7F3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        tabs[index],
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : const Color(0xFF536159),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFFEEF4FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: active
                                ? Colors.white
                                : const Color(0xFF65736A),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> item) {
    final status = item['status']?.toString() ?? 'Menunggu';
    final color = getStatusColor(status);
    final background = getStatusBackground(status);
    final id = item['id_pengaduan']?.toString() ?? '';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: () => _openDetail(item),
        borderRadius: BorderRadius.circular(17),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE3EAF3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF174B75).withOpacity(0.035),
                blurRadius: 11,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item['kode']?.toString() ?? '#PGD-$id',
                      style: const TextStyle(
                        color: Color(0xFF87938B),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          getStatusIcon(status),
                          color: color,
                          size: 12,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusIndonesia(status),
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Text(
                item['judul']?.toString() ?? 'Tanpa Judul',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF26352D),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              _buildMetaRow(
                Icons.calendar_today_outlined,
                item['tanggal']?.toString() ?? '-',
              ),
              const SizedBox(height: 6),
              _buildMetaRow(
                Icons.location_on_outlined,
                item['lokasi']?.toString() ?? 'Lokasi belum ditentukan',
              ),
              const SizedBox(height: 13),
              const Divider(height: 1, color: Color(0xFFEDF1EE)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ketuk untuk melihat perkembangan laporan',
                      style: TextStyle(
                        color: Color(0xFF89958E),
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Text(
                    'Lihat detail',
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: primaryBlue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFF8A968F),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF78857D),
              fontSize: 10.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFilter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE3EAF3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 42,
            color: Color(0xFFA5B0A9),
          ),
          const SizedBox(height: 10),
          Text(
            'Tidak ada pengaduan ${tabs[selectedIndex].toLowerCase()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF526057),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Pengaduan dengan status ini belum tersedia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF929D96),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
