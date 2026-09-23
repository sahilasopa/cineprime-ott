import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/providers/authentication_provider.dart';
import 'package:provider/provider.dart';
import '../../../providers/download_provider.dart';

class DownloadButton extends StatefulWidget {
  final BaseItem baseItem;
  final bool inline;

  const DownloadButton({super.key, required this.baseItem, this.inline = false});

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  String _downloadText = "Download";
  bool downloadButtonClickable = true;
  bool isDownloaded = false;
  bool isDownloading = false;
  bool isPaused = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<AuthenticationProvider>(context);
    final user = userProvider.getUser();
    if (!widget.baseItem.isDownloadable || widget.baseItem.downloadUrl.isEmpty) return Container();
    return Consumer<DownloadProvider>(builder: (BuildContext context, DownloadProvider value, Widget? child) {
      final downloadItemWrapper = value.getDownloadedBaseItemWrapper(widget.baseItem.id);
      final downloadItem = downloadItemWrapper?.downloadedBaseItem;
      if (downloadItem != null && downloadItemWrapper != null) {
        if (downloadItemWrapper.update != null) {
          final exception = downloadItemWrapper.update!.exception;
          if (exception != null && exception.description.contains("Insufficient space")) {
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) {
                value.deleteDownload(widget.baseItem.id, downloadItem.taskId);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You Don't Have Enough Storage Space For This Download")));
              },
            );
          }
        }
        String downloadStatus = downloadItem.status;
        if (downloadStatus == "downloaded" && downloadItem.progress < 1) {
          downloadItem.status = "paused";
          downloadStatus = "paused";
        }
        switch (downloadStatus) {
          case ("downloaded"):
            _downloadText = "Downloaded";
            isDownloaded = true;
            isPaused = false;
            isDownloading = false;
          case ("waiting_to_start"):
            _downloadText = "Starting Download";
            isDownloaded = false;
            isPaused = false;
            isDownloading = true;
          case ("downloading"):
            _downloadText = "Downloading ${(downloadItem.progress * 100).toStringAsPrecision(3)}%";
            isDownloading = true;
            isPaused = false;
            isDownloaded = false;
          case ("not_found"):
            _downloadText = "Download";
            isDownloading = false;
            isDownloaded = false;
            isPaused = false;
          case ("canceled"):
            _downloadText = "Download Cancelled";
            isDownloading = false;
            isDownloaded = false;
            isPaused = false;
          case ("retrying"):
            isDownloading = true;
            isPaused = false;
            isDownloaded = false;
            _downloadText = "Retrying";
          case ("paused"):
            isDownloading = true;
            isPaused = true;
            isDownloaded = false;
            _downloadText = "Download Paused";
          case ("not_downloaded"):
            isDownloading = false;
            isPaused = false;
            isDownloaded = false;
            _downloadText = "Download";
        }
        if (!(isDownloaded || isDownloading)) {
          _downloadText = "Download";
        }
      } else {
        _downloadText = "Download";
        isDownloading = false;
        isDownloaded = false;
        isPaused = false;
      }
      return SizedBox(
        child: Padding(
          padding: widget.inline ? EdgeInsets.zero : const EdgeInsets.only(left: 10, top: 10, right: 10),
          child: GestureDetector(
            onTap: () async {
              if (!downloadButtonClickable) return;
              if (isDownloaded || isDownloading || isPaused) {
                if (isDownloaded) {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withValues(alpha: 0.7),
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.colorBackground.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.colorPrimary.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Delete Download?",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Are you sure you want to delete ${widget.baseItem.title} from downloads?",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            side: BorderSide(
                                              color: Colors.white.withValues(alpha: 0.3),
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            value.deleteDownload(widget.baseItem.id, downloadItem?.taskId);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              } else {
                if (user != null) {
                  if (user.userSubscription == null){
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please Upgrade Your Plan To Download")));
                  }
                  if (user.canDownload) {
                    downloadButtonClickable = false;
                    await value.startDownload(widget.baseItem, user);
                    downloadButtonClickable = true;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please Upgrade Your Plan To Download")));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please Login To Download Content")));
                }
              }
            },
            child: widget.inline
                ? Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.colorSurface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDownloaded ? AppColors.colorPrimary : AppColors.colorInputBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isDownloaded
                              ? Icons.download_done_rounded
                              : isDownloading
                                  ? Icons.downloading_rounded
                                  : Icons.download_rounded,
                          color: isDownloaded ? AppColors.colorPrimary : Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isDownloaded
                                ? 'Saved'
                                : isDownloading
                                    ? ((downloadItem?.progress ?? 0) <= 0
                                        ? '...'
                                        : '${((downloadItem!.progress) * 100).round()}%')
                                    : 'Download',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDownloaded ? AppColors.colorPrimary : Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(3),
                ),
                alignment: Alignment.center,
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      Align(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isDownloaded)
                              const Icon(
                                Icons.download_done,
                                color: Colors.white,
                              ),
                            if (!isDownloaded && !isDownloading)
                              const Icon(
                                Icons.download,
                                color: Colors.white,
                              ),
                            const SizedBox(width: 10),
                            Text(
                              _downloadText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            (isDownloading)
                                ? GestureDetector(
                                    onTap: () async {
                                      if (isPaused && !isDownloaded) {
                                        final didResume = await value.resumeDownload(downloadItem!.taskId);
                                        if (!didResume) {
                                          if (!context.mounted) return;
                                          value.deleteDownload(widget.baseItem.id, downloadItem.taskId);
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resume Failed, Please Download Again")));
                                        }
                                      } else {
                                        await value.pauseDownload(downloadItem!.taskId);
                                      }
                                    },
                                    child: Icon(
                                      (isPaused && !isDownloaded) ? Icons.play_arrow : Icons.pause,
                                      color: Colors.white,
                                    ),
                                  )
                                : Container(),
                            const SizedBox(width: 8),
                            (isDownloading)
                                ? GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors.black.withValues(alpha: 0.7),
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(24),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                                child: Container(
                                                  padding: const EdgeInsets.all(24),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.colorBackground.withValues(alpha: 0.95),
                                                    borderRadius: BorderRadius.circular(24),
                                                    border: Border.all(
                                                      color: AppColors.colorPrimary.withValues(alpha: 0.3),
                                                      width: 1.5,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: 0.5),
                                                        blurRadius: 20,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(16),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.colorPrimary.withValues(alpha: 0.2),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.cancel_outlined,
                                                          color: AppColors.colorPrimary,
                                                          size: 32,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 20),
                                                      const Text(
                                                        "Cancel Download?",
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 12),
                                                      Text(
                                                        "Are you sure you want to cancel ${widget.baseItem.title} from downloading?",
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 24),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: OutlinedButton(
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                              },
                                                              style: OutlinedButton.styleFrom(
                                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                                side: BorderSide(
                                                                  color: Colors.white.withValues(alpha: 0.3),
                                                                  width: 1.5,
                                                                ),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(12),
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                "No",
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          Expanded(
                                                            child: ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                                value.deleteDownload(widget.baseItem.id, downloadItem?.taskId);
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: AppColors.colorPrimary,
                                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(12),
                                                                ),
                                                                elevation: 0,
                                                              ),
                                                              child: const Text(
                                                                "Yes",
                                                                style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: const Icon(
                                      Icons.cancel,
                                      color: Colors.white,
                                    ),
                                  )
                                : Container(),
                            const SizedBox(width: 7),
                          ],
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ),
      );
    });
  }
}
