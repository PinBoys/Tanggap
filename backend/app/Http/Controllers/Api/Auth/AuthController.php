<?php

namespace App\Http\Controllers\Api\Auth;

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
        $request->validate([
            'email' => 'required|email|unique:accounts,email',
            'password' => 'required|min:6',
            'full_name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:20'
        ]);

        try {
            return DB::transaction(function () use ($request) {
                
                $accountId = (string) Str::uuid();
                
                DB::table('accounts')->insert([
                    'id' => $accountId,
                    'email' => $request->email,
                    'password_hash' => Hash::make($request->password), 
                    'is_active' => true,
                    'created_at' => now(),
                ]);

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

        } catch (\Throwable $e) {
            // Kita paksa Laravel mengirim pesan error system aslinya ke SnackBar Flutter
            return response()->json([
                'status' => 'error',
                'detail' => 'Error Laravel: ' . $e->getMessage() . ' di baris ' . $e->getLine()
            ], 500);
        }
    }

    // --- FUNGSI LOGIN ---
    public function login(Request $request)
    {
        $account = DB::table('accounts')->where('email', $request->username)->first();

        if ($account && Hash::check($request->password, $account->password_hash)) {
            
            $userProfile = DB::table('users')->where('account_id', $account->id)->first();

            return response()->json([
                'status' => 'success',
                'data' => [
                    'id' => $account->id,
                    'email' => $account->email,
                    'full_name' => $userProfile ? $userProfile->full_name : 'Warga',
                    'foto_profil' => $userProfile ? $userProfile->foto_profil : null, // <-- TAMBAHAN AGAR FOTO MUNCUL DI DASHBOARD
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
            $request->validate([
                'email' => 'required|email',
                'password' => 'required|min:6',
            ]);

            $updated = DB::table('accounts')
                ->where('email', $request->email)
                ->update([
                    'password_hash' => Hash::make($request->password)
                ]);

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
            return response()->json([
                'status' => 'error',
                'detail' => 'Validasi: ' . $e->validator->errors()->first()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'detail' => 'Sistem Error: ' . $e->getMessage()
            ], 500);
        }
    }
}