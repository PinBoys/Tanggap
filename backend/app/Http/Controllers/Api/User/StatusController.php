<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class StatusController extends Controller
{
    /**
     * 2. Untuk Tampilan "Cek Status Pengaduan" (Semua Laporan)
     */
    public function statusUser($email)
    {
        $account = DB::table('accounts')->where('email', $email)->first();

        if (!$account) {
            return response()->json(['status' => 'error'], 404);
        }

        $user = DB::table('users')->where('account_id', $account->id)->first();

        $pengaduan = DB::table('complaints')
            ->where('user_id', $user->id)
            ->select(
                'id as id_pengaduan',
                'title as judul',
                'created_at as tanggal_pengaduan',
                'address_note as titik_lokasi',
                'status'
            )
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $pengaduan
        ]);
    }
}