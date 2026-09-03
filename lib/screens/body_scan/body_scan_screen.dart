import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/body_scan.dart';
import '../../providers/theme_provider.dart';
import '../../services/body_scan_service.dart';
import '../../widgets/body_scan_sources_citation.dart';
import 'body_scan_flow_screen.dart';

/// Body scan hub: the latest result, how it is trending, and past scans.
class BodyScanScreen extends StatefulWidget {
  const BodyScanScreen({super.key});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen> {
  final BodyScanService _service = BodyScanService();

  List<BodyScan> _scans = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final scans = await _service.fetchHistory();
      if (!mounted) return;
      setState(() {
        _scans = scans;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _loading = false;
        _error = l10n.bodyScanErrorLoadHistory;
      });
    }
  }

  Future<void> _startScan() async {
    final result = await Navigator.of(context).push<BodyScan>(
      MaterialPageRoute(builder: (_) => const BodyScanFlowScreen()),
    );
    if (result != null) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context);
    final latest = _scans.isNotEmpty ? _scans.first : null;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        foregroundColor: theme.textPrimary,
        title: Text(l10n.bodyScanTitle),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: theme.accentOrange,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: TextStyle(color: theme.textSecondary),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (latest == null)
                      _buildEmptyState(theme, l10n)
                    else
                      _buildLatest(theme, l10n, latest),
                    const SizedBox(height: 20),
                    _buildCta(theme, l10n, latest),
                    if (_scans.length > 1) ...[
                      const SizedBox(height: 28),
                      Text(
                        l10n.bodyScanHistoryTitle,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._scans.skip(1).map((s) => _historyRow(theme, l10n, s)),
                    ],
                    const SizedBox(height: 24),
                    BodyScanSourcesCitation(theme: theme, compact: true),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.accessibility_new, size: 34, color: theme.accentOrange),
          const SizedBox(height: 14),
          Text(
            l10n.bodyScanEmptyTitle,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.bodyScanEmptyBody,
            style: TextStyle(color: theme.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildLatest(
    ThemeProvider theme,
    AppLocalizations l10n,
    BodyScan latest,
  ) {
    // Comparing against the previous scan is the point of scanning twice, so
    // surface the delta rather than making the user do the subtraction.
    final previous = _scans.length > 1 ? _scans[1] : null;
    final delta = (latest.bodyFatPercentage != null &&
            previous?.bodyFatPercentage != null)
        ? latest.bodyFatPercentage! - previous!.bodyFatPercentage!
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.bodyScanLatestTitle,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              DateFormat.yMMMd().format(latest.scannedAt),
              style: TextStyle(color: theme.textSecondary, fontSize: 12.5),
            ),
          ],
        ),
        if (delta != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                delta <= 0 ? Icons.trending_down : Icons.trending_up,
                size: 16,
                color: delta <= 0 ? const Color(0xFF4ADE80) : theme.accentOrange,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.bodyScanDeltaSinceLast(delta.abs().toStringAsFixed(1)),
                style: TextStyle(color: theme.textSecondary, fontSize: 12.5),
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        BodyScanMetricsGrid(theme: theme, scan: latest),
      ],
    );
  }

  Widget _buildCta(
    ThemeProvider theme,
    AppLocalizations l10n,
    BodyScan? latest,
  ) {
    // Composition moves slowly and month-to-month agreement is the honest
    // limit of this method, so nudge rather than invite constant rescanning.
    final weeksSince = latest == null
        ? null
        : DateTime.now().difference(latest.scannedAt).inDays ~/ 7;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              latest == null ? l10n.bodyScanStartCta : l10n.bodyScanRescanCta,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
        ),
        if (weeksSince != null && weeksSince < 4) ...[
          const SizedBox(height: 10),
          Text(
            l10n.bodyScanRescanHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.textSecondary, fontSize: 12.5),
          ),
        ],
      ],
    );
  }

  Widget _historyRow(
    ThemeProvider theme,
    AppLocalizations l10n,
    BodyScan scan,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              DateFormat.yMMMd().format(scan.scannedAt),
              style: TextStyle(
                color: theme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (scan.bodyFatPercentage != null)
            Text(
              '${scan.bodyFatPercentage!.toStringAsFixed(1)}%',
              style: TextStyle(
                color: theme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            )
          else
            Text(
              l10n.bodyScanNoComposition,
              style: TextStyle(color: theme.textSecondary, fontSize: 12.5),
            ),
        ],
      ),
    );
  }
}
