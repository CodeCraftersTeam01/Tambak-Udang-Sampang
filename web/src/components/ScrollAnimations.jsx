import { useEffect, useRef } from "react";
import Lenis from "lenis";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export function useLenis() {
  const lenisRef = useRef(null);

  useEffect(() => {
    const lenis = new Lenis({
      duration: 1.4,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      smoothWheel: true,
      wheelMultiplier: 1,
      touchMultiplier: 1.5,
    });

    lenisRef.current = lenis;

    function onRaf(time) {
      lenis.raf(time);
      requestAnimationFrame(onRaf);
    }
    requestAnimationFrame(onRaf);

    return () => {
      lenis.destroy();
    };
  }, []);

  return lenisRef;
}

export function useRevealAnimation(ref, options = {}) {
  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const anim = gsap.fromTo(
      el,
      {
        y: options.y ?? 60,
        opacity: 0,
      },
      {
        y: 0,
        opacity: 1,
        duration: options.duration ?? 1.2,
        ease: "power3.out",
        scrollTrigger: {
          trigger: el,
          start: options.start ?? "top 85%",
          end: "top 40%",
          toggleActions: "play none none reverse",
        },
      }
    );

    return () => {
      anim.kill();
    };
  }, [ref, options.y, options.duration, options.start]);
}
