import 'package:flutter/material.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/media/downloaded_media_item.dart';
import 'package:cineprime/providers/download_provider.dart';
import 'package:provider/provider.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Downloads",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer<DownloadProvider>(
          builder: (context, downloadProvider, _) {
            final downloadWrappers = downloadProvider.getAllDownloads().values.toList();
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: downloadWrappers.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: downloadWrappers.length,
                        itemBuilder: (context, index) {
                          final wrapper = downloadWrappers[index];
                          final item = wrapper.downloadedBaseItem;

                          // Delete expired or cancelled items
                          if (item.status == "canceled" || item.validTill < DateTime.now().millisecondsSinceEpoch) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              downloadProvider.deleteDownload(item.id, item.taskId);
                            });
                            return const SizedBox.shrink();
                          }

                          return DownloadedMediaItem(wrapper: wrapper);
                        },
                      ),
                    )
                  : const EmptyState(
                      icon: Icons.cloud_download_outlined,
                      title: 'No Downloads Yet',
                      subtitle: 'Download your favourite titles to watch offline.',
                    ),
            );
          },
        ),
      ),
    );
  }
}
