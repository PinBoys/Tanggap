import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'detail_pengaduan.dart';
import '../helper/url_helper.dart';

class NotifikasiPage extends StatefulWidget {
  final String emailTarget;

  const NotifikasiPage({
    super.key,
    required this.emailTarget,
  });

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  static const Color primaryBlue = Color(0xFF1769AA);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color pageBackground = Color(0xFFF3F7FC);

  bool isLoading = true;
  bool isError = false;
  List<dynamic> notifikasiList = [];

  @override
  void initState() {
    super.initState();
    fetchNotifikasi();
  }

  Future<void> fetchNotifikasi() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        isError = false;
      });
    }

    try {
      final response = await http.get(
        Uri.parse(
          UrlHelper.api(
            '/api/pengaduan/riwayat/${widget.emailTarget}',
          ),
        ),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final dynamic data = decoded['data'];

        if (!mounted) return;

        setState(() {
          notifikasiList = data is List ? data : [];
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
      debugPrint('Gagal mengambil notifikasi: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  String _statusOf(dynamic item) {
    final raw = (item['status'] ?? 'Menunggu').toString().trim().toUpperCase();

    switch (raw) {
      case 'PENDING':
      case 'MENUNGGU':
        return 'MENUNGGU';
      case 'DIPROSES':
      case 'PROCESS':
      case 'IN_PROGRESS':
        return 'DIPROSES';
      case 'SELESAI':
      case 'COMPLETED':
      case 'DONE':
        return 'SELESAI';
      default:
        return raw;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'MENUNGGU':
        return 'Menunggu';
      case 'DIPROSES':
        return 'Diproses';
      case 'SELESAI':
        return 'Selesai';
      default:
        return status.isEmpty ? 'Pembaruan' : status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'MENUNGGU':
        return const Color(0xFFB87508);
      case 'DIPROSES':
        return const Color(0xFF2169A6);
      case 'SELESAI':
        return const Color(0xFF16834A);
      default:
        return const Color(0xFF66736B);
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'MENUNGGU':
        return const Color(0xFFFFF2D9);
      case 'DIPROSES':
        return const Color(0xFFE7F2FF);
      case 'SELESAI':
        return const Color(0xFFE5F5EA);
      default:
        return const Color(0xFFF0F2F1);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'MENUNGGU':
        return Icons.schedule_rounded;
      case 'DIPROSES':
        return Icons.autorenew_rounded;
      case 'SELESAI':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  String _subtitleFor(String status) {
    switch (status) {
      case 'MENUNGGU':
        return 'Pengaduan telah diterima dan sedang menunggu antrean tindak lanjut.';
      case 'DIPROSES':
        return 'Pengaduan sedang ditindaklanjuti oleh admin atau petugas desa.';
      case 'SELESAI':
        return 'Pengaduan telah selesai ditindaklanjuti. Terima kasih atas partisipasi Anda.';
      default:
        return 'Ada informasi terbaru mengenai pengaduan Anda.';
    }
  }

  void _openDetail(dynamic item) {
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
    ).then((_) => fetchNotifikasi());
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
          tooltip: 'Kembali',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF24332B),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF202B25),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: primaryBlue,
        onRefresh: fetchNotifikasi,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading && notifikasiList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: primaryBlue),
      );
    }

    if (isError && notifikasiList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        children: [
          const SizedBox(height: 150),
          const Icon(
            Icons.wifi_off_rounded,
            size: 58,
            color: Color(0xFF9AA79F),
          ),
          const SizedBox(height: 14),
          const Text(
            'Tidak dapat memuat notifikasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF34443A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Periksa koneksi internet Anda, lalu coba kembali.',
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
              onPressed: fetchNotifikasi,
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

    if (notifikasiList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        children: [
          const SizedBox(height: 145),
          Container(
            width: 104,
            height: 104,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F1FB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 52,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada notifikasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF26352C),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Pembaruan status pengaduan Anda akan\nmuncul di halaman ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF8A968F),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        _buildIntroCard(),
        const SizedBox(height: 23),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Pemberitahuan Terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF25342B),
                ),
              ),
            ),
            Text(
              '${notifikasiList.length} laporan',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF89958E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...notifikasiList.map((item) {
          final status = _statusOf(item);
          final id = item['id_pengaduan']?.toString() ?? '-';
          final waktu = item['waktu']?.toString() ?? 'Waktu tidak tersedia';

          return _buildNotificationCard(
            item: item,
            status: status,
            id: id,
            time: waktu,
          );
        }),
      ],
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1769AA), Color(0xFF07583F)],
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
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Pengaduan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pantau setiap perkembangan laporan yang Anda kirimkan.',
                  style: TextStyle(
                    color: Color(0xFFE4EFFB),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required dynamic item,
    required String status,
    required String id,
    required String time,
  }) {
    final color = _statusColor(status);
    final background = _statusBackground(status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: () => _openDetail(item),
        borderRadius: BorderRadius.circular(17),
        child: Container(
          margin: const EdgeInsets.only(bottom: 11),
          padding: const EdgeInsets.all(14),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _statusIcon(status),
                  color: color,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengaduan #PGD-$id',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF26352D),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _subtitleFor(status),
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.45,
                        color: Color(0xFF78857D),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusLabel(status),
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 11,
                                color: Color(0xFF9AA59E),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  time,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF929D96),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9AA79F),
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
