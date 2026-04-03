declare module "framer-motion" {
  import { FC, ReactNode, CSSProperties, Ref } from "react";
  interface MotionProps {
    initial?: any;
    animate?: any;
    whileInView?: any;
    whileHover?: any;
    whileTap?: any;
    transition?: any;
    exit?: any;
    style?: CSSProperties;
    className?: string;
    children?: ReactNode;
    ref?: Ref<any>;
    onClick?: (e: any) => void;
    id?: string;
    [key: string]: any;
  }
  const motion: {
    div: FC<MotionProps>;
    section: FC<MotionProps & { id?: string; ref?: Ref<HTMLElement> }>;
    span: FC<MotionProps>;
    button: FC<MotionProps & { onClick?: () => void }>;
    a: FC<MotionProps & { href?: string; target?: string; rel?: string }>;
    p: FC<MotionProps>;
    h1: FC<MotionProps>;
    h2: FC<MotionProps>;
    h3: FC<MotionProps>;
    img: FC<MotionProps & { src?: string; alt?: string }>;
  };
  function useScroll(): { scrollYProgress: { get: () => number } };
  function useTransform(input: any, inputRange: any[], outputRange: any[]): any;
  function useSpring(value: any, config: any): any;
  function useInView(ref: any, options?: { once?: boolean; margin?: string }): boolean;
  export { motion, useScroll, useTransform, useSpring, useInView };
}

declare module "lucide-react" {
  import { FC, SVGProps } from "react";
  interface LucideProps extends SVGProps<SVGSVGElement> {
    size?: number | string;
    color?: string;
    strokeWidth?: number | string;
  }
  type Icon = FC<LucideProps>;
  const Github: Icon;
  const Globe: Icon;
  const User: Icon;
  const ExternalLink: Icon;
  const Moon: Icon;
  const Sun: Icon;
  const ChevronDown: Icon;
  const Code: Icon;
  const Cpu: Icon;
  const Zap: Icon;
  const Trophy: Icon;
  const Tags: Icon;
  const FileText: Icon;
  const Paperclip: Icon;
  const Smartphone: Icon;
  const Shield: Icon;
  const Download: Icon;
  const Star: Icon;
  const Heart: Icon;
  const ArrowRight: Icon;
  const Sparkles: Icon;
  export { LucideProps, Icon, Github, Globe, User, ExternalLink, Moon, Sun, ChevronDown, Code, Cpu, Zap, Trophy, Tags, FileText, Paperclip, Smartphone, Shield, Download, Star, Heart, ArrowRight, Sparkles };
}
