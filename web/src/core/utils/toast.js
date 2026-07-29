let toastListener = null;

export const registerToastListener = (listener) => {
  toastListener = listener;
  return () => {
    toastListener = null;
  };
};

export const toast = {
  success: (message, duration = 3000) => {
    toastListener?.(message, "success", duration);
  },
  error: (message, duration = 4000) => {
    toastListener?.(message, "error", duration);
  },
  warning: (message, duration = 4000) => {
    toastListener?.(message, "warning", duration);
  },
  info: (message, duration = 3000) => {
    toastListener?.(message, "info", duration);
  },
};
