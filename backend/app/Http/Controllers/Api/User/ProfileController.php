<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver;

class ProfileController extends Controller
{
    // --- FUNGSI AMBIL PROFIL USER (UNTUK HALAMAN AKUN) ---
    public function getProfile($email)
    {
        $account = DB::table('accounts')->where('email', $email)->first();

        if ($account) {
            $user = DB::table('users')->where('account_id', $account->id)->first();

            return response()->json([
                'status' => 'success',
                'data' => [
                    'full_name' => $user->full_name,
                    'email' => $account->email,
                    'phone' => $user->phone ?? 'Belum diatur',
                    'alamat' => 'Desa Maju Bersama', 
                    'foto_profil' => $user->foto_profil ? str_replace('/storage/', '', $user->foto_profil) : null
                ]
            ], 200);
        }

        return response()->json([
            'status' => 'error',
            'detail' => 'Akun tidak ditemukan.'
        ], 404);
    }

    // --- FUNGSI UPDATE PROFIL (HANYA SATU FUNGSI INI SAJA) ---
    public function updateProfile(Request $request)
    {
        try {

              $request->validate([

                'foto_profil' =>
                    'nullable|image|mimes:jpg,jpeg,png|max:5120'

            ]);
            // Validasi input wajib
            if (!$request->has('email') || empty($request->email)) {
                return response()->json(['status' => 'error', 'message' => 'Email wajib dikirim dari Flutter!'], 400);
            }

            // Cari Akun berdasarkan email
            $account = DB::table('accounts')->where('email', $request->email)->first();

            if (!$account) {
                return response()->json(['status' => 'error', 'message' => 'Akun dengan email ' . $request->email . ' tidak ditemukan'], 404);
            }
            $updateData = [
                'full_name' => $request->full_name,
                'phone' => $request->phone,
                'updated_at' => now(),
            ];

            // ===============================
            // UPLOAD + COMPRESS FOTO PROFIL
            // ===============================
            if ($request->hasFile('foto_profil')) {

                $file = $request->file('foto_profil');

                // Hapus foto lama jika ada
                $user = DB::table('users')
                    ->where('account_id', $account->id)
                    ->first();

                if (
                    $user &&
                    !empty($user->foto_profil)
                ) {

                    $oldPhoto = str_replace(
                        '/storage/',
                        '',
                        $user->foto_profil
                    );

                    if (Storage::disk('public')->exists($oldPhoto)) {
                        Storage::disk('public')->delete($oldPhoto);
                    }
                }

                // Compress gambar
                $manager = new ImageManager(
                    new Driver()
                );

                $image = $manager->read($file);

                $image->scaleDown(width: 800);

                $filename =
                    "profile_" .
                    uniqid() .
                    ".jpg";

                Storage::disk('public')->put(

                    "profile_images/" . $filename,

                    $image->toJpeg(80)->toString()

                );

                $updateData['foto_profil'] =
                    "/storage/profile_images/" .
                    $filename;
            }

            // Lakukan Update ke database
            DB::table('users')->where('account_id', $account->id)->update($updateData);

            return response()->json([
                'status' => 'success',
                'message' => 'Profil berhasil diperbarui'
            ], 200);

        } catch (\Throwable $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Server Error: ' . $e->getMessage()
            ], 500);
        }
    }

    // --- FUNGSI UBAH PASSWORD (CEK PASSWORD LAMA) ---
    public function changePassword(Request $request)
    {
        $account = DB::table('accounts')->where('email', $request->email)->first();
        
        if ($account && Hash::check($request->old_password, $account->password_hash)) {
            DB::table('accounts')->where('email', $request->email)->update([
                'password_hash' => Hash::make($request->new_password)
            ]);
            return response()->json(['status' => 'success', 'message' => 'Password berhasil diubah']);
        }
        return response()->json(['status' => 'error', 'detail' => 'Password lama salah!'], 401);
    }
}