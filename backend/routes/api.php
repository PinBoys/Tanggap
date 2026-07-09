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