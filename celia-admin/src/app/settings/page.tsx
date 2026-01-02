'use client';

import { useEffect, useState } from 'react';
import { Save, Key, Database, Cloud, Bell, Shield } from 'lucide-react';
import Header from '@/components/Header';
import { cn } from '@/lib/utils';

export default function SettingsPage() {
  const [saving, setSaving] = useState(false);
  const [status, setStatus] = useState<{
    ok: boolean;
    missing: string[];
    supabaseOk: boolean;
    supabaseError: string | null;
    falOk: boolean;
    cloudflareOk: boolean;
    kling?: { baseModel: string | null; audioModel: string | null };
  } | null>(null);
  const [loadingStatus, setLoadingStatus] = useState(true);
  const [settings, setSettings] = useState({
    cloudflareAccountId: process.env.CLOUDFLARE_ACCOUNT_ID || '',
    klingApiKey: '',
    notifyOnUpload: true,
    notifyOnGeneration: true,
    autoPublish: false,
  });

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch('/api/admin/status', { method: 'GET' });
        const json = await res.json();
        setStatus(json);
      } catch (_) {
        setStatus({
          ok: false,
          missing: ['Unable to reach /api/admin/status'],
          supabaseOk: false,
          supabaseError: 'Failed to load status',
          falOk: false,
          cloudflareOk: false,
          kling: { baseModel: null, audioModel: null },
        });
      } finally {
        setLoadingStatus(false);
      }
    })();
  }, []);

  const handleSave = async () => {
    setSaving(true);
    // Simulate save
    await new Promise(resolve => setTimeout(resolve, 1000));
    setSaving(false);
  };

  return (
    <div className="min-h-screen bg-[#0F1219]">
      <Header showSearch={false} />

      <div className="p-8 max-w-3xl mx-auto">
        {/* Page Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-white mb-2">Settings</h1>
          <p className="text-gray-500">Manage your dashboard configuration</p>
        </div>

        {/* API Keys Section */}
        <div className="glass rounded-2xl p-6 mb-6">
          <div className="flex items-center gap-3 mb-6">
            <div className="w-10 h-10 bg-orange-500/20 rounded-xl flex items-center justify-center">
              <Key className="w-5 h-5 text-orange-500" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-white">API Keys</h2>
              <p className="text-sm text-gray-500">Configure your service credentials</p>
            </div>
          </div>

          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Supabase URL
              </label>
              <input
                type="text"
                value={process.env.NEXT_PUBLIC_SUPABASE_URL || ''}
                disabled
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-gray-500 cursor-not-allowed"
              />
              <p className="text-xs text-gray-600 mt-1">Configured via environment variables</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Cloudflare Account ID
              </label>
              <input
                type="text"
                value={settings.cloudflareAccountId}
                onChange={(e) => setSettings(prev => ({ ...prev, cloudflareAccountId: e.target.value }))}
                placeholder="Enter your Cloudflare Account ID"
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-orange-500/50"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Kling API Key
              </label>
              <input
                type="password"
                value={settings.klingApiKey}
                onChange={(e) => setSettings(prev => ({ ...prev, klingApiKey: e.target.value }))}
                placeholder="Enter your Kling API key for AI generation"
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-orange-500/50"
              />
              <p className="text-xs text-gray-600 mt-1">Get your API key from fal.ai</p>
            </div>
          </div>
        </div>

        {/* Integrations Status */}
        <div className="glass rounded-2xl p-6 mb-6">
          <div className="flex items-center gap-3 mb-6">
            <div className="w-10 h-10 bg-blue-500/20 rounded-xl flex items-center justify-center">
              <Cloud className="w-5 h-5 text-blue-500" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-white">Integrations</h2>
              <p className="text-sm text-gray-500">Service connection status</p>
            </div>
          </div>

          <div className="space-y-4">
            {[
              { name: 'Supabase Database', status: status?.supabaseOk ? 'connected' : 'not_configured', icon: Database },
              { name: 'Cloudflare Stream', status: status?.cloudflareOk ? 'connected' : 'not_configured', icon: Cloud },
              { name: 'Kling AI (fal.ai)', status: status?.falOk ? 'connected' : 'not_configured', icon: Shield },
            ].map((service) => (
              <div key={service.name} className="flex items-center justify-between p-4 bg-white/5 rounded-xl">
                <div className="flex items-center gap-3">
                  <service.icon className="w-5 h-5 text-gray-400" />
                  <span className="text-white">{service.name}</span>
                </div>
                <span className={cn(
                  "px-3 py-1 rounded-full text-xs font-medium",
                  service.status === 'connected' 
                    ? 'bg-green-500/20 text-green-400'
                    : 'bg-yellow-500/20 text-yellow-400'
                )}>
                  {service.status === 'connected' ? 'Connected' : 'Not Configured'}
                </span>
              </div>
            ))}
          </div>

          {!loadingStatus && status && status.missing.length > 0 && (
            <div className="mt-4 text-xs text-gray-400">
              <p className="text-gray-300 font-medium mb-1">Missing configuration:</p>
              <ul className="list-disc ml-5 space-y-1">
                {status.missing.map((m) => (
                  <li key={m}>{m}</li>
                ))}
              </ul>
              {status.supabaseError && (
                <p className="mt-2 text-gray-500">Supabase check: {status.supabaseError}</p>
              )}
              <p className="mt-2 text-gray-500">
                These must be provided via server environment (e.g. `.env.local`). The dashboard UI does not store secret keys.
              </p>
            </div>
          )}

          {!loadingStatus && status?.kling && (
            <div className="mt-4 text-xs text-gray-500">
              <p>
                Kling model (base): <span className="text-gray-300">{status.kling.baseModel || 'default (hardcoded fallback)'}</span>
              </p>
              <p>
                Kling model (audio): <span className="text-gray-300">{status.kling.audioModel || 'not configured'}</span>
              </p>
            </div>
          )}
        </div>

        {/* Notifications */}
        <div className="glass rounded-2xl p-6 mb-6">
          <div className="flex items-center gap-3 mb-6">
            <div className="w-10 h-10 bg-purple-500/20 rounded-xl flex items-center justify-center">
              <Bell className="w-5 h-5 text-purple-500" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-white">Notifications</h2>
              <p className="text-sm text-gray-500">Configure alert preferences</p>
            </div>
          </div>

          <div className="space-y-4">
            <div className="flex items-center justify-between p-4 bg-white/5 rounded-xl">
              <div>
                <p className="text-white">Video Upload Complete</p>
                <p className="text-sm text-gray-500">Get notified when videos finish processing</p>
              </div>
              <button
                onClick={() => setSettings(prev => ({ ...prev, notifyOnUpload: !prev.notifyOnUpload }))}
                className={cn(
                  "w-12 h-6 rounded-full transition-colors relative",
                  settings.notifyOnUpload ? 'bg-orange-500' : 'bg-gray-600'
                )}
              >
                <span className={cn(
                  "absolute top-1 w-4 h-4 bg-white rounded-full transition-transform",
                  settings.notifyOnUpload ? 'translate-x-7' : 'translate-x-1'
                )} />
              </button>
            </div>

            <div className="flex items-center justify-between p-4 bg-white/5 rounded-xl">
              <div>
                <p className="text-white">AI Generation Complete</p>
                <p className="text-sm text-gray-500">Get notified when AI videos are ready</p>
              </div>
              <button
                onClick={() => setSettings(prev => ({ ...prev, notifyOnGeneration: !prev.notifyOnGeneration }))}
                className={cn(
                  "w-12 h-6 rounded-full transition-colors relative",
                  settings.notifyOnGeneration ? 'bg-orange-500' : 'bg-gray-600'
                )}
              >
                <span className={cn(
                  "absolute top-1 w-4 h-4 bg-white rounded-full transition-transform",
                  settings.notifyOnGeneration ? 'translate-x-7' : 'translate-x-1'
                )} />
              </button>
            </div>

            <div className="flex items-center justify-between p-4 bg-white/5 rounded-xl">
              <div>
                <p className="text-white">Auto-Publish Videos</p>
                <p className="text-sm text-gray-500">Automatically publish videos after processing</p>
              </div>
              <button
                onClick={() => setSettings(prev => ({ ...prev, autoPublish: !prev.autoPublish }))}
                className={cn(
                  "w-12 h-6 rounded-full transition-colors relative",
                  settings.autoPublish ? 'bg-orange-500' : 'bg-gray-600'
                )}
              >
                <span className={cn(
                  "absolute top-1 w-4 h-4 bg-white rounded-full transition-transform",
                  settings.autoPublish ? 'translate-x-7' : 'translate-x-1'
                )} />
              </button>
            </div>
          </div>
        </div>

        {/* Save Button */}
        <button
          onClick={handleSave}
          disabled={saving}
          className="w-full py-4 bg-orange-500 hover:bg-orange-600 disabled:bg-orange-500/50 text-white font-medium rounded-xl transition-colors flex items-center justify-center gap-2"
        >
          {saving ? (
            <>
              <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              Saving...
            </>
          ) : (
            <>
              <Save className="w-5 h-5" />
              Save Settings
            </>
          )}
        </button>
      </div>
    </div>
  );
}

