import 'package:flutter/material.dart';
import 'package:village/screens/profile/notifier/profile_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';

import 'package:flutter/material.dart';
import 'package:village/screens/profile/notifier/profile_notifier.dart';
import 'package:village/screens/profile/model/family_member_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';

class FamilyDetailsScreen extends ConsumerStatefulWidget {
  const FamilyDetailsScreen({super.key});

  @override
  ConsumerState<FamilyDetailsScreen> createState() => _FamilyDetailsScreenState();
}

class _FamilyDetailsScreenState extends ConsumerState<FamilyDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load data from API when screen opens
    Future.microtask(() {
      ref.read(profileNotifierProvider.notifier).loadMember();
    });
  }

  void _addFamilyMember() {
    showDialog(
      context: context,
      builder: (context) => _AddFamilyMemberDialog(
        onAdd: (memberPayload) async {
          await ref.read(profileNotifierProvider.notifier).addFamily(context, memberPayload);
          // Refresh list after adding
          ref.read(profileNotifierProvider.notifier).loadMember();
        },
      ),
    );
  }

  void _editFamilyMember(FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => _AddFamilyMemberDialog(
        // Pass the model's current data to the dialog
        initialData: member.toJson(),
        onAdd: (memberPayload) async {
          await ref.read(profileNotifierProvider.notifier).updateFamily(
            context,
            member.id.toString(),
            memberPayload,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // WATCH the state here. When state change in Notifier, this UI rebuilds.
    final profileState = ref.watch(profileNotifierProvider);
    final familyMembers = profileState.familyMember ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Details'),
        backgroundColor: AppTheme.ssjsSecondaryBlue,
        foregroundColor: AppTheme.backgroundWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addFamilyMember,
          ),
        ],
      ),
      body: SafeArea(
        child: profileState.isLoading && familyMembers.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : familyMembers.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          itemCount: familyMembers.length,
          itemBuilder: (context, index) {
            final member = familyMembers[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue,
                  child: Icon(
                    _getRelationIcon(member.relationship),
                    color: Colors.white,
                  ),
                ),
                title: Text(member.name),
                subtitle: Text(member.relationship),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                      onPressed: () => _editFamilyMember(member),
                    ),
                    // IconButton(
                    //   icon: const Icon(Icons.delete, color: Colors.red),
                    //   onPressed: () {
                    //     // Add delete logic in Notifier if needed
                    //   },
                    // ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFamilyMember,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.family_restroom, size: 80, color: AppTheme.textGrey.withAlpha(128)),
          const SizedBox(height: 16),
          const Text('No family members added'),
        ],
      ),
    );
  }

  IconData _getRelationIcon(String relation) {
    switch (relation.toLowerCase()) {
      case 'spouse': case 'husband': case 'wife': return Icons.favorite;
      case 'father': case 'mother': case 'parent': return Icons.elderly;
      case 'son': case 'daughter': case 'child': return Icons.child_care;
      case 'brother': case 'sister': case 'sibling': return Icons.people;
      default: return Icons.person;
    }
  }
}

class _AddFamilyMemberDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onAdd;

  const _AddFamilyMemberDialog({
    this.initialData,
    required this.onAdd,
  });

  @override
  State<_AddFamilyMemberDialog> createState() => _AddFamilyMemberDialogState();
}

class _AddFamilyMemberDialogState extends State<_AddFamilyMemberDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers (for non-date fields only)
  late TextEditingController _nameController;
  late TextEditingController _relationController;
  late TextEditingController _mobileController;
  late TextEditingController _gotraController;
  late TextEditingController _occupationController;
  late TextEditingController _educationController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _hobbiesController;
  late TextEditingController _nativePlaceController;
  late TextEditingController _notesController;

  // Date variables (NOT controllers — we manage dates as DateTime?)
  DateTime? _selectedDob;
  DateTime? _selectedAnniversary;

  String _selectedGender = 'male';
  bool _isMatrimony = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name']);
    _relationController = TextEditingController(text: widget.initialData?['relationship']);
    _mobileController = TextEditingController(text: widget.initialData?['mobile']);
    _gotraController = TextEditingController(text: widget.initialData?['gotra']);
    _occupationController = TextEditingController(text: widget.initialData?['occupation']);
    _educationController = TextEditingController(text: widget.initialData?['education']);
    _bloodGroupController = TextEditingController(text: widget.initialData?['blood_group']);
    _hobbiesController = TextEditingController(text: widget.initialData?['hobbies']);
    _nativePlaceController = TextEditingController(text: widget.initialData?['native_place']);
    _notesController = TextEditingController(text: widget.initialData?['notes']);

    // Initialize dates from initialData (string -> DateTime)
    final dobStr = widget.initialData?['date_of_birth'];
    if (dobStr != null && dobStr.isNotEmpty) {
      _selectedDob = DateTime.tryParse(dobStr) ?? null;
    }

    final annivStr = widget.initialData?['anniversary_date'];
    if (annivStr != null && annivStr.isNotEmpty) {
      _selectedAnniversary = DateTime.tryParse(annivStr) ?? null;
    }

    _selectedGender = widget.initialData?['gender'] ?? 'male';
    _isMatrimony = widget.initialData?['matrimony'] ?? false;
  }

  @override
  void dispose() {
    // Dispose only text controllers
    for (var controller in [
      _nameController, _relationController, _mobileController,
      _gotraController, _occupationController,
      _educationController, _bloodGroupController, _hobbiesController,
      _nativePlaceController, _notesController
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  // DATE PICKER METHODS
  Future<void> _selectDate(BuildContext context, bool isDob) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDob ? (_selectedDob ?? DateTime.now()) : (_selectedAnniversary ?? DateTime.now()),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isDob) {
          _selectedDob = picked;
        } else {
          _selectedAnniversary = picked;
        }
      });
    }
  }

  // DISPLAY HELPER
  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat('dd MMM yyyy').format(date);
  }

  // API FORMAT HELPER (ISO 8601: yyyy-MM-dd)
  String? _formatDateForApi(DateTime? date) {
    return date?.toIso8601String().split('T').first; // "2025-12-31"
  }

  // DATE PICKER WIDGET
  Widget _buildDatePicker(String label, bool isDob) {
    final date = isDob ? _selectedDob : _selectedAnniversary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Tap to select date',
          prefixIcon: Icon(isDob ? Icons.cake : Icons.favorite),
          border: const OutlineInputBorder(),
        ),
        child: InkWell(
          onTap: () => _selectDate(context, isDob),
          child: Text(
            _formatDate(date),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Add Family Member' : 'Edit Family Member'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(_nameController, 'Name', Icons.person, isRequired: true),
              _buildField(_relationController, 'Relationship', Icons.family_restroom,
                  hint: 'Brother, Spouse, etc.', isRequired: true),
              _buildField(_mobileController, 'Mobile', Icons.phone, keyboard: TextInputType.phone),

              // ✅ DATE PICKERS INSTEAD OF TEXT FIELDS
              _buildDatePicker('Date of Birth', true),
              _buildDatePicker('Anniversary Date', false),

              // Rest of fields
              _buildField(_gotraController, 'Gotra', Icons.groups),
              _buildField(_educationController, 'Education', Icons.school),
              _buildField(_occupationController, 'Occupation', Icons.work),
              _buildField(_bloodGroupController, 'Blood Group', Icons.bloodtype),
              _buildField(_nativePlaceController, 'Native Place', Icons.home),
              _buildField(_hobbiesController, 'Hobbies', Icons.palette),
              _buildField(_notesController, 'Notes', Icons.note, maxLines: 2),

              const SizedBox(height: 16),
              // Gender Selection
              Row(
                children: [
                  const Text("Gender: "),
                  Radio<String>(
                    value: 'male',
                    groupValue: _selectedGender,
                    onChanged: (v) => setState(() => _selectedGender = v!),
                  ),
                  const Text("Male"),
                  Radio<String>(
                    value: 'female',
                    groupValue: _selectedGender,
                    onChanged: (v) => setState(() => _selectedGender = v!),
                  ),
                  const Text("Female"),
                ],
              ),

              // Matrimony Checkbox
              CheckboxListTile(
                title: const Text("Open for Matrimony"),
                value: _isMatrimony,
                onChanged: (v) => setState(() => _isMatrimony = v!),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdd({
                "name": _nameController.text,
                "image": widget.initialData?['image'] ?? "family/default.jpg",
                "relationship": _relationController.text,
                "mobile": _mobileController.text,
                "date_of_birth": _formatDateForApi(_selectedDob),
                "anniversary_date": _formatDateForApi(_selectedAnniversary),
                "gotra": _gotraController.text,
                "occupation": _occupationController.text,
                "education": _educationController.text,
                "blood_group": _bloodGroupController.text,
                "hobbies": _hobbiesController.text,
                "native_place": _nativePlaceController.text,
                "notes": _notesController.text,
                "matrimony": _isMatrimony,
                "gender": _selectedGender
              });
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
          child: const Text('Save'),
        ),
      ],
    );
  }

  // Keep your existing _buildField for non-date inputs
  Widget _buildField(TextEditingController controller, String label, IconData icon,
      {String? hint, bool isRequired = false, TextInputType? keyboard, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
