import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../helper/url_helper.dart';
import 'drawer_admin.dart';
import 'detail_analisis_ai_admin.dart';

class AnalisisAIAdminPage extends StatefulWidget {
  const AnalisisAIAdminPage({super.key});

  @override
  State<AnalisisAIAdminPage> createState() => _AnalisisAIAdminPageState();
}

class _AnalisisAIAdminPageState extends State<AnalisisAIAdminPage> {
  static const Color primaryGreen = Color(0xFF086B50);
  static const Color darkGreen = Color(0xFF064E3B);
  static const Color pageBackground = Color(0xFFF4F6F5);
  static const Color textDark = Color(0xFF263238);
  static const Color textGrey = Color(0xFF7B858C);

  String selectedPeriod = '7 Hari';
  bool isLoading = true;
  bool isGenerating = false;
  String? errorMessage;

  Map<String, dynamic>? summaryData;
  Map<String, dynamic> summaryContent = {};

  int get selectedPeriodDays => selectedPeriod == '7 Hari' ? 7 : 30;

  int get totalReports =>
      (summaryData?['total_reports'] as num?)?.toInt() ?? 0;

  List<Map<String, dynamic>> get categoryData {
    final raw = summaryContent['kategori'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadLatestSummary();
  }

  Future<void> _loadLatestSummary() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
        .get(Uri.parse(UrlHelper.api('/api/admin/analisis-ai')))
        .timeout(const Duration(seconds: 30));

      final decoded = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          decoded is Map
              ? decoded['message']?.toString() ?? 'Gagal mengambil AI Summary.'
              : 'Gagal mengambil AI Summary.',
        );
      }

      if (decoded is! Map || decoded['status'] != 'success') {
        throw Exception('Format respons AI Summary tidak sesuai.');
      }

      final data = decoded['data'];
      if (data == null) {
        if (!mounted) return;
        setState(() {
          summaryData = null;
          summaryContent = {};
        });
        return;
      }

      if (data is! Map) {
        throw Exception('Data AI Summary tidak valid.');
      }

      final parsedData = Map<String, dynamic>.from(data);
      final rawSummary = parsedData['summary'];
      final parsedSummary = rawSummary is Map
          ? Map<String, dynamic>.from(rawSummary)
          : <String, dynamic>{};

      if (!mounted) return;
      setState(() {
        summaryData = parsedData;
        summaryContent = parsedSummary;
        final days = (parsedData['period_days'] as num?)?.toInt();
        if (days == 7 || days == 30) {
          selectedPeriod = '$days Hari';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  
Future<void> _generateSummary() async {
  setState(() {
    isGenerating = true;
    errorMessage = null;
  });

  try {
    final response = await http
        .post(
          Uri.parse(
            UrlHelper.api('/api/admin/analisis-ai/generate'),
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'period_days': selectedPeriodDays,
          }),
        )
        .timeout(const Duration(seconds: 190));

    // DEBUG: melihat respons asli dari server
    debugPrint('========== AI SUMMARY DEBUG ==========');
    debugPrint('PERIOD DAYS: $selectedPeriodDays');
    debugPrint('GENERATE STATUS: ${response.statusCode}');
    debugPrint('GENERATE BODY: ${response.body}');
    debugPrint('======================================');

    final decoded = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map
          ? decoded['detail']?.toString() ??
              decoded['message']?.toString() ??
              'Gagal membuat AI Summary.'
          : 'Gagal membuat AI Summary.';

      throw Exception(message);
    }

    if (decoded is! Map || decoded['status'] != 'success') {
      throw Exception('Respons pembuatan AI Summary tidak valid.');
    }

    final data = decoded['data'];

    if (data is! Map) {
      throw Exception('Data hasil AI Summary tidak ditemukan.');
    }

    final parsedData = Map<String, dynamic>.from(data);
    final rawSummary = parsedData['summary'];

    final parsedSummary = rawSummary is Map
        ? Map<String, dynamic>.from(rawSummary)
        : <String, dynamic>{};

    if (!mounted) return;

    setState(() {
      summaryData = parsedData;
      summaryContent = parsedSummary;
    });

    _showMessage('AI Summary berhasil dibuat.');
  } catch (e) {
    debugPrint('AI SUMMARY ERROR: $e');

    if (!mounted) return;

    setState(() {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    });
  } finally {
    if (mounted) {
      setState(() => isGenerating = false);
    }
  }
}


  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: textGrey),
          ),
        ],
      ],
    );
  }

  Widget _buildAIStatus() {
    final hasSummary = summaryData != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDDF7E7), Color(0xFFC8F0D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFA8DFC0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF087B48),
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasSummary ? 'AI Summary Tersedia' : 'AI Summary Siap Digunakan',
                  style: const TextStyle(
                    color: Color(0xFF17633E),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  hasSummary
                      ? 'Ringkasan laporan berhasil dimuat dari server.'
                      : 'Buat ringkasan laporan berdasarkan kategori dan periode.',
                  style: const TextStyle(
                    color: Color(0xFF527B64),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            hasSummary ? Icons.check_circle_rounded : Icons.info_outline,
            color: const Color(0xFF21965D),
            size: 19,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E8E9),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          _buildPeriodButton('7 Hari'),
          _buildPeriodButton('30 Hari'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: isGenerating
            ? null
            : () => setState(() => selectedPeriod = period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            period,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF647078),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEBEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: textGrey, fontSize: 10),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: textDark,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              description,
              style: const TextStyle(color: textGrey, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Ringkasan Keseluruhan',
          subtitle: 'Gambaran umum laporan yang dianalisis',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatisticCard(
              title: 'Total Laporan',
              value: '$totalReports',
              description: 'Laporan dianalisis',
              icon: Icons.assignment_outlined,
              iconColor: primaryGreen,
              iconBackground: const Color(0xFFE4F4EC),
            ),
            const SizedBox(width: 10),
            _buildStatisticCard(
              title: 'Kategori',
              value: '${categoryData.length}',
              description: 'Kategori dianalisis',
              icon: Icons.category_outlined,
              iconColor: const Color(0xFF477DC3),
              iconBackground: const Color(0xFFEAF1FC),
            ),
          ],
        ),
        if (summaryContent['ringkasan_umum'] != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8ECEA)),
            ),
            child: Text(
              summaryContent['ringkasan_umum'].toString(),
              style: const TextStyle(
                color: Color(0xFF52615B),
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }

  IconData _categoryIcon(String name) {
    final value = name.toLowerCase();
    if (value.contains('jalan') || value.contains('transportasi')) {
      return Icons.construction_rounded;
    }
    if (value.contains('penerangan') || value.contains('listrik')) {
      return Icons.lightbulb_outline_rounded;
    }
    if (value.contains('kebersihan') || value.contains('lingkungan')) {
      return Icons.eco_rounded;
    }
    if (value.contains('keamanan')) return Icons.shield_outlined;
    if (value.contains('pelayanan')) return Icons.people_alt_outlined;
    if (value.contains('air') || value.contains('banjir')) {
      return Icons.water_drop_outlined;
    }
    return Icons.category_outlined;
  }

  Color _categoryColor(String name) {
    final value = name.toLowerCase();
    if (value.contains('jalan') || value.contains('transportasi')) {
      return const Color(0xFF3976C5);
    }
    if (value.contains('penerangan') || value.contains('listrik')) {
      return const Color(0xFFD69B24);
    }
    if (value.contains('kebersihan') || value.contains('lingkungan')) {
      return const Color(0xFF21966A);
    }
    if (value.contains('keamanan')) return const Color(0xFFD45B5B);
    if (value.contains('pelayanan')) return const Color(0xFF8055C7);
    return primaryGreen;
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final name = category['nama_kategori']?.toString() ?? 'Kategori';
    final count = (category['jumlah_laporan'] as num?)?.toInt() ?? 0;
    final color = _categoryColor(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(_categoryIcon(name), color: color, size: 21),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$count laporan dalam $selectedPeriod terakhir',
                      style: const TextStyle(color: textGrey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailAnalisisAIAdminPage(
                      categoryData: category,
                      period: selectedPeriod,
                      totalReports: totalReports,
                      overallSummary:
                          summaryContent['ringkasan_umum']?.toString() ?? '',
                      conclusion:
                          summaryContent['kesimpulan']?.toString() ?? '',
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lihat detail',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemNote() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7E5FA)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF3976C5), size: 18),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Ringkasan AI merupakan informasi pendukung bagi admin. '
              'Hasil analisis tetap perlu ditinjau sebelum digunakan '
              'sebagai dasar tindak lanjut.',
              style: TextStyle(
                color: Color(0xFF52729A),
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    if (errorMessage == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF3CACA)),
      ),
      child: Text(
        errorMessage!,
        style: const TextStyle(color: Color(0xFFAD3030), fontSize: 11),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      drawer: const DrawerAdmin(),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Analisis AI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: primaryGreen,
          onRefresh: _loadLatestSummary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAIStatus(),
                const SizedBox(height: 20),
                _buildSectionTitle(
                  'Periode Analisis',
                  subtitle: 'Pilih rentang waktu laporan',
                ),
                const SizedBox(height: 11),
                _buildPeriodFilter(),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: isGenerating ? null : _generateSummary,
                    icon: isGenerating
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(
                      isGenerating
                          ? 'Sedang membuat ringkasan...'
                          : 'Buat / Perbarui AI Summary',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primaryGreen.withOpacity(0.55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                _buildError(),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 45),
                    child: Center(
                      child: CircularProgressIndicator(color: primaryGreen),
                    ),
                  )
                else if (summaryData == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8ECEA)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.auto_awesome, color: primaryGreen, size: 35),
                        SizedBox(height: 10),
                        Text(
                          'Belum ada AI Summary',
                          style: TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Pilih periode, lalu tekan tombol Buat AI Summary.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textGrey, fontSize: 11),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _buildOverview(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    'Ringkasan per Kategori',
                    subtitle: 'Hasil analisis berdasarkan kategori pengaduan',
                  ),
                  const SizedBox(height: 13),
                  if (categoryData.isEmpty)
                    const Text(
                      'Tidak ada rincian kategori pada hasil AI Summary.',
                      style: TextStyle(color: textGrey, fontSize: 11),
                    )
                  else
                    ...categoryData.map(_buildCategoryCard),
                  const SizedBox(height: 8),
                  if (summaryContent['kesimpulan'] != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8ECEA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kesimpulan AI',
                            style: TextStyle(
                              color: darkGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            summaryContent['kesimpulan'].toString(),
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 11,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildSystemNote(),
                  const SizedBox(height: 8),
                  Text(
                    'Periode data: ${summaryData?['date_from'] ?? '-'} s.d. ${summaryData?['date_to'] ?? '-'}',
                    style: const TextStyle(color: textGrey, fontSize: 9),
                  ),
                ],
                const SizedBox(height: 15),
                const Center(
                  child: Text(
                    'Analisis AI TANGGAP',
                    style: TextStyle(color: Color(0xFF9AA39F), fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
