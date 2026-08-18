<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Laravel\Lumen\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * The Artisan commands provided by your application.
     *
     * @var array
     */
    protected $commands = [
        \Illuminate\Console\KeyGenerateCommand::class,
        \App\Console\Commands\MqttListenerDaemon::class,
        \App\Console\Commands\MqttSubscribeCommand::class,
        \App\Console\Commands\PruneSensorLogs::class,
        \App\Console\Commands\PruneTelemetryCommand::class,
    ];

    /**
     * Define the application's command schedule.
     *
     * @param  \Illuminate\Console\Scheduling\Schedule  $schedule
     * @return void
     */
    protected function schedule(Schedule $schedule)
    {
        $schedule->command('sensors:prune')->daily();
        $schedule->command('telemetry:prune')->daily();
    }
}
