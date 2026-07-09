<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver;

class PengaduanController extends Controller
{
    /**
     * 4. Menyimpan Pengaduan Baru (Dengan Form Lengkap & Foto)
     */
    public function store(Request $request)
    {
        try {

            $request->validate([
                'email' => 'required|email',
                'judul' => 'required|string|max:255',
                'deskripsi' => 'required|string|max:5000',
                'titik_lokasi' => 'required|string|max:255',

                'bukti.*' => 'nullable|image|mimes:jpg,jpeg,png|max:5120',

                'dampak' => 'required|string',
                'sensitivitas' => 'required|string',
                'alternatif' => 'required|string',
                'cakupan' => 'required|string',
            ]);
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
                // ======================
                // BOBOT SAW
                // ======================

                $bobot = [
                    'dampak' => 0.40,
                    'sensitivitas' => 0.30,
                    'alternatif' => 0.15,
                    'cakupan' => 0.15,
                ];
                // =========================
                // NORMALISASI SAW
                // =========================

                // BENEFIT
                $dampak =
                ($mapDampak[$request->dampak] ?? 1) / 5;

                $sensitivitas =
                ($mapSensitivitas[$request->sensitivitas] ?? 1) / 5;

                $cakupan =
                ($mapCakupan[$request->cakupan] ?? 1) / 5;


                // COST
                $nilaiAlternatif =
                $mapAlternatif[$request->alternatif] ?? 1;

                $alternatif =
                1 / $nilaiAlternatif;
                // =========================
                // HITUNG SAW
                // =========================

                $nilaiSAW =
                ($dampak * $bobot['dampak']) +
                ($sensitivitas * $bobot['sensitivitas']) +
                ($alternatif * $bobot['alternatif']) +
                ($cakupan * $bobot['cakupan']);
                if ($nilaiSAW >= 0.81) {

                    $urgensi = "Sangat Tinggi";

                } elseif ($nilaiSAW >= 0.61) {

                    $urgensi = "Tinggi";

                } elseif ($nilaiSAW >= 0.41) {

                    $urgensi = "Sedang";

                } elseif ($nilaiSAW >= 0.21) {

                    $urgensi = "Rendah";

                } else {

                    $urgensi = "Sangat Rendah";

                }

                DB::table('priority_scores')->insert([
                    'complaint_id' => $complaintId,

                    'safety_impact' =>
                        $mapDampak[$request->dampak] ?? 1,

                    'time_sensitivity' =>
                        $mapSensitivitas[$request->sensitivitas] ?? 1,

                    'alternative_availability' =>
                        $mapAlternatif[$request->alternatif] ?? 1,

                    'population_coverage' =>
                        $mapCakupan[$request->cakupan] ?? 1,

                    'saw_score' =>
                        round($nilaiSAW,4),

                    'urgency_level' =>
                        $urgensi,

                    'last_calculated_at' =>
                        now()
                ]);

                // Memeriksa berbagai kemungkinan key pengiriman dari Flutter
                $fileInput = $request->file('bukti') ?? $request->file('foto') ?? $request->file('image') ?? $request->file('foto_bukti');

                if ($fileInput) {
                    // Jadikan array agar aman dilooping (mencegah error jika hanya 1 file)
                    $files = is_array($fileInput) ? $fileInput : [$fileInput];

                    foreach ($files as $file) {
                        // 1. Inisialisasi Manager
                        $manager = new ImageManager(new Driver());
                        $image = $manager->read($file->getRealPath());

                        // 2. Kompresi agar ukuran file kecil dan enteng ditarik Flutter
                        $image->scaleDown(width: 800);

                        // 3. Tentukan nama file
                        $filename = Str::uuid() . ".jpg";
                        $folderPath = "pengaduan_images/" . $filename;

                        // 4. Simpan ke Storage (INI BAGIAN YANG BENAR)
                        Storage::disk('public')->put(
                            $folderPath, 
                            (string) $image->toJpeg(75)
                        );

    // 5. Simpan path ke Database
        $urlPath = "/storage/" . $folderPath;

        DB::table('attachments')->insert([
            'id' => Str::uuid(),
            'complaint_id' => $complaintId,
            'file_url' => $urlPath,
            'file_type' => 'image/jpeg',
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
     * 5. FUNGSI DETAIL PENGADUAN
     */
    public function detail($id)
    {
        $pengaduan = DB::table('complaints')
            ->where('id', 'ilike', $id . '%')
            ->first();

        if (!$pengaduan) {
            return response()->json([
                'status' => 'error',
                'message' => 'Data tidak ditemukan'
            ], 404);
        }

        $priority = DB::table('priority_scores')
            ->where('complaint_id', $pengaduan->id)
            ->first();

            $kategoriUrgensi =
            $priority->urgency_level ?? 'Tidak Diketahui';

            $nilaiSAW =
            $priority->saw_score ?? 0;

        $attachments = DB::table('attachments')
            ->where('complaint_id', $pengaduan->id)
            ->pluck('file_url');

        //RIWAYAT TINDAK LANJUT ADMIN
        $tindakLanjutRaw = DB::table('complaint_actions')
            ->where('complaint_id', $pengaduan->id)
            ->orderBy('created_at', 'desc')
            ->get();

        $tindakLanjut = [];
        foreach ($tindakLanjutRaw as $action) {
            $actionPhotos = DB::table('action_attachments')
                ->where('action_id', $action->id)
                ->pluck('file_url');

            $tindakLanjut[] = [
                'id' => $action->id,
                'status' => $action->status_changed_to,
                'catatan' => $action->notes,
                'tanggal' => date('d M Y, H:i', strtotime($action->created_at)),
                'foto_bukti' => $actionPhotos
            ];
        }

        //AMBIL DATA REVIEW/RATING WARGA ---
        $review = DB::table('complaint_reviews')
            ->where('complaint_id', $pengaduan->id)
            ->select('rating', 'comment', 'created_at')
            ->first();

        if ($review) {
            $review->created_at = date('d M Y, H:i', strtotime($review->created_at));
        }

        $mapDampak = [1 => "Aman", 2 => "Gangguan Kecil", 3 => "Resiko Luka", 4 => "Sangat Berbahaya", 5 => "Gawat Darurat"];
        $mapSensitivitas = [1 => "Stabil", 2 => "Lambat", 3 => "Sedang", 4 => "Cepat", 5 => "Detik Ini"];
        $mapAlternatif = [1 => "Banyak Pilihan", 2 => "Ada Pilihan", 3 => "Sulit", 4 => "Hampir Buntu", 5 => "Total Terisolasi"];
        $mapCakupan = [1 => "Pribadi", 2 => "Tetangga", 3 => "Lingkungan", 4 => "Wilayah Luas", 5 => "Sangat Luas"];

        return response()->json([
            'status' => 'success',
            'data' => [
                'id' => $pengaduan->id,
                'judul' => $pengaduan->title,
                'titik_lokasi' => $pengaduan->address_note,
                'created_at' => $pengaduan->created_at,
                'deskripsi' => $pengaduan->description,
                'status' => $pengaduan->status,
                'urgensi' => $kategoriUrgensi,
                'saw_score' => $nilaiSAW,
                'dampak' => $mapDampak[$priority->safety_impact] ?? '-',
                'sensitivitas' => $mapSensitivitas[$priority->time_sensitivity] ?? '-',
                'alternatif' => $mapAlternatif[$priority->alternative_availability] ?? '-',
                'cakupan' => $mapCakupan[$priority->population_coverage] ?? '-',
                'attachments' => $attachments,
                'riwayat_tindak_lanjut' => $tindakLanjut, // Data timeline dikirim
                'review' => $review // Data rating dikirim
            ]
        ]);
    }

    /**
     * 6. FUNGSI MENYIMPAN RATING & KOMENTAR DARI USER (FITUR BARU)
     */
    public function storeReview(Request $request, $id)
    {
        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string'
        ]);

        try {
            $complaint = DB::table('complaints')->where('id', $id)->first();
            if (!$complaint || $complaint->status !== 'SELESAI') {
                return response()->json([
                    'status' => 'error', 
                    'message' => 'Pengaduan belum diselesaikan atau tidak ditemukan'
                ], 400);
            }

            $existingReview = DB::table('complaint_reviews')->where('complaint_id', $id)->first();
            if ($existingReview) {
                return response()->json(['status' => 'error', 'message' => 'Anda sudah memberikan penilaian'], 400);
            }

            // Simpan ke database
            DB::table('complaint_reviews')->insert([
                'id' => (string) Str::uuid(),
                'complaint_id' => $id,
                'rating' => $request->rating,
                'comment' => $request->comment,
                'created_at' => now(),
                'updated_at' => now()
            ]);

            return response()->json(['status' => 'success', 'message' => 'Terima kasih atas penilaian Anda!'], 200);

        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => 'Gagal memberikan rating: ' . $e->getMessage()], 500);
        }
        
    }
}