import 'package:flutter/material.dart';

class DetailAnalisisAIAdminPage extends StatelessWidget {
  final Map<String, dynamic> categoryData;
  final String period;
  final int totalReports;
  final String overallSummary;
  final String conclusion;

  const DetailAnalisisAIAdminPage({
    super.key,
    required this.categoryData,
    required this.period,
    required this.totalReports,
    required this.overallSummary,
    required this.conclusion,
  });

  static const Color primaryGreen = Color(0xFF086B50);
  static const Color darkGreen = Color(0xFF064E3B);
  static const Color pageBackground = Color(0xFFF4F6F5);
  static const Color textDark = Color(0xFF263238);
  static const Color textGrey = Color(0xFF7B858C);

  String get categoryName =>
      categoryData['nama_kategori']?.toString() ?? 'Kategori';

  String get mainProblem =>
      categoryData['masalah_utama']?.toString() ??
      'Belum ada informasi masalah utama.';

  String get impactSummary =>
      categoryData['dampak_masyarakat']?.toString() ??
      'Belum ada informasi dampak masyarakat.';

  String get aiNote =>
      categoryData['catatan_ai']?.toString() ??
      'Hasil analisis perlu ditinjau oleh admin.';

  List<String> get locations {
    final raw = categoryData['lokasi_pengaduan'];
    if (raw is! List) return [];
    return raw.map((item) => item.toString()).toList();
  }

  List<String> get recommendations {
    final raw = categoryData['saran_tindak_lanjut'];
    if (raw is! List) return [];
    return raw.map((item) => item.toString()).toList();
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textDark,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    Color backgroundColor = Colors.white,
    Color borderColor = const Color(0xFFE8ECEA),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  Widget _buildAnalysisPoint({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE4F4EC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: primaryGreen,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF52615B),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF52615B),
        fontSize: 12,
        height: 1.6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = (categoryData['jumlah_laporan'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Detail Analisis AI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4F4EC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, color: primaryGreen, size: 13),
                            SizedBox(width: 5),
                            Text(
                              'Analisis AI',
                              style: TextStyle(
                                color: primaryGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF269B66),
                        size: 17,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Hasil AI',
                        style: TextStyle(
                          color: Color(0xFF269B66),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    categoryName,
                    style: const TextStyle(
                      color: darkGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Periode analisis: $period terakhir',
                    style: const TextStyle(color: textGrey, fontSize: 11),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(
                        Icons.assignment_outlined,
                        color: primaryGreen,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$count laporan dalam kategori ini',
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$totalReports laporan dianalisis secara keseluruhan',
                    style: const TextStyle(color: textGrey, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Ringkasan AI'),
            const SizedBox(height: 10),
            _buildCard(
              backgroundColor: const Color(0xFFEAF6EF),
              borderColor: const Color(0xFFD2EBDD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: primaryGreen, size: 19),
                      SizedBox(width: 8),
                      Text(
                        'Ringkasan keseluruhan',
                        style: TextStyle(
                          color: darkGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _bodyText(
                    overallSummary.isEmpty
                        ? 'Ringkasan umum belum tersedia.'
                        : overallSummary,
                  ),
                  if (conclusion.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Kesimpulan AI',
                      style: TextStyle(
                        color: darkGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _bodyText(conclusion),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('Poin Penting'),
            const SizedBox(height: 12),
            _buildCard(
              child: Column(
                children: [
                  _buildAnalysisPoint(
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFD69B24),
                    iconBackground: const Color(0xFFFFF4DC),
                    title: 'Masalah Utama',
                    content: _bodyText(mainProblem),
                  ),
                  _buildAnalysisPoint(
                    icon: Icons.location_on_outlined,
                    iconColor: const Color(0xFF3976C5),
                    iconBackground: const Color(0xFFEAF1FC),
                    title: 'Lokasi Pengaduan',
                    content: locations.isEmpty
                        ? _bodyText('Lokasi belum disebutkan atau belum tersedia dalam laporan.')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: locations
                                .map((location) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• '),
                                          Expanded(child: _bodyText(location)),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                  ),
                  _buildAnalysisPoint(
                    icon: Icons.people_alt_outlined,
                    iconColor: const Color(0xFF8055C7),
                    iconBackground: const Color(0xFFF1EAFE),
                    title: 'Dampak Masyarakat',
                    content: _bodyText(impactSummary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('Saran Tindak Lanjut'),
            const SizedBox(height: 10),
            _buildCard(
              child: recommendations.isEmpty
                  ? _bodyText('Belum ada saran tindak lanjut dari AI.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rekomendasi untuk petugas',
                          style: TextStyle(
                            color: darkGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ...List.generate(
                          recommendations.length,
                          (index) => _buildRecommendation(
                            index + 1,
                            recommendations[index],
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD7E5FA)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF3976C5),
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Catatan AI: $aiNote. Hasil analisis merupakan informasi '
                      'pendukung. Admin dan petugas tetap bertanggung jawab '
                      'melakukan verifikasi sebelum menentukan tindakan.',
                      style: const TextStyle(
                        color: Color(0xFF52729A),
                        fontSize: 10,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text(
                  'Kembali ke Analisis AI',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryGreen,
                  side: const BorderSide(color: primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
