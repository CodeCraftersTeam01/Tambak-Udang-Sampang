<?php

/** @var \Laravel\Lumen\Routing\Router $router */

$router->get('/', function () {
    return response()->json([
        'status' => 'ok',
        'service' => 'Aquaculture API',
        'framework' => app()->version()
    ]);
});

// Public route
$router->post('login', 'AuthController@login');

// Protected routes
$router->group(['middleware' => 'auth'], function () use ($router) {

    // Super Admin only
    $router->group(['middleware' => 'role:super_admin'], function () use ($router) {
        $router->post('create-admin', 'AdminController@store');
        $router->get('users', 'UserController@index');
    });

    // Bisa diakses oleh Super Admin ATAU Admin
    $router->group(['middleware' => 'role:super_admin,admin'], function () use ($router) {
    	$router->get('users', 'UserController@index');
    	$router->post('users', 'UserController@store');
    	$router->get('users/{id}', 'UserController@show');
    	$router->put('users/{id}', 'UserController@update');
    	$router->delete('users/{id}', 'UserController@destroy');
    });

    // Petambak only
    $router->group(['middleware' => 'role:petambak'], function () use ($router) {
        $router->post('tambak/input-data', 'TambakController@store');
    });
});