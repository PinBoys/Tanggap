<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class RiwayatController extends Controller
{
    /**
     * Menampilkan Riwayat Pengaduan User
     */
    public function riwayatUser($email)
    {
        // 1. Cari account berdasarkan email
        $account = DB::table('accounts')
            ->where('email', $email)
            ->first();

        if (!$account) {
            return response()->json([
                'status' => 'error',
                'detail' => 'Akun tidak ditemukan'
            ], 404);
        }

        // 2. Cari user_id berdasarkan account_id
        $user = DB::table('users')
            ->where('account_id', $account->id)
            ->first();

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'detail' => 'User tidak ditemukan'
            ], 404);
        }

        // 3. Ambil data pengaduan dengan Subquery untuk foto agar tidak duplikat
        $pengaduan = DB::table('complaints')
            ->where('complaints.user_id', $user->id)
            ->select(
                'complaints.id as id_pengaduan',
                'complaints.title as judul',
                'complaints.address_note as lokasi',
                'complaints.status',
                'complaints.created_at as tanggal_pengaduan',
                // Mengambil foto pertama dari tabel attachments secara efisien
                DB::raw("(SELECT file_url FROM attachments WHERE attachments.complaint_id = complaints.id ORDER BY created_at ASC LIMIT 1) as bukti_pengaduan")
            )
            ->orderBy('complaints.created_at', 'desc')
            ->get();

        // 4. Transformasi data untuk format yang diinginkan
        $pengaduan->transform(function ($item) {
            // Format ID PGD
            $item->id_pengaduan = strtoupper(substr($item->id_pengaduan, 0, 5));

            // Format Tanggal
            $item->tanggal_pengaduan = date('d M Y', strtotime($item->tanggal_pengaduan));

            // Mapping Status
            $statusMap = [
                'PENDING' => 'Menunggu',
                'DIPROSES' => 'Diproses',
                'SELESAI' => 'Selesai'
            ];
            $item->status = $statusMap[strtoupper($item->status)] ?? $item->status;

            return $item;
        });

        return response()->json([
            'status' => 'success',
            'data' => $pengaduan
        ], 200);
    }
}