<?php

namespace App\Http\Controllers;

use App\Models\Relay;
use Illuminate\Http\Request;

class RelayController extends Controller
{
    /**
     * Store multiple relays at once for a kolam.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function storeBatch(Request $request)
    {
        $this->validate($request, [
            'kolam_id' => 'required|exists:kolams,id',
            'relays' => 'required|array',
            'relays.*.nama_relay' => 'required|string',
        ]);

        $kolamId = $request->input('kolam_id');
        $relaysData = $request->input('relays');

        // Optional: clear existing relays if we want this to act as a sync
        Relay::where('kolam_id', $kolamId)->delete();

        $createdRelays = [];
        foreach ($relaysData as $relayItem) {
            $createdRelays[] = Relay::create([
                'kolam_id' => $kolamId,
                'nama_relay' => $relayItem['nama_relay'],
            ]);
        }

        return response()->json([
            'message' => 'Relays saved successfully',
            'data' => $createdRelays,
        ], 201);
    }

    /**
     * Get relay statuses for a kolam.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function status(Request $request)
    {
        $pondId = $request->query('pond_id');
        if (!$pondId) {
            return response()->json(['message' => 'pond_id query parameter is required'], 400);
        }

        $relays = Relay::where('kolam_id', $pondId)->get();

        return response()->json([
            'success' => true,
            'data' => $relays->map(function ($relay) {
                return [
                    'id' => $relay->id,
                    'kolam_id' => (int) $relay->kolam_id,
                    'nama_relay' => $relay->nama_relay,
                    'status' => $relay->is_on ? 'ON' : 'OFF',
                    'is_on' => (bool) $relay->is_on,
                ];
            }),
        ]);
    }
}
