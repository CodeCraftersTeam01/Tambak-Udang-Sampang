<?php

namespace App\Http\Controllers;

use App\Models\Kolam;
use App\Http\Requests\StoreKolamRequest;
use App\Http\Requests\UpdateKolamRequest;
use App\Http\Resources\KolamResource;
use Illuminate\Http\Request;

class KolamController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $kolams = Kolam::with('relays')->get();
        return response()->json([
            'message' => 'Success',
            'data' => KolamResource::collection($kolams)
        ], 200);
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $rules = (new StoreKolamRequest())->rules();
        $this->validate($request, $rules);

        $kolam = Kolam::create($request->all());

        return response()->json([
            'message' => 'Kolam created successfully',
            'data' => new KolamResource($kolam)
        ], 201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        $kolam = Kolam::with('relays')->find($id);

        if (!$kolam) {
            return response()->json(['message' => 'Kolam not found'], 404);
        }

        return response()->json([
            'message' => 'Success',
            'data' => new KolamResource($kolam)
        ], 200);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $kolam = Kolam::find($id);

        if (!$kolam) {
            return response()->json(['message' => 'Kolam not found'], 404);
        }

        $rules = (new UpdateKolamRequest())->rules($id);
        $this->validate($request, $rules);

        $kolam->update($request->all());

        return response()->json([
            'message' => 'Kolam updated successfully',
            'data' => new KolamResource($kolam)
        ], 200);
    }

    /**
     * Remove the specified resource from storage (Soft Delete).
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        $kolam = Kolam::find($id);

        if (!$kolam) {
            return response()->json(['message' => 'Kolam not found'], 404);
        }

        // Perform soft delete
        $kolam->delete();

        return response()->json([
            'message' => 'Kolam deleted successfully'
        ], 200);
    }
}
