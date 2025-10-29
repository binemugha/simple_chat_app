import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat_app/components/chat_bubble.dart';
import 'package:simple_chat_app/components/my_textfield.dart';
import 'package:simple_chat_app/services/auth/auth_service.dart';
import 'package:simple_chat_app/services/chat/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Future<void> _deleteChat() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return;
    List<String> ids = [currentUser.uid, widget.receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');
    final messagesRef = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages');
    final messagesSnapshot = await messagesRef.get();
    for (var doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }
    // Optionally, show a snackbar
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chat cleared.')));
    }
  }

  bool _isBlocked = false;
  bool _loadingBlockState = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIfBlocked();
  }

  Future<void> _checkIfBlocked() async {
    setState(() {
      _loadingBlockState = true;
    });
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return;
    final blockedDoc =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('Blockedusers')
            .doc(widget.receiverID)
            .get();
    setState(() {
      _isBlocked = blockedDoc.exists;
      _loadingBlockState = false;
    });
  }

  Future<void> _toggleBlock() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return;
    setState(() {
      _loadingBlockState = true;
    });
    if (_isBlocked) {
      await _chatService.unBlockUser(widget.receiverID);
    } else {
      await _chatService.blockUser(widget.receiverID);
    }
    await _checkIfBlocked();
  }

  // text controller
  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });

    // wait a bit for listview to be built, then scroll to bottom
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverID,
        _messageController.text,
      );
      _messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Delete/Clear Chat',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Clear Chat'),
                      content: Text(
                        'Are you sure you want to delete all messages in this chat?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                await _deleteChat();
              }
            },
          ),
          _loadingBlockState
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
              : TextButton(
                onPressed: _toggleBlock,
                child: Text(
                  _isBlocked ? 'Unblock' : 'Block',
                  style: TextStyle(
                    color: _isBlocked ? Colors.red : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        ],
      ),
      body: Column(
        children: [Expanded(child: _buildMessageList()), _buildUserInput()],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (_isBlocked) {
          return Center(
            child: Text(
              'You have blocked this user. Unblock to see messages.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          );
        }
        // errors
        if (snapshot.hasError) {
          return const Text("There is something wrong");
        }
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
        // return list view
        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // is current user
    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;

    // align message to the right if sender is the current user, otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
            messageId: doc.id,
            userId: data["senderID"],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    if (_isBlocked) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          // textfield should take up most of the space at the bottom
          Expanded(
            child: MyTextfield(
              hintText: "Type a message",
              obscureText: false,
              controller: _messageController,
              focusNode: myFocusNode,
            ),
          ),

          // send button
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25.0),
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
