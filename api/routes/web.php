<?php

/** @var \Laravel\Lumen\Routing\Router $router */

$router->get('/', function () {
    return response()->json([
        'status'    => 'ok',
        'service'   => 'Aquaculture API',
        'framework' => app()->version()
    ]);
});
