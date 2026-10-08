<?php

namespace App\Models;

use App\Support\CardCatalog;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Schema;

class SiteSetting extends Model
{
    protected $fillable = ['key', 'value'];

    private const CACHE_KEY = 'site_settings.all';

    public static function get(string $key, ?string $default = null): ?string
    {
        $all = self::allCached();

        return array_key_exists($key, $all) ? ($all[$key] ?? $default) : $default;
    }

    public static function set(string $key, ?string $value): void
    {
        self::query()->updateOrCreate(['key' => $key], ['value' => $value]);
        Cache::forget(self::CACHE_KEY);
    }

    /** @return array<string, string|null> */
    public static function allCached(): array
    {
        return Cache::rememberForever(self::CACHE_KEY, function () {
            try {
                if (! Schema::hasTable('site_settings')) {
                    return [];
                }

                return self::query()->pluck('value', 'key')->all();
            } catch (\Throwable) {
                return [];
            }
        });
    }

    public static function flushCache(): void
    {
        Cache::forget(self::CACHE_KEY);
    }

    /** Config exposée au mobile / API publique. */
    public static function publicConfig(): array
    {
        $base = url('/');

        return [
            'contact_email' => self::get('contact_email'),
            'contact_phone' => self::get('contact_phone'),
            'support_email' => self::get('support_email'),
            'default_locale' => self::get('default_locale', 'fr'),
            'opening_hours' => self::get('opening_hours'),
            'app_play_store_url' => self::get('app_play_store_url'),
            'app_qr_code_url' => document_public_url(self::get('app_qr_code_path')),
            'legal' => [
                'privacy' => [
                    'web_url' => self::absoluteUrl(self::get('legal_privacy_url'), $base),
                    'pdf_url' => document_public_url(self::get('legal_privacy_pdf')),
                ],
                'terms' => [
                    'web_url' => self::absoluteUrl(self::get('legal_terms_url'), $base),
                    'pdf_url' => document_public_url(self::get('legal_terms_pdf')),
                ],
                'security' => [
                    'web_url' => self::absoluteUrl(self::get('legal_security_url'), $base),
                    'pdf_url' => document_public_url(self::get('legal_security_pdf')),
                ],
            ],
            'brand_website_url' => self::get('brand_website_url'),
            'card_catalog' => CardCatalog::forPublicApi(),
        ];
    }

    private static function absoluteUrl(?string $url, string $base): ?string
    {
        if ($url === null || trim($url) === '') {
            return null;
        }
        $url = trim($url);
        if (str_starts_with($url, 'http://') || str_starts_with($url, 'https://')) {
            return $url;
        }

        return rtrim($base, '/').'/'.ltrim($url, '/');
    }
}
