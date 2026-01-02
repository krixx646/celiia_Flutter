'use client';

import { Search, Upload } from 'lucide-react';
import { useState } from 'react';

interface HeaderProps {
  onUploadClick?: () => void;
  showUploadButton?: boolean;
  showSearch?: boolean;
  searchPlaceholder?: string;
}

export default function Header({ 
  onUploadClick, 
  showUploadButton = false,
  showSearch = true,
  searchPlaceholder = "Search..."
}: HeaderProps) {
  const [searchQuery, setSearchQuery] = useState('');

  return (
    <header className="h-20 bg-[#0F1219]/80 backdrop-blur-xl border-b border-white/10 flex items-center justify-between px-8 sticky top-0 z-40">
      {/* Search - Only show if enabled */}
      {showSearch ? (
        <div className="relative w-96">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-500" />
          <input
            type="text"
            placeholder={searchPlaceholder}
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-orange-500/50 transition-colors"
          />
        </div>
      ) : (
        <div /> 
      )}

      {/* Right side */}
      <div className="flex items-center gap-4">
        {/* Upload Button - Only show if enabled */}
        {showUploadButton && onUploadClick && (
          <button
            onClick={onUploadClick}
            className="flex items-center gap-2 px-6 py-3 bg-orange-500 hover:bg-orange-600 text-white font-medium rounded-xl transition-colors"
          >
            <Upload className="w-5 h-5" />
            <span>Upload Video</span>
          </button>
        )}
      </div>
    </header>
  );
}

