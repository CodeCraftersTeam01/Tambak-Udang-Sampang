<?php

/** @var \Laravel\Lumen\Routing\Router $router */

$router->get('/', function () {
    return response()->json([
        'status'    => 'ok',
        'service'   => 'Aquaculture API',
        'framework' => app()->version()
    ]);
});

// Public route — strict rate limit: 5 attempts per minute (brute-force protection)
$router->group(['middleware' => 'throttle:5,1'], function () use ($router) {
    $router->post('login', 'AuthController@login');
});

// Protected routes — standard rate limit: 60 requests per minute
$router->group(['middleware' => ['auth', 'throttle:60,1']], function () use ($router) {

    // Super Admin only
    $router->group(['middleware' => 'role:super_admin'], function () use ($router) {
        $router->post('create-admin', 'AdminController@store');
    });

    // Petambak only
    $router->group(['middleware' => 'role:petambak'], function () use ($router) {
        $router->post('tambak/input-data', 'TambakController@store');
    });
});











