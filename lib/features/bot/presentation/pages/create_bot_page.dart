import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/services/bot_service.dart';
import 'package:bytequeens_adm/data/models/ai_model.dart';
import 'package:bytequeens_adm/data/models/knowledge_source.dart';

class CreateBotPage extends StatefulWidget {
  const CreateBotPage({super.key});

  @override
  State<CreateBotPage> createState() => _CreateBotPageState();
}

class _CreateBotPageState extends State<CreateBotPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _botService = BotService();

  AIModel _selectedModel = AIModel.gpt4oMini;
  final List<KnowledgeSource> _knowledgeSources = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _botService.createBot(
          name: _nameController.text.trim(),
          instructions: _instructionsController.text.trim().isEmpty
              ? null
              : _instructionsController.text.trim(),
          model: _selectedModel,
          knowledgeSources: _knowledgeSources,
        );

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bot created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showModelSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Model',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Model list
            Expanded(
              child: ListView.builder(
                itemCount: AIModel.values.length,
                itemBuilder: (context, index) {
                  final model = AIModel.values[index];
                  return ListTile(
                    leading: Icon(
                      Icons.psychology,
                      color: _getModelColor(model),
                    ),
                    title: Text(model.displayName),
                    subtitle: Text(
                      model.description.split('\n')[0],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: _selectedModel == model
                        ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                        : null,
                    onTap: () {
                      setState(() => _selectedModel = model);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getModelColor(AIModel model) {
    switch (model.iconColor) {
      case 'black':
        return Colors.black;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'cyan':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  void _showKnowledgeSourceSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppConstants.knowledgeSources,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            _buildKnowledgeSourceItem(
              Icons.description,
              AppConstants.localFiles,
              AppConstants.localFilesDesc,
              KnowledgeSourceType.localFiles,
            ),
            _buildKnowledgeSourceItem(
              Icons.language,
              AppConstants.website,
              AppConstants.websiteDesc,
              KnowledgeSourceType.website,
            ),
            _buildKnowledgeSourceItem(
              Icons.folder,
              AppConstants.googleDrive,
              AppConstants.googleDriveDesc,
              KnowledgeSourceType.googleDrive,
            ),
            _buildKnowledgeSourceItem(
              Icons.chat,
              AppConstants.slack,
              AppConstants.slackDesc,
              KnowledgeSourceType.slack,
            ),
            _buildKnowledgeSourceItem(
              Icons.article,
              AppConstants.confluence,
              AppConstants.confluenceDesc,
              KnowledgeSourceType.confluence,
            ),
            _buildKnowledgeSourceItem(
              Icons.note,
              AppConstants.notion,
              AppConstants.notionDesc,
              KnowledgeSourceType.notion,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeSourceItem(
    IconData icon,
    String title,
    String subtitle,
    KnowledgeSourceType type,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        _showAddSourceDialog(type);
      },
    );
  }

  void _showAddSourceDialog(KnowledgeSourceType type) {
    // Mock: Just add a sample source
    final source = KnowledgeSource(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${type.toString().split('.').last} source',
      type: type,
      createdAt: DateTime.now(),
    );

    setState(() {
      _knowledgeSources.add(source);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${source.getTypeName()} added'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          AppConstants.createYourOwnBot,
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name field
            const Text(
              '${AppConstants.botName} *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: AppConstants.botNameHint,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter bot name';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Instructions field
            Text(
              AppConstants.instructionsOptional,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _instructionsController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: AppConstants.instructionsHint,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // Knowledge base
            Text(
              AppConstants.knowledgeBaseOptional,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppConstants.knowledgeBaseHint,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            // Knowledge sources list
            if (_knowledgeSources.isNotEmpty)
              ..._knowledgeSources.map((source) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description,
                        size: 20,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          source.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            _knowledgeSources.remove(source);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),

            // Add knowledge source button
            OutlinedButton.icon(
              onPressed: _showKnowledgeSourceSelector,
              icon: const Icon(Icons.add),
              label: const Text(AppConstants.addKnowledgeSource),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
                side: BorderSide(
                  color: AppTheme.primaryBlue,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 24),

            // Model selector
            const Text(
              AppConstants.model,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _showModelSelector,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: _getModelColor(_selectedModel),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedModel.displayName,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.darkBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: const Text(
                      AppConstants.cancel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            AppConstants.create,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
