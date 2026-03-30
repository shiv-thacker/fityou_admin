import 'package:flutter/material.dart';
import '../models/creator.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/creator_form_dialog.dart';

class CreatorsScreen extends StatelessWidget {
  const CreatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header
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
                          color: AppTheme.textMuted, fontSize: 14)),
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

          // Table
          Expanded(
            child: StreamBuilder<List<Creator>>(
              stream: firestoreService.streamCreators(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _ErrorState(error: snapshot.error.toString());
                }
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accent));
                }
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

  void _showForm(BuildContext context, Creator? creator) {
    showDialog(
      context: context,
      builder: (_) => CreatorFormDialog(creator: creator),
    );
  }

  void _confirmDelete(BuildContext context, Creator creator) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Creator',
            style: TextStyle(color: AppTheme.textLight)),
        content: Text(
          'Are you sure you want to delete "${creator.name}"? This action cannot be undone.',
          style: const TextStyle(color: AppTheme.textMuted),
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
              await FirestoreService().deleteCreator(creator.creatorId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${creator.name} deleted'),
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

class _CreatorsTable extends StatelessWidget {
  final List<Creator> creators;
  final void Function(Creator) onEdit;
  final void Function(Creator) onDelete;

  const _CreatorsTable({
    required this.creators,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.white12)),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 48),
                _HeaderCell('Name', flex: 2),
                _HeaderCell('Email', flex: 3),
                _HeaderCell('Instagram', flex: 2),
                _HeaderCell('Actions', flex: 1),
              ],
            ),
          ),

          // Rows
          Expanded(
            child: ListView.separated(
              itemCount: creators.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.white12),
              itemBuilder: (context, i) {
                final c = creators[i];
                return _CreatorRow(
                    creator: c, onEdit: onEdit, onDelete: onDelete);
              },
            ),
          ),

          // Footer count
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border:
                  Border(top: BorderSide(color: Colors.white12)),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Text(
              '${creators.length} creator${creators.length == 1 ? '' : 's'}',
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatorRow extends StatelessWidget {
  final Creator creator;
  final void Function(Creator) onEdit;
  final void Function(Creator) onDelete;

  const _CreatorRow({
    required this.creator,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.card,
            backgroundImage: creator.profileImage.isNotEmpty
                ? NetworkImage(creator.profileImage)
                : null,
            child: creator.profileImage.isEmpty
                ? Text(
                    creator.name.isNotEmpty
                        ? creator.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 8),

          // Name
          Expanded(
            flex: 2,
            child: Text(
              creator.name,
              style: const TextStyle(
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Email
          Expanded(
            flex: 3,
            child: Text(
              creator.email,
              style: const TextStyle(color: AppTheme.textMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Instagram
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.alternate_email,
                    size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    creator.instagram,
                    style:
                        const TextStyle(color: AppTheme.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  color: AppTheme.accent,
                  tooltip: 'Edit',
                  onTap: () => onEdit(creator),
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: Icons.delete_outline,
                  color: AppTheme.danger,
                  tooltip: 'Delete',
                  onTap: () => onDelete(creator),
                ),
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
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline,
              size: 56, color: AppTheme.textMuted.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Error: $error',
          style: const TextStyle(color: AppTheme.danger)),
    );
  }
}
