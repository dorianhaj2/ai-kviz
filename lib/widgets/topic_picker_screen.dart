import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/difficulty_picker_screen.dart';
import '../models/game_mode.dart';

class TopicPickerScreen extends StatefulWidget {
  final List<String> topics;
  final GameMode gameMode;

  const TopicPickerScreen({
    Key? key,
    List<String>? topics,
    this.gameMode = GameMode.normal,
  })  : topics = topics ?? const [
          "General Knowledge",
          "Science",
          "History",
          "Geography",
          "Sports",
          "Entertainment",
        ],
        super(key: key);

  @override
  State<TopicPickerScreen> createState() => _TopicPickerScreenState();
}

class _TopicPickerScreenState extends State<TopicPickerScreen> {
  late final TextEditingController _customTopicController;

  @override
  void initState() {
    super.initState();
    _customTopicController = TextEditingController();
  }

  @override
  void dispose() {
    _customTopicController.dispose();
    super.dispose();
  }

  Future<void> _onTopicSelected(String topic) async {
    if (topic.trim().isEmpty) return;
    
    // Navigate to difficulty selection screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DifficultyPickerScreen(
          topic: topic,
          gameMode: widget.gameMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text("Select Topic"),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.primaryText,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select a topic',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Topic buttons
              ...widget.topics.map<Widget>((topic) {
                return _TopicButton(
                  topic: topic,
                  onPressed: () => _onTopicSelected(topic),
                );
              }),
              
              const SizedBox(height: 16),
              
              // Custom topic input
              _CustomTopicInput(
                controller: _customTopicController,
                onSubmit: () => _onTopicSelected(_customTopicController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Topic button widget
class _TopicButton extends StatelessWidget {
  final String topic;
  final VoidCallback onPressed;

  const _TopicButton({
    required this.topic,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xff4c1d95), width: 2.0),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryText,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(
          topic,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}

/// Custom topic input widget
class _CustomTopicInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _CustomTopicInput({
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xff4c1d95), width: 2.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter custom topic',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 20.0,
                ),
              ),
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 16,
              ),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          IconButton(
            onPressed: onSubmit,
            icon: const Icon(
              Icons.arrow_forward,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
