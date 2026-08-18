import React, { useEffect, useState } from 'react';
import apiClient from '../../core/network/apiClient';
import { Dialog, DialogTitle, DialogContent, IconButton, Typography, Box, ThemeProvider, createTheme } from '@mui/material';
import { FaTimes, FaMapMarkerAlt, FaUser, FaWater, FaThermometerHalf, FaVial, FaWind, FaWater as FaWaterDrop } from 'react-icons/fa';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';

// Fix for Leaflet default icon not showing in React
let DefaultIcon = L.icon({
    iconUrl: icon,
    shadowUrl: iconShadow,
    iconAnchor: [12, 41]
});
L.Marker.prototype.options.icon = DefaultIcon;

const darkTheme = createTheme({
  palette: {
    mode: 'dark',
    background: {
      paper: '#1c1c1e',
    },
    text: {
      primary: '#f5f5f7',
      secondary: '#86868b',
    }
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
  }
});

export default function KolamDetailModal({ open, kolam, onClose }) {
  if (!kolam) return null;

  const [log, setLog] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (open && kolam) {
      setLoading(true);
      apiClient.get(`/produksi/log/${kolam.id}`)
        .then(res => {
          if (res.data.data && res.data.data.length > 0) {
            setLog(res.data.data[0]); // Get latest log
          } else {
            setLog(null);
          }
        })
        .catch(console.error)
        .finally(() => setLoading(false));
    }
  }, [open, kolam]);

  const lat = parseFloat(kolam.lat) || 0;
  const lng = parseFloat(kolam.long) || 0;
  const position = [lat, lng];

  return (
    <ThemeProvider theme={darkTheme}>
      <Dialog 
        open={open} 
        onClose={onClose}
        maxWidth="md"
        fullWidth
        PaperProps={{
          style: {
            backgroundColor: '#1c1c1e',
            color: '#f5f5f7',
            borderRadius: '16px',
            border: '1px solid rgba(255,255,255,0.1)'
          }
        }}
      >
        <DialogTitle sx={{ m: 0, p: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid rgba(255,255,255,0.1)' }}>
          <Typography variant="h6" component="div" sx={{ fontWeight: 600, display: 'flex', alignItems: 'center', gap: 1 }}>
            <FaWater color="#0071e3" /> Detail & Monitoring Kolam
          </Typography>
          <IconButton
            aria-label="close"
            onClick={onClose}
            sx={{ color: '#86868b', '&:hover': { color: '#fff' } }}
          >
            <FaTimes size={16} />
          </IconButton>
        </DialogTitle>
        
        <DialogContent sx={{ p: 3 }}>
          <Box sx={{ mb: 4, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 2, mt: 1 }}>
            <Box>
              <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 0.5 }}>Nama Kolam</Typography>
              <Typography variant="body1" sx={{ fontWeight: 600 }}>{kolam.nama_kolam}</Typography>
            </Box>
            <Box>
              <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 0.5 }}>Pemilik</Typography>
              <Typography variant="body1" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <FaUser size={12} color="#86868b" /> {kolam.pemilik}
              </Typography>
            </Box>
            <Box>
              <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 0.5 }}>Status</Typography>
              <span className={`tableBadge ${kolam.status === "aktif" || kolam.status == 1 ? "active" : "inactive"}`} style={{ display: 'inline-block' }}>
                {kolam.status === "aktif" || kolam.status == 1 ? "Aktif" : "Non-Aktif"}
              </span>
            </Box>
            <Box>
              <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 0.5 }}>Koordinat</Typography>
              <Typography variant="body2" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <FaMapMarkerAlt size={12} color="#ff9f0a" /> {kolam.lat}, {kolam.long}
              </Typography>
            </Box>
          </Box>

          {kolam.image_url && (
            <Box sx={{ mb: 4 }}>
              <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 0.5 }}>Foto Kolam</Typography>
              <img 
                src={kolam.image_url} 
                alt={kolam.nama_kolam} 
                style={{ width: '100%', maxHeight: '200px', objectFit: 'cover', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.1)' }} 
              />
            </Box>
          )}

          {/* SENSOR MONITORING */}
          <Typography variant="subtitle1" sx={{ mb: 2, fontWeight: 600, borderBottom: '1px solid rgba(255,255,255,0.1)', pb: 1 }}>
            Real-time Monitoring {loading && <span style={{ fontSize: 12, fontWeight: 'normal', color: '#86868b' }}>(Memuat...)</span>}
          </Typography>
          
          <Box sx={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 2, mb: 4 }}>
            {/* pH Air */}
            <Box sx={{ background: 'rgba(255,255,255,0.05)', borderRadius: '12px', p: 2, border: '1px solid rgba(255,255,255,0.1)' }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, color: '#86868b', mb: 1 }}>
                <FaVial color="#32ade6" /> <Typography variant="caption">pH Air</Typography>
              </Box>
              <Typography variant="h5" sx={{ fontWeight: 700, color: '#32ade6' }}>{log?.ph ?? "-"}</Typography>
            </Box>

            {/* DO (Dissolved Oxygen) */}
            <Box sx={{ background: 'rgba(255,255,255,0.05)', borderRadius: '12px', p: 2, border: '1px solid rgba(255,255,255,0.1)' }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, color: '#86868b', mb: 1 }}>
                <FaWind color="#fff" /> <Typography variant="caption">DO</Typography>
              </Box>
              <Typography variant="h5" sx={{ fontWeight: 700, color: '#fff' }}>{log?.do ?? "-"} <span style={{ fontSize: '12px', fontWeight: 'normal' }}>mg/L</span></Typography>
            </Box>

            {/* Suhu */}
            <Box sx={{ background: 'rgba(255,255,255,0.05)', borderRadius: '12px', p: 2, border: '1px solid rgba(255,255,255,0.1)' }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, color: '#86868b', mb: 1 }}>
                <FaThermometerHalf color="#ff453a" /> <Typography variant="caption">Suhu</Typography>
              </Box>
              <Typography variant="h5" sx={{ fontWeight: 700, color: '#ff453a' }}>{log?.suhu ?? "-"} <span style={{ fontSize: '12px', fontWeight: 'normal' }}>°C</span></Typography>
            </Box>

            {/* TDS */}
            <Box sx={{ background: 'rgba(255,255,255,0.05)', borderRadius: '12px', p: 2, border: '1px solid rgba(255,255,255,0.1)' }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, color: '#86868b', mb: 1 }}>
                <FaWaterDrop color="#bf5af2" /> <Typography variant="caption">TDS</Typography>
              </Box>
              <Typography variant="h5" sx={{ fontWeight: 700, color: '#bf5af2' }}>{log?.tds ?? "-"} <span style={{ fontSize: '12px', fontWeight: 'normal' }}>ppm</span></Typography>
            </Box>

            {/* Pakan Harian */}
            <Box sx={{ background: 'rgba(255,255,255,0.05)', borderRadius: '12px', p: 2, border: '1px solid rgba(255,255,255,0.1)' }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, color: '#86868b', mb: 1 }}>
                <FaWaterDrop color="#ff9f0a" /> <Typography variant="caption">Pakan Harian</Typography>
              </Box>
              <Typography variant="h5" sx={{ fontWeight: 700, color: '#ff9f0a' }}>{log?.pakan_harian_kg ?? "-"} <span style={{ fontSize: '12px', fontWeight: 'normal' }}>kg</span></Typography>
            </Box>

            {/* Kematian */}
            <Box sx={{ background: 'rgba(255,255,255,0.05)', borderRadius: '12px', p: 2, border: '1px solid rgba(255,255,255,0.1)' }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, color: '#86868b', mb: 1 }}>
                <FaTimes color="#ff3b30" /> <Typography variant="caption">Mortalitas</Typography>
              </Box>
              <Typography variant="h5" sx={{ fontWeight: 700, color: '#ff3b30' }}>{log?.kematian_ekor ?? "-"} <span style={{ fontSize: '12px', fontWeight: 'normal' }}>ekor</span></Typography>
            </Box>
          </Box>

          <Typography variant="subtitle1" sx={{ mb: 2, fontWeight: 600, borderBottom: '1px solid rgba(255,255,255,0.1)', pb: 1 }}>
            Lokasi Peta (Dark Mode)
          </Typography>
          <Box sx={{ height: 250, width: '100%', borderRadius: '12px', overflow: 'hidden', border: '1px solid rgba(255,255,255,0.1)' }}>
            <MapContainer center={position} zoom={15} style={{ height: '100%', width: '100%', zIndex: 1 }} zoomControl={false}>
              {/* Menggunakan CartoDB Dark Matter untuk peta gelap pekat */}
              <TileLayer
                attribution='&copy; <a href="https://carto.com/">CartoDB</a>'
                url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
              />
              <Marker position={position}>
                <Popup>
                  <div style={{ color: '#000', fontWeight: 600 }}>{kolam.nama_kolam}</div>
                </Popup>
              </Marker>
            </MapContainer>
          </Box>
        </DialogContent>
      </Dialog>
    </ThemeProvider>
  );
}
