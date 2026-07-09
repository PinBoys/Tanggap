<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class AdminDashboardController extends Controller
{
    public function getComplaints()
    {
        // =======================
        // FILTER
        // =======================
        $filter = request('filter');

        $query = DB::table('complaints')
            ->leftJoin(
                'priority_scores',
                'complaints.id',
                '=',
                'priority_scores.complaint_id'
            )
            ->select(
                'complaints.*',
                'priority_scores.saw_score',
                'priority_scores.urgency_level'
            );

        if ($filter == "Hari ini") {

            $query->whereDate(
                'complaints.created_at',
                today()
            );

        } elseif ($filter == "Minggu ini") {

            $query->whereBetween(
                'complaints.created_at',
                [
                    now()->startOfWeek(),
                    now()->endOfWeek()
                ]
            );

        } elseif ($filter == "Bulan ini") {

            $query->whereMonth(
                'complaints.created_at',
                now()->month
            )->whereYear(
                'complaints.created_at',
                now()->year
            );

        } elseif ($filter == "Tahun ini") {

            $query->whereYear(
                'complaints.created_at',
                now()->year
            );
        }

        // =======================
        // DATA PENGADUAN
        // =======================
        $complaints = (clone $query)
            ->orderByDesc('priority_scores.saw_score')
            ->orderByDesc('complaints.created_at')
            ->get();

        // =======================
        // GRAFIK
        // =======================
        $grafikQuery = DB::table('complaints');

        if ($filter == "Hari ini") {

            $grafikQuery->whereDate(
                'created_at',
                today()
            );

        } elseif ($filter == "Minggu ini") {

            $grafikQuery->whereBetween(
                'created_at',
                [
                    now()->startOfWeek(),
                    now()->endOfWeek()
                ]
            );

        } elseif ($filter == "Bulan ini") {

            $grafikQuery
                ->whereMonth(
                    'created_at',
                    now()->month
                )
                ->whereYear(
                    'created_at',
                    now()->year
                );

        } elseif ($filter == "Tahun ini") {

            $grafikQuery->whereYear(
                'created_at',
                now()->year
            );
        }

        $grafikMingguan = $grafikQuery
            ->selectRaw("
                EXTRACT(DOW FROM created_at) as hari,
                COUNT(*) as total
            ")
            ->groupByRaw("EXTRACT(DOW FROM created_at)")
            ->get();

        $data = [];

        foreach ($grafikMingguan as $item) {

            $data[(int)$item->hari] = (int)$item->total;
        }

        $dataGrafik = [

            [
                "hari" => "Sen",
                "total" => $data[1] ?? 0,
            ],

            [
                "hari" => "Sel",
                "total" => $data[2] ?? 0,
            ],

            [
                "hari" => "Rab",
                "total" => $data[3] ?? 0,
            ],

            [
                "hari" => "Kam",
                "total" => $data[4] ?? 0,
            ],

            [
                "hari" => "Jum",
                "total" => $data[5] ?? 0,
            ],

            [
                "hari" => "Sab",
                "total" => $data[6] ?? 0,
            ],

            [
                "hari" => "Min",
                "total" => $data[0] ?? 0,
            ],

        ];

        // =======================
        // RESPONSE
        // =======================
        return response()->json([
            'status' => 'success',
            'data' => $complaints,
            'grafik_mingguan' => $dataGrafik
        ]);
    }
}