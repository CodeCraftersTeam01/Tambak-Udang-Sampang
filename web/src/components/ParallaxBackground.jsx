import { useEffect, useRef } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export default function ParallaxBackground() {
  const bgRef = useRef(null);
  const overlayRef = useRef(null);

  useEffect(() => {
    // Parallax effect for the image
    gsap.to(bgRef.current, {
      yPercent: 30,
      ease: "none",
      scrollTrigger: {
        trigger: document.body,
        start: "top top",
        end: "bottom top",
        scrub: true,
      },
    });

    // Fade to black and blur transition when scrolling to features
    gsap.to(overlayRef.current, {
      opacity: 1,
      backdropFilter: "blur(12px)",
      WebkitBackdropFilter: "blur(12px)",
      ease: "none",
      scrollTrigger: {
        trigger: "#features",
        start: "top 85%", // Starts fading when features section enters viewport
        end: "top 15%",   // Fully black/blurred when features section is near top
        scrub: true,
      },
    });
  }, []);

  return (
    <>
      <div
        ref={bgRef}
        style={{
          position: "fixed",
          top: "-10%",
          left: 0,
          width: "100%",
          height: "120vh",
          zIndex: -2,
          backgroundImage: "linear-gradient(to bottom, rgba(0,0,0,0.3), rgba(0,0,0,0.7)), url('/hero-aquaculture.jpg')",
          backgroundSize: "cover",
          backgroundPosition: "center",
          pointerEvents: "none",
        }}
      />
      <div
        ref={overlayRef}
        style={{
          position: "fixed",
          inset: 0,
          zIndex: -1,
          backgroundColor: "rgba(0, 0, 0, 0.9)", // Darkens to near black
          opacity: 0,
          pointerEvents: "none",
        }}
      />
    </>
  );
}
