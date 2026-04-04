import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:village/config/theme.dart';
import 'package:village/screens/profile/notifier/profile_notifier.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  // final Member member;

  const ProfileEditScreen({super.key,});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _labelController = TextEditingController(); // For Label
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _gotraController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  // BUSINESS
  final TextEditingController _firmNameController = TextEditingController();

  // CONTACT
  final TextEditingController _mobileController = TextEditingController(); // Read-only
  final TextEditingController _whatsappController = TextEditingController();

  // ADDRESS
  final TextEditingController _doorNoController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _addressController = TextEditingController(); // Home address
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _officeAddressController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(profileNotifierProvider.notifier).loadProfile();
      loadData();
    });
  }

  void loadData() {
    final profile = ref.read(profileNotifierProvider).profile;
    if (profile == null) return;

    setState(() {
      _nameController.text = profile.name;
      _labelController.text = profile.labelName ?? '';
      _fatherNameController.text = profile.fatherName ?? '';
      _gotraController.text = profile.gotra ?? '';
      _villageController.text = profile.village?.name.toString() ?? '';
      _districtController.text = profile.district ?? '';

      _firmNameController.text = profile.msFirmName ?? '';

      _mobileController.text = profile.mobile;
      _whatsappController.text = profile.whatsapp ?? '';

      _doorNoController.text = profile.dno ?? '';
      _streetController.text = profile.streetRoad ?? '';
      _addressController.text = profile.address2 ?? '';
      _cityController.text = profile.city ?? '';
      _pincodeController.text = profile.pincode ?? '';
      _officeAddressController.text = profile.officeAddress ?? '';
    });
  }

  Future<void> _saveProfile() async {
    final state = ref.watch(profileNotifierProvider);
    if (!_formKey.currentState!.validate() || state.profile == null) return;

    final updatedProfile = state.profile!.copyWith(
      name: _nameController.text.trim(),
      labelName: _labelController.text.trim(),
      fatherName: _fatherNameController.text.trim(),
      gotra: _gotraController.text.trim(),
      district: _districtController.text.trim(),
      msFirmName: _firmNameController.text.trim(),
      businessName: _firmNameController.text.trim(), // Keep synced if needed
      whatsapp: _whatsappController.text.trim(),
      dno: _doorNoController.text.trim(),
      streetRoad: _streetController.text.trim(),
      address2: _addressController.text.trim(),
      city: _cityController.text.trim(),
      pincode: _pincodeController.text.trim(),
      officeAddress: _officeAddressController.text.trim(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    final Map<String, dynamic> payload = updatedProfile.toJson();

    await ref.read(profileNotifierProvider.notifier).submitProfile(context, payload, _profileImage);
  }


  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80, // compress
      maxWidth: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }
  void _showImagePickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Edit Profile'),backgroundColor:AppTheme.ssjsSecondaryBlue ,),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: AppTheme.backgroundGrey,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (state.profile?.image != null
                            ? NetworkImage(state.profile!.image!)
                            : null) as ImageProvider?,
                        child: (_profileImage == null && state.profile?.image == null)
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => _showImagePickerSheet(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                // Basic Info
                // Basic Info
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _labelController, // CHANGED
                  decoration: const InputDecoration(labelText: 'Label', prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fatherNameController,
                  decoration: const InputDecoration(labelText: 'Father Name', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gotraController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Gotra', prefixIcon: Icon(Icons.business)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _villageController, // CHANGED
                  decoration: const InputDecoration(labelText: 'Village', prefixIcon: Icon(Icons.wc)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _districtController, // CHANGED
                  decoration: const InputDecoration(labelText: 'District', prefixIcon: Icon(Icons.wc)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firmNameController,
                  decoration: const InputDecoration(labelText: 'Firm Name (ms_firm_name)', prefixIcon: Icon(Icons.business)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mobileController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Mobile', prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _whatsappController, // CHANGED
                  decoration: const InputDecoration(labelText: 'Whatsapp Number', prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 24),
                Text('Address Details', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _doorNoController, // CHANGED
                  decoration: const InputDecoration(labelText: 'Door No', prefixIcon: Icon(Icons.location_on)),
                  // maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _streetController, // CHANGED
                  decoration: const InputDecoration(labelText: 'Street', prefixIcon: Icon(Icons.location_on)),
                  // maxLines: 2,
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_on)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Pincode', prefixIcon: Icon(Icons.pin)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController, // HOME ADDRESS
                  decoration: const InputDecoration(labelText: 'Address (Home)', prefixIcon: Icon(Icons.location_on)),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _officeAddressController,
                  decoration: const InputDecoration(labelText: 'Office Address', prefixIcon: Icon(Icons.business)),
                  maxLines: 2,
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: state.isSaving ? null : _saveProfile,
                  child: Text(state.isSaving ? 'Saving...' : 'Update Profile'),
                ),
                const SizedBox(height: 24),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
