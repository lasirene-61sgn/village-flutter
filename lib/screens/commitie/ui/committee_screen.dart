import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
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
                : ListView.builder(
                    itemCount: committeeState.committeeList.length,
                    itemBuilder: (context, index) {
                      final member = committeeState.committeeList[index];
                      return _buildCommitteeMemberTile(member);
                    },
                  ),
      ),
    );
  }

  Widget _buildCommitteeMemberTile(CommitteeMember member) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(color: AppTheme.dividerGrey, width: 0.5))),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: (member.imagePath != null && member.imagePath!.isNotEmpty)
                ? NetworkImage(member.imagePath!)
                : null,
            child: (member.imagePath == null || member.imagePath!.isEmpty)
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(member.phone,
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    member.postName,
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (member.phone.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _launchUrl('tel:${member.phone}'),
            ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    LaunchMode mode = LaunchMode.platformDefault;
    if (url.scheme == 'tel' || url.scheme == 'mailto' || url.scheme == 'sms') {
      mode = LaunchMode.externalApplication;
    }
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: mode);
    } else {
      debugPrint('Could not launch $urlString');
    }
  }
}
