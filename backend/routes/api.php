<?php

use Illuminate\Support\Facades\Route;

// AUTH
use App\Http\Controllers\Api\Auth\AuthController;
use App\Http\Controllers\Api\Auth\AdminAuthController;
// USER
use App\Http\Controllers\Api\User\DashboardController;
use App\Http\Controllers\Api\User\PengaduanController;
use App\Http\Controllers\Api\User\ProfileController;
use App\Http\Controllers\Api\User\RiwayatController;
use App\Http\Controllers\Api\User\StatusController;
use App\Http\Controllers\Api\User\NotifikasiController;
// ADMIN
use App\Http\Controllers\Api\Admin\AdminDashboardController;
use App\Http\Controllers\Api\Admin\AdminProfileController;
use App\Http\Controllers\Api\Admin\NotificationController;
use App\Http\Controllers\Api\Admin\ComplaintActionController;
use App\Http\Controllers\Api\Admin\AnalisisAIController;



// ================= AUTH USER =================
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/check-email', [AuthController::class, 'checkEmail']);
Route::post('/update-password', [AuthController::class, 'updatePassword']);
// ================= AUTH ADMIN =================
Route::post('/admin/login', [AdminAuthController::class, 'login']);
// ================= PROFILE USER =================
Route::get('/profile/{email}', [ProfileController::class, 'getProfile']);
Route::post('/profile/update', [ProfileController::class, 'updateProfile']);
Route::post('/profile/change-password', [ProfileController::class, 'changePassword']);
// ================= DASHBOARD USER =================
Route::get('/pengaduan/terbaru', [DashboardController::class, 'pengaduanTerbaru']);
// ================= PENGADUAN USER =================
Route::post('/pengaduan', [PengaduanController::class,'store']);
Route::get('/pengaduan/detail/{id}', [PengaduanController::class,'detail']);
// ================= STATUS USER =================
Route::get('/pengaduan/status/{email}', [StatusController::class,'statusUser']);
// ================= RIWAYAT USER =================
Route::get('/pengaduan/riwayat/{email}', [RiwayatController::class,'riwayatUser']);
// ================= NOTIFIKASI USER =================
Route::get('/notifikasi/{email}', [NotifikasiController::class,'index']);
// ================= DASHBOARD ADMIN =================
Route::get('/admin/complaints', [AdminDashboardController::class,'getComplaints']);
// ================= AKSI ADMIN =================
// DIPERBAIKI: Mengubah Route::put menjadi Route::post agar support MultipartRequest (Foto)
Route::post('/admin/pengaduan/{id}/status', [ComplaintActionController::class,'updateStatus']);
// ================= NOTIFIKASI ADMIN =================
Route::get('/admin/notifikasi', [NotificationController::class,'index']);
// ================= PROFILE ADMIN =================
Route::get('/admin/profile', [AdminProfileController::class,'getProfile']);
Route::post('/admin/profile/update', [AdminProfileController::class,'updateProfile']);
Route::post('/admin/change-password', [AdminProfileController::class,'changePassword']);
// Endpoint untuk menyimpan Tindak Lanjut
Route::post('/admin/pengaduan/{id}/tindak-lanjut', [ComplaintActionController::class, 'storeTindakLanjut']);
// Endpoint untuk menyimpan Rating & Komentar dari Warga
Route::post('/pengaduan/{id}/review', [PengaduanController::class, 'storeReview']);
Route::get(
    '/pengaduan/kategori',
    [PengaduanController::class, 'categories']
);

// ================= ANALISIS AI ADMIN =================
Route::get('/admin/analisis-ai', [AnalisisAIController::class, 'index']);
Route::post('/admin/analisis-ai/generate', [AnalisisAIController::class, 'generate']);


// ================= DIAGNOSTIK STORAGE =================
Route::get('/check-image-storage', [
    PengaduanController::class,
    'checkImageStorage'
]);

// ================= TEST SUPABASE STORAGE =================
Route::post('/test-supabase-storage', function (
    \Illuminate\Http\Request $request
) {
    try {
        $content = 'TANGGAP SUPABASE CONNECTION TEST - ' . now();

        $filename = 'testing/tanggap-test-' .
            \Illuminate\Support\Str::uuid() . '.txt';

        $disk = \Illuminate\Support\Facades\Storage::disk('supabase');

        $uploaded = $disk->put($filename, $content);

        if (!$uploaded) {
            throw new \RuntimeException('Upload gagal.');
        }

        $exists = $disk->exists($filename);
        $downloaded = $disk->get($filename);

        return response()->json([
            'status' => 'success',
            'message' => 'Koneksi Supabase Storage berhasil!',
            'upload' => $uploaded,
            'file_exists' => $exists,
            'content_matches' => $downloaded === $content,
            'file_path' => $filename,
            'bucket' => config('filesystems.disks.supabase.bucket'),
        ]);

    } catch (\Throwable $e) {
        \Illuminate\Support\Facades\Log::error(
            'SUPABASE STORAGE TEST FAILED',
            [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]
        );

        return response()->json([
            'status' => 'error',
            'message' => 'Koneksi Supabase gagal.',
            'detail' => $e->getMessage(),
        ], 500);
    }
});