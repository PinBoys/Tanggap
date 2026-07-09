<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver;
use Intervention\Image\Facades\Image;

class ComplaintActionController extends Controller
{
    public function storeTindakLanjut(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|string',
            'notes' => 'required|string',
            'email_admin' => 'required|email',

            'foto_bukti.*' => 'nullable|image|mimes:jpg,jpeg,png|max:5120',
        ]);

        try {
            DB::beginTransaction();

            // 1. Cek pengaduan
            $complaint = DB::table('complaints')->where('id', $id)->first();
            if (!$complaint) return response()->json(['message' => 'Data tidak ditemukan'], 404);

            // 2. Ambil data admin (Cek jika account null agar tidak error)
            $account = DB::table('accounts')->where('email', $request->email_admin)->first();
            if (!$account) return response()->json(['message' => 'Admin tidak valid'], 404);
            
            $user = DB::table('users')->where('account_id', $account->id)->first();

            // 3. Update Status Utama
            DB::table('complaints')->where('id', $id)->update([
                'status' => $request->status, 
                'updated_at' => now()
            ]);

            // 4. Simpan ke tabel complaint_actions (Sesuai dengan skema tabel Anda yang memiliki kolom 'notes')
            $actionId = (string) Str::uuid();
            DB::table('complaint_actions')->insert([
                'id' => $actionId,
                'complaint_id' => $id,
                'status_changed_to' => $request->status,
                'notes' => $request->notes, 
                'created_at' => now(),
                'updated_at' => now()
            ]);

            // 5. Simpan Foto ke action_attachments
            if ($request->hasFile('foto_bukti')) {
                foreach ($request->file('foto_bukti') as $file) {
            $manager =
            new ImageManager(
            new Driver()
            );

            $image =
            $manager->read($file);

            $image->scaleDown(width:1280);

            $filename=
            Str::uuid().".jpg";

            Storage::disk('public')->put(

            "action_images/".$filename,

            $image
            ->toJpeg(80)
            ->toString()

            );

                    $url=
                    "/storage/action_images/".$filename;

                    DB::table('action_attachments')->insert([
                        'id' => (string) Str::uuid(),
                        'action_id' => $actionId,
                        'file_url' => $url,
                        'created_at' => now(),
                    ]);
                }
            }

            DB::commit();
            return response()->json(['status' => 'success', 'message' => 'Berhasil disimpan']);
        } catch (\Exception $e) {
            DB::rollBack();
            // Memberikan detail error agar Anda tahu bagian mana yang salah
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }
    public function uploadFoto(Request $request) {
    if ($request->hasFile('bukti_pengaduan')) {
        $file = $request->file('bukti_pengaduan');
        
        // 1. Simpan file asli ke temp
        $img = Image::make($file->getRealPath());
        
        // 2. Resize lebar ke 800px dan kompres kualitas ke 70%
        $img->resize(800, null, function ($constraint) {
            $constraint->aspectRatio();
        })->save($file->getRealPath(), 70); 

        // 3. Baru simpan ke storage
        $path = $file->store('pengaduan_images', 'public');
        return response()->json(['path' => $path]);
    }
}
}