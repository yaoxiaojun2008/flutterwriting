import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'api_service.dart'; // Import our new API service

class WritingCoachScreen extends StatefulWidget {
  const WritingCoachScreen({Key? key}) : super(key: key);

  @override
  _WritingCoachScreenState createState() => _WritingCoachScreenState();
}

class _WritingCoachScreenState extends State<WritingCoachScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  PlatformFile? _pickedFile; // Store the actual picked file
  String? _fileName; // Store the file name for display
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add({
      'role': 'assistant',
      'content': 'Hello! I\'m your writing coach. You can share your writing for evaluation or upload a file for analysis.',
    });
    
    // Add listener to update UI when text changes
    _textController.addListener(_onTextChanged);
  }
  
  void _onTextChanged() {
    // Rebuild the widget to update the send button state
    setState(() {});
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Coach'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('No messages yet. Start a conversation!'),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageItem(message);
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          // Display selected file name above the input area
          if (_fileName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selected: $_fileName',
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _fileName = null;
                        _pickedFile = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Writing Coach Info'),
        content: const Text(
          'This writing coach connects to a backend API for AI-powered writing evaluation. '
          'Make sure the backend service is running at https://coachwriting.vercel.app for full functionality.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';
    final content = message['content'];
    final fileName = message['file_name'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85, // Adjust message width for mobile
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            if (fileName != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.insert_drive_file, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Attached: $fileName',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            if (message.containsKey('evaluation_data'))
              _buildEvaluationData(message['evaluation_data']),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationData(dynamic evaluationData) {
    if (evaluationData is! Map) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10), // Slightly reduced padding
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (evaluationData['style_and_topic'] != null &&
              evaluationData['style_and_topic'].toString().trim().isNotEmpty &&
              evaluationData['style_and_topic'] != 'N/A')
            _buildSection(
              '🎯 Style & Topic Analysis',
              evaluationData['style_and_topic'],
            ),
          
          if (evaluationData['strengths'] != null && evaluationData['strengths'] is List)
            _buildListSection('💪 Strengths', evaluationData['strengths']),
            
          if (evaluationData['weaknesses'] != null && evaluationData['weaknesses'] is List)
            _buildListSection('🔍 Areas for Improvement', evaluationData['weaknesses']),
            
          if (evaluationData['improvement_suggestions'] != null && 
              evaluationData['improvement_suggestions'] is List)
            _buildListSection('💡 Improvement Suggestions', evaluationData['improvement_suggestions']),
            
          if (evaluationData['refined_sample'] != null &&
              evaluationData['refined_sample'].toString().trim().isNotEmpty &&
              evaluationData['refined_sample'] != 'N/A')
            _buildSection('✨ Refined Version', evaluationData['refined_sample']),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), // Slightly reduced margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 14), // Slightly smaller font for mobile
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<dynamic> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), // Slightly reduced margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          ...items.map((item) => Container(
                margin: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text(
                  '• ${item.toString()}',
                  style: const TextStyle(fontSize: 14), // Slightly smaller font for mobile
                ),
              )).toList(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _selectFile,
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Type your writing or question...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8), // Reduced padding
              ),
              maxLines: 3, // Allow up to 3 lines for mobile
              minLines: 1,
              onSubmitted: (_) => _sendMessage,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: (_textController.text.trim().isNotEmpty || _pickedFile != null) ? _sendMessage : null,
          ),
        ],
      ),
    );
  }

  void _selectFile() async {
    // Use file_picker to open the OS file selection dialog
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'csv', 'png', 'jpg', 'jpeg', 'md', 'doc', 'docx'],
    );

    if (result != null) {
      // Get the file from the result
      _pickedFile = result.files.first;
      String fileName = _pickedFile!.name;
      
      // Update the UI to show the selected file
      setState(() {
        _fileName = fileName;
      });
      
      // Show a snackbar to confirm the file selection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File "$fileName" selected'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      // User canceled the file selection
      print('File selection was canceled');
    }
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _pickedFile == null) return;

    // Add user message
    _messages.add({
      'role': 'user',
      'content': text,
      'file_name': _fileName,
    });

    setState(() {
      _isLoading = true;
    });

    // Clear input and reset file name
    _textController.clear();
    final fileToSend = _pickedFile;
    _pickedFile = null;
    _fileName = null;

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Get AI response from backend
    final response = await _getAIResponse(text, fileToSend);

    setState(() {
      _isLoading = false;
    });

    // Add AI response
    if (response != null) {
      _messages.add(response);
    } else {
      _messages.add({
        'role': 'assistant',
        'content': 'Sorry, I couldn\'t process your request. Please make sure the backend is running.',
      });
    }

    // Scroll to bottom again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<Map<String, dynamic>?> _getAIResponse(String text, PlatformFile? file) async {
    try {
      if (file != null) {
        // Send file to backend for evaluation
        final response = await ApiService.evaluateFile(file);
        
        if (response != null) {
          return {
            'role': 'assistant',
            'content': 'I\'ve received your file "${file.name}". Here\'s my analysis:',
            'evaluation_data': response,
          };
        } else {
          return {
            'role': 'assistant',
            'content': 'Sorry, I couldn\'t process your file. Please make sure the backend is running.',
          };
        }
      } else {
        // Send text to backend for evaluation
        final response = await ApiService.evaluateText(text);
        
        if (response != null) {
          return {
            'role': 'assistant',
            'content': 'Here\'s my evaluation of your writing:',
            'evaluation_data': response,
          };
        } else {
          return {
            'role': 'assistant',
            'content': 'Sorry, I couldn\'t process your text. Please make sure the backend is running.',
          };
        }
      }
    } catch (e) {
      debugPrint('Error getting AI response: $e');
      return null;
    }
  }
}