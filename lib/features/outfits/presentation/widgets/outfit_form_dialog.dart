import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_size.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../creators/data/datasources/creators_datasource.dart';
import '../../../creators/data/repositories/creators_repository_impl.dart';
import '../../../creators/domain/entities/creator_entity.dart';
import '../../data/datasources/outfits_datasource.dart';
import '../../data/repositories/outfits_repository_impl.dart';
import '../../domain/entities/outfit_entity.dart';
import '../../domain/repositories/outfits_repository.dart';

class OutfitFormDialog extends StatefulWidget {
  final OutfitEntity? outfit;

  const OutfitFormDialog({super.key, this.outfit});

  @override
  State<OutfitFormDialog> createState() => _OutfitFormDialogState();
}

class _OutfitFormDialogState extends State<OutfitFormDialog> {
  late final OutfitsRepository _outfitsRepo =
      OutfitsRepositoryImpl(OutfitsDatasource());

  final _formKey = GlobalKey<FormState>();

  bool _loading         = false;
  bool _fetchingCreators = true;

  List<CreatorEntity> _creators       = [];
  CreatorEntity?      _selectedCreator;

  final _imgCtrl1 = TextEditingController();
  final _imgCtrl2 = TextEditingController();
  final _imgCtrl3 = TextEditingController();

  String? _size;
  String? _skinTone;
  String? _gender;
  String? _category;

  final _tagsCtrl        = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  List<_LinkRow> _linkFields = [];

  @override
  void initState() {
    super.initState();
    _loadCreators();

    final o = widget.outfit;
    if (o != null) {
      if (o.imageUrl.isNotEmpty) _imgCtrl1.text = o.imageUrl[0];
      if (o.imageUrl.length > 1) _imgCtrl2.text = o.imageUrl[1];
      if (o.imageUrl.length > 2) _imgCtrl3.text = o.imageUrl[2];
      _size     = o.size.isNotEmpty     ? o.size     : null;
      _skinTone = o.skinTone.isNotEmpty ? o.skinTone : null;
      _gender   = o.gender.isNotEmpty   ? o.gender   : null;
      _category = o.category.isNotEmpty ? o.category : null;
      _tagsCtrl.text        = o.tags.join(', ');
      _descriptionCtrl.text = o.description;
      _linkFields = o.outfitLinks.map(_LinkRow.fromEntity).toList();
    }
    if (_linkFields.isEmpty) _linkFields = [_LinkRow.empty()];
  }

  Future<void> _loadCreators() async {
    final list = await CreatorsRepositoryImpl(CreatorsDatasource())
        .fetchCreators();
    setState(() {
      _creators          = list;
      _fetchingCreators  = false;
      if (widget.outfit != null) {
        _selectedCreator = list.firstWhere(
          (c) => c.creatorId == widget.outfit!.creatorId,
          orElse: () => list.isEmpty
              ? const CreatorEntity(
                  creatorId: '', name: '', profileImage: '',
                  email: '', instagram: '', instagramUrl: '')
              : list.first,
        );
        if (_selectedCreator?.creatorId.isEmpty ?? true) {
          _selectedCreator = null;
        }
      }
    });
  }

  void _removeLinkAt(int index) {
    if (index < 0 || index >= _linkFields.length) return;
    _linkFields[index].dispose();
    _linkFields.removeAt(index);
    if (_linkFields.isEmpty) _linkFields.add(_LinkRow.empty());
  }

  @override
  void dispose() {
    _imgCtrl1.dispose();
    _imgCtrl2.dispose();
    _imgCtrl3.dispose();
    _tagsCtrl.dispose();
    _descriptionCtrl.dispose();
    for (final row in _linkFields) row.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCreator == null) {
      context.showErrorSnackBar('Please select a creator');
      return;
    }
    setState(() => _loading = true);

    final images = [
      _imgCtrl1.text.trim(),
      _imgCtrl2.text.trim(),
      _imgCtrl3.text.trim(),
    ].where((u) => u.isNotEmpty).toList();

    final tags = _tagsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final links = <OutfitLinkEntity>[];
    for (final row in _linkFields) {
      final label = row.labelCtrl.text.trim();
      final url   = row.urlCtrl.text.trim();
      final price = row.priceCtrl.text.trim();
      if (label.isEmpty && url.isEmpty && price.isEmpty) continue;
      links.add(OutfitLinkEntity(label: label, url: url, price: price));
    }

    final outfit = OutfitEntity(
      outfitId:      widget.outfit?.outfitId ?? '',
      imageUrl:      images,
      creatorId:     _selectedCreator!.creatorId,
      creatorName:   _selectedCreator!.name,
      creatorAvatar: _selectedCreator!.profileImage,
      size:          _size     ?? '',
      skinTone:      _skinTone ?? '',
      gender:        _gender   ?? '',
      category:      _category ?? '',
      tags:          tags,
      outfitLinks:   links,
      description:   _descriptionCtrl.text.trim(),
      createdAt:     widget.outfit?.createdAt,
    );

    try {
      if (widget.outfit == null) {
        await _outfitsRepo.addOutfit(outfit);
      } else {
        await _outfitsRepo.updateOutfit(outfit);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.outfit != null;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 600, maxHeight: 920),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dialog header ────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius:
                          BorderRadius.circular(AppSize.radiusSm),
                    ),
                    child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.accent,
                        size: AppSize.iconMd),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Edit Outfit' : 'Add Outfit',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Scrollable form ──────────────────────────────────────
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
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: AppColors.accent)),
                              )
                            : DropdownButtonFormField<CreatorEntity>(
                                value: _selectedCreator,
                                dropdownColor: AppColors.primary,
                                style: const TextStyle(
                                    color: AppColors.textLight),
                                decoration: const InputDecoration(
                                  labelText: 'Select Creator',
                                  prefixIcon: Icon(
                                      Icons.person_search_outlined,
                                      color: AppColors.textMuted,
                                      size: 18),
                                ),
                                items: _creators
                                    .map((c) =>
                                        DropdownMenuItem<CreatorEntity>(
                                          value: c,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor:
                                                    AppColors.card,
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
                                                        color: AppColors
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
                                validator: (v) =>
                                    v == null ? 'Select a creator' : null,
                              ),

                        if (_selectedCreator != null) ...[
                          const SizedBox(height: 10),
                          _AutoFillChip(
                              label:
                                  'ID: ${_selectedCreator!.creatorId}'),
                        ],

                        // Images
                        const SizedBox(height: 20),
                        _SectionLabel(
                            'Images (up to ${AppConstants.maxOutfitImages})'),
                        _UrlField(ctrl: _imgCtrl1, label: 'Image URL 1', required: true),
                        const SizedBox(height: 10),
                        _UrlField(ctrl: _imgCtrl2, label: 'Image URL 2'),
                        const SizedBox(height: 10),
                        _UrlField(ctrl: _imgCtrl3, label: 'Image URL 3'),

                        // Details
                        const SizedBox(height: 20),
                        _SectionLabel('Details'),
                        Row(
                          children: [
                            Expanded(
                              child: _DropField(
                                label: 'Size',
                                value: _size,
                                items: AppConstants.outfitSizes,
                                onChanged: (v) =>
                                    setState(() => _size = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DropField(
                                label: 'Skin Tone',
                                value: _skinTone,
                                items: AppConstants.skinTones,
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
                                items: AppConstants.genders,
                                onChanged: (v) =>
                                    setState(() => _gender = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DropField(
                                label: 'Category',
                                value: _category,
                                items: AppConstants.categories,
                                onChanged: (v) =>
                                    setState(() => _category = v),
                              ),
                            ),
                          ],
                        ),

                        // Tags
                        const SizedBox(height: 20),
                        _SectionLabel('Tags'),
                        TextFormField(
                          controller: _tagsCtrl,
                          style: const TextStyle(
                              color: AppColors.textLight),
                          decoration: const InputDecoration(
                            labelText: 'Tags (comma-separated)',
                            hintText: 'e.g. summer, casual, cotton',
                            prefixIcon: Icon(Icons.label_outline,
                                color: AppColors.textMuted, size: 18),
                          ),
                        ),

                        // Outfit links
                        const SizedBox(height: 20),
                        _SectionLabel('Outfit links'),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() => _linkFields
                                  .add(_LinkRow.empty()));
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add link'),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.accent),
                          ),
                        ),
                        Text(
                          'Label, shop URL, and optional price per piece.',
                          style: TextStyle(
                            color: AppColors.textMuted.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(_linkFields.length, (i) {
                          final row = _linkFields[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: row.labelCtrl,
                                        style: const TextStyle(
                                            color: AppColors.textLight),
                                        decoration: const InputDecoration(
                                          labelText: 'Label',
                                          hintText: 'T-shirt',
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 104,
                                      child: TextFormField(
                                        controller: row.priceCtrl,
                                        style: const TextStyle(
                                            color: AppColors.textLight),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                                decimal: true),
                                        decoration: const InputDecoration(
                                          labelText: 'Price',
                                          hintText: '29.99',
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Remove row',
                                      onPressed: () {
                                        setState(
                                            () => _removeLinkAt(i));
                                      },
                                      icon: const Icon(Icons.close,
                                          color: AppColors.textMuted,
                                          size: 22),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: row.urlCtrl,
                                  style: const TextStyle(
                                      color: AppColors.textLight),
                                  decoration: const InputDecoration(
                                    labelText: 'URL',
                                    hintText: 'https://…',
                                    isDense: true,
                                    prefixIcon: Icon(Icons.link,
                                        color: AppColors.textMuted,
                                        size: 18),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Description
                        const SizedBox(height: 8),
                        _SectionLabel('Description'),
                        TextFormField(
                          controller: _descriptionCtrl,
                          style: const TextStyle(
                              color: AppColors.textLight),
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            alignLabelWithHint: true,
                            labelText: 'Outfit description',
                            hintText:
                                'Styling notes, occasion, fabric, fit tips…',
                            hintStyle: TextStyle(
                                color: AppColors.textMuted),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Dialog actions ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel',
                        style:
                            TextStyle(color: AppColors.textMuted)),
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

// ── Private helpers ────────────────────────────────────────────────────────

class _LinkRow {
  final TextEditingController labelCtrl;
  final TextEditingController urlCtrl;
  final TextEditingController priceCtrl;

  _LinkRow({String label = '', String url = '', String price = ''})
      : labelCtrl = TextEditingController(text: label),
        urlCtrl   = TextEditingController(text: url),
        priceCtrl = TextEditingController(text: price);

  factory _LinkRow.fromEntity(OutfitLinkEntity link) =>
      _LinkRow(label: link.label, url: link.url, price: link.price);

  factory _LinkRow.empty() => _LinkRow();

  void dispose() {
    labelCtrl.dispose();
    urlCtrl.dispose();
    priceCtrl.dispose();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            )),
      );
}

class _AutoFillChip extends StatelessWidget {
  final String label;
  const _AutoFillChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSize.radiusSm),
          border: Border.all(
              color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Text(label,
            style: const TextStyle(
                color: AppColors.accent, fontSize: 11),
            overflow: TextOverflow.ellipsis),
      );
}

class _UrlField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool required;

  const _UrlField(
      {required this.ctrl, required this.label, this.required = false});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: ctrl,
        style: const TextStyle(color: AppColors.textLight),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.image_outlined,
              color: AppColors.textMuted, size: 18),
        ),
        validator: required
            ? (v) =>
                v!.isEmpty ? 'At least one image URL is required' : null
            : null,
      );
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
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        value: value,
        dropdownColor: AppColors.primary,
        style: const TextStyle(color: AppColors.textLight),
        decoration: InputDecoration(labelText: label),
        items: items
            .map((i) =>
                DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Required' : null,
      );
}
