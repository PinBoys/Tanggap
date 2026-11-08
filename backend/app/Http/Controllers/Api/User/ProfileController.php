<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver;

class ProfileController extends Controller
{
    // ==========================================
    // FUNGSI AMBIL PROFIL USER
    // ==========================================
    public function getProfile($email)
    {
        $account = DB::table('accounts')
            ->where('email', $email)
            ->first();

        if ($account) {
            $user = DB::table('users')
                ->where('account_id', $account->id)
                ->first();

            if (!$user) {
                return response()->json([
                    'status' => 'error',
                    'detail' => 'Data pengguna tidak ditemukan.'
                ], 404);
            }

            return response()->json([
                'status' => 'success',
                'data' => [
                    'full_name' => $user->full_name,
                    'email' => $account->email,
                    'phone' => $user->phone ?? 'Belum diatur',
                    'alamat' => 'Desa Maju Bersama',
                    'foto_profil' => $user->foto_profil
                        ? str_replace('/storage/', '', $user->foto_profil)
                        : null
                ]
            ], 200);
        }

        return response()->json([
            'status' => 'error',
            'detail' => 'Akun tidak ditemukan.'
        ], 404);
    }


    // ==========================================
    // FUNGSI UPDATE PROFIL
    // ==========================================
    public function updateProfile(Request $request)
    {
        try {

            // Validasi foto profil
            $request->validate([
                'foto_profil' => 'nullable|image|mimes:jpg,jpeg,png|max:5120'
            ]);

            // Validasi email
            if (!$request->has('email') || empty($request->email)) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Email wajib dikirim dari Flutter!'
                ], 400);
            }

            // Cari akun berdasarkan email
            $account = DB::table('accounts')
                ->where('email', $request->email)
                ->first();

            if (!$account) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Akun dengan email ' . $request->email . ' tidak ditemukan'
                ], 404);
            }

            // Data yang akan diperbarui
            $updateData = [
                'full_name' => $request->full_name,
                'phone' => $request->phone,
                'updated_at' => now(),
            ];

            // ==========================================
            // UPLOAD DAN COMPRESS FOTO PROFIL
            // ==========================================
            if ($request->hasFile('foto_profil')) {

                $file = $request->file('foto_profil');

                // Ambil data user
                $user = DB::table('users')
                    ->where('account_id', $account->id)
                    ->first();

                // Hapus foto lama jika ada
                if ($user && !empty($user->foto_profil)) {

                    $oldPhoto = str_replace(
                        '/storage/',
                        '',
                        $user->foto_profil
                    );

                    if (Storage::disk('public')->exists($oldPhoto)) {
                        Storage::disk('public')->delete($oldPhoto);
                    }
                }

                // Inisialisasi Image Manager
                $manager = new ImageManager(
                    new Driver()
                );

                // Baca dan kompres gambar
                $image = $manager->read($file);

                $image->scaleDown(width: 800);

                // Buat nama file
                $filename = 'profile_' . uniqid() . '.jpg';

                // Path relatif penyimpanan
                $relativePath = 'profile_images/' . $filename;

                // Simpan foto ke Laravel public storage
                Storage::disk('public')->put(
                    $relativePath,
                    $image->toJpeg(80)->toString()
                );

                // ==========================================
                // DIAGNOSTIK PENYIMPANAN FOTO PROFIL
                // ==========================================
                Log::info('CEK PROFILE STORAGE', [
                    'file_path' => $relativePath,

                    'disk_exists' => Storage::disk('public')
                        ->exists($relativePath),

                    'disk_path' => Storage::disk('public')
                        ->path($relativePath),

                    'storage_link_exists' => file_exists(
                        public_path('storage')
                    ),

                    'storage_link_is_link' => is_link(
                        public_path('storage')
                    ),

                    'public_file_exists' => file_exists(
                        public_path('storage/' . $relativePath)
                    ),

                    'file_readable' => is_readable(
                        public_path('storage/' . $relativePath)
                    ),
                ]);

                // Simpan path foto ke database
                $updateData['foto_profil'] =
                    '/storage/' . $relativePath;
            }

            // ==========================================
            // UPDATE DATABASE
            // ==========================================
            DB::table('users')
                ->where('account_id', $account->id)
                ->update($updateData);

            return response()->json([
                'status' => 'success',
                'message' => 'Profil berhasil diperbarui'
            ], 200);

        } catch (\Throwable $e) {

            Log::error('UPDATE PROFILE ERROR', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Server Error: ' . $e->getMessage()
            ], 500);
        }
    }


    // ==========================================
    // FUNGSI UBAH PASSWORD
    // ==========================================
    public function changePassword(Request $request)
    {
        $account = DB::table('accounts')
            ->where('email', $request->email)
            ->first();

        if (
            $account &&
            Hash::check(
                $request->old_password,
                $account->password_hash
            )
        ) {

            DB::table('accounts')
                ->where('email', $request->email)
                ->update([
                    'password_hash' => Hash::make($request->new_password)
                ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Password berhasil diubah'
            ]);
        }

        return response()->json([
            'status' => 'error',
            'detail' => 'Password lama salah!'
        ], 401);
    }
}
