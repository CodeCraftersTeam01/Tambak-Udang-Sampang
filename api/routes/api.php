<?php

/** @var \Laravel\Lumen\Routing\Router $router */

// ── Public Routes ──
$router->get('api/public/usia-benur', 'ProduksiController@publicUsiaBenur');

// ── Auth Routes ──
$router->group(['prefix' => 'api/auth', 'middleware' => 'throttle:5,1'], function () use ($router) {
    $router->post('login', 'AuthController@login');
    $router->post('register', 'AuthController@register');
});

// ── Semua API route dilindungi JWT + rate limiting ──
$router->group(['prefix' => 'api', 'middleware' => ['auth', 'throttle:60,1']], function () use ($router) {

    // Logout & Me
    $router->post('auth/logout', 'AuthController@logout');
    $router->get('auth/me', 'AuthController@me');

    // Kolam CRUD
    $router->get('kolam',          'KolamController@index');
    $router->post('kolam',         'KolamController@store');
    $router->get('kolam/{id}',     'KolamController@show');
    $router->put('kolam/{id}',     'KolamController@update');
    $router->patch('kolam/{id}',   'KolamController@update');
    $router->delete('kolam/{id}',  'KolamController@destroy');

    // Relay routes
    $router->post('relay',         'RelayController@storeBatch');

    // Produksi CRUD
    $router->get('produksi/log/{kolam_id}', 'ProduksiLogController@index');
    $router->post('produksi/log',    'ProduksiLogController@store');
    $router->get('produksi',         'ProduksiController@index');
    $router->post('produksi',        'ProduksiController@store');
    $router->get('produksi/{id}',    'ProduksiController@show');
    $router->put('produksi/{id}',    'ProduksiController@update');
    $router->patch('produksi/{id}',  'ProduksiController@update');
    $router->delete('produksi/{id}', 'ProduksiController@destroy');

    // Pakan CRUD + statistik
    $router->get('pakan/statistik',  'PakanController@statistik');
    $router->get('pakan',            'PakanController@index');
    $router->post('pakan',           'PakanController@store');
    $router->get('pakan/{id}',       'PakanController@show');
    $router->put('pakan/{id}',       'PakanController@update');
    $router->patch('pakan/{id}',     'PakanController@update');
    $router->delete('pakan/{id}',    'PakanController@destroy');

    // Panen CRUD + statistik
    $router->get('panen/statistik',  'PanenController@statistik');
    $router->get('panen',            'PanenController@index');
    $router->post('panen',           'PanenController@store');
    $router->get('panen/{id}',       'PanenController@show');
    $router->put('panen/{id}',       'PanenController@update');
    $router->patch('panen/{id}',     'PanenController@update');
    $router->delete('panen/{id}',    'PanenController@destroy');

    // Laporan
    $router->get('laporan/{kolam_id}', 'LaporanController@show');
});
