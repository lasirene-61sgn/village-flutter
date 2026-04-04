import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:village/screens/member_detail_screen.dart';
import 'package:village/services/pdf_service/member_pdf.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import 'package:village/screens/members/notifier/member_notifier.dart';
import 'package:village/screens/members/model/member_model.dart';
// Ensure your PdfHelper is imported
// import 'package:village/utils/pdf_helper.dart';

class MembersListScreen extends ConsumerStatefulWidget {
  String villageName;
 List<Member> members;
   MembersListScreen({super.key, required this.members, required this.villageName});

  @override
  ConsumerState<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends ConsumerState<MembersListScreen> {
  final TextEditingController _searchController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.ssjsSecondaryBlue,
        title:  Text(widget.villageName),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar (UI Unchanged)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  // ref.read(membersNotifierProvider.notifier).loadMembers('api/customer/customers?search=$value');
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search member',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppTheme.backgroundGrey.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      // ref.read(membersNotifierProvider.notifier).loadMembers('api/customer/customers');
                      setState(() {});
                    },
                  )
                      : null,
                ),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // 1. Get the search query and clean it
    final query = _searchController.text.toLowerCase();

    // 2. Filter the members list based on Name OR Mobile
    final filteredMembers = widget.members.where((member) {
      final nameLower = member.name.toLowerCase();
      final mobileString = member.mobile.toString(); // Ensure mobile is a string

      return nameLower.contains(query) || mobileString.contains(query);
    }).toList();

    // 3. Handle Empty State
    if (filteredMembers.isEmpty) {
      return const Center(
        child: Text("No Members Found", style: TextStyle(color: Colors.grey)),
      );
    }

    // 4. Return the filtered list
    return ListView.builder(
      itemCount: filteredMembers.length,
      itemBuilder: (context, index) => _buildMemberTile(filteredMembers[index]),
    );
  }
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $urlString');
    }
  }
  Widget _buildMemberTile(Member member) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (c) => MemberDetailScreen(member: member)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.dividerGrey, width: 0.5))),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: (member.image != null && member.image!.isNotEmpty) ? NetworkImage(member.image!) : null,
              child: (member.image == null || member.image!.isEmpty) ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                // Text(member.mobile, style: const TextStyle(color: Colors.grey)),
                Text(member.mobile.toString(), style: const TextStyle(color: Colors.grey)),
              ]),
            ),
            // PDF Icon
           if(member.mobile.isNotEmpty) IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
               onPressed: () => _launchUrl('tel:${member.mobile}'),
            ),
       Icon(Icons.chevron_right),

          ],
        ),
      ),
    );
  }
}