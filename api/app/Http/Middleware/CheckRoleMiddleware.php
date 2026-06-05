<?php

namespace App\Http\Middleware;

use Closure;

class CheckRoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @param  string  $role
     * @return mixed
     */
    public function handle($request, Closure $next, $role)
    {
        $user = $request->user();

        if (!$user || !isset($user->role) || $user->role->name !== $role) {
            return response()->json(['message' => 'Forbidden - You do not have the required role'], 403);
        }

        return $next($request);
    }
}
