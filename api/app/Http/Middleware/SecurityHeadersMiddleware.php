<?php

namespace App\Http\Middleware;

use Closure;

class SecurityHeadersMiddleware
{
    /**
     * Handle an incoming request and inject security headers.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        $response = $next($request);

        // Prevent clickjacking attacks
        $response->header('X-Frame-Options', 'DENY');

        // Enable browser XSS protection filter (legacy browsers)
        $response->header('X-XSS-Protection', '1; mode=block');

        // Prevent MIME type sniffing
        $response->header('X-Content-Type-Options', 'nosniff');

        // Enforce HTTPS for future requests (1 year, include subdomains)
        $response->header('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');

        // Prevent referrer info from leaking
        $response->header('Referrer-Policy', 'strict-origin-when-cross-origin');

        // Control browser features (disable mic, camera, etc.)
        $response->header('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');

        // Restrict content sources to own domain only (adjust if using CDNs)
        $response->header('Content-Security-Policy',
            "default-src 'self'; " .
            "script-src 'self'; " .
            "style-src 'self' 'unsafe-inline'; " .
            "img-src 'self' data:; " .
            "font-src 'self' data:; " .
            "connect-src 'self'; " .
            "frame-ancestors 'none';"
        );

        // Hide server technology fingerprint
        $response->header('X-Powered-By', '');
        $response->headers->remove('X-Powered-By');
        $response->header('Server', 'AquiTech');

        return $response;
    }
}
