<?php

namespace App\Http\Controllers\Api;
use Illuminate\Support\Facades\DB;

use App\Http\Controllers\Controller;
use App\Models\Pengaduan; // Pastikan model ini sudah ada
use Illuminate\Http\Request;

class PengaduanController extends Controller
{
    /**
     * 1. Untuk Tampilan "Pengaduan Terbaru" di Beranda (Home)
     */
    public function pengaduanTerbaru()
    {
        $pengaduan = DB::table('complaints')
    ->leftJoin('attachments', 'complaints.id', '=', 'attachments.complaint_id')
    ->select(
        'complaints.id', 
        'complaints.title', 
        'complaints.status', 
        'complaints.created_at', 
        'attachments.file_url as bukti_pengaduan'
    )
    ->orderBy('complaints.created_at', 'desc')
    ->take(4)
    ->get();

        return response()->json([
            'success' => 'success',
            'message' => 'Daftar Pengaduan Terbaru',
            'data'    => $pengaduan
        ], 200);
    }

    /**
     * 2. Untuk Tampilan "Cek Status Pengaduan" (Bisa difilter)
     */
    public function cekStatus(Request $request)
    {
        // Mulai query dasar, urutkan dari yang paling baru
        $query = Pengaduan::with('wilayah')->orderBy('tanggal_pengaduan', 'desc');

        // Jika user mengklik tab filter (Menunggu, Diproses, Selesai) di aplikasi
        if ($request->has('status') && $request->status !== 'Semua') {
            $query->where('status', $request->status);
        }

        $pengaduan = $query->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar Semua Pengaduan',
            'data'    => $pengaduan
        ], 200);
    }

    /**
     * 3. Menyimpan Pengaduan Baru (Dengan Upload Foto)
     */
    public function store(Request $request)
    {
        // Validasi input dasar
        $request->validate([
            'judul' => 'required|string',
            'titik_lokasi' => 'required|string',
            'deskripsi' => 'required|string',
            'level_prioritas' => 'nullable|string',
            // 'id_user' => 'required' // Buka ini jika kamu sudah punya sistem login user
        ]);

        // Simpan data utama ke tabel Pengaduan
        $pengaduan = Pengaduan::create([
            'id_user' => 1, // <--- SEMENTARA HARDCODE id_user = 1 (Karena belum ada login)
            'judul' => $request->judul,
            'titik_lokasi' => $request->titik_lokasi,
            'deskripsi' => $request->deskripsi,
            'level_prioritas' => $request->level_prioritas ?? 'Sedang',
            'status' => 'Menunggu',
            'tanggal_pengaduan' => now(),
        ]);

        // Simpan Foto Bukti jika ada
        if ($request->hasFile('bukti')) {
            foreach ($request->file('bukti') as $file) {
                // Simpan file ke folder storage/app/public/bukti_pengaduan
                $path = $file->store('bukti_pengaduan', 'public');

                // Simpan path-nya ke database tabel Bukti_Pengaduan
                $pengaduan->bukti_pengaduan()->create([
                    'file_bukti' => $path,
                    'tipe_file' => $file->getClientOriginalExtension(),
                    'uploaded_at' => now(),
                ]);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Pengaduan berhasil dikirim!',
            'data' => $pengaduan
        ], 201);
    }

    // --- FUNGSI UNTUK HALAMAN CEK STATUS PENGADUAN ---
    public function status()
    {
        // 1. Ambil data dari database dan ubah nama kolom (alias) agar sesuai dengan Flutter
        $pengaduan = DB::table('complaints')
            ->select(
                'id as id_pengaduan', 
                'title as judul', 
                'created_at as tanggal_pengaduan', 
                'address_note as titik_lokasi', 
                'status'
            )
            ->orderBy('created_at', 'desc')
            ->get();

        // 2. Rapikan datanya (Format tanggal, UUID, dan terjemahkan statusnya)
        $pengaduan->transform(function ($item) {
            // Karena ID kamu sekarang UUID (sangat panjang), kita ambil 5 huruf pertamanya saja
            $item->id_pengaduan = strtoupper(substr($item->id_pengaduan, 0, 5));
            
            // Format tanggal menjadi lebih rapi (Misal: 15 May 2026)
            $item->tanggal_pengaduan = date('d M Y', strtotime($item->tanggal_pengaduan));

            // Sesuaikan status dengan Tab di Flutter kamu
            if ($item->status == 'PENDING') $item->status = 'Menunggu';
            elseif ($item->status == 'PROCESSED') $item->status = 'Diproses';
            elseif ($item->status == 'RESOLVED') $item->status = 'Selesai';

            return $item;
        });

        // 3. Kirim ke Flutter
        return response()->json([
            'status' => 'success',
            'data' => $pengaduan
        ], 200);
    }

    // --- FUNGSI RIWAYAT PENGADUAN PRIBADI ---
    public function riwayatUser($email)
    {
        $account = DB::table('accounts')->where('email', $email)->first();
        if (!$account) {
            return response()->json(['status' => 'error', 'detail' => 'Akun tidak ditemukan'], 404);
        }

        $user = DB::table('users')->where('account_id', $account->id)->first();

        // Cari pengaduan milik user ini saja
        $pengaduan = DB::table('complaints')
            ->where('user_id', $user->id)
            ->select('id as id_pengaduan', 'title as judul', 'status')
            ->orderBy('created_at', 'desc')
            ->get();

        $pengaduan->transform(function ($item) {
            $item->id_pengaduan = strtoupper(substr($item->id_pengaduan, 0, 5));
            if ($item->status == 'PENDING') $item->status = 'Menunggu';
            elseif ($item->status == 'PROCESSED') $item->status = 'Diproses';
            elseif ($item->status == 'RESOLVED') $item->status = 'Selesai';
            return $item;
        });

        return response()->json(['status' => 'success', 'data' => $pengaduan], 200);
    }
}