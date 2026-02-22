import 'package:chewie/chewie.dart';
import 'package:cine_stream/features/dashboard/home/domain/entities/movie_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class MoviePlayerPage extends StatefulWidget {
  final MovieEntity movie;
  final String videoUrl;

  const MoviePlayerPage({
    super.key,
    required this.movie,
    required this.videoUrl,
  });

  @override
  State<MoviePlayerPage> createState() => _MoviePlayerPageState();
}

class _MoviePlayerPageState extends State<MoviePlayerPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final colors = Theme.of(context).colorScheme;

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showOptions: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        materialProgressColors: ChewieProgressColors(
          playedColor: colors.primary,
          handleColor: colors.primary,
          // Renders over video frames — white is intentional
          bufferedColor: Colors.white38,
          backgroundColor: Colors.white12,
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) => _PlayerError(
          message: errorMessage,
          onRetry: () {
            setState(() => _error = null);
            _disposePlayer();
            _initPlayer();
          },
        ),
      );

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _disposePlayer() {
    _chewieController?.dispose();
    _chewieController = null;
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    _isInitialized = false;
  }

  @override
  void dispose() {
    _disposePlayer();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background, // theme background, not black
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Player — black scoped only to this area ───────────────
            ColoredBox(
              color: Colors.black,
              child: AspectRatio(
                aspectRatio: _isInitialized
                    ? _videoPlayerController!.value.aspectRatio
                    : 16 / 9,
                child: _error != null
                    ? _PlayerError(
                        message: _error!,
                        onRetry: () {
                          setState(() => _error = null);
                          _disposePlayer();
                          _initPlayer();
                        },
                      )
                    : !_isInitialized
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: colors.primary),
                                const SizedBox(height: 16),
                                // white — always on black player bg
                                const Text(
                                  'Loading stream...',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : Chewie(controller: _chewieController!),
              ),
            ),

            // ── Movie info — gradient background ──────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.primary.withOpacity(0.35),
                      colors.surface,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back + title
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colors.onSurface.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: colors.onSurface,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.movie.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Meta row
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _MetaChip('${widget.movie.releaseYear}'),
                        _MetaChip(widget.movie.formattedDuration),
                        if (widget.movie.director.isNotEmpty)
                          _MetaChip(widget.movie.director),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Genres
                    if (widget.movie.genres.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: widget.movie.genres
                            .map(
                              (g) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: colors.primary.withOpacity(0.3)),
                                ),
                                child: Text(
                                  g,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 14),

                    // Description
                    Text(
                      widget.movie.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: colors.onSurface.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;
  const _MetaChip(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.onSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PlayerError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PlayerError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    // Sits inside the black player area — white text intentional
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Failed to load video',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your device may not support this video format.\nTry a lower quality if available.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white24, fontSize: 11),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}