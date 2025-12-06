import 'package:flutter/material.dart';
import '../../../../data/models/prompt.dart';
import '../widgets/prompt_item.dart';
import '../widgets/create_prompt_dialog.dart';

class PromptListPage extends StatefulWidget {
  const PromptListPage({Key? key}) : super(key: key);

  @override
  State<PromptListPage> createState() => _PromptListPageState();
}

class _PromptListPageState extends State<PromptListPage> {
  final List<Prompt> _allPrompts = [
    // Marketing
    Prompt(
      id: 'p1',
      title: 'Social Media Post Generator',
      description:
          'Generate engaging social media posts for Instagram, Facebook, and Twitter with hashtags and emojis.',
      content:
          'Write an engaging social media post about [topic] for [platform], including emojis and relevant hashtags.',
      isPublic: true,
    ),
    Prompt(
      id: 'p2',
      title: 'Product Description Writer',
      description:
          'Create compelling product descriptions that highlight features, benefits, and unique selling points.',
      content:
          'Write a compelling product description for [product], focusing on features, benefits, and unique selling points.',
      isPublic: true,
      isFavorite: true,
    ),
    Prompt(
      id: 'p3',
      title: 'Email Marketing Campaign',
      description:
          'Design email marketing campaigns with subject lines, body content, and call-to-action buttons.',
      content:
          'Create an email marketing campaign for [purpose], including subject line, email body, and call-to-action.',
      isPublic: false,
      isFavorite: true,
    ),
    Prompt(
      id: 'p4',
      title: 'Blog Post Outline',
      description:
          'Create detailed blog post outlines with headings, subheadings, and key points to cover.',
      content:
          'Generate a detailed blog outline about [topic], including headings, subheadings, and key talking points.',
      isPublic: true,
    ),

    // Engineering
    Prompt(
      id: 'p5',
      title: 'Code Review Checklist',
      description:
          'Generate comprehensive code review checklist covering security, performance, and best practices.',
      content:
          'Create a complete code review checklist focused on code quality, best practices, performance, and security.',
      isPublic: true,
      isFavorite: true,
    ),
    Prompt(
      id: 'p6',
      title: 'API Documentation Generator',
      description:
          'Create clear and concise API documentation with endpoints, parameters, and response examples.',
      content:
          'Generate API documentation for an API with endpoints, parameters, request/response examples, and error codes.',
      isPublic: false,
    ),
    Prompt(
      id: 'p7',
      title: 'Bug Report Template',
      description:
          'Generate detailed bug report templates with steps to reproduce, expected vs actual behavior.',
      content:
          'Create a bug report template including title, environment, steps to reproduce, expected result, actual result, and attachments.',
      isPublic: true,
    ),
    Prompt(
      id: 'p8',
      title: 'Unit Test Generator',
      description:
          'Create unit test cases for functions and methods with edge cases and assertions.',
      content:
          'Generate unit test cases for the function [function name], including normal cases, edge cases, and assertions.',
      isPublic: false,
      isFavorite: true,
    ),

    // Support
    Prompt(
      id: 'p9',
      title: 'Customer Support Response',
      description:
          'Generate empathetic and helpful customer support responses for common issues.',
      content:
          'Write an empathetic customer support response for the issue: [describe user issue].',
      isPublic: true,
    ),
    Prompt(
      id: 'p10',
      title: 'FAQ Generator',
      description:
          'Create comprehensive FAQ sections with questions and detailed answers.',
      content:
          'Generate an FAQ section about [topic], including common questions and detailed answers.',
      isPublic: true,
      isFavorite: true,
    ),
    Prompt(
      id: 'p11',
      title: 'Ticket Escalation Template',
      description:
          'Generate professional ticket escalation messages with context and urgency levels.',
      content:
          'Write a ticket escalation message that includes issue summary, urgency level, and required next actions.',
      isPublic: false,
    ),
    Prompt(
      id: 'p12',
      title: 'Knowledge Base Article',
      description:
          'Create detailed knowledge base articles with step-by-step instructions and screenshots.',
      content:
          'Write a knowledge base article explaining how to [task], including steps and troubleshooting tips.',
      isPublic: true,
    ),

    // General
    Prompt(
      id: 'p13',
      title: 'Meeting Notes Summarizer',
      description:
          'Summarize meeting notes into key points, action items, and decisions made.',
      content:
          'Summarize the following meeting notes into key points, decisions made, and action items: [paste notes].',
      isPublic: false,
      isFavorite: true,
    ),
    Prompt(
      id: 'p14',
      title: 'Interview Questions Generator',
      description:
          'Create relevant interview questions for different roles and experience levels.',
      content:
          'Generate interview questions for the position of [job role], including behavioral and technical questions.',
      isPublic: true,
    ),
    Prompt(
      id: 'p15',
      title: 'Project Proposal Writer',
      description:
          'Generate professional project proposals with objectives, timeline, and budget breakdown.',
      content:
          'Write a project proposal for [project name], including objectives, scope, timeline, deliverables, and budget.',
      isPublic: false,
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _filterFavoritesOnly = false;
  bool _showPublicPrompts = true; // true = Public, false = My Prompts

  final List<String> _categories = [
    'All',
    'Marketing',
    'Engineering',
    'Support',
    'General',
  ];
  String _selectedCategory = 'All';

  List<Prompt> get filtered {
    Iterable<Prompt> list = _allPrompts;

    // Filter by public/private based on selected tab
    if (_showPublicPrompts) {
      list = list.where((p) => p.isPublic);
    } else {
      list = list.where((p) => !p.isPublic);
    }

    // // Filter by category
    // if (_selectedCategory != 'All') {
    //   list = list.where((p) => p.category == _selectedCategory);
    // }

    // if (_filterFavoritesOnly) {
    //   list = list.where((p) => p.isFavorite);
    // }

    // if (_searchQuery.isNotEmpty) {
    //   list = list.where(
    //     (p) =>
    //         p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
    //         p.description.toLowerCase().contains(_searchQuery.toLowerCase()),
    //   );
    // }

    return list.toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Prompts Library",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const CreatePromptDialog();
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    _filterFavoritesOnly ? Icons.star : Icons.star_border,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(
                      () => _filterFavoritesOnly = !_filterFavoritesOnly,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab selector (Public prompts / My Prompts)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _showPublicPrompts = true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _showPublicPrompts
                              ? Colors.blue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: _showPublicPrompts
                              ? [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Public Prompts',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: _showPublicPrompts
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _showPublicPrompts
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _showPublicPrompts = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_showPublicPrompts
                              ? Colors.blue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: !_showPublicPrompts
                              ? [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'My Prompts',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: !_showPublicPrompts
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _showPublicPrompts
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search bar with proper width constraints
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      filled: true,
                      fillColor: Color.fromARGB(255, 248, 248, 248),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  return ChoiceChip(
                    label: Text(
                      _categories[i],
                      style: TextStyle(
                        color: _selectedCategory == _categories[i]
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    selected: _selectedCategory == _categories[i],
                    onSelected: (_) {
                      setState(() => _selectedCategory = _categories[i]);
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // radius 20, bạn chỉnh theo ý muốn
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Prompts list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No prompts found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                  : ListView.separated(
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final p = filtered[i];
                        return PromptItem(
                          prompt: p,
                          onToggleFavorite: () {
                            setState(() => p.isFavorite = !p.isFavorite);
                          },
                          onPreview: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(p.title),
                                content: Text(p.content),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onUse: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Using: ${p.title}')),
                            );
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
}
