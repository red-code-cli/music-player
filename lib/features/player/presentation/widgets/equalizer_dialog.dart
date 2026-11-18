import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class EqualizerDialog extends StatefulWidget {
  const EqualizerDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const EqualizerDialog(),
    );
  }

  @override
  State<EqualizerDialog> createState() => _EqualizerDialogState();
}

class _EqualizerDialogState extends State<EqualizerDialog> {
  bool _enabled = true;
  double _bassBoost = 0.5;
  String _selectedPreset = 'Bass Boost';
  final List<double> _bandGains = [0.6, 0.4, 0.0, 0.3, 0.5];

  final List<String> _presets = [
    'Flat',
    'Bass Boost',
    'Rock',
    'Pop',
    'Jazz',
    'Electronic',
  ];

  final List<String> _bands = ['60 Hz', '230 Hz', '910 Hz', '3.6 kHz', '14 kHz'];

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      switch (preset) {
        case 'Flat':
          for (var i = 0; i < _bandGains.length; i++) {
            _bandGains[i] = 0.0;
          }
          _bassBoost = 0.0;
          break;
        case 'Bass Boost':
          _bandGains[0] = 0.8;
          _bandGains[1] = 0.5;
          _bandGains[2] = 0.0;
          _bandGains[3] = 0.2;
          _bandGains[4] = 0.4;
          _bassBoost = 0.75;
          break;
        case 'Rock':
          _bandGains[0] = 0.6;
          _bandGains[1] = 0.2;
          _bandGains[2] = -0.2;
          _bandGains[3] = 0.4;
          _bandGains[4] = 0.6;
          _bassBoost = 0.4;
          break;
        case 'Pop':
          _bandGains[0] = -0.2;
          _bandGains[1] = 0.2;
          _bandGains[2] = 0.5;
          _bandGains[3] = 0.3;
          _bandGains[4] = -0.1;
          _bassBoost = 0.3;
          break;
        case 'Jazz':
          _bandGains[0] = 0.4;
          _bandGains[1] = 0.2;
          _bandGains[2] = -0.1;
          _bandGains[3] = 0.2;
          _bandGains[4] = 0.4;
          _bassBoost = 0.3;
          break;
        case 'Electronic':
          _bandGains[0] = 0.7;
          _bandGains[1] = 0.3;
          _bandGains[2] = 0.0;
          _bandGains[3] = 0.2;
          _bandGains[4] = 0.6;
          _bassBoost = 0.6;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHover,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Equalizer', style: AppTypography.title2),
                Switch(
                  value: _enabled,
                  activeThumbColor: AppColors.accent,
                  onChanged: (val) {
                    setState(() => _enabled = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Presets Horizontal list
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _presets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final preset = _presets[i];
                  final isSelected = _selectedPreset == preset;
                  return ChoiceChip(
                    label: Text(preset),
                    selected: isSelected,
                    onSelected: _enabled ? (_) => _applyPreset(preset) : null,
                    selectedColor: AppColors.accent,
                    backgroundColor: AppColors.surfaceElevated,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Equalizer Sliders
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_bands.length, (index) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 140,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Slider(
                            value: _bandGains[index],
                            min: -1.0,
                            max: 1.0,
                            activeColor: AppColors.accent,
                            inactiveColor: AppColors.surfaceHover,
                            onChanged: _enabled
                                ? (val) {
                                    setState(() {
                                      _bandGains[index] = val;
                                      _selectedPreset = 'Custom';
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _bands[index],
                        style: AppTypography.caption2,
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            // Bass Boost Slider
            Row(
              children: [
                const Icon(Icons.surround_sound_rounded, color: AppColors.accent),
                const SizedBox(width: 12),
                const Text('Bass Boost', style: AppTypography.headline),
                Expanded(
                  child: Slider(
                    value: _bassBoost,
                    min: 0.0,
                    max: 1.0,
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.surfaceHover,
                    onChanged: _enabled
                        ? (val) {
                            setState(() => _bassBoost = val);
                          }
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
