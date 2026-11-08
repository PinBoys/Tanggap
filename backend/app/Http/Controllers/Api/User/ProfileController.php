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
    // MEMBUAT SIGNED URL FOTO SUPABASE
    // ==========================================
    private function getPhotoUrl($path)
    {
        if (empty($path)) {
            return null;
        }

        // Menangani path foto dari sistem lama.
        $path = str_replace('/storage/', '', $path);

        try {
            $disk = Storage::disk('supabase');

            if (!$disk->exists($path)) {
                return null;
            }

            // URL berlaku selama 60 menit.
            return $disk->temporaryUrl(
                $path,
                now()->addMinutes(60)
            );

        } catch (\Throwable $e) {
            Log::error('GENERATE PROFILE PHOTO URL ERROR', [
                'path' => $path,
                'message' => $e->getMessage()
            ]);

            return null;
        }
    }

    // ==========================================
    // FUNGSI AMBIL PROFIL USER
    // ==========================================
    public function getProfile($email)
    {
        $account = DB::table('accounts')
            ->where('email', $email)
            ->first();

        if (!$account) {
            return response()->json([
                'status' => 'error',
                'detail' => 'Akun tidak ditemukan.'
            ], 404);
        }

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

                // URL sementara dari Supabase.
                'foto_profil' => $this->getPhotoUrl(
                    $user->foto_profil
                )
            ]
        ], 200);
    }

    // ==========================================
    // FUNGSI UPDATE PROFIL
    // ==========================================
    public function updateProfile(Request $request)
    {
        try {
            // Validasi foto profil.
            $request->validate([
                'foto_profil' => 'nullable|image|mimes:jpg,jpeg,png|max:5120'
            ]);

            // Validasi email.
            if (!$request->filled('email')) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Email wajib dikirim dari Flutter!'
                ], 400);
            }

            // Cari akun berdasarkan email.
            $account = DB::table('accounts')
                ->where('email', $request->email)
                ->first();

            if (!$account) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Akun tidak ditemukan.'
                ], 404);
            }

            // Ambil data user.
            $user = DB::table('users')
                ->where('account_id', $account->id)
                ->first();

            if (!$user) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Data pengguna tidak ditemukan.'
                ], 404);
            }

            // Data yang akan diperbarui.
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

                // Inisialisasi Image Manager.
                $manager = new ImageManager(new Driver());

                // Baca dan kompres gambar.
                $image = $manager->read($file);

                $image->scaleDown(width: 800);

                // Buat nama file unik.
                $filename = 'profile_' .
                    \Illuminate\Support\Str::uuid() . '.jpg';

                // Path relatif di Supabase.
                $relativePath = 'profile_images/' . $filename;

                // Konversi gambar menjadi JPEG.
                $imageContent = (string) $image->toJpeg(80);

                // Simpan foto ke Supabase Storage.
                $disk = Storage::disk('supabase');

                $saved = $disk->put(
                    $relativePath,
                    $imageContent,
                    [
                        'ContentType' => 'image/jpeg'
                    ]
                );

                if (!$saved || !$disk->exists($relativePath)) {
                    throw new \RuntimeException(
                        'Gagal menyimpan foto profil ke Supabase Storage.'
                    );
                }

                // Simpan path relatif ke database.
                $updateData['foto_profil'] = $relativePath;

                Log::info('PROFILE PHOTO UPLOADED TO SUPABASE', [
                    'account_id' => $account->id,
                    'file_path' => $relativePath,
                    'file_exists' => true
                ]);

                // ==========================================
                // HAPUS FOTO LAMA DARI SUPABASE
                // ==========================================
                if (!empty($user->foto_profil)) {

                    $oldPhoto = str_replace(
                        '/storage/',
                        '',
                        $user->foto_profil
                    );

                    // Jangan menghapus file baru.
                    if (
                        $oldPhoto !== $relativePath &&
                        $disk->exists($oldPhoto)
                    ) {
                        $disk->delete($oldPhoto);
                    }
                }
            }

            // ==========================================
            // UPDATE DATABASE
            // ==========================================
            DB::table('users')
                ->where('account_id', $account->id)
                ->update($updateData);

            // Ambil kembali data terbaru.
            $updatedUser = DB::table('users')
                ->where('account_id', $account->id)
                ->first();

            return response()->json([
                'status' => 'success',
                'message' => 'Profil berhasil diperbarui',
                'data' => [
                    'full_name' => $updatedUser->full_name,
                    'email' => $account->email,
                    'phone' => $updatedUser->phone ?? 'Belum diatur',
                    'foto_profil' => $this->getPhotoUrl(
                        $updatedUser->foto_profil
                    )
                ]
            ], 200);

        } catch (\Throwable $e) {

            Log::error('UPDATE PROFILE ERROR', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Gagal memperbarui profil.'
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
                    'password_hash' => Hash::make(
                        $request->new_password
                    )
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
