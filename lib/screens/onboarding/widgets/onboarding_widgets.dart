import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../providers/theme_provider.dart';

/// Shared pieces of the onboarding steps, so every step looks the same and a
/// step file only has to describe the questions it asks.

/// A question: bold label, optional explainer, then the control.
class ObSection extends StatelessWidget {
  const ObSection({
    super.key,
    required this.theme,
    required this.label,
    required this.child,
    this.explainer,
    this.optional = false,
    this.optionalLabel,
  });

  final ThemeProvider theme;
  final String label;
  final Widget child;
  final String? explainer;
  final bool optional;
  final String? optionalLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (optional && optionalLabel != null)
              Text(
                optionalLabel!,
                style: TextStyle(color: theme.textSecondary, fontSize: 12),
              ),
          ],
        ),
        if (explainer != null) ...[
          const SizedBox(height: 6),
          Text(
            explainer!,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 28),
      ],
    );
  }
}

/// One option in a chip group.
class ObOption<T> {
  const ObOption(this.value, this.label);

  final T value;
  final String label;
}

/// Pick exactly one.
class ObSingleChoice<T> extends StatelessWidget {
  const ObSingleChoice({
    super.key,
    required this.theme,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final ThemeProvider theme;
  final List<ObOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options
          .map(
            (option) => _ObChip(
              theme: theme,
              label: option.label,
              selected: option.value == selected,
              onTap: () => onSelected(option.value),
            ),
          )
          .toList(),
    );
  }
}

/// Pick any number, including none.
class ObMultiChoice<T> extends StatelessWidget {
  const ObMultiChoice({
    super.key,
    required this.theme,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final ThemeProvider theme;
  final List<ObOption<T>> options;
  final List<T> selected;
  final ValueChanged<List<T>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selected.contains(option.value);
        return _ObChip(
          theme: theme,
          label: option.label,
          selected: isSelected,
          onTap: () {
            final next = List<T>.of(selected);
            if (isSelected) {
              next.remove(option.value);
            } else {
              next.add(option.value);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}

class _ObChip extends StatelessWidget {
  const _ObChip({
    required this.theme,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ThemeProvider theme;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      // Generous padding keeps the chip past the 44px touch target even for
      // one-word answers like "Yes".
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      backgroundColor: theme.surface,
      selectedColor: theme.accentOrange.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: selected ? theme.accentOrange : theme.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      shape: StadiumBorder(
        side: BorderSide(color: selected ? theme.accentOrange : theme.border),
      ),
      onSelected: (_) {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}

/// A free-text list: allergies and injuries are too varied to enumerate, so
/// the user can add their own on top of the common chips.
class ObFreeTextList extends StatefulWidget {
  const ObFreeTextList({
    super.key,
    required this.theme,
    required this.values,
    required this.onChanged,
    required this.hint,
  });

  final ThemeProvider theme;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final String hint;

  @override
  State<ObFreeTextList> createState() => _ObFreeTextListState();
}

class _ObFreeTextListState extends State<ObFreeTextList> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final entry = _controller.text.trim();
    if (entry.isEmpty) return;
    final lower = entry.toLowerCase();
    if (widget.values.any((value) => value.toLowerCase() == lower)) {
      _controller.clear();
      return;
    }
    HapticFeedback.lightImpact();
    widget.onChanged([...widget.values, entry]);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.values.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.values
                  .map(
                    (value) => Chip(
                      label: Text(value),
                      backgroundColor: theme.surface,
                      labelStyle: TextStyle(color: theme.textPrimary),
                      shape: StadiumBorder(
                        side: BorderSide(color: theme.border),
                      ),
                      onDeleted: () {
                        final next = List<String>.of(widget.values)
                          ..remove(value);
                        widget.onChanged(next);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ObTextField(
          theme: theme,
          controller: _controller,
          label: widget.hint,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _add(),
          suffix: IconButton(
            icon: Icon(Icons.add, color: theme.accentOrange),
            onPressed: _add,
          ),
        ),
      ],
    );
  }
}

class ObTextField extends StatelessWidget {
  const ObTextField({
    super.key,
    required this.theme,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
  });

  final ThemeProvider theme;
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(color: theme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.surface,
        suffixIcon: suffix,
        counterText: '',
        labelStyle: TextStyle(color: theme.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: theme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: theme.accentOrange),
        ),
      ),
    );
  }
}

/// A soft panel, for read-only results like the BMR estimate or the summary.
class ObCard extends StatelessWidget {
  const ObCard({
    super.key,
    required this.theme,
    required this.child,
    this.accent = false,
  });

  final ThemeProvider theme;
  final Widget child;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent
            ? theme.accentOrange.withValues(alpha: 0.12)
            : theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent ? theme.accentOrange.withValues(alpha: 0.4) : theme.border,
        ),
      ),
      child: child,
    );
  }
}

/// A consent or preference switch row, sized for a comfortable tap.
class ObToggleRow extends StatelessWidget {
  const ObToggleRow({
    super.key,
    required this.theme,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final ThemeProvider theme;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: theme.textPrimary, height: 1.35),
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: value,
              activeThumbColor: theme.accentOrange,
              onChanged: (next) {
                HapticFeedback.lightImpact();
                onChanged(next);
              },
            ),
          ],
        ),
      ),
    );
  }
}
