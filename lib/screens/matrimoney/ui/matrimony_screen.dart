import 'package:flutter/material.dart';
import 'package:village/screens/matrimoney/model/matrimony_model.dart';
import 'package:village/screens/matrimoney/notifier/matrimony_notifier.dart';
import 'package:village/screens/matrimoney/ui/matrimoney_details.dart';
import 'package:village/screens/member_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import 'package:village/screens/members/notifier/member_notifier.dart';
import 'package:village/screens/members/model/member_model.dart';

class MatrimoneyScreen extends ConsumerStatefulWidget {
  const MatrimoneyScreen({super.key});

  @override
  ConsumerState<MatrimoneyScreen> createState() =>
      _MatrimoneyScreenState();
}

class _MatrimoneyScreenState extends ConsumerState<MatrimoneyScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(matrimoneyNotifierProvider.notifier)
          .loadMatrimoney('api/customer/customers-matrimony');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memberState = ref.watch(matrimoneyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.ssjsSecondaryBlue,
        title: const Text('Matrimony'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref
                      .read(matrimoneyNotifierProvider.notifier)
                      .loadMatrimoney(
                    'api/customer/customers-matrimony?search=$value',
                  );
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search Matrimony',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor:
                  AppTheme.backgroundGrey.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                      ref
                          .read(matrimoneyNotifierProvider.notifier)
                          .loadMatrimoney('api/customer/customers-matrimony');
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
    final state = ref.watch(matrimoneyNotifierProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!));
    }

    if (state.matrimoneyList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search,
                size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No help_support found',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.matrimoneyList.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        return _buildMemberTile(state.matrimoneyList[index]);
      },
    );
  }

  Widget _buildMemberTile(Matrimoney member) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MatrimoneyDetailScreen(matrimoney: member),
          ),
        );
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.dividerGrey,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.backgroundGrey,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                  AppTheme.primaryBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child:
                // (member != null &&
                //     member.image!.isNotEmpty)
                //     ? Image.network(
                //   member.image!,
                //   fit: BoxFit.cover,
                //   errorBuilder:
                //       (context, error, stackTrace) =>
                //   const Icon(Icons.person,
                //       color:
                //       AppTheme.primaryBlue),
                // )
                //     :
                const Icon(Icons.person,
                    color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.familyMemberName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone,
                          size: 14,
                          color: AppTheme.textGrey),
                      const SizedBox(width: 6),
                      Text(
                        member.familyMemberMobile.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppTheme.dividerGrey),
          ],
        ),
      ),
    );
  }
}
