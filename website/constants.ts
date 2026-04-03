import { ContentType, Feature, TechItem } from './types';
import { Sparkles, Cpu, Download } from 'lucide-react';

export const FEATURES_DATA: Feature[] = [
  {
    id: '1',
    title: '成就管理',
    description: '轻松记录和管理你的每一项成就，支持标题、描述、日期、组织等丰富字段，让成长轨迹清晰可见。',
    icon: 'Trophy'
  },
  {
    id: '2',
    title: '分类与标签',
    description: '灵活的分类和标签系统，帮助你按领域、类型整理成就，快速筛选和查找历史记录。',
    icon: 'Tags'
  },
  {
    id: '3',
    title: '简历生成',
    description: '一键将成就记录导出为专业简历格式，支持自定义模板，让求职准备更加高效。',
    icon: 'FileText'
  },
  {
    id: '4',
    title: '附件支持',
    description: '支持为成就添加图片和文件附件，证书、截图、证明材料一应俱全，完整留存每份荣誉。',
    icon: 'Paperclip'
  },
  {
    id: '5',
    title: '跨平台支持',
    description: '基于 Flutter 构建，支持 Android、iOS、Windows、macOS、Linux 全平台运行，数据随时随地同步。',
    icon: 'Smartphone'
  },
  {
    id: '6',
    title: '本地存储',
    description: '采用 SQLite 本地数据库，数据完全存储在设备端，隐私安全有保障，无需担心云端泄露。',
    icon: 'Shield'
  }
];

export const TECH_STACK: TechItem[] = [
  { name: 'Flutter', level: 100 },
  { name: 'Dart', level: 95 },
  { name: 'SQLite', level: 90 },
  { name: 'Provider', level: 88 },
  { name: 'Go Router', level: 85 },
  { name: 'Material Design 3', level: 92 }
];

export const NAVIGATION_ITEMS = [
  { type: ContentType.INTRO, label: '概览: ABOUT', icon: Sparkles },
  { type: ContentType.FEATURES, label: '功能: FEATURES', icon: Cpu },
  { type: ContentType.TECH, label: '技术: TECH', icon: Cpu },
  { type: ContentType.DOWNLOAD, label: '获取: DOWNLOAD', icon: Download }
];
