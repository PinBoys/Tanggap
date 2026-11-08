<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver;


class PengaduanController extends Controller
{
    /**
     * Mengambil daftar kategori pengaduan dari database.
     */
    public function categories()
    {
        try {
            $categories = DB::table('complaint_categories')
                ->select('id', 'name', 'icon_url')
                ->orderBy('name', 'asc')
                ->get();

            return response()->json([
                'status' => 'success',
                'data' => $categories
            ], 200);

        } catch (\Throwable $e) {
            Log::error('GET CATEGORIES ERROR', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Gagal mengambil kategori: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Menyimpan pengaduan baru beserta foto bukti.
     */
    public function store(Request $request)
    {
        try {
            $request->validate([
                'email' => 'required|email',
                'category_id' => 'required|uuid|exists:complaint_categories,id',
                'deskripsi' => 'required|string|max:5000',
                'titik_lokasi' => 'required|string|max:255',
                'latitude' => 'nullable|numeric|between:-90,90',
                'longitude' => 'nullable|numeric|between:-180,180',
                'bukti.*' => 'nullable|image|mimes:jpg,jpeg,png|max:5120',
                'dampak' => 'required|string',
                'sensitivitas' => 'required|string',
                'alternatif' => 'required|string',
                'cakupan' => 'required|string',
            ]);

            $latitude = $request->input('latitude');
            $longitude = $request->input('longitude');

            // Mengambil kategori pengaduan.
            $kategori = DB::table('complaint_categories')
                ->where('id', $request->category_id)
                ->first();

            if (!$kategori) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Kategori pengaduan tidak ditemukan.'
                ], 422);
            }

            // Mengambil akun pengguna.
            $account = DB::table('accounts')
                ->where('email', $request->email)
                ->first();

            if (!$account) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Akun tidak ditemukan.'
                ], 404);
            }

            $user = DB::table('users')
                ->where('account_id', $account->id)
                ->first();

            if (!$user) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Data pengguna tidak ditemukan.'
                ], 404);
            }

            DB::transaction(function () use (
                $request,
                $user,
                $latitude,
                $longitude,
                $kategori
            ) {
                $complaintId = (string) Str::uuid();

                // Menentukan titik koordinat lokasi pengaduan.
                if ($latitude !== null && $longitude !== null) {
                    $lat = (float) $latitude;
                    $lng = (float) $longitude;

                    $location = DB::raw(
                        "ST_SetSRID(ST_MakePoint($lng, $lat), 4326)"
                    );
                } else {
                    $location = DB::raw(
                        "ST_SetSRID(ST_MakePoint(115.162, -8.799), 4326)"
                    );
                }

                // Menyimpan data pengaduan.
                DB::table('complaints')->insert([
                    'id' => $complaintId,
                    'user_id' => $user->id,
                    'category_id' => $kategori->id,
                    'title' => $kategori->name,
                    'description' => $request->deskripsi,
                    'address_note' => $request->titik_lokasi,
                    'latitude' => $latitude,
                    'longitude' => $longitude,
                    'location' => $location,
                    'status' => 'PENDING',
                    'created_at' => now(),
                    'updated_at' => now()
                ]);

                // ==================================
                // PERHITUNGAN PRIORITAS SAW
                // ==================================

                $mapDampak = [
                    "Aman" => 1,
                    "Gangguan Kecil" => 2,
                    "Resiko Luka" => 3,
                    "Sangat Berbahaya" => 4,
                    "Gawat Darurat" => 5
                ];

                $mapSensitivitas = [
                    "Stabil" => 1,
                    "Lambat" => 2,
                    "Sedang" => 3,
                    "Cepat" => 4,
                    "Detik Ini" => 5
                ];

                $mapAlternatif = [
                    "Banyak Pilihan" => 1,
                    "Ada Pilihan" => 2,
                    "Sulit" => 3,
                    "Hampir Buntu" => 4,
                    "Total Terisolasi" => 5
                ];

                $mapCakupan = [
                    "Pribadi" => 1,
                    "Tetangga" => 2,
                    "Lingkungan" => 3,
                    "Wilayah Luas" => 4,
                    "Sangat Luas" => 5
                ];

                // Bobot SAW.
                $bobot = [
                    'dampak' => 0.40,
                    'sensitivitas' => 0.30,
                    'alternatif' => 0.15,
                    'cakupan' => 0.15,
                ];

                // Normalisasi benefit.
                $dampak =
                    ($mapDampak[$request->dampak] ?? 1) / 5;

                $sensitivitas =
                    ($mapSensitivitas[$request->sensitivitas] ?? 1) / 5;

                $cakupan =
                    ($mapCakupan[$request->cakupan] ?? 1) / 5;

                // Normalisasi cost.
                $nilaiAlternatif =
                    $mapAlternatif[$request->alternatif] ?? 1;

                $alternatif = 1 / $nilaiAlternatif;

                // Menghitung nilai SAW.
                $nilaiSAW =
                    ($dampak * $bobot['dampak']) +
                    ($sensitivitas * $bobot['sensitivitas']) +
                    ($alternatif * $bobot['alternatif']) +
                    ($cakupan * $bobot['cakupan']);

                // Menentukan tingkat urgensi.
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

                // Menyimpan hasil SAW.
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
                    'saw_score' => round($nilaiSAW, 4),
                    'urgency_level' => $urgensi,
                    'last_calculated_at' => now()
                ]);

                // ==================================
                // PENYIMPANAN FOTO PENGADUAN
                // ==================================

                // Memeriksa kemungkinan nama field dari Flutter.
                $fileInput = $request->file('bukti')
                    ?? $request->file('foto')
                    ?? $request->file('image')
                    ?? $request->file('foto_bukti');

                if ($fileInput) {
                    $files = is_array($fileInput)
                        ? $fileInput
                        : [$fileInput];

                    foreach ($files as $file) {

                        if (!$file->isValid()) {
                            throw new \RuntimeException(
                                'File foto tidak valid.'
                            );
                        }

                        // Membaca dan mengompres foto.
                        $manager = new ImageManager(new Driver());

                        $image = $manager->read(
                            $file->getRealPath()
                        );

                        $image->scaleDown(width: 800);

                        // Membuat nama file unik.
                        $filename = Str::uuid() . '.jpg';

                        $folderPath =
                            'pengaduan_images/' . $filename;

                        // Mengubah gambar menjadi JPEG.
                        $imageContent = (string) $image->toJpeg(75);

                        // Menyimpan foto ke public storage.
                        $saved = Storage::disk('public')->put(
                            $folderPath,
                            $imageContent
                        );

                        if (!$saved) {
                            throw new \RuntimeException(
                                'Gagal menyimpan foto pengaduan ke storage.'
                            );
                        }

                        // ==================================
                        // DIAGNOSTIK STORAGE
                        // ==================================

                        $diskExists = Storage::disk('public')
                            ->exists($folderPath);

                        $diskPath = Storage::disk('public')
                            ->path($folderPath);

                        $publicPath = public_path(
                            'storage/' . $folderPath
                        );

                        Log::info('CEK PENGADUAN STORAGE', [
                            'complaint_id' => $complaintId,
                            'file_path' => $folderPath,
                            'save_result' => $saved,
                            'disk_exists' => $diskExists,
                            'disk_path' => $diskPath,
                            'storage_link_exists' =>
                                file_exists(public_path('storage')),
                            'storage_link_is_link' =>
                                is_link(public_path('storage')),
                            'public_file_exists' =>
                                file_exists($publicPath),
                            'file_readable' =>
                                is_readable($publicPath),
                            'file_size' =>
                                file_exists($publicPath)
                                    ? filesize($publicPath)
                                    : null,
                        ]);

                        // ==================================
                        // SIMPAN PATH KE DATABASE
                        // ==================================

                        $urlPath = '/storage/' . $folderPath;

                        DB::table('attachments')->insert([
                            'id' => (string) Str::uuid(),
                            'complaint_id' => $complaintId,
                            'file_url' => $urlPath,
                            'file_type' => 'image/jpeg',
                            'created_at' => now()
                        ]);
                    }
                }
            });

            return response()->json([
                'status' => 'success',
                'message' => 'Pengaduan berhasil dibuat!'
            ], 201);

        } catch (\Throwable $e) {

            Log::error('STORE PENGADUAN ERROR', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Server Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mengambil detail pengaduan.
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

        // Mengambil riwayat tindak lanjut admin.
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
                'tanggal' => date(
                    'd M Y, H:i',
                    strtotime($action->created_at)
                ),
                'foto_bukti' => $actionPhotos
            ];
        }

        // Mengambil data review/rating warga.
        $review = DB::table('complaint_reviews')
            ->where('complaint_id', $pengaduan->id)
            ->select('rating', 'comment', 'created_at')
            ->first();

        if ($review) {
            $review->created_at = date(
                'd M Y, H:i',
                strtotime($review->created_at)
            );
        }

        $mapDampak = [
            1 => "Aman",
            2 => "Gangguan Kecil",
            3 => "Resiko Luka",
            4 => "Sangat Berbahaya",
            5 => "Gawat Darurat"
        ];

        $mapSensitivitas = [
            1 => "Stabil",
            2 => "Lambat",
            3 => "Sedang",
            4 => "Cepat",
            5 => "Detik Ini"
        ];

        $mapAlternatif = [
            1 => "Banyak Pilihan",
            2 => "Ada Pilihan",
            3 => "Sulit",
            4 => "Hampir Buntu",
            5 => "Total Terisolasi"
        ];

        $mapCakupan = [
            1 => "Pribadi",
            2 => "Tetangga",
            3 => "Lingkungan",
            4 => "Wilayah Luas",
            5 => "Sangat Luas"
        ];

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
                'dampak' =>
                    $mapDampak[$priority->safety_impact ?? 0] ?? '-',
                'sensitivitas' =>
                    $mapSensitivitas[$priority->time_sensitivity ?? 0] ?? '-',
                'alternatif' =>
                    $mapAlternatif[$priority->alternative_availability ?? 0] ?? '-',
                'cakupan' =>
                    $mapCakupan[$priority->population_coverage ?? 0] ?? '-',
                'attachments' => $attachments,
                'riwayat_tindak_lanjut' => $tindakLanjut,
                'review' => $review
            ]
        ]);
    }

    /**
     * Menyimpan rating dan komentar dari pengguna.
     */
    public function storeReview(Request $request, $id)
    {
        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string'
        ]);

        try {
            $complaint = DB::table('complaints')
                ->where('id', $id)
                ->first();

            if (!$complaint || $complaint->status !== 'SELESAI') {
                return response()->json([
                    'status' => 'error',
                    'message' =>
                        'Pengaduan belum diselesaikan atau tidak ditemukan'
                ], 400);
            }

            $existingReview = DB::table('complaint_reviews')
                ->where('complaint_id', $id)
                ->first();

            if ($existingReview) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Anda sudah memberikan penilaian'
                ], 400);
            }

            DB::table('complaint_reviews')->insert([
                'id' => (string) Str::uuid(),
                'complaint_id' => $id,
                'rating' => $request->rating,
                'comment' => $request->comment,
                'created_at' => now(),
                'updated_at' => now()
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Terima kasih atas penilaian Anda!'
            ], 200);

        } catch (\Throwable $e) {

            Log::error('STORE REVIEW ERROR', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Gagal memberikan rating: ' . $e->getMessage()
            ], 500);
        }
    }
    public function checkImageStorage()
{
    $files = [
        'pengaduan_images/84e0334f-ee52-4897-bd5c-833313447390.jpg',
        'pengaduan_images/b5738d50-0289-4df6-8abf-afdade4b489e.jpg',
        'pengaduan_images/0c93cb3e-c4e4-42b7-b297-70e99f094836.jpg',
        'profile_images/profile_6af06b86e1a49.jpg',
    ];

    $results = [];

    foreach ($files as $file) {
        $publicPath = public_path('storage/' . $file);

        $results[] = [
            'file' => $file,
            'disk_exists' => Storage::disk('public')->exists($file),
            'public_exists' => file_exists($publicPath),
            'readable' => is_readable($publicPath),
            'permissions' => file_exists($publicPath)
                ? substr(sprintf('%o', fileperms($publicPath)), -4)
                : null,
            'size' => file_exists($publicPath)
                ? filesize($publicPath)
                : null,
        ];
    }

    return response()->json([
        'status' => 'success',
        'results' => $results
    ]);
}
}
