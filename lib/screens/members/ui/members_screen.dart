import 'package:flutter/material.dart';
import 'package:village/screens/member_detail_screen.dart';
import 'package:village/screens/members/ui/member_list_View.dart';
import 'package:village/services/pdf_service/member_pdf.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import 'package:village/screens/members/notifier/member_notifier.dart';
import 'package:village/screens/members/model/member_model.dart';
// Ensure your PdfHelper is imported
// import 'package:village/utils/pdf_helper.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(membersNotifierProvider.notifier).loadMembers('api/customer/customers');
    });
  }

  @override
  Widget build(BuildContext context) {

    final state = ref.watch(membersNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.ssjsSecondaryBlue,
        title: const Text('Villages'),
        elevation: 0,
        actions: [
          if(state.allMembers.isNotEmpty)
            Padding(
            padding: const EdgeInsets.only(right: 16.0), // This adds the margin to the right
            child: Center( // Center ensures the button stays vertically aligned
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => MembersListScreen(members: state.allMembers,villageName:"All Members",)));
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F5F5),
                  // Adjusted padding: horizontal 16 is usually enough for AppBars
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero, // Allows button to shrink to fit padding
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: StadiumBorder(
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: const Text(
                  "All Members",
                  style: TextStyle(
                    color: Color(0xFF331B16),
                    fontSize: 14, // Slightly smaller font usually looks better in AppBars
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   tooltip: 'Reset List',
          //   onPressed: _resetList,
          // ),
          // IconButton(
          //   icon: const Icon(Icons.picture_as_pdf,color: Colors.red),
          //   tooltip: 'Download Full List',
          //   onPressed: () {
          //     final members = ref.read(membersNotifierProvider).membersList;
          //     PdfHelper.downloadFullMemberList(members);
          //   },
          // ),
          // IconButton(
          //   icon: const Icon(Icons.filter_list),
          //   onPressed: () => _showMultiFilter(context),
          // ),
        ],
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
                  ref.read(membersNotifierProvider.notifier).loadMembers('api/customer/customers?search=$value');
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
                      ref.read(membersNotifierProvider.notifier).loadMembers('api/customer/customers');
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
  // void _showMultiFilter(BuildContext context) {
  //   final categories = ['Gotra', 'Area', 'Street/Road', 'Pincode'];
  //
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => ListView(
  //       shrinkWrap: true,
  //       children: categories.map((cat) => ListTile(
  //         title: Text(cat),
  //         trailing: const Icon(Icons.arrow_forward_ios, size: 14),
  //         onTap: () {
  //           Navigator.pop(context);
  //           _showSubFilterOptions(context, cat);
  //         },
  //       )).toList(),
  //     ),
  //   );
  // }

  // void _showSubFilterOptions(BuildContext context, String category) {
  //   final state = ref.read(membersNotifierProvider);
  //   List<String> allOptions = [];
  //
  //   // 1. Extract unique non-null values based on category
  //   if (category == 'Gotra') {
  //     allOptions = state.allMembers.map((m) => m.gotra ?? "").where((s) => s.isNotEmpty).toSet().toList();
  //   } else if (category == 'Area') {
  //     allOptions = state.allMembers.map((m) => m.area ?? "").where((s) => s.isNotEmpty).toSet().toList();
  //   } else if (category == 'Street/Road') {
  //     allOptions = state.allMembers.map((m) => m.streetRoad ?? "").where((s) => s.isNotEmpty).toSet().toList();
  //   } else if (category == 'Pincode') {
  //     allOptions = state.allMembers.map((m) => m.pincode ?? "").where((s) => s.isNotEmpty).toSet().toList();
  //   }
  //
  //   allOptions.sort(); // Keep options alphabetical for better UX
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  //     builder: (context) {
  //       final TextEditingController modalSearchController = TextEditingController();
  //
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setModalState) {
  //           // Filter logic applied to the list
  //           final filteredOptions = allOptions
  //               .where((opt) => opt.toLowerCase().contains(modalSearchController.text.toLowerCase()))
  //               .toList();
  //
  //           return DraggableScrollableSheet(
  //             expand: false,
  //             initialChildSize: 0.7,
  //             maxChildSize: 0.9,
  //             builder: (_, scrollController) => Column(
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.all(16),
  //                   child: Column(
  //                     children: [
  //                       Text("Select $category", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
  //                       const SizedBox(height: 12),
  //                       TextField(
  //                         controller: modalSearchController,
  //                         keyboardType: category == 'Pincode' ? TextInputType.number : TextInputType.text,
  //                         onChanged: (value) {
  //                           // setModalState refreshes only the bottom sheet UI
  //                           setModalState(() {});
  //                         },
  //                         decoration: InputDecoration(
  //                           hintText: 'Search $category...',
  //                           prefixIcon: const Icon(Icons.search),
  //                           // Clear button (Suffix Icon)
  //                           suffixIcon: modalSearchController.text.isNotEmpty
  //                               ? IconButton(
  //                             icon: const Icon(Icons.clear),
  //                             onPressed: () {
  //                               modalSearchController.clear();
  //                               setModalState(() {});
  //                             },
  //                           )
  //                               : null,
  //                           filled: true,
  //                           fillColor: Colors.grey[200],
  //                           border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(12),
  //                             borderSide: BorderSide.none,
  //                           ),
  //                           contentPadding: const EdgeInsets.symmetric(vertical: 0),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: filteredOptions.isEmpty
  //                       ? Center(
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Icon(
  //                           Icons.search_off_rounded,
  //                           size: 64,
  //                           color: Colors.grey[400],
  //                         ),
  //                         const SizedBox(height: 16),
  //                         Text(
  //                           "No ${category.toLowerCase()} found",
  //                           style: TextStyle(
  //                             fontSize: 16,
  //                             color: Colors.grey[600],
  //                             fontWeight: FontWeight.w500,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 8),
  //                         Text(
  //                           "Try searching with a different keyword",
  //                           style: TextStyle(
  //                             fontSize: 14,
  //                             color: Colors.grey[400],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   )
  //                       : ListView.builder(
  //                     controller: scrollController,
  //                     itemCount: filteredOptions.length,
  //                     itemBuilder: (context, index) {
  //                       final item = filteredOptions[index];
  //                       return ListTile(
  //                         title: Text(item),
  //                         trailing: const Icon(Icons.chevron_right, size: 18),
  //                         onTap: () {
  //                           ref.read(membersNotifierProvider.notifier).filterByField(category, item);
  //                           Navigator.pop(context);
  //                         },
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Widget _buildBody() {
    final state = ref.watch(membersNotifierProvider);
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.error != null) return Center(child: Text(state.error!));

    return ListView.builder(
      itemCount: state.membersList.length,
      itemBuilder: (context, index) => _buildMemberTile(state.membersList[index]),
    );
  }

  Widget _buildMemberTile(Village member) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (c) => MembersListScreen(members: member.customers,villageName: member.name,)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.dividerGrey, width: 0.5))),
        child: Row(
          children: [
            // CircleAvatar(
            //   backgroundImage: (member.image != null && member.image!.isNotEmpty) ? NetworkImage(member.!) : null,
            //   child: (member.image == null || member.image!.isEmpty) ? const Icon(Icons.person) : null,
            // ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                // Text(member.mobile, style: const TextStyle(color: Colors.grey)),
                Text("Users: ${member.customerCount.toString()}", style: const TextStyle(color: Colors.grey)),
              ]),
            ),
            // PDF Icon
            // IconButton(
            //   icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            //   onPressed: () async {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: Text("Preparing PDF for ${member.name}..."))
            //     );
            //     await PdfHelper.downloadMemberPdf(member);
            //   },
            // ),
             Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}