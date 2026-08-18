<?php

namespace App\Http\Controllers;

use App\Models\Kolam;
use App\Models\Relay;
use App\Http\Requests\StoreKolamRequest;
use Illuminate\Support\Facades\DB;
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
        $user = auth()->user();
        $query = Kolam::with('relays');

        if ($user) {
            if (!$user->relationLoaded('role')) {
                $user->load('role');
            }
            $roleName = $user->role ? $user->role->name : '';
            if ($roleName !== 'super_admin' && $roleName !== 'admin') {
                $query->where('pemilik', $user->id);
            }
        }

        $kolams = $query->get();
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

        DB::beginTransaction();
        try {
            $pemilikId = $request->input('pemilik');
            if (!$pemilikId) {
                $pemilikId = auth()->user()->id ?? 1;
            }

            $imagePath = null;
            if ($request->hasFile('image_file') && $request->file('image_file')->isValid()) {
                $file = $request->file('image_file');
                $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
                $dir = storage_path('app/public/ponds');
                if (!file_exists($dir)) {
                    mkdir($dir, 0777, true);
                }
                $file->move($dir, $filename);
                $imagePath = 'storage/ponds/' . $filename;
            }

            $kolam = Kolam::create([
                'pemilik' => $pemilikId,
                'nama_kolam' => $request->input('nama_kolam'),
                'mqtt_id' => $request->input('id_mqtt'),
                'lat' => $request->input('lat'),
                'long' => $request->input('long'),
                'status' => $request->input('status') === 'aktif' || $request->input('status') == 1 ? 1 : 0,
                'luas_kolam' => $request->input('luas'),
                'detail_udang' => $request->input('detail_udang'),
                'image_path' => $imagePath,
            ]);

            $relaysInput = $request->input('relays');
            if (is_array($relaysInput)) {
                foreach ($relaysInput as $relayName) {
                    Relay::create([
                        'kolam_id' => $kolam->id,
                        'nama_relay' => $relayName
                    ]);
                }
            }

            DB::commit();

            $kolam->load('relays');

            return response()->json([
                'message' => 'Kolam created successfully',
                'data' => new KolamResource($kolam)
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to create kolam',
                'error' => $e->getMessage()
            ], 500);
        }
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

        $data = $request->all();
        if ($request->has('id_mqtt')) {
            $data['mqtt_id'] = $request->input('id_mqtt');
        }
        if ($request->has('luas')) {
            $data['luas_kolam'] = $request->input('luas');
        }

        if ($request->hasFile('image_file') && $request->file('image_file')->isValid()) {
            if ($kolam->image_path) {
                $oldPath = storage_path('app/public/' . str_replace('storage/', '', $kolam->image_path));
                if (file_exists($oldPath)) {
                    @unlink($oldPath);
                }
            }
            $file = $request->file('image_file');
            $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $dir = storage_path('app/public/ponds');
            if (!file_exists($dir)) {
                mkdir($dir, 0777, true);
            }
            $file->move($dir, $filename);
            $data['image_path'] = 'storage/ponds/' . $filename;
        }

        $kolam->update($data);

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

    /**
     * Get farm management summary.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function farmSummary()
    {
        $uniqueOwners = \App\Models\Kolam::distinct('pemilik')->pluck('pemilik');
        $owners = \App\Models\User::whereIn('id', $uniqueOwners)->get();
        
        $totalPonds = \App\Models\Kolam::count();
        $activePonds = \App\Models\Kolam::where('status', 1)->count();
        $totalArea = (float) \App\Models\Kolam::sum('luas_kolam');
        
        $farms = $owners->map(function ($owner) {
            $pondsCount = \App\Models\Kolam::where('pemilik', $owner->id)->count();
            $activePondsCount = \App\Models\Kolam::where('pemilik', $owner->id)->where('status', 1)->count();
            
            return [
                'id' => $owner->id,
                'name' => "Farm " . ($owner->name ?? "User #{$owner->id}"),
                'owner_name' => $owner->name,
                'ponds_count' => $pondsCount,
                'active_ponds_count' => $activePondsCount,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'total_farms' => $farms->count(),
                'total_ponds' => $totalPonds,
                'active_ponds' => $activePonds,
                'total_area' => $totalArea,
                'farms' => $farms
            ]
        ], 200);
    }

    /**
     * Start active culturing cycle for a pond.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function startCycle(Request $request, $id)
    {
        $kolam = Kolam::find($id);
        if (!$kolam) {
            return response()->json(['message' => 'Kolam not found'], 404);
        }

        $tanggalTebar = $request->input('tanggal_tebar', date('Y-m-d'));

        $kolam->update([
            'status_siklus' => 'aktif',
            'tanggal_tebar' => $tanggalTebar,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Siklus budidaya berhasil dimulai.',
            'data' => new KolamResource($kolam)
        ]);
    }

    /**
     * End active culturing cycle for a pond.
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function endCycle($id)
    {
        $kolam = Kolam::find($id);
        if (!$kolam) {
            return response()->json(['message' => 'Kolam not found'], 404);
        }

        $kolam->update([
            'status_siklus' => 'persiapan',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Siklus budidaya berhasil diakhiri.',
            'data' => new KolamResource($kolam)
        ]);
    }
}
