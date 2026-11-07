<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class GeminiService
{
    public function generateSummary(array $data): array
    {
        $apiKey = config('services.gemini.key');
        $model = config('services.gemini.model');

        if (!$apiKey) {
            throw new RuntimeException('Gemini API Key belum diatur.');
        }

        $prompt = $this->buildPrompt($data);

        $response = Http::connectTimeout(15)
            ->timeout(150)
            ->retry([1000, 2000, 4000], throw: false)
            ->withHeaders([
                'x-goog-api-key' => $apiKey,
                'Content-Type' => 'application/json',
            ])
            ->post(
                "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent",
                [
                    'contents' => [
                        [
                            'parts' => [
                                ['text' => $prompt],
                            ],
                        ],
                    ],
                    'generationConfig' => [
                        'responseMimeType' => 'application/json',
                        'temperature' => 0.3,
                    ],
                ]
            );

        if ($response->failed()) {
            Log::error('Gemini API Error', [
                'status' => $response->status(),
                'response' => $response->body(),
            ]);

            throw new RuntimeException(
                'Gemini API Error ' .
                $response->status() . ': ' .
                $response->body()
            );
        }

        $text = $response->json('candidates.0.content.parts.0.text');

        if (!$text) {
            throw new RuntimeException(
                'Gemini tidak menghasilkan ringkasan.'
            );
        }

        $result = json_decode($text, true);

        if (!is_array($result)) {
            throw new RuntimeException(
                'Format JSON dari Gemini tidak valid.'
            );
        }

        return $result;
    }

    private function buildPrompt(array $data): string
    {
        $jsonData = json_encode(
            $data,
            JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT
        );

        return <<<PROMPT
Kamu adalah AI yang membantu petugas desa memahami laporan pengaduan masyarakat.

Tugasmu adalah menganalisis kumpulan laporan berdasarkan kategori dan membuat ringkasan yang objektif.

DATA LAPORAN:
{$jsonData}

ATURAN ANALISIS:
1. Analisis laporan berdasarkan kategori.
2. Jelaskan masalah utama yang sering muncul.
3. Identifikasi lokasi yang disebutkan dalam laporan jika tersedia.
4. Jelaskan dampak yang mungkin dirasakan masyarakat berdasarkan isi laporan.
5. Berikan saran tindak lanjut yang relevan.
6. Jangan membuat fakta, lokasi, atau kejadian yang tidak terdapat dalam data.
7. Jika informasi tidak cukup, tulis bahwa informasi belum cukup.
8. Jangan menentukan tingkat prioritas atau skor SAW.
9. Jangan menyatakan bahwa laporan sudah diverifikasi.
10. Gunakan bahasa Indonesia yang jelas dan formal.

Kembalikan hanya JSON valid dengan struktur berikut:

{
  "ringkasan_umum": "Ringkasan keseluruhan laporan",
  "kategori": [
    {
      "nama_kategori": "Nama kategori",
      "jumlah_laporan": 0,
      "masalah_utama": "Masalah utama",
      "lokasi_pengaduan": ["Lokasi 1"],
      "dampak_masyarakat": "Dampak yang ditemukan",
      "saran_tindak_lanjut": [
        "Saran pertama",
        "Saran kedua"
      ],
      "catatan_ai": "Keterbatasan atau catatan analisis"
    }
  ],
  "kesimpulan": "Kesimpulan keseluruhan analisis"
}
PROMPT;
    }
}