<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MonitoringController extends Controller
{
    public function latest(Request $request)
    {
        $pondId = (int) $request->query('pond_id', 1);

        $pond = DB::table('kolams')->where('id', $pondId)->first();
        if (!$pond) {
            return response()->json(['success' => false, 'message' => 'Pond not found'], 404);
        }

        // Calculate DOC if active
        $doc = null;
        if ($pond->status_siklus === 'aktif' && $pond->tanggal_tebar) {
            $now = \Carbon\Carbon::now()->startOfDay();
            $tebar = \Carbon\Carbon::parse($pond->tanggal_tebar)->startOfDay();
            $diff = $tebar->diffInDays($now, false);
            $doc = $diff < 0 ? 0 : (int) $diff;
        }

        $rows = DB::select("
            SELECT
                st.code,
                st.name,
                sr.value,
                sr.unit,
                sr.recorded_at,
                s.id AS sensor_id,
                s.sensor_code
            FROM sensors s
            JOIN sensor_types st ON st.id = s.sensor_type_id
            JOIN devices d ON d.id = s.device_id
            JOIN sensor_readings sr ON sr.sensor_id = s.id
            WHERE d.pond_id = ?
            AND sr.id = (
                SELECT sr2.id
                FROM sensor_readings sr2
                WHERE sr2.sensor_id = s.id
                ORDER BY sr2.recorded_at DESC, sr2.id DESC
                LIMIT 1
            )
            ORDER BY st.id ASC
        ", [$pondId]);

        $sensorsData = [];
        foreach ($rows as $row) {
            $minVal = null;
            $maxVal = null;

            // Load phase threshold only if cycle is active and rule matches DOC
            if ($doc !== null) {
                // Find matching rule: doc_start <= doc and (doc_end >= doc or doc_end is null)
                // Order by doc_start DESC to pick the closest phase boundary
                $threshold = DB::table('sensor_thresholds')
                    ->where('pond_id', $pondId)
                    ->where('sensor_type', $row->code)
                    ->where('doc_start', '<=', $doc)
                    ->where(function ($q) use ($doc) {
                        $q->where('doc_end', '>=', $doc)
                          ->orWhereNull('doc_end');
                    })
                    ->orderBy('doc_start', 'desc')
                    ->first();

                if ($threshold) {
                    $minVal = $threshold->min_value !== null ? (float) $threshold->min_value : null;
                    $maxVal = $threshold->max_value !== null ? (float) $threshold->max_value : null;
                }
            }

            // Fallback to sensor type defaults if no active cycle threshold is set
            if ($minVal === null && $maxVal === null) {
                $sensorType = DB::table('sensor_types')->where('code', $row->code)->first();
                if ($sensorType) {
                    $minVal = $sensorType->normal_min !== null ? (float) $sensorType->normal_min : null;
                    $maxVal = $sensorType->normal_max !== null ? (float) $sensorType->normal_max : null;
                }
            }

            $sensorsData[] = [
                'code' => $row->code,
                'name' => $row->name,
                'value' => (float) $row->value,
                'unit' => $row->unit,
                'min' => $minVal,
                'max' => $maxVal,
                'recorded_at' => $row->recorded_at,
                'sensor_id' => (int) $row->sensor_id,
                'sensor_code' => $row->sensor_code,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => [
                'pond_id' => $pondId,
                'doc' => $doc,
                'sensors' => $sensorsData,
            ],
        ]);
    }

    public function history($id)
    {
        $pondId = (int) $id;

        $rows = DB::select("
            SELECT
                st.code,
                sr.value,
                sr.recorded_at
            FROM sensor_readings sr
            JOIN sensors s ON s.id = sr.sensor_id
            JOIN sensor_types st ON st.id = s.sensor_type_id
            JOIN devices d ON d.id = s.device_id
            WHERE d.pond_id = ?
            ORDER BY sr.recorded_at DESC, sr.id DESC
            LIMIT 1000
        ", [$pondId]);

        $histories = [
            'temperature' => [],
            'ph' => [],
            'do' => [],
            'tds' => [],
        ];

        foreach ($rows as $row) {
            $code = $row->code;
            if (array_key_exists($code, $histories) && count($histories[$code]) < 150) {
                $histories[$code][] = [
                    'value' => (float) $row->value,
                    'recorded_at' => $row->recorded_at,
                ];
            }
        }

        // Reverse to chronological order (oldest to newest)
        foreach ($histories as $code => $list) {
            $histories[$code] = array_reverse($list);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'pond_id' => $pondId,
                'history' => $histories,
            ]
        ]);
    }
}
