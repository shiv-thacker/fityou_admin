import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../data/datasources/creators_datasource.dart';
import '../../data/repositories/creators_repository_impl.dart';
import '../../domain/entities/creator_entity.dart';
import '../../domain/repositories/creators_repository.dart';
import '../widgets/creator_form_dialog.dart';

class CreatorsScreen extends StatelessWidget {
  const CreatorsScreen({super.key});

  CreatorsRepository get _repo =>
      CreatorsRepositoryImpl(CreatorsDatasource());

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
                  Text('Creators',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  const Text('Manage fashion creators',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 14)),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showForm(context, null),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Creator'),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<CreatorEntity>>(
              stream: _repo.streamCreators(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return AppErrorView(
                      message: 'Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) return const AppLoader();

                final creators = snapshot.data!;
                if (creators.isEmpty) {
                  return const _EmptyState(
                      message: 'No creators yet. Add your first creator!');
                }
                return _CreatorsTable(
                  creators: creators,
                  onEdit: (c) => _showForm(context, c),
                  onDelete: (c) => _confirmDelete(context, c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, CreatorEntity? creator) {
    showDialog(
      context: context,
      builder: (_) => CreatorFormDialog(creator: creator),
    );
  }

  void _confirmDelete(BuildContext context, CreatorEntity creator) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Creator',
            style: TextStyle(color: AppColors.textLight)),
        content: Text(
          'Are you sure you want to delete "${creator.name}"? '
          'This action cannot be undone.',
          style: const TextStyle(color: AppColors.textMuted),
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
              await _repo.deleteCreator(creator.creatorId);
              if (context.mounted) {
                context.showSuccessSnackBar(
                    '${creator.name} deleted');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Table ──────────────────────────────────────────────────────────────────

class _CreatorsTable extends StatelessWidget {
  final List<CreatorEntity> creators;
  final void Function(CreatorEntity) onEdit;
  final void Function(CreatorEntity) onDelete;

  const _CreatorsTable({
    required this.creators,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.white12)),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 48),
                _HeaderCell('Name',      flex: 2),
                _HeaderCell('Email',     flex: 3),
                _HeaderCell('Instagram', flex: 2),
                _HeaderCell('Actions',   flex: 1),
              ],
            ),
          ),

          // Data rows
          Expanded(
            child: ListView.separated(
              itemCount: creators.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.white12),
              itemBuilder: (_, i) => _CreatorRow(
                creator: creators[i],
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
          ),

          // Footer count
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white12)),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Text(
              '${creators.length} creator${creators.length == 1 ? '' : 's'}',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatorRow extends StatelessWidget {
  final CreatorEntity creator;
  final void Function(CreatorEntity) onEdit;
  final void Function(CreatorEntity) onDelete;

  const _CreatorRow({
    required this.creator,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _AvatarCircle(
            url: creator.profileImage,
            fallbackLabel: creator.name.isNotEmpty
                ? creator.name[0].toUpperCase()
                : '?',
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(creator.name,
                style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 3,
            child: Text(creator.email,
                style: const TextStyle(color: AppColors.textMuted),
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.alternate_email,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(creator.instagram,
                      style:
                          const TextStyle(color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppEditButton(onTap: () => onEdit(creator)),
                const SizedBox(width: 6),
                AppDeleteButton(onTap: () => onDelete(creator)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _HeaderCell(this.label, {this.flex = 1});

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline,
                size: 56,
                color: AppColors.textMuted.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
}

/// Circle avatar with graceful network image fallback for Flutter Web.
class _AvatarCircle extends StatelessWidget {
  final String url;
  final String fallbackLabel;
  final double radius;

  const _AvatarCircle({
    required this.url,
    this.fallbackLabel = '?',
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.card,
        child: Text(
          fallbackLabel,
          style: const TextStyle(
              color: AppColors.textLight, fontWeight: FontWeight.bold),
        ),
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
          errorBuilder: (_, __, ___) => Text(
            fallbackLabel,
            style: const TextStyle(
                color: AppColors.textLight, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
