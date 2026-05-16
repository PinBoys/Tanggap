<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    // --- FUNGSI REGISTER ---
    public function register(Request $request)
    {
        // 1. Validasi Input
        $request->validate([
            'email' => 'required|email|unique:accounts,email',
            'password' => 'required|min:6',
            'full_name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:20'
        ]);

        try {
            // Gunakan Transaction agar tersimpan di 2 tabel dengan aman
            return DB::transaction(function () use ($request) {
                
                $accountId = (string) Str::uuid();
                
                // 2. Simpan Langsung ke Tabel ACCOUNTS
                DB::table('accounts')->insert([
                    'id' => $accountId,
                    'email' => $request->email,
                    'password_hash' => Hash::make($request->password), // Enkripsi password
                    'is_active' => true,
                    'created_at' => now(),
                ]);

                // 3. Simpan Langsung ke Tabel USERS
                DB::table('users')->insert([
                    'id' => (string) Str::uuid(),
                    'account_id' => $accountId,
                    'full_name' => $request->full_name,
                    'phone' => $request->phone,
                    'is_verified' => false,
                    'updated_at' => now(),
                ]);

                return response()->json([
                    'status' => 'success',
                    'message' => 'Registrasi Berhasil!'
                ], 201);
            });

        // Menggunakan \Throwable agar HAPUS SEMUA jenis error terekam
        } catch (\Throwable $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Terjadi kesalahan DB: ' . $e->getMessage()
            ], 500);
        }
    }

    // --- FUNGSI LOGIN ---
    public function login(Request $request)
    {
        // Cari akun di database menggunakan DB::table
        $account = DB::table('accounts')->where('email', $request->username)->first();

        // Cek kecocokan password
        if ($account && Hash::check($request->password, $account->password_hash)) {
            
            // Ambil data nama
            $userProfile = DB::table('users')->where('account_id', $account->id)->first();

            return response()->json([
                'status' => 'success',
                'data' => [
                    'id' => $account->id,
                    'email' => $account->email,
                    'full_name' => $userProfile ? $userProfile->full_name : 'Warga',
                ]
            ]);
        }

        return response()->json([
            'status' => 'error',
            'detail' => 'Email atau Password salah'
        ], 401);
    }

    // --- FUNGSI CEK EMAIL (LUPA PASSWORD) ---
    public function checkEmail(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $account = DB::table('accounts')->where('email', $request->email)->first();

        if ($account) {
            return response()->json([
                'status' => 'success',
                'message' => 'Email ditemukan!'
            ], 200);
        }

        return response()->json([
            'status' => 'error',
            'detail' => 'Email tidak terdaftar di sistem kami.'
        ], 404);
    }
    // --- FUNGSI GANTI PASSWORD BARU ---
    public function updatePassword(Request $request)
    {
        try {
            // 1. Cek apakah input sudah benar (password wajib minimal 6 karakter)
            $request->validate([
                'email' => 'required|email',
                'password' => 'required|min:6',
            ]);

            // 2. Timpa password lama dengan yang baru di database (Menggunakan DB murni agar lebih kebal error)
            $updated = DB::table('accounts')
                ->where('email', $request->email)
                ->update([
                    'password_hash' => Hash::make($request->password)
                ]);

            // 3. Beri laporan sukses ke Flutter
            if ($updated) {
                return response()->json([
                    'status' => 'success',
                    'message' => 'Password berhasil diubah!'
                ], 200);
            }

            return response()->json([
                'status' => 'error',
                'detail' => 'Akun tidak ditemukan di database.'
            ], 404);

        } catch (\Illuminate\Validation\ValidationException $e) {
            // Jika password kurang dari 6 huruf
            return response()->json([
                'status' => 'error',
                'detail' => 'Validasi: ' . $e->validator->errors()->first()
            ], 422);
        } catch (\Exception $e) {
            // Jika ada error dari sistem atau database
            return response()->json([
                'status' => 'error',
                'detail' => 'Sistem Error: ' . $e->getMessage()
            ], 500);
        }
    }

    // --- FUNGSI AMBIL PROFIL USER ---
    public function getProfile($email)
    {
        // 1. Cari akun berdasarkan email
        $account = DB::table('accounts')->where('email', $email)->first();

        if ($account) {
            // 2. Cari data detail user (nama, hp) yang terhubung dengan akun tersebut
            $user = DB::table('users')->where('account_id', $account->id)->first();

            return response()->json([
                'status' => 'success',
                'data' => [
                    'full_name' => $user->full_name,
                    'email' => $account->email,
                    'phone' => $user->phone ?? 'Belum diatur',
                    'alamat' => 'Desa Maju Bersama', // Bisa disesuaikan dengan relasi wilayah nanti
                ]
            ], 200);
        }

        return response()->json([
            'status' => 'error',
            'detail' => 'Akun tidak ditemukan.'
        ], 404);
    }

    // --- FUNGSI UPDATE PROFIL ---
    public function updateProfile(Request $request)
    {
        $account = DB::table('accounts')->where('email', $request->email)->first();
        if ($account) {
            DB::table('users')->where('account_id', $account->id)->update([
                'full_name' => $request->full_name,
                'phone' => $request->phone
            ]);
            return response()->json(['status' => 'success', 'message' => 'Profil berhasil diperbarui']);
        }
        return response()->json(['status' => 'error', 'detail' => 'Akun tidak ditemukan'], 404);
    }

    // --- FUNGSI UBAH PASSWORD (CEK PASSWORD LAMA) ---
    public function changePassword(Request $request)
    {
        $account = DB::table('accounts')->where('email', $request->email)->first();
        
        // Cek apakah password lama yang dimasukkan cocok dengan di database
        if ($account && Hash::check($request->old_password, $account->password_hash)) {
            DB::table('accounts')->where('email', $request->email)->update([
                'password_hash' => Hash::make($request->new_password)
            ]);
            return response()->json(['status' => 'success', 'message' => 'Password berhasil diubah']);
        }
        return response()->json(['status' => 'error', 'detail' => 'Password lama salah!'], 401);
    }
}