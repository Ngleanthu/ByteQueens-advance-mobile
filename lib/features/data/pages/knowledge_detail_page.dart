import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../data/models/knowledge_base.dart';
import '../../data/models/knowledge_unit.dart';
import '../../../services/knowledge_service.dart';
import '../widgets/knowledge_unit_item.dart';
import '../widgets/add_knowledge_unit_dialog.dart';
import '../widgets/import_local_files_dialog.dart';
import '../widgets/import_website_dialog.dart';
import '../widgets/import_google_drive_dialog.dart';
import '../widgets/import_slack_dialog.dart';
import '../widgets/import_confluence_dialog.dart';
import 'dart:io';

class KnowledgeDetailPage extends StatefulWidget {
  final KnowledgeBase knowledge;

  const KnowledgeDetailPage({super.key, required this.knowledge});

  @override
  State<KnowledgeDetailPage> createState() => _KnowledgeDetailPageState();
}

class _KnowledgeDetailPageState extends State<KnowledgeDetailPage> {
  final TextEditingController _searchController = TextEditingController();
  final KnowledgeService _knowledgeService = KnowledgeService();

  List<KnowledgeUnit> _allUnits = [];
  List<KnowledgeUnit> _knowledgeUnits = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  static const primaryBlue = Color(0xFF2196F3);
  static const lightBlue = Color(0xFF4A90E2);
  static const backgroundWhite = Color(0xFFFAFBFF);
  static const cardWhite = Colors.white;
  static const textDark = Color(0xFF1A1D2E);
  static const textGray = Color(0xFF6B7280);
  static const borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _loadKnowledgeUnits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _loadKnowledgeUnits() async {
    _safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📥 ========== LOADING DATASOURCES ==========');
      print('🆔 Knowledge ID: ${widget.knowledge.id}');

      final response = await _knowledgeService.getDatasources(
        widget.knowledge.id,
        limit: 20,
      );

      print('📊 Response status: ${response.statusCode}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = response.data;

        if (data == null || data is! Map) {
          throw Exception('Invalid response data');
        }

        final dynamic datasourcesData = data['data'];

        if (datasourcesData == null) {
          print('⚠️ No datasources found in response');
          _safeSetState(() {
            _allUnits = [];
            _filterUnits();
            _isLoading = false;
          });
          return;
        }

        if (datasourcesData is! List) {
          throw Exception('Datasources is not a List');
        }

        final List<dynamic> datasources = datasourcesData;
        print('📊 Found ${datasources.length} datasources');

        // ✅ Parse each datasource with correct types
        final units = datasources
            .map((ds) {
              try {
                if (ds is! Map) {
                  print('⚠️ Skipping invalid datasource');
                  return null;
                }

                final dsMap = Map<String, dynamic>.from(ds);

                // ✅ Parse status - API returns bool, convert to string
                final statusBool = dsMap['status'];
                final statusString = statusBool is bool
                    ? (statusBool ? 'active' : 'inactive')
                    : 'unknown';

                // ✅ Parse createdAt from metadata.created_at
                final metadata = dsMap['metadata'];
                final createdAtStr = metadata is Map
                    ? metadata['created_at']
                    : null;
                final createdAt = createdAtStr is String
                    ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
                    : DateTime.now();

                // ✅ Parse syncStatus
                final syncStatus = dsMap['syncStatus']?.toString() ?? 'unknown';

                final unit = KnowledgeUnit(
                  id: dsMap['id']?.toString() ?? '',
                  knowledgeId:
                      dsMap['knowledgeId']?.toString() ?? widget.knowledge.id,
                  name: dsMap['name']?.toString() ?? 'Unnamed datasource',
                  type: dsMap['type']?.toString() ?? 'unknown',
                  status: statusString, // ✅ Now a string
                  sizeInBytes: _calculateSize(dsMap),
                  createdAt: createdAt,
                );

                print('✅ Parsed: ${unit.name} (${unit.type}) - $statusString');
                return unit;
              } catch (e) {
                print('⚠️ Error parsing datasource: $e');
                return null;
              }
            })
            .whereType<KnowledgeUnit>()
            .toList();

        print('✅ Successfully parsed ${units.length} datasources');

        _safeSetState(() {
          _allUnits = units;
          _filterUnits();
          _isLoading = false;
        });

        print('✅ ========== LOADING COMPLETED ==========\n');
      } else {
        throw Exception('Failed to load datasources: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ ========== LOADING FAILED ==========');
      print('❌ Error: $e');
      print('❌ =====================================\n');

      if (!mounted) return;

      _safeSetState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
      _showSnackBar('Error loading units: $_errorMessage', isError: true);
    }
  }

  /// Calculate size from datasource data
  int _calculateSize(Map<String, dynamic> datasource) {
    try {
      final sizeValue = datasource['size'];
      if (sizeValue != null) {
        if (sizeValue is int) return sizeValue;
        if (sizeValue is String) {
          final parsed = int.tryParse(sizeValue);
          if (parsed != null) return parsed;
        }
      }
      final metadata = datasource['metadata'];
      if (metadata != null && metadata is Map) {
        final metaSize = metadata['size'];
        if (metaSize != null) {
          if (metaSize is int) return metaSize;
          if (metaSize is String) {
            final parsed = int.tryParse(metaSize);
            if (parsed != null) return parsed;
          }
        }
      }
      final type = datasource['type']?.toString() ?? 'unknown';
      switch (type) {
        case 'web':
          return 1234567; // ~1.2 MB
        case 'confluence':
          return 2345678; // ~2.2 MB
        case 'google_drive':
          return 3456789; // ~3.3 MB
        case 'local_file':
          return 4567890; // ~4.4 MB
        default:
          return 1000000; // 1 MB default
      }
    } catch (e) {
      return 1000000;
    }
  }

  /// Filter units based on search query
  void _filterUnits() {
    if (_searchQuery.isEmpty) {
      _knowledgeUnits = List.from(_allUnits);
    } else {
      final query = _searchQuery.toLowerCase();
      _knowledgeUnits = _allUnits.where((unit) {
        return unit.name.toLowerCase().contains(query) ||
            unit.type.toLowerCase().contains(query) ||
            unit.status.toLowerCase().contains(query);
      }).toList();
    }
  }

  void _onAddKnowledgeUnitPressed() async {
    final source = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddKnowledgeUnitDialog(),
    );

    if (source != null && mounted) {
      await _handleSourceTap(context, source);
    }
  }

  Future<void> _handleDeleteUnit(KnowledgeUnit unit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Datasource'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('Are you sure you want to delete "${unit.name}"?'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      _safeSetState(() => _isLoading = true);

      try {
        // Call API to delete datasource
        await _knowledgeService.deleteDatasource(widget.knowledge.id, unit.id);

        if (!mounted) return;

        // Remove from local list
        _safeSetState(() {
          _allUnits.removeWhere((u) => u.id == unit.id);
          _filterUnits();
          _isLoading = false;
        });

        _showSnackBar('Datasource deleted successfully');
      } catch (e) {
        if (!mounted) return;

        _safeSetState(() => _isLoading = false);
        _showSnackBar(
          'Failed to delete: ${e.toString().replaceAll('Exception: ', '')}',
          isError: true,
        );
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleSearch(String value) {
    _safeSetState(() {
      _searchQuery = value;
      _filterUnits();
    });
  }

  Future<void> _handleSourceTap(BuildContext context, String source) async {
    Widget dialog;

    switch (source) {
      case 'local_files':
        dialog = const ImportLocalFilesDialog();
        break;
      case 'website':
        dialog = const ImportWebsiteDialog();
        break;
      case 'google_drive':
        dialog = const ImportGoogleDriveDialog();
        break;
      case 'slack':
        dialog = const ImportSlackDialog();
        break;
      case 'confluence':
        dialog = const ImportConfluenceDialog();
        break;
      default:
        return;
    }

    // ✅ Accept dynamic result from dialog
    final result = await showDialog(context: context, builder: (_) => dialog);

    print('🔍 Dialog result type: ${result.runtimeType}');
    print('🔍 Dialog result value: $result');

    if (result != null && mounted) {
      // ✅ Handle the result with proper type conversion
      await _handleImportResult(source, result);
    }
  }

  /// ✅ Handle import result with proper type conversion
  Future<void> _handleImportResult(String source, dynamic result) async {
    // ✅ Convert result to Map<String, dynamic> safely
    Map<String, dynamic> resultMap;

    try {
      if (result is Map<String, dynamic>) {
        resultMap = result;
      } else if (result is Map) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        resultMap = Map<String, dynamic>.from(result);
      } else {
        throw Exception(
          'Invalid result type: ${result.runtimeType}. Expected Map.',
        );
      }
    } catch (e) {
      print('❌ Type conversion error: $e');
      _showSnackBar('Invalid data format from dialog', isError: true);
      return;
    }

    // Validate resultMap is not empty
    if (resultMap.isEmpty) {
      print('⚠️ Warning: Result map is empty');
      _showSnackBar('No data received from dialog', isError: true);
      return;
    }

    // Show loading dialog
    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CupertinoPopupSurface(
          isSurfacePainted: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(radius: 14),
                const SizedBox(height: 18),
                Text(
                  'Importing ${_getSourceDisplayName(source)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Please wait a moment…',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      switch (source) {
        case 'website':
          await _handleWebsiteImport(resultMap);
          break;
        case 'local_files':
          await _handleLocalFilesImport(resultMap);
          break;
        case 'google_drive':
          await _handleGoogleDriveImport(resultMap);
          break;
        case 'confluence':
          await _handleConfluenceImport(resultMap);
          break;
        case 'slack':
          await _handleSlackImport(resultMap);
          break;
        default:
          throw Exception('Unknown source type: $source');
      }

      // Close loading dialog
      if (!mounted) return;
      Navigator.pop(context);

      // Show success message
      final name = resultMap['name']?.toString() ?? 'datasource';
      _showSnackBar('Successfully imported: $name');

      // Reload datasources
      await _loadKnowledgeUnits();
    } catch (e, stackTrace) {
      // Close loading dialog
      if (!mounted) return;
      Navigator.pop(context);

      // Show error message
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      _showSnackBar('Import failed: $errorMsg', isError: true);
    }
  }

  /// Get display name for source type
  String _getSourceDisplayName(String source) {
    switch (source) {
      case 'website':
        return 'website';
      case 'local_files':
        return 'files';
      case 'google_drive':
        return 'Google Drive';
      case 'slack':
        return 'Slack';
      case 'confluence':
        return 'Confluence';
      default:
        return 'datasource';
    }
  }

  Future<void> _handleWebsiteImport(Map<String, dynamic> result) async {
    final name = result['name']?.toString()?.trim();
    final url = result['url']?.toString()?.trim();

    if (name == null || name.isEmpty) {
      throw Exception('Name is required');
    }
    if (url == null || url.isEmpty) {
      throw Exception('URL is required');
    }

    // Convert interval to API format
    final intervalMap = {
      '30 min': '30m',
      '1 hour': '1h',
      '6 hours': '6h',
      '12 hours': '12h',
      '1 day': '24h',
      '3 days': '72h',
      '1 week': '168h',
    };
    final crawlType = result['crawlType']?.toString() ?? 'single_page';
    final autoUpdate = result['autoUpdate'];
    final autoSync = autoUpdate is bool ? autoUpdate : true;
    final intervalKey = result['interval']?.toString() ?? '12 hours';
    final interval = intervalMap[intervalKey] ?? '12h';
    final response = await _knowledgeService.addWebDatasource(
      widget.knowledge.id,
      name: name,
      url: url,
      crawlType: crawlType,
      autoSync: autoSync,
      syncInterval: interval,
      pageLimit: 64,
    );
  }

  /// Handle local files import (placeholder)
  Future<void> _handleLocalFilesImport(Map<String, dynamic> result) async {
    final name = result['name']?.toString()?.trim();
    if (name == null || name.isEmpty) {
      throw Exception('Datasource name is required');
    }

    final files = result['files'];
    if (files == null || files is! List || files.isEmpty) {
      throw Exception('No files selected');
    }

    final List<File> fileList = files.cast<File>();
    final uploadResponse = await _knowledgeService.uploadFiles(files: fileList);

    if (uploadResponse.statusCode != 200 && uploadResponse.statusCode != 201) {
      throw Exception('Failed to upload files: ${uploadResponse.statusCode}');
    }

    // Parse upload response
    final uploadData = uploadResponse.data;
    if (uploadData == null || uploadData['files'] == null) {
      throw Exception('Invalid upload response');
    }

    final List<dynamic> uploadedFiles = uploadData['files'];
    // Extract file IDs and types
    final List<String> fileIds = [];
    final Map<String, String> fileTypes = {};

    for (var uploadedFile in uploadedFiles) {
      if (uploadedFile is Map) {
        final fileId = uploadedFile['id']?.toString();
        final extension = uploadedFile['extension']?.toString() ?? 'pdf';

        if (fileId != null) {
          fileIds.add(fileId);
          fileTypes[fileId] = extension;
        }
      }
    }

    if (fileIds.isEmpty) {
      throw Exception('No file IDs received from upload');
    }
    final response = await _knowledgeService.addLocalFilesDatasource(
      widget.knowledge.id,
      name: name,
      fileIds: fileIds,
    );
    if (response.data != null) {
      print('Local files datasource created successfully');
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _handleGoogleDriveImport(Map<String, dynamic> result) async {
    throw UnimplementedError('Google Drive import not implemented yet');
  }

  /// Handle Confluence import (placeholder)
  Future<void> _handleConfluenceImport(Map<String, dynamic> result) async {
    try {
      final name = result['name']?.toString().trim();
      final url = result['url']?.toString().trim();
      final username = result['username']?.toString().trim();
      final token = result['token']?.toString().trim();
      final autoSync = result['autoSync'] == true;
      final pageLimit = result['pageLimit'] is int ? result['pageLimit'] : 128;
      if (name == null || name.isEmpty) {
        throw Exception('Datasource name is required');
      }

      if (url == null || url.isEmpty) {
        throw Exception('Confluence URL is required');
      }

      if (!url.contains('atlassian.net/wiki')) {
        throw Exception('Invalid Confluence wiki URL');
      }

      if (username == null || username.isEmpty) {
        throw Exception('Confluence username (email) is required');
      }

      if (token == null || token.isEmpty) {
        throw Exception('Confluence API token is required');
      }
      final response = await _knowledgeService.addDatasources(
        widget.knowledge.id,
        datasources: [
          {
            'name': name,
            'type': 'confluence',
            'credentials': {'url': url, 'username': username, 'token': token},
            'options': {'sync': autoSync, 'pageLimit': pageLimit},
          },
        ],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _handleSlackImport(Map<String, dynamic> result) async {
    try {
      final name = result['name']?.toString().trim();
      final token = result['token']?.toString().trim();
      final autoUpdate = result['autoUpdate'] == true;

      if (name == null || name.isEmpty) {
        throw Exception('Datasource name is required');
      }

      if (token == null || token.isEmpty) {
        throw Exception('Slack bot token is required');
      }

      if (!token.startsWith('xoxb-')) {
        throw Exception('Invalid Slack bot token (must start with xoxb-)');
      }
      final response = await _knowledgeService.addDatasources(
        widget.knowledge.id,
        datasources: [
          {
            'name': name,
            'type': 'slack',
            'credentials': {'token': token, 'autoUpdate': autoUpdate},
          },
        ],
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardWhite,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.knowledge.name,
              style: const TextStyle(
                color: textDark,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              widget.knowledge.description,
              style: TextStyle(
                color: textGray.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.xmark, color: textDark),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Add Knowledge Unit Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _isLoading ? null : _onAddKnowledgeUnitPressed,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: _isLoading
                        ? [textGray.withOpacity(0.5), textGray.withOpacity(0.5)]
                        : [primaryBlue, lightBlue],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.add_circled_solid,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Add Knowledge Unit',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _handleSearch,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Search knowledge units...',
                  hintStyle: TextStyle(
                    color: textGray.withOpacity(0.6),
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    color: textGray,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: textGray,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _handleSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Knowledge Units List
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                ? _buildErrorState()
                : _knowledgeUnits.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadKnowledgeUnits,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _knowledgeUnits.length,
                      itemBuilder: (context, index) {
                        final unit = _knowledgeUnits[index];
                        return KnowledgeUnitItem(
                          unit: unit,
                          onTap: () {
                            _showSnackBar('Opening: ${unit.name}');
                          },
                          onDelete: () => _handleDeleteUnit(unit),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CupertinoActivityIndicator(radius: 16));
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 40,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Error Loading Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Unknown error',
              style: TextStyle(fontSize: 15, color: textGray.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            onPressed: _loadKnowledgeUnits,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _searchQuery.isNotEmpty
                  ? CupertinoIcons.search
                  : CupertinoIcons.doc_text_search,
              size: 60,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty
                ? 'No datasources found'
                : 'No datasources yet',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search'
                  : 'Add your first datasource to get started',
              style: TextStyle(fontSize: 15, color: textGray.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
