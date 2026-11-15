import 'package:flutter/material.dart';

import '../services/file_storage_service.dart';
import '../services/file_uri_service.dart';

class MyFilesScreen extends StatefulWidget {
  const MyFilesScreen({super.key});

  @override
  State<MyFilesScreen> createState() => _MyFilesScreenState();
}

class _MyFilesScreenState extends State<MyFilesScreen> {
  List<Map<String, dynamic>> files = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  Future<void> loadFiles() async {
    if (mounted) {
      setState(() => isLoading = true);
    }

    try {
      final result = await FileStorageService.getSavedFiles();

      if (!mounted) return;

      setState(() {
        files = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Files load nahi hui: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredFiles {
    if (searchQuery.trim().isEmpty) return files;

    final query = searchQuery.toLowerCase();

    return files.where((file) {
      final name = (file['name'] ?? '').toString().toLowerCase();
      final category =
          (file['category'] ?? '').toString().toLowerCase();

      return name.contains(query) || category.contains(query);
    }).toList();
  }

  String formatSize(dynamic value) {
    final bytes = value is num ? value.toDouble() : 0.0;

    if (bytes < 1024) {
      return '${bytes.toStringAsFixed(0)} B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String formatDate(dynamic value) {
    try {
      final date = DateTime.parse(value.toString()).toLocal();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return 'Unknown date';
    }
  }

  IconData fileIcon(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return Icons.image_outlined;
    }

    if (mimeType == 'application/pdf') {
      return Icons.picture_as_pdf_outlined;
    }

    return Icons.insert_drive_file_outlined;
  }

  Future<void> openSavedFile(Map<String, dynamic> file) async {
    final uri = file['uri']?.toString();

    if (uri == null || uri.isEmpty) {
      showMessage('File URI nahi mila.');
      return;
    }

    try {
      await FileUriService.openFile(
        uri: uri,
        mimeType: file['mimeType']?.toString() ?? '*/*',
      );
    } catch (e) {
      showMessage('File open nahi hui: $e');
    }
  }

  Future<void> shareSavedFile(Map<String, dynamic> file) async {
    final uri = file['uri']?.toString();

    if (uri == null || uri.isEmpty) {
      showMessage('File URI nahi mila.');
      return;
    }

    try {
      await FileUriService.shareFile(
        uri: uri,
        mimeType: file['mimeType']?.toString() ?? '*/*',
      );
    } catch (e) {
      showMessage('File share nahi hui: $e');
    }
  }

  Future<void> removeHistory(Map<String, dynamic> file) async {
    final uri = file['uri']?.toString();

    if (uri == null || uri.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from My Files?'),
        content: const Text(
          'Ye file sirf DocsIND ki My Files history se hategi. '
          'Phone se original file delete nahi hogi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FileStorageService.removeFromHistory(uri);
      await loadFiles();

      if (!mounted) return;

      showMessage('File history se remove ho gayi.');
    } catch (e) {
      showMessage('Remove nahi ho payi: $e');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget buildFileCard(Map<String, dynamic> file) {
    final name = (file['name'] ?? 'Untitled').toString();
    final category = (file['category'] ?? 'Document').toString();
    final mimeType = (file['mimeType'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8EDF5),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              fileIcon(mimeType),
              color: const Color(0xFF2864DC),
              size: 27,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF172B4D),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$category • ${formatSize(file['size'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  formatDate(file['savedAt']),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            tooltip: 'File options',
            onSelected: (value) {
              if (value == 'open') {
                openSavedFile(file);
              } else if (value == 'share') {
                shareSavedFile(file);
              } else if (value == 'remove') {
                removeHistory(file);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.open_in_new, size: 20),
                    SizedBox(width: 10),
                    Text('Open'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Remove from history',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleFiles = filteredFiles;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172B4D),
        elevation: 0,
        title: const Text(
          'My Files',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loadFiles,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
            child: TextField(
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Search your saved files...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF2F5FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : visibleFiles.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: loadFiles,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Saved Documents',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF172B4D),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${visibleFiles.length} files',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            ...visibleFiles.map(buildFileCard),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 52,
                color: Color(0xFF2864DC),
              ),
            ),

            const SizedBox(height: 22),

            Text(
              searchQuery.isEmpty
                  ? 'No files saved yet'
                  : 'No matching files found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              searchQuery.isEmpty
                  ? 'Files created with DocsIND will appear here.'
                  : 'Try searching with another file name.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

