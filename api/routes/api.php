<?php

/** @var \Laravel\Lumen\Routing\Router $router */

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It is a breeze. Simply tell Lumen the URIs it should respond to
| and give it the Closure to call when that URI is requested.
|
*/

// $router->group(['prefix' => 'api', 'middleware' => ['auth', 'CheckRole:admin']], function () use ($router) {
$router->group(['prefix' => 'api'], function () use ($router) {
    $router->get('kolam', 'KolamController@index');
    $router->post('kolam', 'KolamController@store');
    $router->get('kolam/{id}', 'KolamController@show');
    $router->put('kolam/{id}', 'KolamController@update');
    // Using patch as well just in case
    $router->patch('kolam/{id}', 'KolamController@update');
    $router->delete('kolam/{id}', 'KolamController@destroy');
});
