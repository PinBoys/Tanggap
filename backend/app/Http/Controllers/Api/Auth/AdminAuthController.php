<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class AdminAuthController extends Controller
{
    public function login(Request $request)
    {
        try {

            Log::info('=== ADMIN LOGIN MASUK ===');

            $request->validate([
                'email' => 'required|email',
                'password' => 'required',
            ]);

            // CEK ACCOUNT + ROLE
            $account = DB::table('accounts')

                ->join(
                    'users',
                    'accounts.id',
                    '=',
                    'users.account_id'
                )

                ->join(
                    'roles',
                    'users.role_id',
                    '=',
                    'roles.id'
                )

                ->where(
                    'accounts.email',
                    trim($request->email)
                )

                ->select(
                    'accounts.*',
                    'users.id as user_id',
                    'users.full_name',
                    'users.role_id',
                    'roles.slug as role'
                )

                ->first();

            // EMAIL TIDAK ADA
            if (!$account) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Akun tidak ditemukan'
                ], 401);
            }

            Log::info('ACCOUNT DITEMUKAN', [
                'email' => $account->email,
                'hash' => $account->password_hash,
            ]);

            // PASSWORD BELUM ADA
            if (empty($account->password_hash)) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Password akun belum tersedia'
                ], 500);
            }

            // PASSWORD SALAH
            if (!Hash::check(
                $request->password,
                $account->password_hash
            )) {

                return response()->json([
                    'status' => 'error',
                    'message' => 'Password salah'
                ], 401);
            }

            // LOGIN BERHASIL
            return response()->json([

                'status' => 'success',

                'message' => 'Login berhasil',

                'role' => $account->role,

                'account' => [

                    'id' => $account->id,

                    'user_id' => $account->user_id,

                    'role_id' => $account->role_id,

                    'email' => $account->email,

                    'full_name' => $account->full_name,

                ]

            ], 200);

        } catch (\Throwable $e) {

            Log::error('ADMIN LOGIN ERROR', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]);

            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}