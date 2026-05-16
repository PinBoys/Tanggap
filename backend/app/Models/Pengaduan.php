<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pengaduan extends Model
{
    use HasFactory;

    // 1. Tentukan nama tabel yang benar (bahasa Inggris)
    protected $table = 'complaints';

    // 2. Primary Key di tabel kamu adalah 'id'
    protected $primaryKey = 'id';

    // 3. WAJIB DITAMBAHKAN KARENA PAKAI UUID (Bukan angka urut)
    public $incrementing = false;
    protected $keyType = 'string';

    // 4. Izinkan semua kolom diisi (Mass Assignment)
    protected $guarded = [];

    /**
     * Relasi ke Bukti Pengaduan (Tabel attachments)
     */
    public function bukti_pengaduan()
    {
        // Sesuaikan dengan foreign key di database: 'complaint_id'
        return $this->hasMany(BuktiPengaduan::class, 'complaint_id', 'id');
    }

    /**
     * Catatan: Relasi wilayah dimatikan sementara karena di struktur tabel 'complaints' 
     * milikmu tidak ada kolom 'id_wilayah', melainkan langsung titik koordinat (location GEOGRAPHY).
     */
    // public function wilayah()
    // {
    //     return $this->belongsTo(Wilayah::class, 'id_wilayah', 'id_wilayah');
    // }
}