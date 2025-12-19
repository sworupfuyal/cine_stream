import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(theme),
                const SizedBox(height: 16),
                _categories(theme), // ✅ now defined
                const SizedBox(height: 20),
                _featuredBanner(theme),
                const SizedBox(height: 30),
                _movieSection(title: "Continue Watching"),
                _movieSection(title: "Your Next Watch"),
                _movieSection(title: "International TV Shows"),
                _movieSection(title: "Relentless Crime Dramas"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _header(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        "Results for Sworup Phuyal",
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  // ---------- CATEGORIES (FIXED) ----------
  Widget _categories(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip("TV Shows", theme),
            const SizedBox(width: 8),
            _chip("Movies", theme),
            const SizedBox(width: 8),
            _chip("Categories", theme, icon: Icons.expand_more),
          ],
        ),
      ),
    );
  }

  // ---------- CHIP ----------
  Widget _chip(String text, ThemeData theme, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
          if (icon != null) ...[
            const SizedBox(width: 4),
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onSurface,
            ),
          ],
        ],
      ),
    );
  }

  // ---------- FEATURED BANNER ----------
  Widget _featuredBanner(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surface,
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 16,
                right: 16,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(
                    Icons.play_arrow,
                    size: 30,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- MOVIE SECTION ----------
  Widget _movieSection({required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 12,
              childAspectRatio: 2 / 3,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return _movieCard(context);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------- MOVIE CARD ----------
  Widget _movieCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.movie,
          size: 40,
          color: Colors.white38,
        ),
      ),
    );
  }
}
