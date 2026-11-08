<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/debug-storage', function () {
    $path = 'pengaduan_images/b5738d50-0289-4df6-8abf-afdade4b489e.jpg';

    return response()->json([
        'storage_link_exists' => file_exists(public_path('storage')),
        'storage_link_is_link' => is_link(public_path('storage')),
        'storage_link_target' => readlink(public_path('storage')),
        'file_exists_in_disk' => Storage::disk('public')->exists($path),
        'file_exists_public' => file_exists(public_path('storage/' . $path)),
        'file_readable' => is_readable(public_path('storage/' . $path)),
        'file_path' => public_path('storage/' . $path),
    ]);
});
