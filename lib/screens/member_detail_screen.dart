import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../screens/members/model/member_model.dart';

class MemberDetailScreen extends StatelessWidget {
  final Member member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        backgroundColor: AppTheme.ssjsSecondaryBlue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------------- PROFILE HEADER ----------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: AppTheme.backgroundGrey,
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryBlue, width: 3),
                      ),
                      child: member.image != null
                          ? ClipOval(
                        child: Image.network(
                          member.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person, size: 80),
                        ),
                      )
                          : const Icon(Icons.person, size: 80),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      member.labelName ?? member.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (member.status.isNotEmpty)
                      Text(
                        member.status.toUpperCase(),
                        style: const TextStyle(color: Colors.green),
                      ),
                  ],
                ),
              ),

              /// ---------------- CONTACT ----------------


              /// ---------------- PERSONAL ----------------
              _section(context, 'Personal Information', [
                if (member.name.isNotEmpty)
                  _row('Name', "${member.name} ji", Icons.person),
                if (member.labelName != null)
                  _row('Label Name', member.labelName!, Icons.perm_identity),
                if (member.fatherName != null)
                  _row('Father Name', member.fatherName!, Icons.person),
                if (member.gotra != null)
                  _row('Gotra', member.gotra!, Icons.account_tree),
                // if (member.gender != null && member.gender!.isNotEmpty)
                //   _row('Gender', member.gender!, Icons.wc),
                // if (member.age != null)
                //   _row('Age', '${member.age} Years', Icons.calendar_today),
                // if (member.dateOfBirth != null)
                //   _row(
                //     'Date of Birth',
                //     DateFormat('dd MMM yyyy').format(member.dateOfBirth!),
                //     Icons.cake,
                //   ),
                // if (member.anniversaryDate != null)
                //   _row(
                //     'Anniversary',
                //     DateFormat('dd MMM yyyy').format(member.anniversaryDate!),
                //     Icons.favorite,
                //   ),
                // if (member.education != null)
                //   _row('Education', member.education!, Icons.school),
                // if (member.occupation != null)
                //   _row('Occupation', member.occupation!, Icons.work),
                // if (member.bloodGroup != null)
                //   _row('Blood Group', member.bloodGroup!, Icons.bloodtype),
                // if (member.hobbies != null)
                //   _row('Hobbies', member.hobbies!, Icons.sports),

                if (member.district != null)
                  _row('District', member.district!, Icons.map),
                if (member.occupation != null)
                  _row('Village', member.occupation!, Icons.place),
                if (member.msFirmName != null)
                      _row('Firm Name', member.msFirmName!, Icons.business),
              ]),

              /// ---------------- BUSINESS ----------------
              // if (member.businessType != null ||
              //     member.businessName != null ||
              //     member.productService != null)
              //   _section(context, 'Business Information', [
              //     if (member.msFirmName != null)
              //       _row('Firm Name', member.msFirmName!, Icons.business),
              //     if (member.businessType != null)
              //       _row('Business Type', member.businessType!, Icons.work),
              //     if (member.businessName != null)
              //       _row('Business Name', member.businessName!, Icons.store),
              //     if (member.productService != null)
              //       _row('Products / Services', member.productService!, Icons.inventory),
              //     if (member.officeAddress != null)
              //       _row('Office Address', member.officeAddress!, Icons.location_on),
              //   ]),
            if(member.mobile.isNotEmpty || (member.whatsapp != null && member.whatsapp!.isNotEmpty))  _section(context, 'Contact Information', [
                // Mobile Launcher
                if (member.mobile.isNotEmpty)
                  _row(
                    'Mobile',
                    member.mobile,
                    Icons.phone,
                    onTap: () => _launchUrl('tel:${member.mobile}'),
                  ),

                // WhatsApp Launcher
                if (member.whatsapp != null && member.whatsapp!.isNotEmpty)
                  _row(
                    'WhatsApp',
                    member.whatsapp!,
                    Icons.chat,
                    onTap: () => _launchUrl('https://wa.me/${member.whatsapp!.replaceAll(RegExp(r'[^0-9]'), '')}'),
                  ),

                if (member.email != null && member.email!.isNotEmpty)
                  _row(
                    'Email',
                    member.email!,
                    Icons.email,
                    onTap: () => _launchUrl('mailto:${member.email}'),
                  ),
              ]),
              /// ---------------- ADDRESS ----------------
              _section(context, 'Address', [
                if (member.dno != null)
                  _row('Door No', member.dno!, Icons.home),
                if (member.streetRoad != null)
                  _row('Street', member.streetRoad!, Icons.signpost),
                if (member.address2 != null)
                  _row('Address 2', member.address2!, Icons.location_city),
                if (member.city != null)
                  _row('City', member.city!, Icons.location_city),
                if (member.pincode != null)
                  _row('Pincode', member.pincode!, Icons.pin),
              ]),

              /// ---------------- FAMILY ----------------
              // if (member.familyMembers.isNotEmpty)
              //   _section(
              //     context,
              //     'Family Members',
              //     member.familyMembers.map((fm) {
              //       return Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           _row('Name', fm.name, Icons.person),
              //           if (fm.relationship != null)
              //             _row('Relation', fm.relationship!, Icons.group),
              //           if (fm.mobile != null)
              //             _row('Mobile', fm.mobile!, Icons.phone),
              //           if (fm.gender != null)
              //             _row('Gender', fm.gender!, Icons.wc),
              //           if (fm.education != null)
              //             _row('Education', fm.education!, Icons.school),
              //           if (fm.occupation != null)
              //             _row('Occupation', fm.occupation!, Icons.work),
              //           if (fm.bloodGroup != null)
              //             _row('Blood Group', fm.bloodGroup!, Icons.bloodtype),
              //           const Divider(),
              //         ],
              //       );
              //     }).toList(),
              //   ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $urlString');
    }
  }
  /// ---------------- UI HELPERS ----------------
  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textGrey)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    // Add underline if it's a clickable link
                    decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
                    color: onTap != null ? Colors.blue.shade700 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
          if(label == "Mobile" )
            GestureDetector(
                onTap: onTap,
                child: const Icon(Icons.call, size: 28, color: Colors.green))
          else if(label == "WhatsApp")
            GestureDetector(
                onTap: onTap,
                child:  Container(
                  height: 35,
                  width: 35,
                  decoration:BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: AssetImage("assets/icon/whatsapp_image.png"),fit: BoxFit.fill)
                  )
                    ))
          else if(label == "Email")
            GestureDetector(
                onTap: onTap,
                child:
                const Icon(Icons.email, size: 28, color: Colors.green)),
        ],
      ),
    );
  }
}
