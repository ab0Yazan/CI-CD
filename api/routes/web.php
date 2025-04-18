<?php

use Illuminate\Support\Facades\Route;

Route::get('/api', function () {
    return view('welcome');
});
