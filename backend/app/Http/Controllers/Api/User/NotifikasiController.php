<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class NotifikasiController extends Controller
{
    /**
     * Menampilkan Notifikasi User
     */
    public function index($email)
    {
        $account = DB::table('accounts')
            ->where('email', $email)
            ->first();

        if (!$account) {

            return response()->json([
                'status' => 'error',
                'detail' => 'Akun tidak ditemukan'
            ], 404);

        }

        $user = DB::table('users')
            ->where('account_id', $account->id)
            ->first();

        $notifikasi = DB::table('complaints')

            ->leftJoin(
                'attachments',
                'complaints.id',
                '=',
                'attachments.complaint_id'
            )

            ->where(
                'complaints.user_id',
                $user->id
            )

            ->select(

                'complaints.id as id_pengaduan',

                'complaints.title as judul',

                'complaints.status',

                'complaints.updated_at as waktu',

                'attachments.file_url as bukti_pengaduan'

            )

            ->orderBy(
                'complaints.updated_at',
                'desc'
            )

            ->get();

        // Menghindari data ganda jika foto lebih dari satu
        $notifikasi = $notifikasi
            ->unique('id_pengaduan')
            ->values();

        $notifikasi->transform(function ($item) {

            $item->id_pengaduan =
                strtoupper(
                    substr(
                        $item->id_pengaduan,
                        0,
                        5
                    )
                );

            $item->waktu =
                date(
                    'd M Y H:i',
                    strtotime(
                        $item->waktu
                    )
                );

            switch ($item->status) {

                case 'PENDING':

                    $item->status = 'Menunggu';

                    $item->pesan =
                        'Pengaduan berhasil dikirim dan sedang menunggu verifikasi.';

                    break;

                case 'DIPROSES':

                    $item->status = 'Diproses';

                    $item->pesan =
                        'Pengaduan sedang diproses oleh petugas.';

                    break;

                case 'SELESAI':

                    $item->status = 'Selesai';

                    $item->pesan =
                        'Pengaduan telah selesai ditangani.';

                    break;

                default:

                    $item->pesan =
                        'Status pengaduan diperbarui.';
            }

            return $item;
        });

        return response()->json([

            'status' => 'success',

            'data' => $notifikasi

        ], 200);
    }
}