import 'package:speech_to_text/speech_to_text.dart' as stt;

/// 🎤 Voice-Based Expense Entry Service (Feature 2)
/// Allows users to add expenses using voice input
/// Example: "Add 200 rupees food expense"
class VoiceInputService {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _lastWords = '';

  Future<void> initialize() async {
    _speechToText = stt.SpeechToText();
    await _speechToText.initialize(
      onError: (error) => print('Error: $error'),
      onStatus: (status) => print('Status: $status'),
    );
  }

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  /// Start listening for voice input
  Future<void> startListening() async {
    if (!_isListening && _speechToText.isAvailable) {
      _isListening = true;
      _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          print('Recognized: $_lastWords');
        },
        localeId: 'en_US',
      );
    }
  }

  /// Stop listening and return recognized text
  Future<String> stopListening() async {
    _isListening = false;
    await _speechToText.stop();
    return _lastWords;
  }

  /// Parse voice input to extract expense details
  /// Expected format: "Add {amount} {currency} {category} expense" or "{category} {amount}"
  /// Examples:
  /// - "Add 200 rupees food expense" -> {amount: 200, category: "Food"}
  /// - "Spent 50 on transport" -> {amount: 50, category: "Transport"}
  /// - "Food 300" -> {amount: 300, category: "Food"}
  Map<String, dynamic> parseVoiceInput(String input) {
    final lowerInput = input.toLowerCase().trim();

    // Extract amount using regex
    final amountRegex = RegExp(r'(\d+(?:\.\d+)?)');
    final amountMatch = amountRegex.firstMatch(lowerInput);
    double? amount = amountMatch != null
        ? double.tryParse(amountMatch.group(1) ?? '0')
        : 0;

    // Remove common phrases
    var cleanedInput = lowerInput
        .replaceAll('add ', '')
        .replaceAll('spent ', '')
        .replaceAll('expense', '')
        .replaceAll('rupees', '')
        .replaceAll('rs', '')
        .replaceAll('inr', '')
        .replaceAll(amountRegex, '')
        .trim();

    // Extract category by checking keywords
    String category = _extractCategory(cleanedInput);

    return {
      'amount': amount,
      'category': category,
      'description': input,
      'isValid': amount != null && amount > 0,
    };
  }

  /// Extract category from voice input
  String _extractCategory(String text) {
    const categories = {
      'food': [
        'food',
        'restaurant',
        'lunch',
        'dinner',
        'breakfast',
        'pizza',
        'burger',
        'cafe',
        'coffee',
      ],
      'transport': [
        'transport',
        'uber',
        'taxi',
        'bus',
        'auto',
        'fuel',
        'petrol',
        'metro',
        'ola',
        'bike',
      ],
      'shopping': [
        'shopping',
        'shop',
        'mall',
        'cloth',
        'shoes',
        'buy',
        'purchase',
      ],
      'utilities': [
        'electricity',
        'water',
        'internet',
        'phone',
        'bill',
        'utilities',
      ],
      'entertainment': [
        'movie',
        'game',
        'netflix',
        'spotify',
        'show',
        'entertainment',
      ],
      'health': [
        'medical',
        'doctor',
        'hospital',
        'medicine',
        'pharmacy',
        'health',
      ],
      'education': [
        'school',
        'college',
        'book',
        'course',
        'tuition',
        'education',
      ],
    };

    for (var entry in categories.entries) {
      for (var keyword in entry.value) {
        if (text.contains(keyword)) {
          return entry.key[0].toUpperCase() + entry.key.substring(1);
        }
      }
    }

    return 'Other';
  }

  /// Dispose resources
  void dispose() {
    _speechToText.stop();
  }
}
