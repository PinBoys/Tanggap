<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    /**
     * 1. Untuk Tampilan "Pengaduan Terbaru" di Beranda (Dashboard)
     */
public function pengaduanTerbaru()
{
    $pengaduan = DB::table('complaints')
        ->select(
            'complaints.id as id_pengaduan',
            'complaints.title as judul',
            'complaints.address_note as lokasi',
            'complaints.status',
            'complaints.created_at as tanggal_pengaduan'
        )
        ->orderByDesc('complaints.created_at')
        ->take(4)
        ->get();

    foreach ($pengaduan as $item) {

        $foto = DB::table('attachments')
            ->where('complaint_id', $item->id_pengaduan)
            ->value('file_url');

        $item->bukti_pengaduan = str_replace('/storage/', '', $foto);

        $item->id_pengaduan = strtoupper(substr($item->id_pengaduan, 0, 5));
        $item->tanggal_pengaduan = date('d M Y', strtotime($item->tanggal_pengaduan));

        if ($item->status == 'PENDING') {
            $item->status = 'Menunggu';
        } elseif ($item->status == 'DIPROSES') {
            $item->status = 'Diproses';
        } elseif ($item->status == 'SELESAI') {
            $item->status = 'Selesai';
        }
    }

    return response()->json([
        'status' => 'success',
        'message' => 'Daftar Pengaduan Terbaru',
        'data' => $pengaduan
    ]);
}
}