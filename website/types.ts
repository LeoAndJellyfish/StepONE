import { ReactNode } from "react";

export enum ContentType {
  INTRO = 'INTRO',
  FEATURES = 'FEATURES',
  TECH = 'TECH',
  DOWNLOAD = 'DOWNLOAD'
}

export interface Feature {
  id: string;
  title: string;
  description: string;
  icon: string;
}

export interface TechItem {
  name: string;
  level: number;
}

export interface NavButtonProps {
  onClick: () => void;
  icon: ReactNode;
  label: string;
  isActive?: boolean;
}
