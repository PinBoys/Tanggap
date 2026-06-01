<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminAuthController extends Controller
{
    public function login(Request $request)
    {

        $request->validate([

            'email' => 'required',
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
                'users.full_name',
                'roles.slug as role'
            )

            ->first();

        // EMAIL TIDAK ADA
        if (!$account) {

            return response()->json([

                'status' => 'error',

                'message' =>
                    'Akun tidak ditemukan'

            ], 401);

        }

        // PASSWORD SALAH
        if (
            $request->password !=
            $account->password_hash
        ) {

            return response()->json([

                'status' => 'error',

                'message' =>
                    'Password salah'

            ], 401);

        }

        // LOGIN BERHASIL
        return response()->json([

            'status' => 'success',

            'message' =>
                'Login berhasil',

            'role' =>
                $account->role,

            'account' => [

                'email' =>
                    $account->email,

                'full_name' =>
                    $account->full_name,

            ]

        ], 200);

    }
}