<?php

namespace App\Console\Commands;

class MqttListenerDaemon extends MqttSubscribeCommand
{
    protected $signature = 'mqtt:listen';
    protected $description = 'Alias command delegating execution to mqtt:subscribe';
}
