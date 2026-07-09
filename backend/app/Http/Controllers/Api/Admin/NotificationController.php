<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class NotificationController extends Controller
{
    public function index()
    {
        $notifikasi = DB::table('complaints')

            ->join(
                'users',
                'complaints.user_id',
                '=',
                'users.id'
            )

            ->leftJoin(
                'priority_scores',
                'complaints.id',
                '=',
                'priority_scores.complaint_id'
            )

            ->select(
                'complaints.id',
                'complaints.title',
                'complaints.status',
                'complaints.created_at',

                'users.full_name',

                'priority_scores.saw_score',
                'priority_scores.urgency_level'
            )

            // Pengaduan terbaru tampil paling atas
            ->orderByDesc('complaints.created_at')

            // Jika waktu sama, urutkan berdasarkan tingkat urgensi
            ->orderByRaw("
                CASE priority_scores.urgency_level
                    WHEN 'Sangat Tinggi' THEN 5
                    WHEN 'Tinggi' THEN 4
                    WHEN 'Sedang' THEN 3
                    WHEN 'Rendah' THEN 2
                    WHEN 'Sangat Rendah' THEN 1
                    ELSE 0
                END DESC
            ")

            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $notifikasi
        ]);
    }
}