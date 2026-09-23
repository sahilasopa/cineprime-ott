import 'dart:io';
import 'dart:ui' as ui;

import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/controls/icon_text.dart';
import 'package:cineprime/presentation/pages/media/offline_video_player.dart';
import 'package:cineprime/providers/download_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class DownloadBottomSheetWidget extends StatefulWidget {
  final String baseItemId;

  const DownloadBottomSheetWidget({super.key, required this.baseItemId});

  @override
  State<DownloadBottomSheetWidget> createState() => _DownloadBottomSheetWidgetState();
}

class _DownloadBottomSheetWidgetState extends State<DownloadBottomSheetWidget> {
  bool? _isHorizontal;
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadImageDimensions();
    });
  }

  Future<void> _loadImageDimensions() async {
    if (!mounted) return;
    final downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
    final downloadedWrapper = downloadProvider.getDownloadedBaseItemWrapper(widget.baseItemId);
    if (downloadedWrapper == null) return;

    try {
      final file = File(downloadedWrapper.downloadedBaseItem.posterPath);
      if (!await file.exists()) {
        setState(() {
          _isHorizontal = false;
          _aspectRatio = 2 / 3;
        });
        return;
      }

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      final width = image.width.toDouble();
      final height = image.height.toDouble();
      final aspectRatio = width / height;
      
      setState(() {
        _aspectRatio = aspectRatio;
        _isHorizontal = aspectRatio > 1.0;
      });
      
      image.dispose();
    } catch (e) {
      setState(() {
        _isHorizontal = false;
        _aspectRatio = 2 / 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloadProvider = Provider.of<DownloadProvider>(context);
    final downloadedWrapper = downloadProvider.getDownloadedBaseItemWrapper(widget.baseItemId);
    if (downloadedWrapper == null) {
      Navigator.of(context).pop();
      return Container(
        color: AppColors.colorBackground,
      );
    }
    if (downloadedWrapper.downloadedBaseItem.status == "downloaded" && downloadedWrapper.downloadedBaseItem.progress < 1){
      downloadedWrapper.downloadedBaseItem.status = "paused";
    }
    bool isPaused = downloadedWrapper.downloadedBaseItem.status == "paused";
    String pauseText = isPaused ? "Resume Download" : "Pause Download";
    if (downloadedWrapper.downloadedBaseItem.progress == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => OfflineVideoDetailsPage(downloadedWrapper),
        ));
      });
    }

    // Use detected aspect ratio or default to 2/3
    final aspectRatio = _aspectRatio ?? 2 / 3;
    final isHorizontal = _isHorizontal ?? false;

    return SafeArea(
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal layout: poster on top, controls below
            if (isHorizontal) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: Image.file(
                    File(downloadedWrapper.downloadedBaseItem.posterPath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${(downloadedWrapper.downloadedBaseItem.progress * 100).toStringAsPrecision(3)}% Downloaded",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: downloadedWrapper.downloadedBaseItem.progress,
                      color: AppColors.colorPrimary,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        if (isPaused) {
                          final didResume = await downloadProvider.resumeDownload(downloadedWrapper.downloadedBaseItem.taskId);
                          if (!didResume) {
                            if (!context.mounted) return;
                            downloadProvider.deleteDownload(downloadedWrapper.downloadedBaseItem.id, downloadedWrapper.downloadedBaseItem.taskId);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resume Failed, Please Download Again")));
                          }
                        } else {
                          await downloadProvider.pauseDownload(downloadedWrapper.downloadedBaseItem.taskId);
                        }
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: IconText(
                            icon: Icon(isPaused ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 24),
                            text: Text(
                              pauseText,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
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
                                  filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                                            color: Colors.orange.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.cancel_outlined,
                                            color: Colors.orange,
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
                                          "Are you sure you want to cancel ${downloadedWrapper.downloadedBaseItem.title} from downloading?",
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
                                                  downloadProvider.deleteDownload(downloadedWrapper.downloadedBaseItem.id, downloadedWrapper.downloadedBaseItem.taskId);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.orange,
                                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: const Text(
                                                  "Cancel",
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
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: IconText(
                            icon: Icon(Icons.cancel, color: Colors.white, size: 24),
                            text: Text(
                              "Cancel Download",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Vertical layout: side-by-side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 160),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: aspectRatio,
                        child: Image.file(
                          File(downloadedWrapper.downloadedBaseItem.posterPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16, bottom: 8),
                          child: Text(
                            "${(downloadedWrapper.downloadedBaseItem.progress * 100).toStringAsPrecision(3)}% Downloaded",
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16, bottom: 16),
                          child: LinearProgressIndicator(
                            value: downloadedWrapper.downloadedBaseItem.progress,
                            color: AppColors.colorPrimary,
                            minHeight: 10,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (isPaused) {
                              final didResume = await downloadProvider.resumeDownload(downloadedWrapper.downloadedBaseItem.taskId);
                              if (!didResume) {
                                if (!context.mounted) return;
                                downloadProvider.deleteDownload(downloadedWrapper.downloadedBaseItem.id, downloadedWrapper.downloadedBaseItem.taskId);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resume Failed, Please Download Again")));
                              }
                            } else {
                              await downloadProvider.pauseDownload(downloadedWrapper.downloadedBaseItem.taskId);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16, bottom: 16),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: IconText(
                                  icon: Icon(isPaused ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 24),
                                  text: Text(
                                    pauseText,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Cancel Download"),
                                  content: Text("Are you sure you want to cancel ${downloadedWrapper.downloadedBaseItem.title} from downloading?"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text("No"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("Yes"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        downloadProvider.deleteDownload(downloadedWrapper.downloadedBaseItem.id, downloadedWrapper.downloadedBaseItem.taskId);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16, bottom: 16),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: IconText(
                                  icon: Icon(Icons.cancel, color: Colors.white, size: 24),
                                  text: Text(
                                    "Cancel Download",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
