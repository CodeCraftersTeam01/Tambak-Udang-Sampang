<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Cache\RateLimiter;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class RateLimitMiddleware
{
    /**
     * @var RateLimiter
     */
    protected $limiter;

    public function __construct(RateLimiter $limiter)
    {
        $this->limiter = $limiter;
    }

    /**
     * Handle an incoming request.
     *
     * @param  Request  $request
     * @param  Closure  $next
     * @param  int  $maxAttempts   Number of requests allowed
     * @param  int  $decayMinutes  Window in minutes
     * @return mixed
     */
    public function handle($request, Closure $next, int $maxAttempts = 60, int $decayMinutes = 1)
    {
        $key = $this->resolveRequestKey($request);

        if ($this->limiter->tooManyAttempts($key, $maxAttempts)) {
            $retryAfter = $this->limiter->availableIn($key);
            return response()->json([
                'message' => 'Terlalu banyak permintaan. Coba lagi dalam ' . $retryAfter . ' detik.',
                'retry_after' => $retryAfter,
            ], 429, [
                'Retry-After'           => $retryAfter,
                'X-RateLimit-Limit'     => $maxAttempts,
                'X-RateLimit-Remaining' => 0,
            ]);
        }

        $this->limiter->hit($key, $decayMinutes * 60);

        $response = $next($request);

        $remaining = $this->limiter->remaining($key, $maxAttempts);

        return $response->withHeaders([
            'X-RateLimit-Limit'     => $maxAttempts,
            'X-RateLimit-Remaining' => $remaining,
        ]);
    }

    /**
     * Resolve a unique key for this request (IP + route).
     */
    protected function resolveRequestKey(Request $request): string
    {
        return Str::lower($request->method()) . '|' . $request->ip() . '|' . $request->path();
    }
}
