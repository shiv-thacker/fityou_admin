import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../models/creator.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class CreatorFormDialog extends StatefulWidget {
  final Creator? creator; // null = add, non-null = edit

  const CreatorFormDialog({super.key, this.creator});

  @override
  State<CreatorFormDialog> createState() => _CreatorFormDialogState();
}

class _CreatorFormDialogState extends State<CreatorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  bool _loading = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _avatarCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _instagramCtrl;
  late final TextEditingController _instagramUrlCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.creator;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _avatarCtrl = TextEditingController(text: c?.profileImage ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _instagramCtrl = TextEditingController(text: c?.instagram ?? '');
    _instagramUrlCtrl =
        TextEditingController(text: c?.instagramUrl ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _avatarCtrl.dispose();
    _emailCtrl.dispose();
    _instagramCtrl.dispose();
    _instagramUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final creator = Creator(
      creatorId: widget.creator?.creatorId ?? '',
      name: _nameCtrl.text.trim(),
      profileImage: _avatarCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      instagram: _instagramCtrl.text.trim(),
      instagramUrl: _instagramUrlCtrl.text.trim(),
    );

    try {
      if (widget.creator == null) {
        await _firestoreService.addCreator(creator);
      } else {
        await _firestoreService.updateCreator(creator);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        final msg = e is FirebaseException
            ? '${e.code}: ${e.message ?? e.toString()}'
            : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.creator != null;
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person_add,
                          color: AppTheme.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEdit ? 'Edit Creator' : 'Add Creator',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppTheme.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _Field(
                    ctrl: _nameCtrl,
                    label: 'Name',
                    icon: Icons.badge_outlined,
                    validator: (v) =>
                        v!.isEmpty ? 'Name is required' : null),
                const SizedBox(height: 14),
                _Field(
                    ctrl: _avatarCtrl,
                    label: 'Avatar URL',
                    icon: Icons.image_outlined,
                    validator: (v) =>
                        v!.isEmpty ? 'Avatar URL is required' : null),
                const SizedBox(height: 14),
                _Field(
                  ctrl: _emailCtrl,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _Field(
                    ctrl: _instagramCtrl,
                    label: 'Instagram Handle',
                    icon: Icons.alternate_email,
                    validator: (v) =>
                        v!.isEmpty ? 'Instagram handle is required' : null),
                const SizedBox(height: 14),
                _Field(
                    ctrl: _instagramUrlCtrl,
                    label: 'Instagram URL',
                    icon: Icons.link_outlined,
                    validator: (v) =>
                        v!.isEmpty ? 'Instagram URL is required' : null),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel',
                          style:
                              TextStyle(color: AppTheme.textMuted)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : Text(isEdit ? 'Update' : 'Add Creator'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textLight),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 18),
      ),
      validator: validator,
    );
  }
}
