'use client';

import { useState, useRef, useCallback } from 'react';
import { Upload, X, Loader2, CheckCircle, AlertCircle } from 'lucide-react';
import { cn } from '@/lib/utils';

interface UploadPanelProps {
  isOpen: boolean;
  onClose: () => void;
  onUploadComplete?: () => void;
}

const categories = [
  'Yoga', 'HIIT', 'Strength', 'Cardio', 'Flexibility', 'Dance', 'Pilates', 'Mindfulness'
];

const bodyParts = [
  { id: 'arms', label: 'Arms' },
  { id: 'shoulders', label: 'Shoulders' },
  { id: 'chest', label: 'Chest' },
  { id: 'back', label: 'Back' },
  { id: 'core', label: 'Core' },
  { id: 'abs', label: 'Abs' },
  { id: 'legs', label: 'Legs' },
  { id: 'glutes', label: 'Glutes' },
  { id: 'full_body', label: 'Full Body' },
];

const difficultyLevels = ['Beginner', 'Intermediate', 'Advanced'];

const equipmentOptions = [
  'None', 'Dumbbells', 'Resistance Bands', 'Mat', 'Kettlebell', 'Jump Rope', 'Pull-up Bar'
];

export default function UploadPanel({ isOpen, onClose, onUploadComplete }: UploadPanelProps) {
  const [file, setFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [uploadStatus, setUploadStatus] = useState<'idle' | 'uploading' | 'success' | 'error'>('idle');
  const [uploadStep, setUploadStep] = useState<'idle' | 'init' | 'cloudflare' | 'saving'>('idle');
  const [errorMessage, setErrorMessage] = useState('');
  const [dragActive, setDragActive] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [formData, setFormData] = useState({
    title: '',
    description: '',
    category: '',
    bodyPart: '',
    difficulty: 'Beginner',
    equipment: [] as string[],
  });

  const handleDrag = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === 'dragenter' || e.type === 'dragover') {
      setDragActive(true);
    } else if (e.type === 'dragleave') {
      setDragActive(false);
    }
  }, []);

  const handleDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);

    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      const droppedFile = e.dataTransfer.files[0];
      if (droppedFile.type.startsWith('video/')) {
        setFile(droppedFile);
        const fileName = droppedFile.name.replace(/\.[^/.]+$/, '');
        setFormData(prev => ({ ...prev, title: fileName }));
      }
    }
  }, []);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const selectedFile = e.target.files[0];
      setFile(selectedFile);
      const fileName = selectedFile.name.replace(/\.[^/.]+$/, '');
      setFormData(prev => ({ ...prev, title: fileName }));
    }
  };

  const uploadToCloudflareWithProgress = (uploadURL: string, fileToUpload: File) => {
    return new Promise<void>((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open('POST', uploadURL, true);

      // Large uploads can take a while. This is just a safety net; tweak as needed.
      xhr.timeout = 15 * 60 * 1000; // 15 minutes

      xhr.upload.onprogress = (evt) => {
        if (!evt.lengthComputable) return;
        const ratio = evt.total > 0 ? evt.loaded / evt.total : 0;
        // Use 0-90% for the file transfer portion.
        const pct = Math.max(0, Math.min(90, Math.round(ratio * 90)));
        setUploadProgress(pct);
      };

      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          resolve();
        } else {
          reject(new Error(`Cloudflare upload failed (HTTP ${xhr.status})`));
        }
      };
      xhr.onerror = () => reject(new Error('Cloudflare upload failed (network error)'));
      xhr.ontimeout = () => reject(new Error('Cloudflare upload timed out'));

      const cfForm = new FormData();
      cfForm.append('file', fileToUpload);
      xhr.send(cfForm);
    });
  };

  const handleUpload = async () => {
    if (!file) return;

    setUploading(true);
    setUploadStatus('uploading');
    setUploadStep('init');
    setUploadProgress(0);
    setErrorMessage('');

    try {
      // 1) Request a direct upload URL (server-side only stores Cloudflare token; safe for cloud deploy)
      const initRes = await fetch('/api/upload-video/init', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: formData.title,
          maxDurationSeconds: 3600,
        }),
      });
      const initText = await initRes.text();
      const initJson = (() => {
        try {
          return JSON.parse(initText);
        } catch {
          return null;
        }
      })();
      if (!initRes.ok) throw new Error(initJson?.error || initText || 'Failed to initialize upload');

      const uploadURL = initJson.uploadURL as string;
      const uid = initJson.uid as string;
      if (!uploadURL || !uid) throw new Error('Invalid upload URL response');

      // 2) Upload the file directly to Cloudflare (browser -> Cloudflare) with real progress
      setUploadStep('cloudflare');
      setUploadProgress(1);
      await uploadToCloudflareWithProgress(uploadURL, file);

      // 3) Tell server to save metadata to Supabase (and read Cloudflare duration/status)
      setUploadStep('saving');
      setUploadProgress((p) => Math.max(p, 92));
      const completeRes = await fetch('/api/upload-video/complete', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          uid,
          title: formData.title,
          description: formData.description,
          category: formData.category,
          bodyPart: formData.bodyPart,
          difficulty: formData.difficulty,
          equipment: formData.equipment,
        }),
      });
      const completeText = await completeRes.text();
      const completeJson = (() => {
        try {
          return JSON.parse(completeText);
        } catch {
          return null;
        }
      })();
      if (!completeRes.ok) {
        throw new Error(
          completeJson?.error ||
            completeJson?.details ||
            (uid ? `Upload failed (Cloudflare uid: ${uid})` : 'Upload failed') ||
            completeText
        );
      }

      setUploadProgress(100);
      setUploadStatus('success');
      
      // Reset after delay
      setTimeout(() => {
        resetForm();
        onUploadComplete?.();
        onClose();
      }, 1500);

    } catch (error: any) {
      console.error('Upload failed:', error);
      setUploadStatus('error');
      setErrorMessage(error.message || 'Upload failed. Please try again.');
      setUploading(false);
      setUploadStep('idle');
    }
  };

  const resetForm = () => {
    setFile(null);
    setFormData({
      title: '',
      description: '',
      category: '',
      bodyPart: '',
      difficulty: 'Beginner',
      equipment: [],
    });
    setUploading(false);
    setUploadProgress(0);
    setUploadStatus('idle');
    setUploadStep('idle');
    setErrorMessage('');
  };

  const toggleEquipment = (item: string) => {
    setFormData(prev => ({
      ...prev,
      equipment: prev.equipment.includes(item)
        ? prev.equipment.filter(e => e !== item)
        : [...prev.equipment, item]
    }));
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-end">
      <div className="w-[520px] h-full bg-[#1A1D2E] border-l border-white/10 overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-white/10">
          <h2 className="text-xl font-bold text-white">Upload Exercise Video</h2>
          <button 
            onClick={() => { resetForm(); onClose(); }}
            className="p-2 text-gray-400 hover:text-white transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-6 space-y-6">
          {/* Drop Zone */}
          <div
            className={cn(
              "border-2 border-dashed rounded-2xl p-8 text-center transition-colors",
              dragActive ? "border-orange-500 bg-orange-500/10" : "border-white/20 hover:border-white/40",
              file && "border-green-500 bg-green-500/10"
            )}
            onDragEnter={handleDrag}
            onDragLeave={handleDrag}
            onDragOver={handleDrag}
            onDrop={handleDrop}
          >
            {file ? (
              <div className="space-y-2">
                <div className="w-12 h-12 bg-green-500/20 rounded-full flex items-center justify-center mx-auto">
                  <Upload className="w-6 h-6 text-green-500" />
                </div>
                <p className="text-white font-medium">{file.name}</p>
                <p className="text-gray-500 text-sm">
                  {(file.size / (1024 * 1024)).toFixed(2)} MB
                </p>
                <button
                  onClick={() => setFile(null)}
                  className="text-red-400 text-sm hover:text-red-300"
                >
                  Remove
                </button>
              </div>
            ) : (
              <>
                <Upload className="w-10 h-10 text-gray-500 mx-auto mb-4" />
                <p className="text-gray-400 mb-2">
                  Drag & Drop video file here
                </p>
                <p className="text-gray-600 text-sm mb-4">or</p>
                <button
                  onClick={() => fileInputRef.current?.click()}
                  className="text-orange-500 hover:text-orange-400 font-medium"
                >
                  Browse
                </button>
              </>
            )}
            <input
              ref={fileInputRef}
              type="file"
              accept="video/*"
              onChange={handleFileChange}
              className="hidden"
            />
          </div>

          {/* Form Fields */}
          <div className="space-y-4">
            {/* Title */}
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Video Title *
              </label>
              <input
                type="text"
                value={formData.title}
                onChange={(e) => setFormData(prev => ({ ...prev, title: e.target.value }))}
                placeholder="e.g., Lateral Arm Raises"
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-orange-500/50"
              />
            </div>

            {/* Description */}
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Description
              </label>
              <textarea
                value={formData.description}
                onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
                placeholder="Describe the exercise and proper form..."
                rows={2}
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-orange-500/50 resize-none"
              />
            </div>

            {/* Body Part - NEW FIELD */}
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Target Body Part *
              </label>
              <div className="grid grid-cols-4 gap-2">
                {bodyParts.map((part) => (
                  <button
                    key={part.id}
                    onClick={() => setFormData(prev => ({ ...prev, bodyPart: part.id }))}
                    className={cn(
                      "px-3 py-2 rounded-lg text-xs font-medium transition-colors",
                      formData.bodyPart === part.id
                        ? "bg-orange-500/20 text-orange-400 border border-orange-500/50"
                        : "bg-white/5 text-gray-400 border border-white/10 hover:bg-white/10"
                    )}
                  >
                    {part.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Category */}
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Category *
              </label>
              <select
                value={formData.category}
                onChange={(e) => setFormData(prev => ({ ...prev, category: e.target.value }))}
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-orange-500/50 appearance-none cursor-pointer"
              >
                <option value="" className="bg-gray-800">Select category</option>
                {categories.map(cat => (
                  <option key={cat} value={cat.toLowerCase()} className="bg-gray-800">
                    {cat}
                  </option>
                ))}
              </select>
            </div>

            {/* Difficulty */}
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Difficulty Level
              </label>
              <div className="flex gap-2">
                {difficultyLevels.map(level => (
                  <button
                    key={level}
                    onClick={() => setFormData(prev => ({ ...prev, difficulty: level }))}
                    className={cn(
                      "flex-1 py-2 px-4 rounded-lg text-sm font-medium transition-colors",
                      formData.difficulty === level
                        ? "bg-orange-500 text-white"
                        : "bg-white/5 text-gray-400 hover:bg-white/10"
                    )}
                  >
                    {level}
                  </button>
                ))}
              </div>
            </div>

            {/* Equipment */}
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Equipment Needed
              </label>
              <div className="flex flex-wrap gap-2">
                {equipmentOptions.map(item => (
                  <button
                    key={item}
                    onClick={() => toggleEquipment(item)}
                    className={cn(
                      "px-3 py-1.5 rounded-lg text-sm font-medium transition-colors",
                      formData.equipment.includes(item)
                        ? "bg-orange-500/20 text-orange-400 border border-orange-500/50"
                        : "bg-white/5 text-gray-400 border border-white/10 hover:bg-white/10"
                    )}
                  >
                    {item}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* Upload Status */}
          {uploadStatus === 'uploading' && (
            <div className="space-y-2">
              <div className="flex items-center justify-between text-sm">
                <span className="text-gray-400">
                  {uploadStep === 'init'
                    ? 'Preparing upload...'
                    : uploadStep === 'cloudflare'
                      ? 'Uploading file to Cloudflare Stream...'
                      : uploadStep === 'saving'
                        ? 'Saving metadata...'
                        : 'Uploading...'}
                </span>
                <span className="text-orange-500">{uploadProgress}%</span>
              </div>
              <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                <div 
                  className="h-full bg-orange-500 transition-all duration-300"
                  style={{ width: `${uploadProgress}%` }}
                />
              </div>
            </div>
          )}

          {uploadStatus === 'success' && (
            <div className="flex items-center gap-3 p-4 bg-green-500/10 border border-green-500/30 rounded-xl">
              <CheckCircle className="w-5 h-5 text-green-500" />
              <p className="text-sm text-green-400">Video uploaded successfully!</p>
            </div>
          )}

          {uploadStatus === 'error' && (
            <div className="flex items-center gap-3 p-4 bg-red-500/10 border border-red-500/30 rounded-xl">
              <AlertCircle className="w-5 h-5 text-red-500" />
              <p className="text-sm text-red-400">{errorMessage}</p>
            </div>
          )}

          {/* Upload Button */}
          <button
            onClick={handleUpload}
            disabled={!file || !formData.title || !formData.bodyPart || !formData.category || uploading}
            className={cn(
              "w-full py-4 rounded-xl font-medium flex items-center justify-center gap-2 transition-colors",
              file && formData.title && formData.bodyPart && formData.category && !uploading
                ? "bg-orange-500 hover:bg-orange-600 text-white"
                : "bg-white/10 text-gray-500 cursor-not-allowed"
            )}
          >
            {uploading ? (
              <>
                <Loader2 className="w-5 h-5 animate-spin" />
                Uploading...
              </>
            ) : (
              <>
                <Upload className="w-5 h-5" />
                Upload Video
              </>
            )}
          </button>

          {/* Help Text */}
          <p className="text-xs text-gray-500 text-center">
            Videos are uploaded to Cloudflare Stream and metadata is saved to Supabase.
            <br />
            Supported formats: MP4, MOV, WebM (max 200MB)
          </p>
        </div>
      </div>
    </div>
  );
}
