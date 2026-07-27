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
}
