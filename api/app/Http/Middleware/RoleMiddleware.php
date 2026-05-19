<?php

namespace App\Http\Middleware;

use Closure;

class RoleMiddleware
{
    public function handle($request, Closure $next, ...$roles)
    {
        $user = $request->user();

        // Cek apakah user sudah login dan role-nya termasuk yang diizinkan
        if (!$user || !in_array($user->role->name, $roles)) {
            return response()->json(['message' => 'Forbidden - Akses ditolak'], 403);
        }

        return $next($request);
    }
}
