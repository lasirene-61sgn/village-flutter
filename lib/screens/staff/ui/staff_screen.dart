import 'package:flutter/material.dart';
import 'package:village/config/theme.dart' show AppTheme;
import 'package:village/screens/business/model/business_model.dart';
import 'package:village/screens/business/notifier/business_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:village/screens/staff/model/staff_model.dart';
import 'package:village/screens/staff/notifier/staff_notifier.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {

  String _selectedCategory = 'All';


  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final future = <Future>[];
      final staffNotifier = ref.read(staffNotifierProvider.notifier);
        future.addAll([
          staffNotifier.loadStaff("api/customer/support"),
          staffNotifier.loadCategory("api/customer/support/categories"),
       ]);
        await Future.wait(future);
    });
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(staffNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.ssjsSecondaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Staff',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header with gradient
          if(state.category.isNotEmpty)
            Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: const BoxDecoration(
              color: AppTheme.ssjsSecondaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height:state.category.isEmpty?30: 40,
                  child:  state.isLoading && state.category.isEmpty
                      ?
                  Center(
                    child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator()),
                  )
                      :
                  state.category.isEmpty?
                  SizedBox()
                      :  ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.category.length,
                    itemBuilder: (context, index) {
                      final category = state.category[index];
                      final isSelected = category.categoryName == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () async {
                            if (_selectedCategory == category.categoryName) return; // Prevent redundant calls

                            setState(() {
                              _selectedCategory = category.categoryName;
                            });

                            // Determine the correct URL based on selection
                            final String url = (category.categoryName == "All")
                                ? "api/customer/support"
                                : "api/customer/support/categories?category=${category.categoryName}";

                            // Call the staff notifier to refresh the list
                            await ref.read(staffNotifierProvider.notifier).loadStaff(url);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category.categoryName,
                              style: TextStyle(
                                color: isSelected ? AppTheme.deepRedColor : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Business List
          Expanded(
            child:
            state.isLoading && state.staffList.isEmpty
                ?
            Center(
              child: SizedBox(
                height: 20,
                  width: 20,
                  child: CircularProgressIndicator()),
            )
                :
            state.staffList.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Staff found',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.staffList.length,
              itemBuilder: (context, index) {
                final business = state.staffList[index];
                return _buildBusinessCard(business);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(Staff business) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _showBusinessDetails(business);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  business.image.toString(),
                  fit: BoxFit.cover,
                  errorBuilder:
                  (context, error, stackTrace) {
                    return Icon(Icons.person, color: Colors.grey[400]);
                  },
                  loadingBuilder:
                      (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                      }
                ),
              ),
              const SizedBox(width: 16),
              // Business Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      business.phone.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Row(
                    //   children: [
                    //     Icon(Icons.category, size: 14, color: Colors.grey[600]),
                    //     const SizedBox(width: 4),
                    //     Expanded(
                    //       child: Text(
                    //         business..toString(),
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           color: Colors.grey[600],
                    //         ),
                    //         overflow: TextOverflow.ellipsis,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              // Call Button
              IconButton(
                icon: const Icon(Icons.phone, color: Color(0xFF1E90FF)),
                onPressed: () {
                  _makePhoneCall(business.phone.toString());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBusinessDetails(Staff business) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                business.name.toString(),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              Align(
                alignment: Alignment.center,
                child: Container(

                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(
                      business.image.toString(),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return Icon(Icons.person, color: Colors.grey[400]);
                      },
                      loadingBuilder:
                          (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      }
                  ),
                ),
              ),
              _buildDetailRow(Icons.person, 'Name', business.name),
              // _buildDetailRow(Icons.category, 'MsFirmName', business.msFirmName.toString()),
              _buildDetailRow(Icons.phone, 'Phone', business.phone.toString()),
              // _buildDetailRow(Icons.location_on, 'Address', business.officeAddress.toString()),
              // const SizedBox(height: 12),
              // const Text(
              //   'Description',
              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 14,
              //     color: Color(0xFF1E90FF),
              //   ),
              // ),
              // const SizedBox(height: 4),
              // Text(
              //   business['description'],
              //   style: const TextStyle(fontSize: 12, color: Colors.black87),
              // ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _makePhoneCall(business.phone.toString());
            },
            icon: const Icon(Icons.phone, color: Colors.white),
            label: const Text('Call Now', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E90FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E90FF)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

}
