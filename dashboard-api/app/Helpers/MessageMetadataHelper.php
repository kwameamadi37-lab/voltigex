<?php

namespace App\Helpers;

class MessageMetadataHelper
{
    /**
     * Métadonnées JSON : toujours un objet {} côté client (évite [] qui casse le parse Flutter).
     *
     * @return array<string, mixed>|\stdClass
     */
    public static function forJson(mixed $meta): array|\stdClass
    {
        if (! is_array($meta) || $meta === [] || array_is_list($meta)) {
            return new \stdClass();
        }

        return $meta;
    }

    public static function clientId(mixed $meta): ?string
    {
        if (! is_array($meta) || array_is_list($meta)) {
            return null;
        }
        $id = $meta['client_id'] ?? null;

        return $id !== null && $id !== '' ? (string) $id : null;
    }
}
