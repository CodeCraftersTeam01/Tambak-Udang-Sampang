<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use PhpMqtt\Client\MqttClient;
use PhpMqtt\Client\ConnectionSettings;
use App\Services\FirebasePushService;
use Illuminate\Support\Facades\Cache;

class MqttListenerDaemon extends Command
{
    protected $signature = 'mqtt:listen';
    protected $description = 'Listen to MQTT broker and trigger Firebase Push Notifications';

    public function handle(FirebasePushService $pushService)
    {
        $server   = 'm-tech.fun';
        $port     = 1883;
        $clientId = 'laravel-daemon-' . uniqid();

        $connectionSettings = (new ConnectionSettings)
            ->setUsername('mhs1')
            ->setPassword('mhs123');

        $mqtt = new MqttClient($server, $port, $clientId);

        $this->info("Connecting to MQTT at {$server}:{$port}...");

        $mqtt->connect($connectionSettings, true);

        $topic = 'pkm2026/t01/#';
        
        $this->info("Subscribed to {$topic}");

        $mqtt->subscribe($topic, function ($topic, $message) use ($pushService) {
            $this->info("Received message on topic [{$topic}]: {$message}");
            
            $value = (float) $message;

            if (str_ends_with($topic, '/suhu') && $value > 35) {
                $this->triggerWarning('suhu', $value, $pushService);
            }

            if (str_ends_with($topic, '/ph') && $value < 7.5) {
                $this->triggerWarning('ph', $value, $pushService);
            }
        }, 0);

        $mqtt->loop(true);
    }

    protected function triggerWarning($parameter, $value, FirebasePushService $pushService)
    {
        $cacheKey = "mqtt_alert_sent_{$parameter}";
        
        // Throttling: only send once every 10 minutes
        if (!Cache::has($cacheKey)) {
            $title = ($parameter == 'suhu') ? 'BAHAYA: Suhu Kolam Kritis' : 'BAHAYA: pH Kolam Kritis';
            $unit = ($parameter == 'suhu') ? '°C' : '';
            $body = ucfirst($parameter) . " saat ini: {$value}{$unit}";
            
            try {
                $pushService->sendWarningNotification($title, $body);
                $this->info("Push Notification sent: {$title}");
                // Store in cache for 10 mins
                Cache::put($cacheKey, true, 60 * 10);
            } catch (\Exception $e) {
                $this->error("Failed to send Push Notification: " . $e->getMessage());
            }
        }
    }
}
