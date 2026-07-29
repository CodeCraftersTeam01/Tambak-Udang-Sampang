<?php

/** @var \Laravel\Lumen\Routing\Router $router */

// ==========================================
// ── LECTURER SPECIFICATION ROOT ROUTES ──
// ==========================================

// Public Root Routes
$router->group(['middleware' => 'throttle:5,1'], function () use ($router) {
    $router->post('login', 'AuthController@login');
});

// Protected Root Routes (JWT Auth + Rate Limiting)
$router->group(['middleware' => ['auth', 'throttle:60,1']], function () use ($router) {
    $router->get('ponds', 'KolamController@index');
    $router->get('monitoring/latest', 'MonitoringController@latest');
    $router->get('devices', 'DeviceController@index');
    $router->get('farm-management/summary', 'KolamController@farmSummary');
    $router->get('production-management/summary', 'ProduksiController@productionSummary');
    $router->get('production-cycles', 'ProduksiController@index');
    $router->get('production-cycles/{id}', 'ProduksiController@show');
});


// ==========================================
// ── LEGACY & PREFIXED /API ROUTES ──
// ==========================================

// Public Legacy Routes
$router->get('api/public/usia-benur', 'ProduksiController@publicUsiaBenur');

// Auth Legacy Routes
$router->group(['prefix' => 'api/auth', 'middleware' => 'throttle:5,1'], function () use ($router) {
    $router->post('login', 'AuthController@login');
    $router->post('register', 'AuthController@register');
});

// Protected Prefix API Routes (JWT Auth + Rate Limiting)
$router->group(['prefix' => 'api', 'middleware' => ['auth', 'throttle:60,1']], function () use ($router) {

    // Logout & Me
    $router->post('auth/logout', 'AuthController@logout');
    $router->get('auth/me', 'AuthController@me');

    // Kolam (Pond) CRUD
    $router->get('kolam',          'KolamController@index');
    $router->post('kolam',         'KolamController@store');
    $router->get('kolam/{id}',     'KolamController@show');
    $router->put('kolam/{id}',     'KolamController@update');
    $router->patch('kolam/{id}',   'KolamController@update');
    $router->delete('kolam/{id}',  'KolamController@destroy');

    // Mapped English Ponds CRUD (For spec compatibility under /api)
    $router->get('ponds',          'KolamController@index');
    $router->post('ponds',         'KolamController@store');
    $router->get('ponds/{id}',     'KolamController@show');
    $router->put('ponds/{id}',     'KolamController@update');
    $router->delete('ponds/{id}',  'KolamController@destroy');

    // Relay routes
    $router->post('relay',         'RelayController@storeBatch');

    // Produksi (Production Cycle) CRUD
    $router->get('produksi/log/{kolam_id}', 'ProduksiLogController@index');
    $router->post('produksi/log',    'ProduksiLogController@store');
    $router->get('produksi',         'ProduksiController@index');
    $router->post('produksi',        'ProduksiController@store');
    $router->get('produksi/{id}',    'ProduksiController@show');
    $router->put('produksi/{id}',    'ProduksiController@update');
    $router->patch('produksi/{id}',  'ProduksiController@update');
    $router->delete('produksi/{id}', 'ProduksiController@destroy');

    // Mapped English Production Cycles (For spec compatibility under /api)
    $router->get('production-management/summary', 'ProduksiController@productionSummary');
    $router->get('production-cycles',             'ProduksiController@index');
    $router->get('production-cycles/{id}',         'ProduksiController@show');

    // Pakan CRUD
    $router->get('pakan/statistik',  'PakanController@statistik');
    $router->get('pakan',            'PakanController@index');
    $router->post('pakan',           'PakanController@store');
    $router->get('pakan/{id}',       'PakanController@show');
    $router->put('pakan/{id}',       'PakanController@update');
    $router->patch('pakan/{id}',     'PakanController@update');
    $router->delete('pakan/{id}',    'PakanController@destroy');

    // Panen CRUD
    $router->get('panen/statistik',  'PanenController@statistik');
    $router->get('panen',            'PanenController@index');
    $router->post('panen',           'PanenController@store');
    $router->get('panen/{id}',       'PanenController@show');
    $router->put('panen/{id}',       'PanenController@update');
    $router->patch('panen/{id}',     'PanenController@update');
    $router->delete('panen/{id}',    'PanenController@destroy');

    // Laporan
    $router->get('laporan/{kolam_id}', 'LaporanController@show');
<<<<<<< Updated upstream
=======

    // Devices & Calibration
    $router->get('devices',                  'DeviceController@index');
    $router->get('devices/{id}',             'DeviceController@show');
    $router->get('devices/{id}/sensors',     'DeviceController@sensors');
    $router->get('devices/{id}/calibration', 'DeviceController@calibration');
    $router->put('devices/{id}/calibration', 'DeviceController@updateCalibration');

    // Monitoring
    $router->get('monitoring/latest', 'MonitoringController@latest');

    // Farm Management summary under /api
    $router->get('farm-management/summary', 'KolamController@farmSummary');

    // User CRUD
    $router->group(['middleware' => 'role:super_admin,admin'], function () use ($router) {
        $router->get('users', 'UserController@index');
        $router->post('users', 'UserController@store');
        $router->get('users/{id}', 'UserController@show');
        $router->put('users/{id}', 'UserController@update');
        $router->delete('users/{id}', 'UserController@destroy');
    });
>>>>>>> Stashed changes
});
