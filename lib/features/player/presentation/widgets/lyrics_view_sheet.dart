import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/lrc_parser.dart';
import '../../library/domain/models/song_model.dart';

class LyricsViewSheet extends StatefulWidget {
  final SongModel song;
  final Duration currentPosition;

  const LyricsViewSheet({
    super.key,
    required this.song,
    required this.currentPosition,
  });

  static void show(BuildContext context, SongModel song, Duration currentPosition) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LyricsViewSheet(
        song: song,
        currentPosition: currentPosition,
      ),
    );
  }

  @override
  State<LyricsViewSheet> createState() => _LyricsViewSheetState();
}

class _LyricsViewSheetState extends State<LyricsViewSheet> {
  List<LyricLine> _lyrics = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLyrics() async {
    try {
      final filePath = widget.song.filePath;
      if (filePath.isNotEmpty) {
        final lastDotIndex = filePath.lastIndexOf('.');
        final lrcPath = lastDotIndex != -1
            ? '${filePath.substring(0, lastDotIndex)}.lrc'
            : '$filePath.lrc';

        final file = File(lrcPath);
        if (await file.exists()) {
          final content = await file.readAsString();
          final parsed = LrcParser.parse(content);
          if (mounted) {
            setState(() {
              _lyrics = parsed;
              _isLoading = false;
            });
            return;
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _lyrics = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Lyrics', style: AppTypography.title2),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : _lyrics.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.lyrics_rounded,
                                size: 54,
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No Synced Lyrics Found',
                                style: AppTypography.headline,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Place a .lrc file with the same name as the song in your music folder to enjoy synchronized real-time lyrics.',
                                textAlign: TextAlign.center,
                                style: AppTypography.subhead,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _lyrics.length,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          itemBuilder: (context, index) {
                            final line = _lyrics[index];
                            final isCurrent = widget.currentPosition >= line.time &&
                                (index == _lyrics.length - 1 ||
                                    widget.currentPosition < _lyrics[index + 1].time);

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                line.text,
                                style: TextStyle(
                                  fontSize: isCurrent ? 24 : 18,
                                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                                  color: isCurrent
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary.withValues(alpha: 0.6),
                                  height: 1.4,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}
