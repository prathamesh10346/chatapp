import 'dart:convert';
import 'dart:io';

import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/screens/video_thumbnail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String userId; // Change _userId to userId
  static const int MAX_FILE_SIZE = 2 * 1024 * 1024; // 2MB in bytes

  ChatService(this.userId); // Update constructor
  Future<String> _convertFileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    if (bytes.length > MAX_FILE_SIZE) {
      throw Exception('File size exceeds 2MB limit');
    }
    return base64Encode(bytes);
  }

  Future<void> sendMessage({
    required String receiverId,
    required String content,
    required MessageType type,
    File? file,
  }) async {
    try {
      final String chatRoomId = getChatRoomId(userId, receiverId);
      String? base64Data;
      String? mimeType;

      // Handle file if present
      if (file != null && type != MessageType.text) {
        // Get file extension and validate
        final extension = path.extension(file.path).toLowerCase();

        // Check file type
        switch (extension) {
          case '.jpg':
          case '.jpeg':
            mimeType = 'image/jpeg';
            break;
          case '.png':
            mimeType = 'image/png';
            break;
          case '.pdf':
            mimeType = 'application/pdf';
            break;
          default:
            throw Exception('Unsupported file type: $extension');
        }

        // Convert file to base64
        base64Data = await _convertFileToBase64(file);
      }

      // Create message
      final MessageModel message = MessageModel(
        messageId:
            '${DateTime.now().millisecondsSinceEpoch}_${userId}_$receiverId',
        senderId: userId,
        receiverId: receiverId,
        content: content,
        type: type,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        mediaUrl: null, // We're not using URLs anymore
        mediaData: base64Data, // Add this field to your MessageModel
        mimeType: mimeType,
      );

      // Create batch write
      final batch = _firestore.batch();

      // Add message to chat collection
      final messageRef = _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(message.messageId);
      batch.set(messageRef, message.toJson());

      // Update chat room metadata
      final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
      batch.set(
          chatRoomRef,
          {
            'lastMessage': type == MessageType.text
                ? content
                : '${type.toString().split('.').last} message',
            'lastMessageTime': message.timestamp.toIso8601String(),
            'lastMessageType': message.type.toString(),
            'participants': [message.senderId, message.receiverId],
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      // Commit batch
      await batch.commit();
    } catch (e) {
      print('Error in sendMessage: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // Future<String?> _generateVideoThumbnail(File videoFile) async {
  //   try {

  //     final thumbnail = await VideoThumbnail.thumbnailData(
  //       video: videoFile.path,
  //       imageFormat: ImageFormat.JPEG,
  //       maxWidth: 200,
  //       quality: 25,
  //     );

  //     if (thumbnail != null) {
  //       // Upload thumbnail to Firebase Storage
  //       final fileName = 'thumbnails/${DateTime.now().millisecondsSinceEpoch}.jpg';
  //       final ref = _storage.ref().child(fileName);

  //       final metadata = SettableMetadata(
  //         contentType: 'image/jpeg',
  //       );

  //       await ref.putData(thumbnail, metadata);
  //       return await ref.getDownloadURL();
  //     }
  //     return null;
  //   } catch (e) {
  //     print('Error generating thumbnail: $e');
  //     return null;
  //   }
  // }
  // Send message

  Future<String> _uploadMediaToStorage(
      File file, String receiverId, MessageType type) async {
    try {
      // Create a unique file name using timestamp and extension
      final String extension = path.extension(file.path);
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}$extension';

      // Create storage path based on message type and users
      String storagePath =
          'chat_media/$userId/$receiverId/${type.toString().split('.').last}/$fileName';

      // Create storage reference
      final storageRef = _storage.ref().child(storagePath);

      // Set appropriate content type
      String contentType;
      switch (type) {
        case MessageType.image:
          contentType = 'image/${extension.replaceAll('.', '')}';
          break;
        case MessageType.video:
          contentType = 'video/${extension.replaceAll('.', '')}';
          break;
        case MessageType.document:
          contentType = 'application/${extension.replaceAll('.', '')}';
          break;
        default:
          contentType = 'application/octet-stream';
      }

      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'userId': userId,
          'receiverId': receiverId,
          'messageType': type.toString(),
        },
      );

      // Perform upload
      final uploadTask = storageRef.putFile(file, metadata);

      // Wait for upload to complete and get download URL
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading media: $e');
      throw Exception('Failed to upload media: $e');
    }
  }

  // Get messages stream
  Stream<List<MessageModel>> getMessages(String receiverId) {
    final String chatRoomId = getChatRoomId(userId, receiverId);
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()))
          .toList();
    });
  }

  // Upload file to Firebase Storage
  Future<String> _uploadFile(File file, MessageType type) async {
    try {
      String path = 'chat/${userId}/${DateTime.now().millisecondsSinceEpoch}';
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error in _uploadFile: $e');
      throw e;
    }
  }

  // Update chat room
  Future<void> _updateChatRoom(String chatRoomId, MessageModel message) async {
    try {
      await _firestore.collection('chatRooms').doc(chatRoomId).set({
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp.toIso8601String(),
        'lastMessageType': message.type.toString(),
        'participants': [message.senderId, message.receiverId],
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error in _updateChatRoom: $e');
      throw e;
    }
  }

  // Generate chat room ID
  String getChatRoomId(String userId1, String userId2) {
    return userId1.compareTo(userId2) > 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }
}
