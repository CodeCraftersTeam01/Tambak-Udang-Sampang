import { useEffect, useRef } from "react";
import gsap from "gsap";
import { FaTint, FaWifi, FaBell, FaChartLine, FaArrowRight } from "react-icons/fa";

export default function HeroSection() {
  const root = useRef(null);
  const titleRef = useRef(null);
  const descRef = useRef(null);
  const actionsRef = useRef(null);
  const badgesRef = useRef(null);

  useEffect(() => {
    const ctx = gsap.context(() => {
      gsap.from(titleRef.current.children, {
        y: 80,
        opacity: 0,
        duration: 1,
        ease: "power3.out",
        stagger: 0.15,
        delay: 0.3,
      });

      gsap.from(descRef.current, {
        y: 40,
        opacity: 0,
        duration: 1,
        ease: "power3.out",
        delay: 0.6,
      });

      gsap.from(actionsRef.current.children, {
        y: 30,
        opacity: 0,
        duration: 0.8,
        ease: "power3.out",
        stagger: 0.15,
        delay: 0.85,
      });

      gsap.from(badgesRef.current.children, {
        y: 20,
        opacity: 0,
        duration: 0.6,
        ease: "power3.out",
        stagger: 0.08,
        delay: 1.1,
      });
    }, root);

    return () => ctx.revert();
  }, []);

  return (
    <section id="home" className="hero" ref={root}>
      <div className="heroContent">
        <div className="heroEyebrow">
          <span className="heroEyebrowDot" />
          Smart Aquaculture System
        </div>

        <div className="heroTitle" ref={titleRef}>
          <div>Monitoring Tambak</div>
          <div>
            Berbasis{" "}
            <span className="heroTitleGradient">IoT & AI</span>
          </div>
        </div>

        <p className="heroDesc" ref={descRef}>
          Pantau kualitas air tambak udang secara real-time dengan sensor IoT,
          peringatan dini, dan dashboard analitik untuk hasil panen yang optimal.
        </p>

        <div className="heroActions" ref={actionsRef}>
          <a href="#features" className="heroBtnPrimary">
            Explore Features <FaArrowRight />
          </a>
          <a href="#contact" className="heroBtnSecondary">
            Contact Us
          </a>
        </div>

        <div className="heroBadges" ref={badgesRef}>
          <div className="heroBadge">
            <FaTint /> Water Quality
          </div>
          <div className="heroBadge">
            <FaWifi /> IoT Sensor
          </div>
          <div className="heroBadge">
            <FaBell /> Early Warning
          </div>
          <div className="heroBadge">
            <FaChartLine /> Analytics
          </div>
        </div>
      </div>
    </section>
  );
}
