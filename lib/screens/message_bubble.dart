import 'dart:convert';
import 'dart:typed_data';

import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/screens/file_attachment%20.dart';
import 'package:chatapp/screens/image_view_screen%20.dart';
import 'package:chatapp/screens/video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  MessageBubble({
    required this.message,
    required this.isMe,
  });

  void _showFullScreenImage(BuildContext context, Uint8List imageData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            color: Colors.black,
            child: Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Image.memory(
                  imageData,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    if (message.mediaData == null) return const SizedBox();

    try {
      final decodedData = base64Decode(message.mediaData!);

      switch (message.type) {
        case MessageType.image:
          return GestureDetector(
            onTap: () => _showFullScreenImage(context, decodedData),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 200,
                maxHeight: 200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  decodedData,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );

        case MessageType.document:
          if (message.mimeType?.contains('pdf') == true) {
            return GestureDetector(
              onTap: () => _openPdfViewer(context, decodedData),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message.content,
                        style: TextStyle(color: Colors.blue),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insert_drive_file),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message.content,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );

        default:
          return const SizedBox();
      }
    } catch (e) {
      print('Error displaying media: $e');
      return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error displaying media'),
          ],
        ),
      );
    }
  }

  void _openPdfViewer(BuildContext context, Uint8List pdfData) {
    // You'll need to add the pdf_viewer package for this
    // For now, we'll just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('PDF Viewer'),
        content: Text('PDF viewing will be implemented soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.type == MessageType.text)
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                ),
              )
            else if (message.type == MessageType.image)
              // For documents, show an icon and filename
              _buildMediaContent(
                context,
              )
            else if (message.type == MessageType.document)
              // For documents, show an icon and filename
              _buildMediaContent(
                context,
              ),
            SizedBox(height: 4),
            Text(
              timeago.format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
