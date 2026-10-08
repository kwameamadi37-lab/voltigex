<?php

namespace App\Support;

use App\Models\SiteSetting;

class CardCatalog
{
    public const SETTING_KEY = 'card_catalog';

    /** @return list<array<string, mixed>> */
    public static function defaults(): array
    {
        return [
            [
                'key' => 'gold',
                'label_fr' => 'Gold',
                'label_en' => 'Gold',
                'label_de' => 'Gold',
                'label_es' => 'Gold',
                'label_it' => 'Gold',
                'enabled' => true,
                'sort' => 1,
                'image_path' => '',
                'amount' => 650.00,
            ],
            [
                'key' => 'diamond',
                'label_fr' => 'Diamond',
                'label_en' => 'Diamond',
                'label_de' => 'Diamond',
                'label_es' => 'Diamond',
                'label_it' => 'Diamond',
                'enabled' => true,
                'sort' => 2,
                'image_path' => '',
                'amount' => 1500.00,
            ],
            [
                'key' => 'platinum',
                'label_fr' => 'Platinum',
                'label_en' => 'Platinum',
                'label_de' => 'Platinum',
                'label_es' => 'Platinum',
                'label_it' => 'Platinum',
                'enabled' => true,
                'sort' => 3,
                'image_path' => '',
                'amount' => 3500.00,
            ],
        ];
    }

    public static function amountForType(string $type): float
    {
        $type = strtolower(trim($type));
        foreach (self::all() as $row) {
            if (strtolower((string) $row['key']) === $type) {
                return (float) ($row['amount'] ?? 0);
            }
        }

        return 0.0;
    }

    public static function labelForType(string $type, string $locale = 'fr'): string
    {
        $type = strtolower(trim($type));
        foreach (self::all() as $row) {
            if (strtolower((string) $row['key']) !== $type) {
                continue;
            }
            $key = 'label_'.$locale;

            return (string) ($row[$key] ?? $row['label_fr'] ?? $row['key']);
        }

        return $type !== '' ? ucfirst($type) : '—';
    }

    /** @return list<array<string, mixed>> */
    public static function all(): array
    {
        $raw = SiteSetting::get(self::SETTING_KEY);
        if ($raw === null || trim($raw) === '') {
            return self::defaults();
        }

        $decoded = json_decode($raw, true);
        if (! is_array($decoded)) {
            return self::defaults();
        }

        return self::mergeWithDefaults($decoded);
    }

    /** @param list<array<string, mixed>> $stored */
    private static function mergeWithDefaults(array $stored): array
    {
        $byKey = [];
        foreach ($stored as $row) {
            if (! is_array($row) || empty($row['key'])) {
                continue;
            }
            $byKey[strtolower((string) $row['key'])] = $row;
        }

        $out = [];
        foreach (self::defaults() as $default) {
            $key = $default['key'];
            $row = array_merge($default, $byKey[$key] ?? []);
            $row['key'] = $key;
            $row['enabled'] = filter_var($row['enabled'] ?? true, FILTER_VALIDATE_BOOLEAN);
            $row['sort'] = (int) ($row['sort'] ?? $default['sort']);
            $row['image_path'] = (string) ($row['image_path'] ?? '');
            $row['amount'] = round((float) ($row['amount'] ?? $default['amount'] ?? 0), 2);
            $out[] = $row;
        }

        usort($out, fn ($a, $b) => ($a['sort'] <=> $b['sort']));

        return $out;
    }

    /** @return list<array<string, mixed>> */
    public static function enabled(): array
    {
        return array_values(array_filter(self::all(), fn ($row) => ! empty($row['enabled'])));
    }

    public static function isValidType(string $type): bool
    {
        $type = strtolower(trim($type));
        foreach (self::enabled() as $row) {
            if (strtolower((string) $row['key']) === $type) {
                return true;
            }
        }

        return false;
    }

    /** @return list<string> */
    public static function enabledKeys(): array
    {
        return array_map(fn ($row) => (string) $row['key'], self::enabled());
    }

    /** Liste pour règle `in:` (toujours non vide). */
    public static function validationInList(): string
    {
        $keys = self::enabledKeys();
        if ($keys === []) {
            return 'gold,diamond,platinum';
        }

        return implode(',', $keys);
    }

    /** Payload pour l’API publique / mobile. */
    public static function forPublicApi(): array
    {
        $items = [];
        foreach (self::enabled() as $row) {
            $imagePath = trim((string) ($row['image_path'] ?? ''));
            $items[] = [
                'key' => (string) $row['key'],
                'labels' => [
                    'fr' => (string) ($row['label_fr'] ?? $row['key']),
                    'en' => (string) ($row['label_en'] ?? $row['label_fr'] ?? $row['key']),
                    'de' => (string) ($row['label_de'] ?? $row['label_fr'] ?? $row['key']),
                    'es' => (string) ($row['label_es'] ?? $row['label_fr'] ?? $row['key']),
                    'it' => (string) ($row['label_it'] ?? $row['label_fr'] ?? $row['key']),
                ],
                'image_url' => $imagePath !== '' ? document_public_url($imagePath) : null,
                'sort' => (int) ($row['sort'] ?? 0),
                'amount' => round((float) ($row['amount'] ?? 0), 2),
            ];
        }

        return $items;
    }

    /** @param array<string, mixed> $input */
    public static function persistFromAdminInput(array $input): void
    {
        $catalog = self::all();
        foreach ($catalog as $i => $row) {
            $key = $row['key'];
            $prefix = 'card_'.$key.'_';
            if (array_key_exists($prefix.'label_fr', $input)) {
                $catalog[$i]['label_fr'] = (string) $input[$prefix.'label_fr'];
            }
            if (array_key_exists($prefix.'label_en', $input)) {
                $catalog[$i]['label_en'] = (string) $input[$prefix.'label_en'];
            }
            if (array_key_exists($prefix.'label_de', $input)) {
                $catalog[$i]['label_de'] = (string) $input[$prefix.'label_de'];
            }
            if (array_key_exists($prefix.'amount', $input)) {
                $catalog[$i]['amount'] = round((float) str_replace(',', '.', (string) $input[$prefix.'amount']), 2);
            }
            $catalog[$i]['enabled'] = ! empty($input[$prefix.'enabled']);
        }

        SiteSetting::set(self::SETTING_KEY, json_encode($catalog, JSON_UNESCAPED_UNICODE));
    }

    public static function updateImagePath(string $key, string $path): void
    {
        $catalog = self::all();
        foreach ($catalog as $i => $row) {
            if ($row['key'] === $key) {
                $catalog[$i]['image_path'] = $path;
                break;
            }
        }
        SiteSetting::set(self::SETTING_KEY, json_encode($catalog, JSON_UNESCAPED_UNICODE));
    }
}
