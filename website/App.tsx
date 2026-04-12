import React, { useState, useEffect, useRef } from "react";
import { motion, useScroll, useTransform, useInView, useSpring } from "framer-motion";
import {
  Github, Globe, Moon, Sun, ChevronDown,
  Trophy, Tags, FileText, Paperclip, Smartphone, Shield,
  Download, ExternalLink, Heart, ArrowRight
} from "lucide-react";
import { FEATURES_DATA, TECH_STACK, NAVIGATION_ITEMS } from "./constants";
import { ContentType } from "./types";

const iconMap: Record<string, React.FC<{ size?: number; className?: string }>> = {
  Trophy,
  Tags,
  FileText,
  Paperclip,
  Smartphone,
  Shield
};

const App: React.FC = () => {
  const [isDark, setIsDark] = useState(true);
  const [activeSection, setActiveSection] = useState<string>("intro");

  const containerRef = useRef<HTMLDivElement>(null);
  const introRef = useRef<HTMLElement>(null);
  const featuresRef = useRef<HTMLElement>(null);
  const techRef = useRef<HTMLElement>(null);
  const downloadRef = useRef<HTMLElement>(null);

  const { scrollYProgress } = useScroll();
  const smoothProgress = useSpring(scrollYProgress, { stiffness: 100, damping: 30, restDelta: 0.001 });

  const cardProgress = useTransform(scrollYProgress, [0, 0.15], [0, 1]);
  const cardScale = useTransform(cardProgress, [0, 1], [1, 3]);
  const cardBlur = useTransform(cardProgress, [0, 0.5, 1], [0, 10, 30]);
  const cardOpacity = useTransform(cardProgress, [0, 0.7, 1], [1, 0.8, 0.3]);
  const cardY = useTransform(cardProgress, [0, 1], [0, -200]);
  const contentOpacity = useTransform(cardProgress, [0.3, 0.6], [0, 1]);

  useEffect(() => {
    if (isDark) {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
  }, [isDark]);

  useEffect(() => {
    const refs = [
      { ref: introRef, id: "intro" },
      { ref: featuresRef, id: "features" },
      { ref: techRef, id: "tech" },
      { ref: downloadRef, id: "download" },
    ];

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setActiveSection(entry.target.id);
          }
        });
      },
      { threshold: 0.3 }
    );

    refs.forEach(({ ref }) => {
      if (ref.current) observer.observe(ref.current);
    });

    return () => observer.disconnect();
  }, []);

  const scrollToSection = (id: string) => {
    const element = document.getElementById(id);
    if (element) element.scrollIntoView({ behavior: "smooth" });
  };

  const bgLight = "url('/zzSQs.jpg')";
  const bgDark = "url('/zzSQs.jpg')";

  return (
    <div
      ref={containerRef}
      className="min-h-screen bg-cover bg-center bg-fixed font-sans transition-colors duration-1000"
      style={{ backgroundImage: isDark ? bgDark : bgLight }}
    >
      <div className={`fixed inset-0 backdrop-blur-[2px] transition-colors duration-1000 pointer-events-none ${isDark ? "bg-black/30" : "bg-white/50"}`} />

      <motion.div
        className="fixed top-0 left-0 right-0 h-0.5 bg-white/50 dark:bg-white/20 origin-left z-[60]"
        style={{ scaleX: smoothProgress }}
      />

      <button
        onClick={() => setIsDark(!isDark)}
        className="fixed top-4 right-4 md:top-6 md:right-6 z-[70] p-2.5 md:p-3 rounded-full bg-white/30 dark:bg-black/50 backdrop-blur-lg border border-white/40 dark:border-white/10 text-gray-800 dark:text-gray-200 shadow-lg hover:scale-105 transition-transform"
      >
        {isDark ? <Sun size={20} className="md:w-6 md:h-6" /> : <Moon size={20} className="md:w-6 md:h-6" />}
      </button>

      <motion.div
        className="fixed top-4 left-2 right-2 md:top-6 md:left-1/2 md:right-auto md:-translate-x-1/2 z-[70] flex space-x-0.5 md:space-x-1 p-1 md:p-1.5 rounded-3xl bg-white/70 dark:bg-black/40 backdrop-blur-xl border border-white/60 dark:border-white/10 shadow-lg"
        style={{ opacity: contentOpacity }}
      >
        {NAVIGATION_ITEMS.map((item) => {
          const Icon = item.icon;
          const isActive = activeSection === item.type.toLowerCase();
          return (
            <button
              key={item.label}
              onClick={() => scrollToSection(item.type.toLowerCase())}
              className={`flex items-center justify-center md:justify-start gap-1.5 md:gap-2 px-2.5 md:px-4 py-2 rounded-3xl text-xs md:text-sm font-medium transition-all flex-1 md:flex-none ${
                isActive
                  ? "bg-white/80 dark:bg-white/15 text-gray-900 dark:text-white shadow-sm"
                  : "text-gray-600 dark:text-gray-400 hover:bg-white/50 dark:hover:bg-white/5 hover:text-gray-900 dark:hover:text-white"
              }`}
            >
              <Icon size={14} className="md:w-4 md:h-4" />
              <span className="hidden md:inline">{item.label.split(": ")[1]}</span>
            </button>
          );
        })}
      </motion.div>

      <motion.div
        className="fixed inset-0 z-[5] flex items-center justify-center pointer-events-none px-4"
        style={{
          opacity: cardOpacity,
          scale: cardScale,
          y: cardY,
          filter: useTransform(cardBlur, (b) => `blur(${b}px)`),
        }}
      >
        <div className="w-full max-w-[95vw] md:w-[850px] h-[420px] md:h-[580px] max-h-[75vh] bg-white/80 dark:bg-gray-900/40 backdrop-blur-2xl shadow-[0_8px_32px_0_rgba(31,38,135,0.15)] border border-white/60 dark:border-white/10 flex flex-col overflow-hidden pointer-events-auto rounded-none">
          <HeroContent />
        </div>
      </motion.div>

      <main className="relative z-20">
        <div className="h-screen" />

        <section id="intro" ref={introRef} className="min-h-screen flex items-center justify-center px-4 py-20">
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            className="max-w-3xl mx-auto text-center"
          >
            <motion.div
              initial={{ scale: 0, opacity: 0 }}
              whileInView={{ scale: 1, opacity: 1 }}
              transition={{ duration: 0.6, type: "spring", stiffness: 200 }}
              className="w-28 h-28 md:w-36 md:h-36 rounded-[22px] overflow-hidden shadow-2xl ring-4 ring-white/50 dark:ring-white/20 mx-auto mb-8"
            >
              <img src="/favicon.png" alt="StepONE" className="w-full h-full object-cover" />
            </motion.div>

            <h1 className="text-4xl md:text-6xl lg:text-7xl font-light tracking-tight text-gray-900 dark:text-white mb-4">
              Step<span className="font-semibold text-gray-700 dark:text-gray-200">ONE</span>
            </h1>

            <p className="text-lg md:text-xl lg:text-2xl text-gray-800 dark:text-gray-300 font-medium mb-4 md:mb-6">
              成就管理平台
            </p>

            <p className="text-base md:text-lg text-gray-700 dark:text-gray-400 leading-relaxed max-w-lg mx-auto mb-6 md:mb-8">
              记录每一步成长，汇聚每一份荣誉。StepONE 帮助你系统化管理个人成就，
              从校园竞赛到职场里程碑，让每一段高光时刻都不被遗忘。
            </p>

            <div className="flex flex-wrap justify-center gap-3 mb-8">
              {['Flutter', 'SQLite', '跨平台', '隐私优先'].map((tag) => (
                <span key={tag} className="px-4 py-1.5 text-xs md:text-sm bg-white/60 dark:bg-white/10 text-gray-600 dark:text-gray-300 rounded-full font-medium border border-white/60 dark:border-white/10 backdrop-blur-sm">
                  {tag}
                </span>
              ))}
            </div>

            <motion.div initial={{ opacity: 0 }} whileInView={{ opacity: 1 }} transition={{ duration: 0.6, delay: 0.3 }} className="animate-bounce">
              <ChevronDown size={32} className="mx-auto text-gray-400 dark:text-gray-500" />
            </motion.div>
          </motion.div>
        </section>

        <FeaturesSection ref={featuresRef} />
        <TechSection ref={techRef} />
        <DownloadSection ref={downloadRef} />
      </main>

      <style>{`
        html { scroll-behavior: smooth; }
        * { -webkit-tap-highlight-color: transparent; }
        @media (max-width: 768px) { html { font-size: 14px; } }
        .custom-scrollbar::-webkit-scrollbar { width: 6px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background-color: rgba(156,163,175,0.5); border-radius: 10px; }
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
      `}</style>
    </div>
  );
};

const HeroContent: React.FC = () => {
  return (
    <div className="flex flex-col items-center justify-center h-full text-center space-y-3 md:space-y-6 p-4 md:p-10">
      <div className="w-14 h-14 md:w-20 md:h-20 rounded-[14px] md:rounded-[18px] overflow-hidden shadow-lg">
        <img src="/favicon.png" alt="StepONE" className="w-full h-full object-cover" />
      </div>
      <div className="text-center">
        <h1 className="text-2xl md:text-4xl lg:text-5xl font-light tracking-tight text-gray-900 dark:text-white mb-1 md:mb-2">
          Step<span className="font-semibold text-gray-700 dark:text-gray-200">ONE</span>
        </h1>
        <p className="text-sm md:text-lg text-gray-600 dark:text-gray-300 font-medium">
          成就管理平台 · Achievement Manager
        </p>
      </div>
      <p className="text-xs md:text-base max-w-xs md:max-w-md text-gray-700 dark:text-gray-400 leading-relaxed">
        记录每一步成长，汇聚每一份荣耀。系统化管理个人成就与荣誉记录。
      </p>
      <div className="flex gap-2 mt-2">
        <span className="px-3 py-1 text-[10px] md:text-xs bg-white/60 dark:bg-white/10 text-gray-500 dark:text-gray-400 rounded-full">v1.1.1</span>
        <span className="px-3 py-1 text-[10px] md:text-xs bg-white/60 dark:bg-white/10 text-gray-500 dark:text-gray-400 rounded-full">Open Source</span>
      </div>
    </div>
  );
};

const FeaturesSection = React.forwardRef<HTMLElement>((_, ref) => {
  return (
    <section id="features" ref={ref} className="min-h-screen flex items-center py-20 px-4">
      <div className="max-w-5xl mx-auto w-full">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-12 md:mb-16"
        >
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-light text-gray-900 dark:text-white mb-3 md:mb-4">
            核心功能
          </h2>
          <p className="text-gray-700 dark:text-gray-400 text-base md:text-lg max-w-lg mx-auto">
            为你的成就管理之旅提供全方位支持
          </p>
        </motion.div>

        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {FEATURES_DATA.map((feature, idx) => {
            const IconComponent = iconMap[feature.icon] || Trophy;
            return (
              <motion.div
                key={feature.id}
                initial={{ opacity: 0, y: 50 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: 0.15 + idx * 0.1 }}
                className="group bg-white/80 dark:bg-gray-900/50 backdrop-blur-xl p-5 md:p-7 rounded-3xl border border-white/80 dark:border-white/10 hover:shadow-2xl hover:bg-white/90 dark:hover:bg-gray-900/70 transition-all cursor-default hover:-translate-y-1"
              >
                <div className="w-11 h-11 md:w-13 md:h-13 rounded-2xl bg-white/70 dark:bg-white/10 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform backdrop-blur-sm">
                  <IconComponent size={22} className="md:w-6 md:h-6 text-gray-500 dark:text-gray-400" />
                </div>
                <h3 className="text-base md:text-lg font-medium text-gray-900 dark:text-gray-100 mb-2">
                  {feature.title}
                </h3>
                <p className="text-xs md:text-sm text-gray-600 dark:text-gray-400 leading-relaxed">
                  {feature.description}
                </p>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
});

const TechSection = React.forwardRef<HTMLElement>((_, ref) => {
  return (
    <section id="tech" ref={ref} className="min-h-screen flex items-center py-20 px-4">
      <div className="max-w-3xl mx-auto w-full">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-12 md:mb-16"
        >
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-light text-gray-900 dark:text-white mb-3 md:mb-4">
            技术栈
          </h2>
          <p className="text-gray-700 dark:text-gray-400 text-base md:text-lg">
            构建于现代技术之上，追求卓越的用户体验
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-x-12 gap-y-8">
          {TECH_STACK.map((tech, idx) => (
            <motion.div
              key={tech.name}
              initial={{ opacity: 0, x: idx % 2 === 0 ? -30 : 30 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.5, delay: 0.2 + idx * 0.1 }}
              className="w-full"
            >
              <div className="flex justify-between text-xs md:text-sm text-gray-800 dark:text-gray-300 mb-2 md:mb-3 font-medium">
                <span>{tech.name}</span>
                <span>{tech.level}%</span>
              </div>
              <div className="h-1.5 md:h-2 bg-gray-300/70 dark:bg-gray-700/50 rounded-full overflow-hidden backdrop-blur-sm">
                <motion.div
                  initial={{ width: 0 }}
                  whileInView={{ width: `${tech.level}%` }}
                  transition={{ duration: 1.2, delay: 0.4 + idx * 0.1, ease: "easeOut" }}
                  className="h-full bg-gray-400/60 dark:bg-white/30 rounded-full"
                />
              </div>
            </motion.div>
          ))}
        </div>

        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.8 }}
          className="mt-16 text-center"
        >
          <div className="inline-flex flex-wrap justify-center gap-3">
            {['Material Design 3', 'SQLite 本地存储', 'Provider 状态管理', 'Go Router 导航'].map((badge) => (
              <span key={badge} className="px-4 py-1.5 text-xs bg-white/60 dark:bg-white/10 backdrop-blur-sm text-gray-700 dark:text-gray-300 rounded-full border border-gray-200/60 dark:border-white/10">
                {badge}
              </span>
            ))}
          </div>
        </motion.div>
      </div>
    </section>
  );
});

const DownloadSection = React.forwardRef<HTMLElement>((_, ref) => {
  return (
    <section id="download" ref={ref} className="min-h-screen flex items-center py-20 px-4">
      <div className="max-w-2xl mx-auto w-full text-center">
        <motion.div
          initial={{ scale: 0, opacity: 0 }}
          whileInView={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.6, type: "spring", stiffness: 200 }}
          className="w-24 h-24 md:w-32 md:h-32 rounded-3xl bg-white/80 dark:bg-white/10 backdrop-blur-xl flex items-center justify-center mx-auto mb-8 shadow-2xl"
        >
          <Heart size={48} className="md:w-14 md:h-14 text-gray-400 dark:text-gray-300" strokeWidth={1.5} />
        </motion.div>

        <motion.h2
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-3xl md:text-4xl lg:text-5xl font-light text-gray-900 dark:text-white mb-4 md:mb-6"
        >
          开始使用 StepONE
        </motion.h2>

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="text-gray-700 dark:text-gray-400 text-base md:text-lg mb-8 md:mb-12 max-w-md mx-auto"
        >
          开源免费，隐私优先。立即下载，开始记录你的成就之路。
        </motion.p>

        <div className="flex flex-col sm:flex-row gap-3 md:gap-4 justify-center mb-12">
          <motion.a
            href="https://github.com/LeoAndJellyfish/StepONE"
            target="_blank"
            rel="noreferrer"
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.98 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="flex items-center justify-center gap-2 md:gap-3 px-8 md:px-10 py-3.5 md:py-4.5 bg-white/80 dark:bg-white/15 hover:bg-white/95 dark:hover:bg-white/25 backdrop-blur-xl rounded-3xl border border-white/60 dark:border-white/10 text-gray-900 dark:text-gray-200 transition-all shadow-lg hover:shadow-xl group font-medium text-base md:text-lg"
          >
            <Github size={20} className="md:w-5 md:h-5 group-hover:scale-110 transition-transform" />
            <span>GitHub</span>
            <ExternalLink size={14} className="md:w-3.5 md:h-3.5" />
          </motion.a>

          <motion.a
            href="https://github.com/LeoAndJellyfish/StepONE/releases/latest"
            target="_blank"
            rel="noreferrer"
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.98 }}
            transition={{ duration: 0.5, delay: 0.4 }}
            className="flex items-center justify-center gap-2 md:gap-3 px-8 md:px-10 py-3.5 md:py-4.5 bg-white/80 dark:bg-gray-900/50 hover:bg-white/95 dark:hover:bg-gray-900/80 backdrop-blur-xl rounded-3xl border border-white/80 dark:border-white/10 text-gray-900 dark:text-gray-200 transition-all shadow-lg hover:shadow-xl group font-medium text-base md:text-lg"
          >
            <Download size={20} className="md:w-5 md:h-5 group-hover:scale-110 transition-transform" />
            <span>下载安装包</span>
            <ArrowRight size={16} className="md:w-4 md:h-4" />
          </motion.a>
        </div>

        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.6 }}
          className="bg-white/50 dark:bg-white/5 backdrop-blur-sm rounded-2xl p-6 md:p-8 border border-white/60 dark:border-white/10 max-w-lg mx-auto"
        >
          <p className="text-sm md:text-base text-gray-600 dark:text-gray-400 leading-relaxed mb-4">
            支持 <strong className="text-gray-800 dark:text-gray-200">Android</strong>、
            <strong className="text-gray-800 dark:text-gray-200"> Windows</strong> 平台
          </p>
          <div className="flex justify-center gap-4 text-xs text-gray-500 dark:text-gray-500">
            <span className="flex items-center gap-1"><Smartphone size={12} /> 移动端</span>
            <span className="flex items-center gap-1"><Globe size={12} /> 桌面端</span>
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.8 }}
          className="mt-12 md:mt-16 text-gray-500 dark:text-gray-500 text-xs md:text-sm"
        >
          <p>Made with ❤️ by Leo & Jellyfish</p>
          <p className="mt-1 md:mt-2">© 2026 StepONE · 仅供学习与个人用途</p>
        </motion.div>
      </div>
    </section>
  );
});

export default App;
