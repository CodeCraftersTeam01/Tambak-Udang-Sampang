import { useState, useEffect, useCallback } from "react";
import { FaPlus, FaUsers, FaEdit, FaTrash } from "react-icons/fa";
import DashboardLayout from "../../components/admin/DashboardLayout";
import apiClient from "../../core/network/apiClient";



const emptyForm = { name: "", email: "", password: "", role: "petambak", nomor_hp: "", alamat: "" };

function Toast({ message, type, onHide }) {
  useEffect(() => {
    const t = setTimeout(onHide, 3000);
    return () => clearTimeout(t);
  }, [onHide]);
  return <div className={`toast ${type}`}>{message}</div>;
}

function UserModal({ mode, data, onClose, onSaved }) {
  const [form, setForm] = useState(
    data
      ? { name: data.name, email: data.email, password: "", role: data.role || "petambak", nomor_hp: data.nomor_hp || "", alamat: data.alamat || "" }
      : emptyForm
  );
  const [saving, setSaving] = useState(false);

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const body = { ...form, role: form.role };
      if (mode === "edit" && !body.password) delete body.password;

      if (mode === "edit") {
        await apiClient.put(`/users/${data.id}`, body);
        onSaved("User berhasil diperbarui!");
      } else {
        await apiClient.post(`/users`, body);
        onSaved("User berhasil ditambahkan!");
      }
      onClose();
    } catch {
      onSaved("Terjadi kesalahan.", "error");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="dashModalOverlay" onClick={onClose}>
      <div className="dashModal" onClick={(e) => e.stopPropagation()}>
        <div className="dashModalHeader">
          <h3 className="dashModalTitle">{mode === "edit" ? "Edit User" : "Tambah User"}</h3>
          <button className="dashModalClose" onClick={onClose}>&times;</button>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="dashFormGroup">
            <label>Nama Lengkap</label>
            <input name="name" value={form.name} onChange={handleChange} placeholder="Nama User" required />
          </div>
          <div className="dashFormGroup">
            <label>Email</label>
            <input type="email" name="email" value={form.email} onChange={handleChange} placeholder="email@example.com" required />
          </div>
          <div className="dashFormGroup">
            <label>Password {mode === "edit" && <span style={{ color: "var(--dash-muted)", fontWeight: 400 }}>(kosongkan jika tidak diubah)</span>}</label>
            <input
              type="password"
              name="password"
              value={form.password}
              onChange={handleChange}
              placeholder={mode === "edit" ? "••••••••" : "Min. 6 karakter"}
              required={mode === "add"}
            />
          </div>
          <div className="dashFormGroup">
            <label>Role</label>
            <select name="role" value={form.role} onChange={handleChange}>
              <option value="super_admin">Super Admin</option>
              <option value="admin">Admin</option>
              <option value="petambak">Petambak</option>
            </select>
          </div>
          <div className="dashFormRow">
            <div className="dashFormGroup">
              <label>Nomor HP</label>
              <input name="nomor_hp" value={form.nomor_hp} onChange={handleChange} placeholder="0812-3456-7890" />
            </div>
          </div>
          <div className="dashFormGroup">
            <label>Alamat</label>
            <textarea
              name="alamat"
              value={form.alamat}
              onChange={handleChange}
              placeholder="Jl. Raya No. 123, Kecamatan..."
              rows={3}
              style={{
                width: "100%",
                padding: "10px 14px",
                background: "rgba(255,255,255,0.05)",
                border: "1px solid var(--dash-border)",
                borderRadius: 10,
                color: "var(--dash-text)",
                fontSize: 14,
                outline: "none",
                resize: "vertical",
                fontFamily: "inherit",
              }}
            />
          </div>
          <div className="dashFormActions">
            <button type="button" className="btnCancel" onClick={onClose}>Batal</button>
            <button type="submit" className="btnSubmit" disabled={saving}>
              {saving ? "Menyimpan..." : "Simpan"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function ConfirmDelete({ user, onCancel, onConfirm }) {
  return (
    <div className="dashModalOverlay" onClick={onCancel}>
      <div className="confirmDialog" onClick={(e) => e.stopPropagation()}>
        <div className="confirmIcon">👤</div>
        <h3 className="confirmTitle">Hapus User?</h3>
        <p className="confirmDesc">
          User <strong>&ldquo;{user.name}&rdquo;</strong> akan dihapus secara permanen dan tidak dapat dikembalikan.
        </p>
        <div className="confirmActions">
          <button className="btnCancel" onClick={onCancel}>Batal</button>
          <button className="btnDanger" onClick={onConfirm}>Ya, Hapus</button>
        </div>
      </div>
    </div>
  );
}

export default function UsersPage() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [modal, setModal] = useState(null);
  const [confirmDelete, setConfirmDelete] = useState(null);
  const [toast, setToast] = useState(null);


  const fetchUsers = useCallback(async () => {
    setLoading(true);
    try {
      const res = await apiClient.get(`/users`);
      setUsers(res.data.data || []);
    } catch {
      showToast("Gagal memuat data user.", "error");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchUsers(); }, [fetchUsers]);

  const showToast = (message, type = "success") => setToast({ message, type });

  const handleDelete = async () => {
    if (!confirmDelete) return;
    try {
      await apiClient.delete(`/users/${confirmDelete.id}`);
      showToast("User berhasil dihapus!");
      fetchUsers();
    } catch {
      showToast("Gagal menghapus user.", "error");
    } finally {
      setConfirmDelete(null);
    }
  };



  const filtered = users.filter(
    (u) =>
      u.name?.toLowerCase().includes(search.toLowerCase()) ||
      u.email?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <DashboardLayout title="Manajemen User">
      <div className="dashPageHeader">
        <div>
          <h1 className="dashPageTitle">Manajemen User</h1>
          <p className="dashPageSubtitle">{users.length} user terdaftar dalam sistem</p>
        </div>
        <button className="btnPrimary" onClick={() => setModal({ mode: "add", data: null })}>
          <FaPlus /> Tambah User
        </button>
      </div>

      <div className="tableCard">
        <div className="tableCardHeader">
          <span className="tableCardTitle">Daftar User</span>
          <input
            className="tableSearch"
            placeholder="Cari nama atau email..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>

        <div className="tableWrapper">
          {loading ? (
            <div className="loadingSpinner">Memuat data...</div>
          ) : filtered.length === 0 ? (
            <div className="emptyState">
              <FaUsers />
              <p>Belum ada data user.</p>
            </div>
          ) : (
            <table>
              <thead>
                <tr>
                  <th>#</th>
                  <th>Nama</th>
                  <th>Email</th>
                  <th>Role</th>
                  <th>Nomor HP</th>
                  <th>Alamat</th>
                  <th>Bergabung</th>
                  <th>Aksi</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((u, i) => {

                  return (
                    <tr key={u.id}>
                      <td className="tdMuted">{i + 1}</td>
                      <td>
                        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                          <div className="dashAvatar" style={{ width: 30, height: 30, fontSize: 12 }}>
                            {u.name?.charAt(0).toUpperCase()}
                          </div>
                          <span style={{ fontWeight: 600 }}>{u.name}</span>
                        </div>
                      </td>
                      <td className="tdMuted">{u.email}</td>
                      <td>
                        <span className={`tableBadge ${u.role}`}>
                          {u.role || '-'}
                        </span>
                      </td>
                      <td className="tdMuted">{u.nomor_hp || "-"}</td>
                      <td className="tdMuted" style={{ maxWidth: 200, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                        {u.alamat || "-"}
                      </td>
                      <td className="tdMuted">
                        {u.created_at ? new Date(u.created_at).toLocaleDateString("id-ID") : "-"}
                      </td>
                      <td>
                        <div className="tableActions">
                          <button className="btnEdit" onClick={() => setModal({ mode: "edit", data: u })}>
                            <FaEdit style={{ marginRight: 4 }} /> Edit
                          </button>
                          <button className="btnDelete" onClick={() => setConfirmDelete(u)}>
                            <FaTrash style={{ marginRight: 4 }} /> Hapus
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          )}
        </div>
      </div>

      {modal && (
        <UserModal
          mode={modal.mode}
          data={modal.data}
          onClose={() => setModal(null)}
          onSaved={(msg, type) => { showToast(msg, type); fetchUsers(); }}
        />
      )}

      {confirmDelete && (
        <ConfirmDelete
          user={confirmDelete}
          onCancel={() => setConfirmDelete(null)}
          onConfirm={handleDelete}
        />
      )}

      {toast && (
        <Toast message={toast.message} type={toast.type} onHide={() => setToast(null)} />
      )}
    </DashboardLayout>
  );
}
