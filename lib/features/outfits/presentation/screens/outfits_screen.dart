import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_size.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/cloudinary_url.dart';
import '../../data/datasources/outfits_datasource.dart';
import '../../data/repositories/outfits_repository_impl.dart';
import '../../domain/entities/outfit_entity.dart';
import '../../domain/repositories/outfits_repository.dart';
import '../widgets/outfit_form_dialog.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> {
  final OutfitsRepository _repo = OutfitsRepositoryImpl(OutfitsDatasource());

  /// Created once so rebuilds don't resubscribe (which flashes the loader).
  late final Stream<List<OutfitEntity>> _outfits = _repo.streamOutfits();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Outfits',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  const Text('Manage fashion outfits',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 14)),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showForm(context, null),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Outfit'),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Grid ─────────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<OutfitEntity>>(
              stream: _outfits,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return AppErrorView(
                      message: 'Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) return const AppLoader();

                final outfits = snapshot.data!;
                if (outfits.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.checkroom_outlined,
                            size: 56,
                            color: AppColors.textMuted.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        const Text(
                            'No outfits yet. Add the first one!',
                            style: TextStyle(
                                color: AppColors.textMuted)),
                      ],
                    ),
                  );
                }
                return _OutfitsGrid(
                  outfits: outfits,
                  onEdit: (o) => _showForm(context, o),
                  onDelete: (o) => _confirmDelete(context, o),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, OutfitEntity? outfit) {
    showDialog(
      context: context,
      builder: (_) => OutfitFormDialog(outfit: outfit),
    );
  }

  void _confirmDelete(BuildContext context, OutfitEntity outfit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Outfit',
            style: TextStyle(color: AppColors.textLight)),
        content: const Text(
          'Are you sure you want to delete this outfit? '
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _repo.deleteOutfit(outfit.outfitId);
                if (context.mounted) {
                  context.showSuccessSnackBar('Outfit deleted');
                }
              } catch (e) {
                if (context.mounted) {
                  context.showErrorSnackBar('Could not delete outfit: $e');
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Grid ───────────────────────────────────────────────────────────────────

class _OutfitsGrid extends StatelessWidget {
  final List<OutfitEntity> outfits;
  final void Function(OutfitEntity) onEdit;
  final void Function(OutfitEntity) onDelete;

  const _OutfitsGrid({
    required this.outfits,
    required this.onEdit,
    required this.onDelete,
  });

  static const double _maxCardWidth = 260;
  static const double _spacing = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            ((constraints.maxWidth + _spacing) / (_maxCardWidth + _spacing))
                .ceil()
                .clamp(1, 8);
        final cardWidth =
            (constraints.maxWidth - _spacing * (columns - 1)) / columns;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: _spacing,
            crossAxisSpacing: _spacing,
            mainAxisExtent:
                cardWidth / _OutfitCard.imageAspectRatio + _OutfitCard.infoHeight,
          ),
          itemCount: outfits.length,
          itemBuilder: (_, i) => _OutfitCard(
            key: ValueKey(outfits[i].outfitId),
            outfit: outfits[i],
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        );
      },
    );
  }
}

class _OutfitCard extends StatelessWidget {
  final OutfitEntity outfit;
  final void Function(OutfitEntity) onEdit;
  final void Function(OutfitEntity) onDelete;

  const _OutfitCard({
    super.key,
    required this.outfit,
    required this.onEdit,
    required this.onDelete,
  });

  /// Same 3:4 portrait frame the user-facing app uses for outfit photos.
  static const double imageAspectRatio = 3 / 4;

  /// Fixed so every card's photo gets the same frame regardless of how
  /// many tags / how much description an outfit has.
  static const double infoHeight = 176;

  @override
  Widget build(BuildContext context) {
    final hasImage = outfit.imageUrl.isNotEmpty;
    final dateStr  = outfit.createdAt != null
        ? DateFormat('MMM d, yyyy').format(outfit.createdAt!)
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSize.radiusLg),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          AspectRatio(
            aspectRatio: imageAspectRatio,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSize.radiusLg)),
              child: hasImage
                  ? _ImageCarousel(urls: outfit.imageUrl)
                  : const _ImagePlaceholder(),
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Creator
                  Row(
                    children: [
                      _AvatarCircle(url: outfit.creatorAvatar, radius: 12),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          outfit.creatorName,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Tags: one row; whatever doesn't fit is hidden.
                  SizedBox(
                    height: 22,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      clipBehavior: Clip.hardEdge,
                      children: [
                        if (outfit.category.isNotEmpty)
                          _Tag(outfit.category, AppColors.accent),
                        if (outfit.size.isNotEmpty)
                          _Tag(outfit.size, AppColors.card),
                        if (outfit.gender.isNotEmpty)
                          _Tag(outfit.gender, AppColors.card),
                        ...outfit.tags
                            .take(6)
                            .map((t) => _Tag(t, AppColors.card)),
                        if (outfit.tags.length > 6)
                          _Tag('+${outfit.tags.length - 6}', AppColors.card),
                      ],
                    ),
                  ),
                  if (outfit.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      outfit.description,
                      style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          height: 1.25),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (outfit.outfitLinks.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${outfit.outfitLinks.length} shop link'
                      '${outfit.outfitLinks.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                  const Spacer(),

                  // Date + actions
                  Row(
                    children: [
                      Text(dateStr,
                          style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11)),
                      const Spacer(),
                      AppEditButton(onTap: () => onEdit(outfit)),
                      const SizedBox(width: 6),
                      AppDeleteButton(onTap: () => onDelete(outfit)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSize.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color == AppColors.accent
              ? AppColors.accent
              : AppColors.textMuted,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.card,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              color: AppColors.textMuted, size: 36),
        ),
      );
}

/// Circle avatar with graceful network image loading for Flutter Web.
class _AvatarCircle extends StatelessWidget {
  final String url;
  final double radius;

  const _AvatarCircle({required this.url, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.card,
        child: Icon(Icons.person, size: radius, color: AppColors.textMuted),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.card,
      child: ClipOval(
        child: Image.network(
          CloudinaryUrl.deliverable(url),
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.person,
            size: radius,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// All outfit images, one at a time, with arrows, dots and a "1/3" counter.
class _ImageCarousel extends StatefulWidget {
  final List<String> urls;

  const _ImageCarousel({required this.urls});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void didUpdateWidget(covariant _ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Images were edited (e.g. 3 → 1): don't stay on a page that's gone.
    if (_index >= widget.urls.length) {
      _index = 0;
      if (_controller.hasClients) _controller.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) => _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );

  @override
  Widget build(BuildContext context) {
    final count = widget.urls.length;
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: count,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (_, i) => _NetImage(url: widget.urls[i]),
        ),
        if (count > 1) ...[
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppSize.radiusSm),
              ),
              child: Text(
                '${_index + 1}/$count',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
          if (_index > 0)
            Positioned(
              left: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ArrowButton(
                  icon: Icons.chevron_left,
                  onTap: () => _goTo(_index - 1),
                ),
              ),
            ),
          if (_index < count - 1)
            Positioned(
              right: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ArrowButton(
                  icon: Icons.chevron_right,
                  onTap: () => _goTo(_index + 1),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < count; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _index ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// Outfit photo with a spinner while loading and a placeholder on error.
class _NetImage extends StatelessWidget {
  final String url;

  const _NetImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      CloudinaryUrl.deliverable(url),
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.card,
          child: const Center(
            child: CircularProgressIndicator(
                color: AppColors.accent, strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
    );
  }
}
