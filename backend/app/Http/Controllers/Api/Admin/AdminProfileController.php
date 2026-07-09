<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AdminProfileController extends Controller
{
    /**
     * Ambil Profil Admin
     */
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
                'accounts.id as account_id',
                'users.id as user_id',
                'accounts.email',
                'users.full_name',
                'users.phone',
                'users.foto_profil'
            )

            ->first();

        if (!$admin) {
            return response()->json([
                'status' => 'error',
                'message' => 'Admin tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $admin
        ]);
    }

    /**
     * Update Profil Admin
     */
    public function updateProfile(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'full_name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:20',
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

            ->select(
                'accounts.id as account_id',
                'users.id as user_id'
            )

            ->first();

        if (!$admin) {
            return response()->json([
                'status' => 'error',
                'message' => 'Admin tidak ditemukan'
            ], 404);
        }

        DB::transaction(function () use ($request, $admin) {

            DB::table('accounts')
                ->where(
                    'id',
                    $admin->account_id
                )
                ->update([
                    'email' => $request->email
                ]);

            $updateUser = [

                'full_name' => $request->full_name,

                'phone' => $request->phone

            ];

            // Jika nanti ingin upload foto admin
            if ($request->hasFile('foto_profil')) {

                $path = $request
                    ->file('foto_profil')
                    ->store(
                        'profile_images',
                        'public'
                    );

                $updateUser['foto_profil'] =
                    '/storage/' . $path;
            }

            DB::table('users')
                ->where(
                    'id',
                    $admin->user_id
                )
                ->update($updateUser);

        });

        return response()->json([
            'status' => 'success',
            'message' => 'Profil berhasil diperbarui'
        ]);
    }

    /**
     * Ganti Password Admin
     */
    public function changePassword(Request $request)
    {
        $request->validate([
            'old_password' => 'required',
            'new_password' => 'required|min:6'
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

        if (!$admin) {

            return response()->json([
                'status' => 'error',
                'message' => 'Admin tidak ditemukan'
            ], 404);

        }

        if (
            !Hash::check(
                $request->old_password,
                $admin->password_hash
            )
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
                    Hash::make(
                        $request->new_password
                    )

            ]);

        return response()->json([

            'status' => 'success',

            'message' =>
                'Password berhasil diubah'

        ]);
    }
}