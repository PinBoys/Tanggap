<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class RiwayatController extends Controller
{
    /**
     * Mengubah path foto menjadi signed URL Supabase.
     */
    private function getSupabaseImageUrl($path)
    {
        if (!$path) {
            return null;
        }

        // Membersihkan format path lama.
        $path = str_replace('/storage/', '', $path);
        $path = ltrim($path, '/');

        try {
            $disk = Storage::disk('supabase');

            // Memastikan file tersedia di Supabase.
            if (!$disk->exists($path)) {
                Log::warning('FOTO RIWAYAT TIDAK DITEMUKAN DI SUPABASE', [
                    'path' => $path
                ]);

                return null;
            }

            // Membuat signed URL berlaku selama 60 menit.
            return $disk->temporaryUrl(
                $path,
                now()->addMinutes(60)
            );

        } catch (\Throwable $e) {
            Log::error('GAGAL MEMBUAT URL FOTO RIWAYAT', [
                'path' => $path,
                'message' => $e->getMessage()
            ]);

            return null;
        }
    }

    /**
     * Menampilkan Riwayat Pengaduan User.
     */
    public function riwayatUser($email)
    {
        try {
            // 1. Cari account berdasarkan email.
            $account = DB::table('accounts')
                ->where('email', $email)
                ->first();

            if (!$account) {
                return response()->json([
                    'status' => 'error',
                    'detail' => 'Akun tidak ditemukan'
                ], 404);
            }

            // 2. Cari user_id berdasarkan account_id.
            $user = DB::table('users')
                ->where('account_id', $account->id)
                ->first();

            if (!$user) {
                return response()->json([
                    'status' => 'error',
                    'detail' => 'User tidak ditemukan'
                ], 404);
            }

            // 3. Ambil data pengaduan dan foto pertama.
            $pengaduan = DB::table('complaints')
                ->where('complaints.user_id', $user->id)
                ->select(
                    'complaints.id as id_pengaduan',
                    'complaints.title as judul',
                    'complaints.address_note as lokasi',
                    'complaints.status',
                    'complaints.created_at as tanggal_pengaduan',
                    DB::raw("
                        (
                            SELECT file_url
                            FROM attachments
                            WHERE attachments.complaint_id = complaints.id
                            ORDER BY created_at ASC
                            LIMIT 1
                        ) as bukti_pengaduan
                    ")
                )
                ->orderBy('complaints.created_at', 'desc')
                ->get();

            // 4. Transformasi data.
            $pengaduan->transform(function ($item) {

                // Format ID pengaduan.
                $item->id_pengaduan = strtoupper(
                    substr($item->id_pengaduan, 0, 5)
                );

                // Format tanggal.
                $item->tanggal_pengaduan = date(
                    'd M Y',
                    strtotime($item->tanggal_pengaduan)
                );

                // Mapping status.
                $statusMap = [
                    'PENDING' => 'Menunggu',
                    'DIPROSES' => 'Diproses',
                    'SELESAI' => 'Selesai'
                ];

                $item->status = $statusMap[
                    strtoupper($item->status)
                ] ?? $item->status;

                // Mengubah path foto menjadi signed URL Supabase.
                $item->bukti_pengaduan =
                    $this->getSupabaseImageUrl(
                        $item->bukti_pengaduan
                    );

                return $item;
            });

            // 5. Mengembalikan respons API.
            return response()->json([
                'status' => 'success',
                'data' => $pengaduan
            ], 200);

        } catch (\Throwable $e) {

            Log::error('RIWAYAT PENGADUAN ERROR', [
                'email' => $email,
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);

            return response()->json([
                'status' => 'error',
                'detail' => 'Gagal mengambil riwayat pengaduan.'
            ], 500);
        }
    }
}
