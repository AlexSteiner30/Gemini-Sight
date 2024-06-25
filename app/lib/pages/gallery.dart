import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:video_player/video_player.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key, required this.user}) : super(key: key);
  final GoogleSignInAccount user;

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Map<String, dynamic>> _mediaItems = [
    {'type': 'image', 'url': 'https://via.placeholder.com/150'},
    {
      'type': 'video',
      'url':
          'https://videocdn.cdnpk.net/cdn/content/video/premium/video0449/large_watermarked/295%20-%20Animated%20Horizontal%20Brush%20Strokes%20Pack_666_Brush_6_preview.mp4'
    },
    {'type': 'image', 'url': 'https://via.placeholder.com/150/0000FF/808080'},
    {
      'type': 'video',
      'url': 'https://www.sample-videos.com/video123/mp4/480/asdasdas.mp4'
    },
    // Add more media URLs here
  ];

  String _filter = 'all';

  void _filterMedia(String type) {
    setState(() {
      _filter = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredMedia = _filter == 'all'
        ? _mediaItems
        : _mediaItems.where((item) => item['type'] == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _filterMedia,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'all', child: Text('All')),
                PopupMenuItem(value: 'image', child: Text('Pictures')),
                PopupMenuItem(value: 'video', child: Text('Videos')),
              ];
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 3 / 4, // Aspect ratio for each grid item
        ),
        itemCount: filteredMedia.length,
        itemBuilder: (context, index) {
          var media = filteredMedia[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenMedia(url: media['url']),
                ),
              );
            },
            child: media['type'] == 'image'
                ? CachedNetworkImage(
                    imageUrl: media['url'],
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  )
                : VideoPlayerWidget(url: media['url']),
          );
        },
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  VideoPlayerWidget({required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);

    // Ensure playback state updates
    _controller.addListener(() {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlaying() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              IconButton(
                onPressed: _togglePlaying,
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 50.0,
                  color: Colors.white,
                ),
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class FullScreenMedia extends StatelessWidget {
  final String url;

  FullScreenMedia({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Screen Media'),
      ),
      body: Center(
        child: url.endsWith('.mp4')
            ? VideoPlayerWidget(url: url)
            : Image.network(url),
      ),
    );
  }
}
