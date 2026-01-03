import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gemini_service.dart';
import '../providers/diary_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/star_background.dart';

class ChatDiaryScreen extends StatefulWidget {
  const ChatDiaryScreen({super.key});

  @override
  State<ChatDiaryScreen> createState() => _ChatDiaryScreenState();
}

class _ChatDiaryScreenState extends State<ChatDiaryScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode(); // 입력창 포커스 유지용
  final List<ChatMessage> _messages = [];
  
  bool _isLoading = false;
  bool _isConvertingToDiary = false;
  String? _generatedDiary;
  String? _analyzedMood;

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _startConversation() async {
    setState(() => _isLoading = true);
    
    try {
      final greeting = await _geminiService.startConversation();
      setState(() {
        _messages.add(ChatMessage(text: greeting, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        // 에러 시 기본 인사 메시지 표시
        _messages.add(ChatMessage(
          text: '안녕! 오늘 하루는 어땠어? 무슨 일이 있었는지 이야기해줘 😊',
          isUser: false,
        ));
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _messageController.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await _geminiService.chat(text);
      
      // 자동 변환이 트리거된 경우 (사용자가 '응' 등으로 동의)
      if (_geminiService.autoConvertTriggered) {
        _geminiService.resetAutoConvert();
        setState(() => _isLoading = false);
        // 바로 일기 변환 시작 (꼬리질문 없이)
        _convertToDiary();
        return;
      }
      
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('응답을 받을 수 없어요.');
    }
    
    // 포커스 복원을 위해 약간의 딜레이 후 실행
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  Future<void> _convertToDiary() async {
    setState(() => _isConvertingToDiary = true);

    try {
      final diary = await _geminiService.convertToDiary();
      final mood = await _geminiService.analyzeMood();
      
      setState(() {
        _generatedDiary = diary;
        _analyzedMood = mood;
        _isConvertingToDiary = false;
      });
      
      _showDiaryPreview();
    } catch (e) {
      setState(() => _isConvertingToDiary = false);
      _showError('일기 변환에 실패했어요.');
    }
  }

  void _showDiaryPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DiaryPreviewSheet(
        diary: _generatedDiary!,
        mood: _analyzedMood!,
        onSave: _saveDiary,
        onEdit: (edited) {
          setState(() => _generatedDiary = edited);
        },
      ),
    );
  }

  Future<void> _saveDiary() async {
    if (_generatedDiary == null || _analyzedMood == null) return;

    final provider = context.read<DiaryProvider>();
    provider.selectDate(DateTime.now());
    
    final result = await provider.createDiary(
      content: _generatedDiary!,
      mood: _analyzedMood!,
    );

    if (result != null && mounted) {
      Navigator.pop(context); // Close bottom sheet
      Navigator.pop(context); // Go back to home
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('일기가 저장되었어요! 💫'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('대화로 일기쓰기'),
        actions: [
          if (_geminiService.conversationCount >= 2)
            TextButton.icon(
              onPressed: _isConvertingToDiary ? null : _convertToDiary,
              icon: _isConvertingToDiary
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.accentPurple,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: const Text('일기로 변환'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accentPurple,
              ),
            ),
        ],
      ),
      body: StarBackground(
        showMoon: false,
        child: SafeArea(
          child: Column(
            children: [
              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return const _TypingIndicator();
                    }
                    return _ChatBubble(message: _messages[index]);
                  },
                ),
              ),
              // Input area
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: AppTheme.accentPurple.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                autofocus: true,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: '대화를 입력하세요...',
                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) {
                  _sendMessage();
                  // 전송 후에도 포커스 유지
                  Future.delayed(const Duration(milliseconds: 50), () {
                    _focusNode.requestFocus();
                  });
                },
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.purpleGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class _ChatBubble extends StatefulWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.message.isUser ? 0.3 : -0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: widget.message.isUser 
                ? MainAxisAlignment.end 
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.message.isUser) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppTheme.purpleGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.message.isUser
                        ? AppTheme.accentPurple.withValues(alpha: 0.8)
                        : AppTheme.cardDark,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(widget.message.isUser ? 16 : 4),
                      bottomRight: Radius.circular(widget.message.isUser ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    widget.message.text,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              if (widget.message.isUser) const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
    });
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // 순차적으로 애니메이션 시작
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.purpleGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _animations[index],
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withValues(
                          alpha: _animations[index].value,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaryPreviewSheet extends StatefulWidget {
  final String diary;
  final String mood;
  final VoidCallback onSave;
  final Function(String) onEdit;

  const _DiaryPreviewSheet({
    required this.diary,
    required this.mood,
    required this.onSave,
    required this.onEdit,
  });

  @override
  State<_DiaryPreviewSheet> createState() => _DiaryPreviewSheetState();
}

class _DiaryPreviewSheetState extends State<_DiaryPreviewSheet> {
  late TextEditingController _editController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.diary);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.accentPurple,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '변환된 일기',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _isEditing = !_isEditing);
                    if (!_isEditing) {
                      widget.onEdit(_editController.text);
                    }
                  },
                  icon: Icon(
                    _isEditing ? Icons.check : Icons.edit_outlined,
                    color: AppTheme.accentPurple,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _isEditing
                  ? TextField(
                      controller: _editController,
                      maxLines: null,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        height: 1.8,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.cardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _editController.text,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          height: 1.8,
                        ),
                      ),
                    ),
            ),
          ),
          // Save button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: widget.onSave,
                icon: const Icon(Icons.save_alt),
                label: const Text(
                  '일기 저장하기',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
