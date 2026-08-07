<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class ThresholdController extends Controller
{
    public function update(Request $request)
    {
        $this->validate($request, [
            'pond_id' => 'required|integer|exists:kolams,id',
            'sensor_type_id' => 'required|integer|exists:sensor_types,id',
            'min_value' => 'nullable|numeric',
            'max_value' => 'nullable|numeric',
        ]);

        $pondId = (int) $request->input('pond_id');
        $sensorTypeId = (int) $request->input('sensor_type_id');
        $minValue = $request->input('min_value') !== null ? (float) $request->input('min_value') : null;
        $maxValue = $request->input('max_value') !== null ? (float) $request->input('max_value') : null;

        // Check if a threshold config already exists
        $existing = DB::table('sensor_thresholds')
            ->where('pond_id', $pondId)
            ->where('sensor_type_id', $sensorTypeId)
            ->first();

        if ($existing) {
            DB::table('sensor_thresholds')
                ->where('id', $existing->id)
                ->update([
                    'min_value' => $minValue,
                    'max_value' => $maxValue,
                    'is_active' => 1,
                    'updated_at' => date('Y-m-d H:i:s'),
                ]);
        } else {
            DB::table('sensor_thresholds')->insert([
                'pond_id' => $pondId,
                'sensor_type_id' => $sensorTypeId,
                'min_value' => $minValue,
                'max_value' => $maxValue,
                'is_active' => 1,
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ]);
        }

        // Clear Cache key for this specific threshold config so new limits are active immediately
        Cache::forget("sensor_threshold_{$pondId}_{$sensorTypeId}");

        return response()->json([
            'success' => true,
            'message' => 'Sensor threshold updated successfully.',
            'data' => [
                'pond_id' => $pondId,
                'sensor_type_id' => $sensorTypeId,
                'min_value' => $minValue,
                'max_value' => $maxValue,
            ]
        ]);
    }
}
