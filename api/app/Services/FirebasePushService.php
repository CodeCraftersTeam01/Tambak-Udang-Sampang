<?php

namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class FirebasePushService
{
    protected $messaging;

    public function __construct()
    {
        $factory = (new Factory)->withServiceAccount(storage_path('firebase/credentials.json'));
        $this->messaging = $factory->createMessaging();
    }

    public function sendWarningNotification($title, $body)
    {
        $notification = Notification::create($title, $body);

        $message = CloudMessage::withTarget('topic', 'tambak_alerts')
            ->withNotification($notification)
            ->withData(['type' => 'alert']);

        return $this->messaging->send($message);
    }
}
