import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_size.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../data/datasources/outfits_datasource.dart';
import '../../data/repositories/outfits_repository_impl.dart';
import '../../domain/entities/outfit_entity.dart';
import '../../domain/repositories/outfits_repository.dart';
import '../widgets/outfit_form_dialog.dart';

class OutfitsScreen extends StatelessWidget {
  const OutfitsScreen({super.key});

  OutfitsRepository get _repo =>
      OutfitsRepositoryImpl(OutfitsDatasource());

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
              stream: _repo.streamOutfits(),
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
                            color: AppColors.textMuted.withOpacity(0.4)),
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
              await _repo.deleteOutfit(outfit.outfitId);
              if (context.mounted) {
                context.showSuccessSnackBar('Outfit deleted');
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

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: outfits.length,
      itemBuilder: (_, i) => _OutfitCard(
        outfit: outfits[i],
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

class _OutfitCard extends StatelessWidget {
  final OutfitEntity outfit;
  final void Function(OutfitEntity) onEdit;
  final void Function(OutfitEntity) onDelete;

  const _OutfitCard({
    required this.outfit,
    required this.onEdit,
    required this.onDelete,
  });

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
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSize.radiusLg)),
              child: hasImage
                  ? _NetImage(url: outfit.imageUrl[0])
                  : const _ImagePlaceholder(),
            ),
          ),

          // Info
          Padding(
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

                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
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
                const SizedBox(height: 8),

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
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSize.radiusSm),
        border: Border.all(color: color.withOpacity(0.4)),
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
          url,
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

/// Loads a network image that works on Flutter Web (handles CORS gracefully).
class _NetImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const _NetImage({required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: double.infinity,
      fit: fit,
      headers: const {'Access-Control-Allow-Origin': '*'},
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
