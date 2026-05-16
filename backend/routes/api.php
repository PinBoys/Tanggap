<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\PengaduanController;

// Jalur yang akan dipanggil oleh Flutter
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Tambahkan baris ini untuk Lupa Password:
Route::post('/check-email', [AuthController::class, 'checkEmail']);
// Tambahkan baris ini untuk menyimpan password baru:
Route::post('/update-password', [AuthController::class, 'updatePassword']);

// Endpoint untuk Homepage
Route::get('/pengaduan/terbaru', [PengaduanController::class, 'pengaduanTerbaru']);

// Endpoint untuk Halaman Cek Status (Bisa menerima parameter misal: /pengaduan/status?status=Diproses)
Route::get('/pengaduan/status', [PengaduanController::class, 'cekStatus']);

// Tambahkan di bawah route yang sudah ada
Route::post('/pengaduan', [PengaduanController::class, 'store']);

// Route untuk halaman Cek Status Pengaduan (Semua riwayat)
Route::get('/pengaduan/status', [App\Http\Controllers\Api\PengaduanController::class, 'status']);

Route::post('/profile/update', [App\Http\Controllers\Api\ProfileController::class, 'updateProfile']);

// Route untuk mengambil data profil berdasarkan email
Route::get('/profile/{email}', [App\Http\Controllers\Api\AuthController::class, 'getProfile']);

// --- JALUR UNTUK HALAMAN AKUN ---
Route::post('/profile/update', [App\Http\Controllers\Api\AuthController::class, 'updateProfile']);
Route::post('/profile/change-password', [App\Http\Controllers\Api\AuthController::class, 'changePassword']);
Route::get('/pengaduan/riwayat/{email}', [App\Http\Controllers\Api\PengaduanController::class, 'riwayatUser']);

// Route untuk membuat pengaduan baru
Route::post('/pengaduan', [App\Http\Controllers\Api\PengaduanController::class, 'store']);

// Route untuk mengambil detail 1 pengaduan berdasarkan ID
Route::get('/pengaduan/detail/{id}', [App\Http\Controllers\Api\PengaduanController::class, 'detail']);

