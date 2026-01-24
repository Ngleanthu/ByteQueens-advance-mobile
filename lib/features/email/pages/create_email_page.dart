import 'package:flutter/material.dart';
import '../widgets/email_input_field.dart';
import '../widgets/email_section.dart';
import '../widgets/segmented_control.dart';
import '../widgets/modern_dropdown.dart';
import '../widgets/email_draft_dialog.dart';
import '../../../services/create_email_service.dart';
import '../../../data/models/email_model.dart';

class CreateEmailPage extends StatefulWidget {
  const CreateEmailPage({super.key});

  @override
  State<CreateEmailPage> createState() => _CreateEmailPageState();
}

class _CreateEmailPageState extends State<CreateEmailPage> {
  final _mainIdeaCtrl = TextEditingController();
  final _actionCtrl = TextEditingController(text: "Reply to this email");
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _senderCtrl = TextEditingController();
  final _receiverCtrl = TextEditingController();

  late final EmailService _emailService;
  bool _isGenerating = false;

  String length = "long";
  String formality = "neutral";
  String tone = "friendly";
  String language = "vietnamese";
  String model = "claude-3-sonnet-20240229";

  @override
  void initState() {
    super.initState();
    _emailService = EmailService();
  }

  @override
  void dispose() {
    _mainIdeaCtrl.dispose();
    _actionCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _senderCtrl.dispose();
    _receiverCtrl.dispose();
    super.dispose();
  }

  Future<void> _onGenerate() async {
    // Validation
    if (_mainIdeaCtrl.text.isEmpty && _emailCtrl.text.isEmpty) {
      _showErrorSnackBar("Please enter main idea or original email");
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final response = await _emailService.generateEmail(
        model: model,
        email: _emailCtrl.text,
        action: _actionCtrl.text,
        mainIdea: _mainIdeaCtrl.text,
        metadata: EmailMetadata(
          subject: _subjectCtrl.text,
          sender: _senderCtrl.text,
          receiver: _receiverCtrl.text,
          style: EmailStyle(length: length, formality: formality, tone: tone),
          language: language,
        ),
      );

      if (mounted) {
        _showEmailDraftDialog(response);
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Error: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showEmailDraftDialog(EmailResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EmailDraftDialog(
        subject: response.subject.isEmpty
            ? (_subjectCtrl.text.isEmpty
                  ? "RE: ${_emailCtrl.text.split('\n').first}"
                  : _subjectCtrl.text)
            : response.subject,
        sender: response.sender.isEmpty
            ? (_senderCtrl.text.isEmpty ? "you@example.com" : _senderCtrl.text)
            : response.sender,
        receiver: response.receiver.isEmpty
            ? (_receiverCtrl.text.isEmpty
                  ? "recipient@example.com"
                  : _receiverCtrl.text)
            : response.receiver,
        generatedContent: response.content,
        onSend: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Email sent successfully!"),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        onEdit: () {
          Navigator.pop(context);
          // TODO: Implement edit functionality
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Create Email",
          style: TextStyle(
            color: Color(0xFF1A1D2E),
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2196F3)),
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                EmailSection(
                  title: "AI Model",
                  child: ModernDropdown(
                    value: model,
                    items: const [
                      "claude-3-haiku-20240307",
                      "claude-3-sonnet-20240229",
                      "gemini-1.5-flash-latest",
                      "gemini-1.5-pro-latest",
                      "gpt-4o",
                      "gpt-4o-mini",
                    ],
                    onChanged: (v) => setState(() => model = v),
                    displayNames: const {
                      "claude-3-haiku-20240307": "Claude 3 Haiku",
                      "claude-3-sonnet-20240229": "Claude 3 Sonnet",
                      "gemini-1.5-flash-latest": "Gemini 1.5 Flash",
                      "gemini-1.5-pro-latest": "Gemini 1.5 Pro",
                      "gpt-4o": "GPT-4O",
                      "gpt-4o-mini": "GPT-4O Mini",
                    },
                  ),
                ),
                EmailSection(
                  title: "Main Idea",
                  child: EmailInputField(
                    controller: _mainIdeaCtrl,
                    maxLines: 3,
                    hint: "Enter the main idea you want to convey...",
                  ),
                ),
                EmailSection(
                  title: "Action",
                  child: EmailInputField(controller: _actionCtrl),
                ),
                EmailSection(
                  title: "Original Email",
                  child: EmailInputField(
                    controller: _emailCtrl,
                    maxLines: 6,
                    hint: "Paste the original email content here...",
                  ),
                ),
                EmailSection(
                  title: "Subject",
                  child: EmailInputField(controller: _subjectCtrl),
                ),
                Row(
                  children: [
                    Expanded(
                      child: EmailSection(
                        title: "Sender",
                        child: EmailInputField(
                          controller: _senderCtrl,
                          hint: "From",
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: EmailSection(
                        title: "Receiver",
                        child: EmailInputField(
                          controller: _receiverCtrl,
                          hint: "To",
                        ),
                      ),
                    ),
                  ],
                ),
                EmailSection(
                  title: "Length",
                  child: SegmentedControl(
                    value: length,
                    items: const ["short", "medium", "long"],
                    onChanged: (v) => setState(() => length = v),
                  ),
                ),
                EmailSection(
                  title: "Formality",
                  child: SegmentedControl(
                    value: formality,
                    items: const ["formal", "neutral", "casual"],
                    onChanged: (v) => setState(() => formality = v),
                  ),
                ),
                EmailSection(
                  title: "Tone",
                  child: SegmentedControl(
                    value: tone,
                    items: const ["friendly", "professional", "polite"],
                    onChanged: (v) => setState(() => tone = v),
                  ),
                ),
                EmailSection(
                  title: "Language",
                  child: ModernDropdown(
                    value: language,
                    items: const ["vietnamese", "english"],
                    onChanged: (v) => setState(() => language = v),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Material(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(14),
                elevation: 4,
                shadowColor: const Color(0xFF2196F3).withOpacity(0.4),
                child: InkWell(
                  onTap: _isGenerating ? null : _onGenerate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _isGenerating
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Generating...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Generate Email",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
