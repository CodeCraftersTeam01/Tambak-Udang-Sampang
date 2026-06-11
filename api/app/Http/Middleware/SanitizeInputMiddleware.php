<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class SanitizeInputMiddleware
{
    /**
     * Fields that should NOT be sanitized (e.g. passwords).
     */
    protected array $skipFields = ['password', 'password_confirmation', 'current_password'];

    /**
     * Handle an incoming request and sanitize all string input.
     *
     * @param  Request  $request
     * @param  Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        $input = $request->all();
        $this->sanitize($input);
        $request->merge($input);

        return $next($request);
    }

    /**
     * Recursively sanitize all string values in an array.
     */
    protected function sanitize(array &$data): void
    {
        foreach ($data as $key => &$value) {
            if (in_array($key, $this->skipFields, true)) {
                continue;
            }

            if (is_array($value)) {
                $this->sanitize($value);
            } elseif (is_string($value)) {
                // Strip HTML & PHP tags to prevent XSS
                $value = strip_tags($value);
                // Encode special characters
                $value = htmlspecialchars($value, ENT_QUOTES | ENT_HTML5, 'UTF-8');
                // Trim excess whitespace
                $value = trim($value);
                // Remove null bytes (used in Null Byte Injection attacks)
                $value = str_replace("\0", '', $value);
            }
        }
    }
}
