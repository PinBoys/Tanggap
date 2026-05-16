<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class PengaduanController extends Controller
{
    /**
     * 1. Untuk Tampilan "Pengaduan Terbaru" di Beranda (Dashboard)
     * (Sudah diperbaiki agar mengambil foto dari tabel attachments)
     */
    public function pengaduanTerbaru()
    {
        $pengaduan = DB::table('complaints')
            ->leftJoin('attachments', 'complaints.id', '=', 'attachments.complaint_id')
            ->select(
                'complaints.id as id_pengaduan', 
                'complaints.title as judul', 
                'complaints.status', 
                'complaints.created_at as tanggal_pengaduan', 
                'attachments.file_url as bukti_pengaduan'
            )
            ->orderBy('complaints.created_at', 'desc')
            ->take(4) // Ambil 4 terbaru untuk dashboard
            ->get();

        $pengaduan->transform(function ($item) {
            $item->id_pengaduan = strtoupper(substr($item->id_pengaduan, 0, 5));
            $item->tanggal_pengaduan = date('d M Y', strtotime($item->tanggal_pengaduan));

            if ($item->status == 'PENDING') $item->status = 'Menunggu';
            elseif ($item->status == 'PROCESSED') $item->status = 'Diproses';
            elseif ($item->status == 'RESOLVED') $item->status = 'Selesai';

            return $item;
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Daftar Pengaduan Terbaru',
            'data'    => $pengaduan
        ], 200);
    }

    /**
     * 2. Untuk Tampilan "Cek Status Pengaduan" (Semua Laporan)
     */
    public function status()
    {
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

        $pengaduan->transform(function ($item) {
            $item->id_pengaduan = strtoupper(substr($item->id_pengaduan, 0, 5));
            $item->tanggal_pengaduan = date('d M Y', strtotime($item->tanggal_pengaduan));

            if ($item->status == 'PENDING') $item->status = 'Menunggu';
            elseif ($item->status == 'PROCESSED') $item->status = 'Diproses';
            elseif ($item->status == 'RESOLVED') $item->status = 'Selesai';

            return $item;
        });

        return response()->json([
            'status' => 'success',
            'data' => $pengaduan
        ], 200);
    }

/**
     * 3. Untuk Tampilan "Riwayat Pengaduan" & Notifikasi
     */
    public function riwayatUser($email)
    {
        $account = DB::table('accounts')->where('email', $email)->first();
        if (!$account) {
            return response()->json(['status' => 'error', 'detail' => 'Akun tidak ditemukan'], 404);
        }

        $user = DB::table('users')->where('account_id', $account->id)->first();

        // TAMBAHAN: Ambil kolom 'updated_at' untuk dijadikan Jam Notifikasi
        $pengaduan = DB::table('complaints')
            ->where('user_id', $user->id)
            ->select('id as id_pengaduan', 'title as judul', 'status', 'updated_at as waktu')
            ->orderBy('updated_at', 'desc')
            ->get();

        $pengaduan->transform(function ($item) {
            $item->id_pengaduan = strtoupper(substr($item->id_pengaduan, 0, 5));
            
            // Format jam untuk notifikasi (Contoh: 14:25)
            $item->waktu = date('H:i', strtotime($item->waktu));
            
            if ($item->status == 'PENDING') $item->status = 'Menunggu';
            elseif ($item->status == 'PROCESSED') $item->status = 'Diproses';
            elseif ($item->status == 'RESOLVED') $item->status = 'Selesai';
            
            return $item;
        });

        return response()->json(['status' => 'success', 'data' => $pengaduan], 200);
    }
    
    /**
     * 4. Menyimpan Pengaduan Baru (Dengan Form Lengkap & Foto)
     */
    public function store(Request $request)
    {
        try {
            $account = DB::table('accounts')->where('email', $request->email)->first();
            if (!$account) {
                return response()->json(['status' => 'error', 'message' => 'Akun tidak ditemukan'], 404);
            }
            $user = DB::table('users')->where('account_id', $account->id)->first();

            DB::transaction(function () use ($request, $user) {
                $complaintId = (string) Str::uuid();

                // Simpan Data Teks Pengaduan
                DB::table('complaints')->insert([
                    'id' => $complaintId,
                    'user_id' => $user->id,
                    'title' => $request->judul,
                    'description' => $request->deskripsi,
                    'address_note' => $request->titik_lokasi,
                    'location' => DB::raw("ST_SetSRID(ST_MakePoint(115.162, -8.799), 4326)"), 
                    'status' => 'PENDING',
                    'created_at' => now(),
                    'updated_at' => now()
                ]);

                // Hitung Scoring Prioritas
                $mapDampak = ["Aman"=>1, "Gangguan Kecil"=>2, "Resiko Luka"=>3, "Sangat Berbahaya"=>4, "Gawat Darurat"=>5];
                $mapSensitivitas = ["Stabil"=>1, "Lambat"=>2, "Sedang"=>3, "Cepat"=>4, "Detik Ini"=>5];
                $mapAlternatif = ["Banyak Pilihan"=>1, "Ada Pilihan"=>2, "Sulit"=>3, "Hampir Buntu"=>4, "Total Terisolasi"=>5];
                $mapCakupan = ["Pribadi"=>1, "Tetangga"=>2, "Lingkungan"=>3, "Wilayah Luas"=>4, "Sangat Luas"=>5];

                DB::table('priority_scores')->insert([
                    'complaint_id' => $complaintId,
                    'safety_impact' => $mapDampak[$request->dampak] ?? 1,
                    'time_sensitivity' => $mapSensitivitas[$request->sensitivitas] ?? 1,
                    'alternative_availability' => $mapAlternatif[$request->alternatif] ?? 1,
                    'population_coverage' => $mapCakupan[$request->cakupan] ?? 1,
                    'last_calculated_at' => now()
                ]);

                // Simpan Foto
                if ($request->hasFile('bukti')) {
                    foreach ($request->file('bukti') as $file) {
                        $path = $file->store('pengaduan_images', 'public');
                        
                        DB::table('attachments')->insert([
                            'id' => (string) Str::uuid(),
                            'complaint_id' => $complaintId,
                            'file_url' => '/storage/' . $path,
                            'file_type' => $file->getClientMimeType(),
                            'created_at' => now()
                        ]);
                    }
                }
            });

            return response()->json(['status' => 'success', 'message' => 'Pengaduan berhasil dibuat!'], 201);
            
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => 'Server Error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * 5. FUNGSI DETAIL PENGADUAN (Untuk melihat data lengkap 1 pengaduan)
     */
    public function detail($id)
    {
        $pengaduan = DB::table('complaints')
            ->where('id', 'ilike', $id . '%') 
            ->first();

        if (!$pengaduan) {
            return response()->json(['status' => 'error', 'message' => 'Data tidak ditemukan'], 404);
        }

        $foto = DB::table('attachments')
            ->where('complaint_id', $pengaduan->id)
            ->select('file_url')
            ->get();

        $statusMap = ['PENDING' => 'Menunggu', 'PROCESSED' => 'Diproses', 'RESOLVED' => 'Selesai'];
        $statusIndo = $statusMap[$pengaduan->status] ?? $pengaduan->status;

        return response()->json([
            'status' => 'success',
            'data' => [
                'id_pengaduan' => strtoupper(substr($pengaduan->id, 0, 5)),
                'judul' => $pengaduan->title,
                'tanggal' => date('d M Y, H:i \W\I\T\A', strtotime($pengaduan->created_at)),
                'lokasi' => $pengaduan->address_note,
                'deskripsi' => $pengaduan->description,
                'status' => $statusIndo,
                'foto' => $foto->pluck('file_url') 
            ]
        ], 200);
    }
}