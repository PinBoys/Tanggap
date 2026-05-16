<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BuktiPengaduan extends Model
{
    protected $table = 'attachments'; // Nama tabel yang benar di database
    protected $primaryKey = 'id';
    public $incrementing = false;
    protected $keyType = 'string';
    protected $guarded = [];
}