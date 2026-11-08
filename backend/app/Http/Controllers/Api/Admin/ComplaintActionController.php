<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver;

class ComplaintActionController extends Controller
{
    /**
     * Menyimpan tindak lanjut pengaduan beserta foto bukti ke Supabase.
     */
    public function storeTindakLanjut(Request $request, $id)
    {
        $validated = $request->validate([
            'status' => 'required|string|in:PENDING,DIPROSES,SELESAI',
            'notes' => 'required|string',
            'email_admin' => 'required|email',

            // Foto bersifat opsional, maksimal 3 file.
            'foto_bukti' => 'nullable|array|max:3',
            'foto_bukti.*' => 'nullable|image|mimes:jpg,jpeg,png|max:5120',
        ]);

        $uploadedPaths = [];

        try {
            // 1. Pastikan pengaduan tersedia.
            $complaint = DB::table('complaints')
                ->where('id', $id)
                ->first();

            if (!$complaint) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Data pengaduan tidak ditemukan.',
                ], 404);
            }

            // 2. Pastikan akun admin tersedia.
            $account = DB::table('accounts')
                ->where('email', $validated['email_admin'])
                ->first();

            if (!$account) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Admin tidak valid.',
                ], 404);
            }

            // 3. Ambil file foto. Normalisasi agar satu file maupun banyak file aman.
            $files = $request->file('foto_bukti', []);

            if ($files instanceof \Illuminate\Http\UploadedFile) {
                $files = [$files];
            }

            // 4. Siapkan ID riwayat tindak lanjut.
            $actionId = (string) Str::uuid();

            DB::beginTransaction();

            // 5. Update status utama pengaduan.
            DB::table('complaints')
                ->where('id', $id)
                ->update([
                    'status' => $validated['status'],
                    'updated_at' => now(),
                ]);

            // 6. Simpan catatan tindak lanjut.
            DB::table('complaint_actions')->insert([
                'id' => $actionId,
                'complaint_id' => $id,
                'status_changed_to' => $validated['status'],
                'notes' => $validated['notes'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // 7. Upload foto ke bucket Supabase yang private.
            if (!empty($files)) {
                $manager = new ImageManager(new Driver());

                foreach ($files as $file) {
                    if (!$file || !$file->isValid()) {
                        throw new \RuntimeException('Ada file foto yang tidak valid.');
                    }

                    $image = $manager->read($file->getRealPath());

                    // Batasi lebar maksimal 1280 px tanpa memperbesar foto kecil.
                    $image->scaleDown(width: 1280);

                    $filename = Str::uuid() . '.jpg';
                    $path = 'action_images/' . $filename;

                    $imageContent = $image->toJpeg(85)->toString();

                    $saved = Storage::disk('supabase')->put(
                        $path,
                        $imageContent,
                        ['ContentType' => 'image/jpeg']
                    );

                    if (!$saved) {
                        throw new \RuntimeException(
                            'Gagal mengunggah foto tindak lanjut ke Supabase.'
                        );
                    }

                    $uploadedPaths[] = $path;

                    // Simpan path relatif, bukan URL lokal atau signed URL.
                    DB::table('action_attachments')->insert([
                        'id' => (string) Str::uuid(),
                        'action_id' => $actionId,
                        'file_url' => $path,
                        'created_at' => now(),
                    ]);

                    Log::info('FOTO TINDAK LANJUT DIUPLOAD KE SUPABASE', [
                        'action_id' => $actionId,
                        'file_path' => $path,
                    ]);
                }
            }

            DB::commit();

            return response()->json([
                'status' => 'success',
                'message' => 'Tindak lanjut dan foto berhasil disimpan.',
                'data' => [
                    'action_id' => $actionId,
                    'jumlah_foto' => count($uploadedPaths),
                    'foto' => $uploadedPaths,
                ],
            ], 200);

        } catch (\Throwable $e) {
            if (DB::transactionLevel() > 0) {
                DB::rollBack();
            }

            // Bersihkan file Supabase jika penyimpanan database gagal.
            foreach ($uploadedPaths as $path) {
                try {
                    Storage::disk('supabase')->delete($path);
                } catch (\Throwable $deleteError) {
                    Log::error('GAGAL MENGHAPUS FOTO SUPABASE SAAT ROLLBACK', [
                        'path' => $path,
                        'message' => $deleteError->getMessage(),
                    ]);
                }
            }

            Log::error('GAGAL MENYIMPAN TINDAK LANJUT', [
                'complaint_id' => $id,
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menyimpan tindak lanjut: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Endpoint upload foto pengaduan lama.
     *
     * Tetap disediakan agar route yang sudah ada tidak rusak,
     * tetapi penyimpanannya juga diarahkan ke Supabase.
     */
    public function uploadFoto(Request $request)
    {
        $request->validate([
            'bukti_pengaduan' => 'required|image|mimes:jpg,jpeg,png|max:5120',
        ]);

        try {
            $file = $request->file('bukti_pengaduan');

            $manager = new ImageManager(new Driver());
            $image = $manager->read($file->getRealPath());
            $image->scaleDown(width: 800);

            $filename = Str::uuid() . '.jpg';
            $path = 'pengaduan_images/' . $filename;

            $saved = Storage::disk('supabase')->put(
                $path,
                $image->toJpeg(85)->toString(),
                ['ContentType' => 'image/jpeg']
            );

            if (!$saved) {
                throw new \RuntimeException(
                    'Gagal mengunggah foto pengaduan ke Supabase.'
                );
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Foto berhasil diunggah.',
                'path' => $path,
            ], 200);

        } catch (\Throwable $e) {
            Log::error('GAGAL UPLOAD FOTO PENGADUAN', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Gagal mengunggah foto: ' . $e->getMessage(),
            ], 500);
        }
    }
}
