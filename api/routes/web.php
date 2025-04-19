<?php

use Illuminate\Support\Facades\Route;

Route::get('/api', function () {
    return view('welcome');
});

Route::get('/api/hello', function () {
    return "hello world";
});
