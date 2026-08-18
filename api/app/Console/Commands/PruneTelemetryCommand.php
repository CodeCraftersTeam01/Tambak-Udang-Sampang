<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Carbon\Carbon;

class PruneTelemetryCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'telemetry:prune';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Prune telemetry data older than 30 days to prevent database explosion';

    /**
     * Execute the console command.
     *
     * @return int
     */
    public function handle()
    {
        $cutoff = Carbon::now()->subDays(30);
        
        $query = DB::table('sensor_readings');
        
        if (Schema::hasColumn('sensor_readings', 'recorded_at')) {
            $query->where('recorded_at', '<', $cutoff);
        } else {
            $query->where('created_at', '<', $cutoff);
        }
        
        $deleted = $query->delete();

        $this->info("Successfully pruned {$deleted} old telemetry records older than {$cutoff->toDateTimeString()} from the database.");
        
        return 0;
    }
}
