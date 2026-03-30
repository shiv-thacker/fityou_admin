import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/outfit.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/outfit_form_dialog.dart';

class OutfitsScreen extends StatelessWidget {
  const OutfitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                          color: AppTheme.textMuted, fontSize: 14)),
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

          Expanded(
            child: StreamBuilder<List<Outfit>>(
              stream: firestoreService.streamOutfits(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style:
                            const TextStyle(color: AppTheme.danger)),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accent));
                }
                final outfits = snapshot.data!;
                if (outfits.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.checkroom_outlined,
                            size: 56,
                            color:
                                AppTheme.textMuted.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        const Text('No outfits yet. Add the first one!',
                            style: TextStyle(color: AppTheme.textMuted)),
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

  void _showForm(BuildContext context, Outfit? outfit) {
    showDialog(
      context: context,
      builder: (_) => OutfitFormDialog(outfit: outfit),
    );
  }

  void _confirmDelete(BuildContext context, Outfit outfit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Outfit',
            style: TextStyle(color: AppTheme.textLight)),
        content: const Text(
          'Are you sure you want to delete this outfit? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger),
            onPressed: () async {
              Navigator.of(context).pop();
              await FirestoreService().deleteOutfit(outfit.outfitId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Outfit deleted'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _OutfitsGrid extends StatelessWidget {
  final List<Outfit> outfits;
  final void Function(Outfit) onEdit;
  final void Function(Outfit) onDelete;

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
  final Outfit outfit;
  final void Function(Outfit) onEdit;
  final void Function(Outfit) onDelete;

  const _OutfitCard({
    required this.outfit,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = outfit.imageUrl.isNotEmpty;
    final dateStr = outfit.createdAt != null
        ? DateFormat('MMM d, yyyy').format(outfit.createdAt!)
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
              child: hasImage
                  ? Image.network(
                      outfit.imageUrl[0],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _ImagePlaceholder(),
                    )
                  : _ImagePlaceholder(),
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
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppTheme.card,
                      backgroundImage:
                          outfit.creatorAvatar.isNotEmpty
                              ? NetworkImage(outfit.creatorAvatar)
                              : null,
                      child: outfit.creatorAvatar.isEmpty
                          ? const Icon(Icons.person,
                              size: 12,
                              color: AppTheme.textMuted)
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        outfit.creatorName,
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Tags row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (outfit.category.isNotEmpty)
                      _Tag(outfit.category, AppTheme.accent),
                    if (outfit.size.isNotEmpty)
                      _Tag(outfit.size, AppTheme.card),
                    if (outfit.gender.isNotEmpty)
                      _Tag(outfit.gender, AppTheme.card),
                  ],
                ),
                const SizedBox(height: 8),

                // Date + actions
                Row(
                  children: [
                    Text(dateStr,
                        style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11)),
                    const Spacer(),
                    InkWell(
                      onTap: () => onEdit(outfit),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.accent.withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            size: 14, color: AppTheme.accent),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => onDelete(outfit),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.danger.withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.delete_outline,
                            size: 14, color: AppTheme.danger),
                      ),
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color == AppTheme.accent
                ? AppTheme.accent
                : AppTheme.textMuted,
            fontSize: 11),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.card,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined,
            color: AppTheme.textMuted, size: 36),
      ),
    );
  }
}
