import 'package:flutter/material.dart';
import 'package:village/screens/commitie/model/commitie_model.dart';
import 'package:village/screens/commitie/notifier/commitie_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';

class CommitteeScreen extends ConsumerStatefulWidget {
  const CommitteeScreen({super.key});

  @override
  ConsumerState<CommitteeScreen> createState() => _CommitteeScreenState();
}

class _CommitteeScreenState extends ConsumerState<CommitteeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(committeeNotifierProvider.notifier).loadCommittee();
    });
  }

  @override
  Widget build(BuildContext context) {
    final committeeState = ref.watch(committeeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.ssjsSecondaryBlue,
        title: const Text('Committee Members'),
      ),
      body: SafeArea(
        child: committeeState.isLoading && committeeState.committeeList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : committeeState.committeeList.isEmpty
                ? const Center(child: Text('No committee members found'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7, // Slightly increased height ratio
                    ),
                    itemCount: committeeState.committeeList.length,
                    itemBuilder: (context, index) {
                      final member = committeeState.committeeList[index];
                      return _buildCommitteeMemberCard(member);
                    },
                  ),
      ),
    );
  }

  Widget _buildCommitteeMemberCard(CommitteeMember member) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerGrey, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    // Avatar
                    Container(
                      width: 70, // Slightly reduced
                      height: 70, // Slightly reduced
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundGrey,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryBlue, width: 2),
                      ),
                      child: member.imagePath != null
                          ? ClipOval(
                              child: Image.network(
                                member.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    color: AppTheme.primaryBlue,
                                    size: 40,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: AppTheme.primaryBlue,
                              size: 40,
                            ),
                    ),
                    const SizedBox(height: 8),
                    // Name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        member.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Mobile
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone, size: 12, color: AppTheme.textGrey),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              member.phone,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textGrey,
                                    fontSize: 10,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: AppTheme.dividerGrey,
                    ),
                    const SizedBox(height: 6),
                    // Position
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        member.postName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.backgroundWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
