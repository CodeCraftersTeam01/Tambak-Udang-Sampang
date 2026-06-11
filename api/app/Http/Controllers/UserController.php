<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    /**
     * GET /users
     * Super admin & admin
     */
    public function index()
    {
        $users = User::with('role')->get();

        return response()->json([
            'status' => 'success',
            'data' => $users
        ]);
    }

    /**
     * POST /users
     * Create user (admin / petambak)
     */
    public function store(Request $request)
    {
        $this->validate($request, [
            'name'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users',
            'password' => 'required|min:6',
            'role_id'  => 'required|exists:roles,id',
            'nomor_hp' => 'nullable|string|max:20',
            'alamat'   => 'nullable|string'
        ]);

        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
            'role_id'  => $request->role_id,
            'nomor_hp' => $request->nomor_hp,
            'alamat'   => $request->alamat
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'User created',
            'data' => $user
        ], 201);
    }

    /**
     * GET /users/{id}
     */
    public function show($id)
    {
        $user = User::with('role')->find($id);

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $user
        ]);
    }

    /**
     * PUT /users/{id}
     */
    public function update(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not found'
            ], 404);
        }

        $this->validate($request, [
            'name'     => 'sometimes|string|max:255',
            'email'    => 'sometimes|email|unique:users,email,' . $id,
            'password' => 'sometimes|min:6',
            'role_id'  => 'sometimes|exists:roles,id',
            'nomor_hp' => 'nullable|string|max:20',
            'alamat'   => 'nullable|string'
        ]);

        $user->name = $request->name ?? $user->name;
        $user->email = $request->email ?? $user->email;

        if ($request->password) {
            $user->password = Hash::make($request->password);
        }

        if ($request->role_id) {
            $user->role_id = $request->role_id;
        }

        if ($request->has('nomor_hp')) {
            $user->nomor_hp = $request->nomor_hp;
        }

        if ($request->has('alamat')) {
            $user->alamat = $request->alamat;
        }

        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'User updated',
            'data' => $user
        ]);
    }

    /**
     * DELETE /users/{id}
     */
    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not found'
            ], 404);
        }

        $user->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'User deleted'
        ]);
    }
}
