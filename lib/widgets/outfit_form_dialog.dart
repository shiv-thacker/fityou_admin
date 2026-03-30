import 'package:flutter/material.dart';
import '../models/creator.dart';
import '../models/outfit.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class OutfitFormDialog extends StatefulWidget {
  final Outfit? outfit;

  const OutfitFormDialog({super.key, this.outfit});

  @override
  State<OutfitFormDialog> createState() => _OutfitFormDialogState();
}

class _OutfitFormDialogState extends State<OutfitFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  bool _loading = false;
  bool _fetchingCreators = true;

  List<Creator> _creators = [];
  Creator? _selectedCreator;

  final _imgCtrl1 = TextEditingController();
  final _imgCtrl2 = TextEditingController();
  final _imgCtrl3 = TextEditingController();

  String? _size;
  String? _skinTone;
  String? _gender;
  String? _category;

  static const _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const _skinTones = [
    'Fair',
    'Light',
    'Medium',
    'Olive',
    'Tan',
    'Brown',
    'Dark'
  ];
  static const _genders = ['Male', 'Female', 'Unisex'];
  static const _categories = [
    'Casual',
    'Formal',
    'Sportswear',
    'Streetwear',
    'Ethnic',
    'Party',
    'Beach',
    'Winter',
    'Summer',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadCreators();

    final o = widget.outfit;
    if (o != null) {
      if (o.imageUrl.isNotEmpty) _imgCtrl1.text = o.imageUrl[0];
      if (o.imageUrl.length > 1) _imgCtrl2.text = o.imageUrl[1];
      if (o.imageUrl.length > 2) _imgCtrl3.text = o.imageUrl[2];
      _size = o.size.isNotEmpty ? o.size : null;
      _skinTone = o.skinTone.isNotEmpty ? o.skinTone : null;
      _gender = o.gender.isNotEmpty ? o.gender : null;
      _category = o.category.isNotEmpty ? o.category : null;
    }
  }

  Future<void> _loadCreators() async {
    final list = await _firestoreService.fetchCreators();
    setState(() {
      _creators = list;
      _fetchingCreators = false;
      if (widget.outfit != null) {
        _selectedCreator = list.firstWhere(
          (c) => c.creatorId == widget.outfit!.creatorId,
          orElse: () => list.isEmpty
              ? Creator(
                  creatorId: '',
                  name: '',
                  profileImage: '',
                  email: '',
                  instagram: '',
                  instagramUrl: '')
              : list.first,
        );
        if (_selectedCreator?.creatorId.isEmpty ?? true) {
          _selectedCreator = null;
        }
      }
    });
  }

  @override
  void dispose() {
    _imgCtrl1.dispose();
    _imgCtrl2.dispose();
    _imgCtrl3.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCreator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a creator'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final images = [
      _imgCtrl1.text.trim(),
      _imgCtrl2.text.trim(),
      _imgCtrl3.text.trim(),
    ].where((u) => u.isNotEmpty).toList();

    final outfit = Outfit(
      outfitId: widget.outfit?.outfitId ?? '',
      imageUrl: images,
      creatorId: _selectedCreator!.creatorId,
      creatorName: _selectedCreator!.name,
      creatorAvatar: _selectedCreator!.profileImage,
      size: _size ?? '',
      skinTone: _skinTone ?? '',
      gender: _gender ?? '',
      category: _category ?? '',
      createdAt: widget.outfit?.createdAt,
    );

    try {
      if (widget.outfit == null) {
        await _firestoreService.addOutfit(outfit);
      } else {
        await _firestoreService.updateOutfit(outfit);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.outfit != null;
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 560, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined,
                        color: AppTheme.accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Edit Outfit' : 'Add Outfit',
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
              const SizedBox(height: 20),

              // Scrollable form
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Creator picker
                        _SectionLabel('Creator'),
                        _fetchingCreators
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(
                                      color: AppTheme.accent),
                                ),
                              )
                            : DropdownButtonFormField<Creator>(
                                value: _selectedCreator,
                                dropdownColor: AppTheme.primary,
                                style: const TextStyle(
                                    color: AppTheme.textLight),
                                decoration: const InputDecoration(
                                  labelText: 'Select Creator',
                                  prefixIcon: Icon(
                                      Icons.person_search_outlined,
                                      color: AppTheme.textMuted,
                                      size: 18),
                                ),
                                items: _creators
                                    .map((c) =>
                                        DropdownMenuItem<Creator>(
                                          value: c,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor:
                                                    AppTheme.card,
                                                backgroundImage: c
                                                        .profileImage
                                                        .isNotEmpty
                                                    ? NetworkImage(
                                                        c.profileImage)
                                                    : null,
                                                child: c.profileImage
                                                        .isEmpty
                                                    ? const Icon(
                                                        Icons.person,
                                                        size: 12,
                                                        color: AppTheme
                                                            .textMuted)
                                                    : null,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(c.name),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedCreator = v),
                                validator: (v) => v == null
                                    ? 'Select a creator'
                                    : null,
                              ),

                        // Auto-filled info
                        if (_selectedCreator != null) ...[
                          const SizedBox(height: 10),
                          _AutoFillChip(
                            label: 'ID: ${_selectedCreator!.creatorId}',
                          ),
                        ],

                        const SizedBox(height: 20),
                        _SectionLabel('Images (up to 3)'),
                        _UrlField(
                            ctrl: _imgCtrl1,
                            label: 'Image URL 1',
                            required: true),
                        const SizedBox(height: 10),
                        _UrlField(
                            ctrl: _imgCtrl2, label: 'Image URL 2'),
                        const SizedBox(height: 10),
                        _UrlField(
                            ctrl: _imgCtrl3, label: 'Image URL 3'),

                        const SizedBox(height: 20),
                        _SectionLabel('Details'),
                        Row(
                          children: [
                            Expanded(
                              child: _DropField(
                                label: 'Size',
                                value: _size,
                                items: _sizes,
                                onChanged: (v) =>
                                    setState(() => _size = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DropField(
                                label: 'Skin Tone',
                                value: _skinTone,
                                items: _skinTones,
                                onChanged: (v) =>
                                    setState(() => _skinTone = v),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _DropField(
                                label: 'Gender',
                                value: _gender,
                                items: _genders,
                                onChanged: (v) =>
                                    setState(() => _gender = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DropField(
                                label: 'Category',
                                value: _category,
                                items: _categories,
                                onChanged: (v) =>
                                    setState(() => _category = v),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppTheme.textMuted)),
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
                        : Text(isEdit ? 'Update' : 'Add Outfit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _AutoFillChip extends StatelessWidget {
  final String label;
  const _AutoFillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: AppTheme.accent, fontSize: 11),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _UrlField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool required;

  const _UrlField({
    required this.ctrl,
    required this.label,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.textLight),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.image_outlined,
            color: AppTheme.textMuted, size: 18),
      ),
      validator: required
          ? (v) => v!.isEmpty ? 'At least one image URL is required' : null
          : null,
    );
  }
}

class _DropField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppTheme.primary,
      style: const TextStyle(color: AppTheme.textLight),
      decoration: InputDecoration(labelText: label),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required' : null,
    );
  }
}
