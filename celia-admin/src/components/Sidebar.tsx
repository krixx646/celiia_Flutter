'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  Video, 
  ListVideo, 
  Sparkles, 
  Settings,
  LogOut,
  Flame
} from 'lucide-react';
import { cn } from '@/lib/utils';

const navItems = [
  { href: '/', label: 'Videos', icon: Video },
  { href: '/routines', label: 'Routines', icon: ListVideo },
  { href: '/ai-generator', label: 'AI Generator', icon: Sparkles },
  { href: '/settings', label: 'Settings', icon: Settings },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="fixed left-0 top-0 h-screen w-64 bg-[#1A1D2E]/80 backdrop-blur-xl border-r border-white/10 flex flex-col z-50">
      {/* Logo */}
      <div className="p-6 flex items-center gap-3">
        <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-orange-600 rounded-xl flex items-center justify-center">
          <Flame className="w-6 h-6 text-white" />
        </div>
        <span className="text-xl font-bold text-white">Celia</span>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-4 py-6">
        <ul className="space-y-2">
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            return (
              <li key={item.href}>
                <Link
                  href={item.href}
                  className={cn(
                    "flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200",
                    isActive 
                      ? "bg-orange-500/20 text-orange-500" 
                      : "text-gray-400 hover:text-white hover:bg-white/5"
                  )}
                >
                  <item.icon className="w-5 h-5" />
                  <span className="font-medium">{item.label}</span>
                </Link>
              </li>
            );
          })}
        </ul>
      </nav>

      {/* Admin User */}
      <div className="p-4 border-t border-white/10">
        <div className="flex items-center gap-3 px-4 py-3">
          <div className="w-10 h-10 bg-gradient-to-br from-gray-600 to-gray-700 rounded-full flex items-center justify-center">
            <span className="text-sm font-medium text-white">CA</span>
          </div>
          <div className="flex-1">
            <p className="text-sm font-medium text-white">Carlos Admin</p>
            <p className="text-xs text-gray-500">Administrator</p>
          </div>
          <button className="p-2 text-gray-400 hover:text-white transition-colors">
            <LogOut className="w-4 h-4" />
          </button>
        </div>
      </div>
    </aside>
  );
}

