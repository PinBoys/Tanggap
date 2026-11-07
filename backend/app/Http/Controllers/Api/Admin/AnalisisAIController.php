<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Services\GeminiService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Log;
use Throwable;

class AnalisisAIController extends Controller
{
    // Mengambil hasil AI Summary terakhir
    public function index()
    {
        $summary = DB::table('ai_summaries')
            ->orderByDesc('created_at')
            ->first();

        if (!$summary) {
            return response()->json([
                'status' => 'success',
                'message' => 'Belum ada hasil AI Summary.',
                'data' => null,
            ]);
        }

        $summary->summary = json_decode(
            $summary->summary,
            true
        );

        return response()->json([
            'status' => 'success',
            'data' => $summary,
        ]);
    }

    // Membuat AI Summary baru
    public function generate(Request $request, GeminiService $gemini)
    {
        // Memberikan waktu eksekusi maksimal 180 detik
        set_time_limit(180);

        $validated = $request->validate([
            'period_days' => 'required|integer|in:7,30',
        ]);

        try {
            $periodDays = (int) $validated['period_days'];

            $dateTo = Carbon::now();
            $dateFrom = Carbon::now()->subDays($periodDays);

            // Mengambil laporan yang memiliki kategori
            $reports = DB::table('complaints')
                ->join(
                    'complaint_categories',
                    'complaints.category_id',
                    '=',
                    'complaint_categories.id'
                )
                ->whereBetween('complaints.created_at', [
                    $dateFrom->copy()->startOfDay(),
                    $dateTo->copy()->endOfDay(),
                ])
                ->select(
                    'complaint_categories.name as category_name',
                    'complaints.description',
                    'complaints.created_at',
                    'complaints.status'
                )
                ->orderBy('complaints.created_at')
                ->limit(500)
                ->get();

            if ($reports->isEmpty()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Belum ada laporan berkategori pada periode ini.',
                ], 404);
            }

            // Mengelompokkan laporan berdasarkan kategori
            $groupedReports = $reports->groupBy('category_name');

            $analysisData = [];

            foreach ($groupedReports as $categoryName => $items) {
                $analysisData[] = [
                    'kategori' => $categoryName,
                    'jumlah_laporan' => $items->count(),
                    'laporan' => $items->map(function ($item) {
                        $description = (string) $item->description;

                        // Menyamarkan email
                        $description = preg_replace(
                            '/[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}/i',
                            '[EMAIL DISEMBUNYIKAN]',
                            $description
                        );

                        // Menyamarkan nomor telepon
                        $description = preg_replace(
                            '/(?:\+?62|0)[0-9\s\-]{8,15}/',
                            '[NOMOR DISEMBUNYIKAN]',
                            $description
                        );

                        return [
                            'deskripsi' => $description,
                            'tanggal' => $item->created_at,
                            'status' => $item->status,
                        ];
                    })->values()->all(),
                ];
            }

            // Mengirim data ke Gemini
            $aiResult = $gemini->generateSummary([
                'periode' => $periodDays . ' hari',
                'tanggal_mulai' => $dateFrom->toDateString(),
                'tanggal_selesai' => $dateTo->toDateString(),
                'total_laporan' => $reports->count(),
                'data_kategori' => $analysisData,
            ]);

            // Menyimpan hasil analisis ke PostgreSQL
            $summaryId = (string) Str::uuid();

            DB::table('ai_summaries')->insert([
                'id' => $summaryId,
                'period_days' => $periodDays,
                'date_from' => $dateFrom->toDateString(),
                'date_to' => $dateTo->toDateString(),
                'total_reports' => $reports->count(),
                'summary' => json_encode(
                    $aiResult,
                    JSON_UNESCAPED_UNICODE
                ),
                'model' => config('services.gemini.model'),
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'AI Summary berhasil dibuat.',
                'data' => [
                    'id' => $summaryId,
                    'period_days' => $periodDays,
                    'total_reports' => $reports->count(),
                    'summary' => $aiResult,
                ],
            ]);

        } catch (Throwable $e) {
            Log::error('AI Summary gagal dibuat', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Gagal membuat AI Summary.',
                'detail' => config('app.debug')
                    ? $e->getMessage()
                    : null,
            ], 500);
        }
    }
}
