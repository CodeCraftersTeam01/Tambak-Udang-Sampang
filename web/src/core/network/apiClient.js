import axios from 'axios';
import API_URL from '../../services/api';

const apiClient = axios.create({
  baseURL: `${API_URL}/api`,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
}, (error) => {
  return Promise.reject(error);
});

apiClient.interceptors.response.use((response) => {
  return response;
}, (error) => {
  const status = error.response?.status;
  if (status === 401) {
    localStorage.removeItem('token');
    if (window.location.pathname !== '/') {
      window.location.href = '/';
    }
  } else if (status === 422) {
    const message = error.response?.data?.message || 'Validation error';
    alert(`Error 422: ${message}`);
  } else if (status >= 500) {
    alert(`Server Error: ${error.response?.data?.message || 'Internal Server Error'}`);
  }
  return Promise.reject(error);
});

export default apiClient;
