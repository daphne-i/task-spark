import 'dart:async'; // Import Timer for debouncing
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScratchPadScreen extends StatefulWidget {
  const ScratchPadScreen({super.key});

  @override
  State<ScratchPadScreen> createState() => _ScratchPadScreenState();
}

class _ScratchPadScreenState extends State<ScratchPadScreen> {
  final TextEditingController _controller = TextEditingController();
  SharedPreferences? _prefs; // To hold the instance
  Timer? _debounce; // For saving delay

  // Key for saving the scratch pad text
  static const String _scratchPadKey = 'scratchPadText';

  @override
  void initState() {
    super.initState();
    _loadSavedText(); // Load text when the screen initializes
    // Add listener to save text automatically
    _controller.addListener(_onTextChanged);
  }

  // Load text from SharedPreferences
  Future<void> _loadSavedText() async {
    _prefs = await SharedPreferences.getInstance();
    final savedText = _prefs?.getString(_scratchPadKey) ?? '';
    _controller.text = savedText;
  }

  // Save text when it changes (with debouncing)
  void _onTextChanged() {
    // Cancel the previous timer if it exists
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Start a new timer to save after 500ms of inactivity
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _prefs?.setString(_scratchPadKey, _controller.text);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged); // Clean up listener
    _controller.dispose();
    _debounce?.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Make it slightly taller than the details sheet
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scratch Pad',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Optional: Add a close button if needed
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // --- Text Field ---
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null, // Allows infinite lines
              expands: true, // Fills the available space
              textAlignVertical: TextAlignVertical.top,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Jot down quick notes here...',
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor
                    .withOpacity(0.5), // Use a slightly different background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
