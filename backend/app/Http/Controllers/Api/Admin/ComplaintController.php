<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ComplaintController extends Controller
{
    /**
     * Menampilkan daftar pengaduan
     */
    public function index()
    {

    }

    /**
     * Menampilkan detail pengaduan
     */
    public function detail($id)
{
    // Pastikan import 'use Illuminate\Support\Facades\DB;' sudah ada di atas
    $pengaduan = DB::table('complaints')->where('id', $id)->first();
    if (!$pengaduan) return response()->json(['message' => 'Not found'], 404);

    $attachments = DB::table('attachments')
        ->where('complaint_id', $pengaduan->id)
        ->pluck('file_url');

    $tindakLanjutRaw = DB::table('complaint_actions')->where('complaint_id', $pengaduan->id)->get();
    $tindakLanjut = [];
    foreach ($tindakLanjutRaw as $action) {
        $actionPhotos = DB::table('action_attachments')
            ->where('action_id', $action->id)
            ->pluck('file_url');

        $tindakLanjut[] = [
            'id' => $action->id,
            'status' => $action->status_changed_to,
            'catatan' => $action->notes,
            'foto_bukti' => $actionPhotos 
        ];
    }

    return response()->json([
        'status' => 'success',
        'data' => [
            'attachments' => $attachments,
            'riwayat_tindak_lanjut' => $tindakLanjut,
        ]
    ]);
}
}