import { useState, useEffect } from "react";
import { registerToastListener } from "../../core/utils/toast";
import { FaCheckCircle, FaExclamationCircle, FaInfoCircle, FaTimes } from "react-icons/fa";
import { motion, AnimatePresence } from "framer-motion";
import "./Toast.css";

export default function ToastContainer() {
  const [toasts, setToasts] = useState([]);

  useEffect(() => {
    const addToast = (message, type, duration) => {
      const id = Date.now() + Math.random();
      setToasts((prev) => [...prev, { id, message, type, duration }]);

      // Auto remove after duration
      setTimeout(() => {
        setToasts((prev) => prev.filter((t) => t.id !== id));
      }, duration);
    };

    const unsubscribe = registerToastListener(addToast);
    return () => unsubscribe();
  }, []);

  const removeToast = (id) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  const getIcon = (type) => {
    switch (type) {
      case "success":
        return <FaCheckCircle className="toastIcon success" />;
      case "error":
        return <FaExclamationCircle className="toastIcon error" />;
      case "warning":
        return <FaExclamationCircle className="toastIcon warning" />;
      default:
        return <FaInfoCircle className="toastIcon info" />;
    }
  };

  return (
    <div className="toastContainer">
      <AnimatePresence>
        {toasts.map((toast) => (
          <motion.div
            key={toast.id}
            layout
            initial={{ opacity: 0, y: 30, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 20, scale: 0.95, transition: { duration: 0.2 } }}
            transition={{ type: "spring", stiffness: 350, damping: 25 }}
            className={`toastItem ${toast.type}`}
          >
            <div className="toastContent">
               {getIcon(toast.type)}
               <span className="toastMessage">{toast.message}</span>
            </div>
            <button className="toastCloseBtn" onClick={() => removeToast(toast.id)}>
              <FaTimes />
            </button>
          </motion.div>
        ))}
      </AnimatePresence>
    </div>
  );
}
