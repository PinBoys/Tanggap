<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminProfileController extends Controller
{
    public function getProfile()
    {
        $admin = DB::table('accounts')

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
                'roles.slug',
                'admin'
            )

            ->select(
                'accounts.email',
                'users.full_name',
                'users.phone'
            )

            ->first();

        return response()->json([
            'status' => 'success',
            'data' => $admin
        ]);
    }

    public function updateProfile(
        Request $request
    )
    {
        $admin = DB::table('accounts')

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
                'roles.slug',
                'admin'
            )

            ->select(
                'accounts.id as account_id',
                'users.id as user_id'
            )

            ->first();

        DB::table('accounts')
            ->where(
                'id',
                $admin->account_id
            )
            ->update([
                'email' =>
                    $request->email
            ]);

        DB::table('users')
            ->where(
                'id',
                $admin->user_id
            )
            ->update([
                'full_name' =>
                    $request->full_name,

                'phone' =>
                    $request->phone
            ]);

        return response()->json([
            'status' => 'success',
            'message' =>
                'Profil berhasil diperbarui'
        ]);
    }

    
public function changePassword(Request $request)
{
    $request->validate([
        'old_password' => 'required',
        'new_password' => 'required'
    ]);

    $admin = DB::table('accounts')

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
            'roles.slug',
            'admin'
        )

        ->select('accounts.*')

        ->first();

    if (
        $admin->password_hash !=
        $request->old_password
    ) {

        return response()->json([
            'status' => 'error',
            'message' => 'Password lama salah'
        ], 400);
    }

    DB::table('accounts')
        ->where(
            'id',
            $admin->id
        )
        ->update([
            'password_hash' =>
                $request->new_password
        ]);

    return response()->json([
        'status' => 'success',
        'message' => 'Password berhasil diubah'
    ]);
}
}
