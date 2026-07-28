import { useEffect, useRef } from "react";
import gsap from "gsap";
import {
  FaTint,
  FaWifi,
  FaBell,
  FaChartLine,
  FaArrowRight
} from "react-icons/fa";
import { motion } from "framer-motion";
import SplitText from "../SplitText";
import ShinyText from "../common/ShinyText";

export default function HeroSection({ onCtaClick }) {
  const root = useRef(null);
  const descRef = useRef(null);
  const actionsRef = useRef(null);
  const badgesRef = useRef(null);

  useEffect(() => {
    const ctx = gsap.context(() => {
      gsap.from(descRef.current, {
        y: 40,
        opacity: 0,
        duration: 1,
        ease: "power3.out",
        delay: 1.2,
      });

      gsap.from(actionsRef.current.children, {
        y: 30,
        opacity: 0,
        duration: 0.8,
        ease: "power3.out",
        stagger: 0.15,
        delay: 1.5,
      });

      gsap.from(badgesRef.current.children, {
        y: 20,
        opacity: 0,
        duration: 0.6,
        ease: "power3.out",
        stagger: 0.08,
        delay: 1.8,
      });
    }, root);

    return () => ctx.revert();
  }, []);

  return (
    <section id="home" className="hero" ref={root}>
      <div className="heroContent">
        <div className="heroTitle">
          <SplitText
            text="Monitoring Tambak"
            tag="span"
            delay={40}
            duration={0.8}
            ease="power3.out"
            splitType="words, chars"
            from={{ opacity: 0, y: 60, rotateX: -15 }}
            to={{ opacity: 1, y: 0, rotateX: 0 }}
            threshold={0.01}
            rootMargin="0px"
            textAlign="center"
          />
          <br />
          <motion.span
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.8, ease: "easeOut" }}
            style={{ display: "inline-block", width: "100%" }}
          >
            <ShinyText
              text="Berbasis IoT & AI"
              speed={3.5}
              color="#0071e3"
              shineColor="#a78bfa"
              spread={90}
              className="heroTitleGradient"
            />
          </motion.span>
        </div>

        <p className="heroDesc" ref={descRef}>
          Pantau kualitas air tambak udang secara real-time dengan sensor IoT,
          peringatan dini, dan dashboard analitik untuk hasil panen yang optimal.
        </p>

        <div className="heroActions" ref={actionsRef}>
          <button onClick={onCtaClick} className="heroBtnPrimary">
            Mulai Pantau Tambak <FaArrowRight />
          </button>
          <a href="#features" className="heroBtnSecondary">
            Pelajari Fitur
          </a>
        </div>

        <div className="heroBadges" ref={badgesRef}>
          <div className="heroBadge">
            <FaTint /> Kualitas Air
          </div>
          <div className="heroBadge">
            <FaWifi /> Sensor IoT
          </div>
          <div className="heroBadge">
            <FaBell /> Peringatan Dini
          </div>
          <div className="heroBadge">
            <FaChartLine /> Analisis AI
          </div>
        </div>
      </div>
    </section>
  );
}