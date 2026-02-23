import 'package:flutter/material.dart';
import 'package:frugal_ai/backend/backend.dart';

/// 💬 Feedback & Suggestions Screen
class FeedbackSuggestionsScreen extends StatefulWidget {
  const FeedbackSuggestionsScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackSuggestionsScreen> createState() =>
      _FeedbackSuggestionsScreenState();
}

class _FeedbackSuggestionsScreenState extends State<FeedbackSuggestionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FeedbackService _feedbackService = FeedbackService();
  final SuggestionsService _suggestionsService = SuggestionsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ===== SUBMIT FEEDBACK =====
  void _showFeedbackDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    var selectedCategory = FeedbackService.FEEDBACK_CATEGORIES[0];
    int? rating;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('📝 Send Feedback'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField(
                  value: selectedCategory,
                  items: FeedbackService.FEEDBACK_CATEGORIES
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => selectedCategory = value ?? selectedCategory,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Star Rating for Feedback
                Row(
                  children: [
                    const Text('Rating: '),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => GestureDetector(
                          onTap: () => setState(() => rating = index + 1),
                          child: Icon(
                            Icons.star,
                            color: (rating ?? 0) > index
                                ? Colors.orange
                                : Colors.grey[300],
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await _feedbackService.submitFeedback(
                  category: selectedCategory,
                  title: titleController.text,
                  description: descriptionController.text,
                  rating: rating,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '✅ Feedback submitted successfully'
                            : '❌ Failed to submit feedback',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // ===== SUBMIT SUGGESTION =====
  void _showSuggestionDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    var selectedCategory = SuggestionsService.SUGGESTIONS_CATEGORIES[0];
    int priority = 3;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('💡 Suggest Feature'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField(
                  value: selectedCategory,
                  items: SuggestionsService.SUGGESTIONS_CATEGORIES
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => selectedCategory = value ?? selectedCategory,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'How would this improve the app?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Slider(
                  value: priority.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: 'Priority: $priority',
                  onChanged: (value) =>
                      setState(() => priority = value.toInt()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await _suggestionsService.submitSuggestion(
                  category: selectedCategory,
                  title: titleController.text,
                  description: descriptionController.text,
                  priority: priority,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '✅ Suggestion submitted successfully'
                            : '❌ Failed to submit suggestion',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💬 Feedback & Suggestions'),
        backgroundColor: const Color(0xFF0F9D58),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '📝 Feedback', icon: Icon(Icons.feedback)),
            Tab(text: '💡 Suggestions', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 📝 Feedback Tab
          _buildFeedbackTab(),
          // 💡 Suggestions Tab
          _buildSuggestionsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tabController.index == 0
            ? _showFeedbackDialog
            : _showSuggestionDialog,
        icon: Icon(
          _tabController.index == 0 ? Icons.feedback : Icons.lightbulb,
        ),
        label: Text(
          _tabController.index == 0 ? 'Send Feedback' : 'Suggest Feature',
        ),
        backgroundColor: const Color(0xFF0F9D58),
      ),
    );
  }

  // ===== FEEDBACK TAB =====
  Widget _buildFeedbackTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _feedbackService.getUserFeedback(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📝', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  'No feedback submitted yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final feedback = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            feedback['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            feedback['category'] ?? '',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feedback['description'] ?? '',
                      style: TextStyle(color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (feedback['rating'] != null)
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                Icons.star,
                                size: 16,
                                color: i < (feedback['rating'] ?? 0)
                                    ? Colors.orange
                                    : Colors.grey[300],
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: feedback['status'] == 'responded'
                                ? Colors.green[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            feedback['status'] ?? 'pending',
                            style: TextStyle(
                              fontSize: 12,
                              color: feedback['status'] == 'responded'
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===== SUGGESTIONS TAB =====
  Widget _buildSuggestionsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _suggestionsService.getUserSuggestions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💡', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  'No suggestions yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final suggestion = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            suggestion['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            3,
                            (i) => Icon(
                              Icons.thumb_up,
                              size: 16,
                              color: i < ((suggestion['priority'] ?? 3) ~/ 2)
                                  ? const Color(0xFF0F9D58)
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      suggestion['description'] ?? '',
                      style: TextStyle(color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            suggestion['category'] ?? '',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${suggestion['votes'] ?? 0}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
