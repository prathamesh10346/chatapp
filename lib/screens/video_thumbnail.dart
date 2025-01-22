import 'package:flutter/material.dart';

class VideoThumbnail extends StatelessWidget {
  final String url;

  const VideoThumbnail({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            url,
            width: 200,
            height: 150,
            fit: BoxFit.cover,
          ),
          Icon(
            Icons.play_circle_filled,
            size: 50,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}