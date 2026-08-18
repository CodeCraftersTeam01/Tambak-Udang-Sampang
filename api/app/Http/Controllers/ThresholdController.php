<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class ThresholdController extends Controller
{
    /**
     * Display a listing of thresholds for a pond.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $pondId = $request->query('pond_id');
        if (!$pondId) {
            return response()->json(['message' => 'pond_id query parameter is required'], 400);
        }

        $thresholds = DB::table('sensor_thresholds')
            ->where('pond_id', $pondId)
            ->orderBy('sensor_type')
            ->orderBy('doc_start')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $thresholds
        ]);
    }

    /**
     * Store a newly created threshold.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $this->validate($request, [
            'pond_id' => 'required|integer|exists:kolams,id',
            'sensor_type' => 'required|string|in:ph,do,temperature,tds,water_level',
            'doc_start' => 'required|integer|min:0',
            'doc_end' => 'nullable|integer|gte:doc_start',
            'min_value' => 'nullable|numeric',
            'max_value' => 'nullable|numeric',
        ]);

        $pondId = (int) $request->input('pond_id');
        $sensorType = $request->input('sensor_type');
        $docStart = (int) $request->input('doc_start');
        $docEnd = $request->input('doc_end') !== null ? (int) $request->input('doc_end') : null;
        $minValue = $request->input('min_value') !== null ? (float) $request->input('min_value') : null;
        $maxValue = $request->input('max_value') !== null ? (float) $request->input('max_value') : null;

        // Check overlapping phases for the same pond and sensor type
        // Rules: overlap if docStart lies in existing range, OR docEnd lies in existing range, OR existing range lies inside new range
        // If existing has doc_end NULL, it goes to infinity!
        $existingRules = DB::table('sensor_thresholds')
            ->where('pond_id', $pondId)
            ->where('sensor_type', $sensorType)
            ->get();

        foreach ($existingRules as $rule) {
            $eStart = (int) $rule->doc_start;
            $eEnd = $rule->doc_end !== null ? (int) $rule->doc_end : null;

            $overlap = false;
            // Case 1: new range overlaps existing finite range
            if ($eEnd !== null) {
                if ($docEnd !== null) {
                    // Both finite: standard overlap check
                    if (($docStart >= $eStart && $docStart <= $eEnd) || 
                        ($docEnd >= $eStart && $docEnd <= $eEnd) ||
                        ($eStart >= $docStart && $eStart <= $docEnd)) {
                        $overlap = true;
                    }
                } else {
                    // New range is infinite: overlaps if new start is <= existing end
                    if ($docStart <= $eEnd) {
                        $overlap = true;
                    }
                }
            } else {
                // Existing range is infinite: overlaps if new end is null or new end >= existing start
                if ($docEnd === null || $docEnd >= $eStart) {
                    $overlap = true;
                }
            }

            if ($overlap) {
                $rangeStr = $eEnd !== null ? "DOC {$eStart} - {$eEnd}" : "DOC {$eStart} - Infinity";
                return response()->json([
                    'success' => false,
                    'message' => "Fase DOC tumpang tindih dengan aturan yang ada ({$rangeStr})."
                ], 422);
            }
        }

        $id = DB::table('sensor_thresholds')->insertGetId([
            'pond_id' => $pondId,
            'sensor_type' => $sensorType,
            'doc_start' => $docStart,
            'doc_end' => $docEnd,
            'min_value' => $minValue,
            'max_value' => $maxValue,
            'created_at' => date('Y-m-d H:i:s'),
            'updated_at' => date('Y-m-d H:i:s'),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Sensor threshold created successfully.',
            'data' => [
                'id' => $id,
                'pond_id' => $pondId,
                'sensor_type' => $sensorType,
                'doc_start' => $docStart,
                'doc_end' => $docEnd,
                'min_value' => $minValue,
                'max_value' => $maxValue,
            ]
        ], 201);
    }

    /**
     * Update the specified threshold.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $this->validate($request, [
            'doc_start' => 'required|integer|min:0',
            'doc_end' => 'nullable|integer|gte:doc_start',
            'min_value' => 'nullable|numeric',
            'max_value' => 'nullable|numeric',
        ]);

        $threshold = DB::table('sensor_thresholds')->where('id', $id)->first();
        if (!$threshold) {
            return response()->json(['success' => false, 'message' => 'Threshold not found'], 404);
        }

        $docStart = (int) $request->input('doc_start');
        $docEnd = $request->input('doc_end') !== null ? (int) $request->input('doc_end') : null;
        $minValue = $request->input('min_value') !== null ? (float) $request->input('min_value') : null;
        $maxValue = $request->input('max_value') !== null ? (float) $request->input('max_value') : null;

        // Check overlapping phases excluding self
        $existingRules = DB::table('sensor_thresholds')
            ->where('pond_id', $threshold->pond_id)
            ->where('sensor_type', $threshold->sensor_type)
            ->where('id', '<>', $id)
            ->get();

        foreach ($existingRules as $rule) {
            $eStart = (int) $rule->doc_start;
            $eEnd = $rule->doc_end !== null ? (int) $rule->doc_end : null;

            $overlap = false;
            if ($eEnd !== null) {
                if ($docEnd !== null) {
                    if (($docStart >= $eStart && $docStart <= $eEnd) || 
                        ($docEnd >= $eStart && $docEnd <= $eEnd) ||
                        ($eStart >= $docStart && $eStart <= $docEnd)) {
                        $overlap = true;
                    }
                } else {
                    if ($docStart <= $eEnd) {
                        $overlap = true;
                    }
                }
            } else {
                if ($docEnd === null || $docEnd >= $eStart) {
                    $overlap = true;
                }
            }

            if ($overlap) {
                $rangeStr = $eEnd !== null ? "DOC {$eStart} - {$eEnd}" : "DOC {$eStart} - Infinity";
                return response()->json([
                    'success' => false,
                    'message' => "Fase DOC tumpang tindih dengan aturan yang ada ({$rangeStr})."
                ], 422);
            }
        }

        DB::table('sensor_thresholds')
            ->where('id', $id)
            ->update([
                'doc_start' => $docStart,
                'doc_end' => $docEnd,
                'min_value' => $minValue,
                'max_value' => $maxValue,
                'updated_at' => date('Y-m-d H:i:s'),
            ]);

        return response()->json([
            'success' => true,
            'message' => 'Sensor threshold updated successfully.',
            'data' => [
                'id' => $id,
                'pond_id' => $threshold->pond_id,
                'sensor_type' => $threshold->sensor_type,
                'doc_start' => $docStart,
                'doc_end' => $docEnd,
                'min_value' => $minValue,
                'max_value' => $maxValue,
            ]
        ]);
    }

    /**
     * Remove the specified threshold.
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        $threshold = DB::table('sensor_thresholds')->where('id', $id)->first();
        if (!$threshold) {
            return response()->json(['success' => false, 'message' => 'Threshold not found'], 404);
        }

        DB::table('sensor_thresholds')->where('id', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Sensor threshold deleted successfully.'
        ]);
    }
}
