import 'package:flutter/material.dart';
import '../widgets/email_input_field.dart';
import '../widgets/email_section.dart';
import '../widgets/segmented_control.dart';
import '../widgets/modern_dropdown.dart';
import '../theme/app_colors.dart';

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

  String length = "long";
  String formality = "neutral";
  String tone = "friendly";
  String language = "vietnamese";

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

  void _onGenerate() {
    final payload = {
      "mainIdea": _mainIdeaCtrl.text,
      "action": _actionCtrl.text,
      "email": _emailCtrl.text,
      "metadata": {
        "subject": _subjectCtrl.text,
        "sender": _senderCtrl.text,
        "receiver": _receiverCtrl.text,
        "style": {"length": length, "formality": formality, "tone": tone},
        "language": language,
      },
    };

    debugPrint(payload.toString());
    // TODO: call API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.cardWhite,
        centerTitle: true,
        title: const Text(
          "Create Email",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
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
                color: AppColors.cardWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Material(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(14),
                elevation: 4,
                shadowColor: AppColors.primaryBlue.withOpacity(0.4),
                child: InkWell(
                  onTap: _onGenerate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
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
