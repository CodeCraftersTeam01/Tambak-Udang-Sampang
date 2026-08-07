<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PruneSensorLogs extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'sensors:prune';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Prune sensor readings older than 24 hours';

    /**
     * Execute the console command.
     *
     * @return int
     */
    public function handle()
    {
        $cutoff = Carbon::now()->subHours(24);
        
        $deleted = DB::table('sensor_readings')
            ->where('recorded_at', '<', $cutoff)
            ->delete();

        $this->info("Successfully pruned {$deleted} sensor readings older than {$cutoff->toDateTimeString()}.");
        
        return 0;
    }
}
