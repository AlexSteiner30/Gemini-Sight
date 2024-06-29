import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

class GalleryPage extends StatefulWidget {
  GalleryPage({Key? key}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  bool _showImagesOnly = true;

  final List<String> allPhotos = [
    'https://m.media-amazon.com/images/I/71IeYNcBYdL._SX679_.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/e/e7/Everest_North_Face_toward_Base_Camp_Tibet_Luca_Galuzzi_2006.jpg',
    'https://hairstyleonpoint.com/wp-content/uploads/2015/09/4ce06e936dcd5e5c5c3e44be9edbc8ff.jpg',
    'https://bsmedia.business-standard.com/_media/bs/img/article/2020-12/11/full/1607656152-0479.jpg',
    'https://cdn.pixabay.com/photo/2015/04/19/08/32/marguerite-729510__340.jpg',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
  ];

  List<String> get filteredPhotos {
    if (_showImagesOnly) {
      return allPhotos.where((photo) => !photo.endsWith('.mp4')).toList();
    } else {
      return allPhotos.where((photo) => photo.endsWith('.mp4')).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gallery"),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              setState(() {
                _showImagesOnly = !_showImagesOnly;
              });
            },
          ),
        ],
      ),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.all(1),
        itemCount: filteredPhotos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: ((context, index) {
          final String photo = filteredPhotos[index];
          return Container(
            padding: const EdgeInsets.all(0.5),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PhotoViewPage(photos: filteredPhotos, index: index),
                ),
              ),
              child: Hero(
                tag: photo,
                child: photo.endsWith('.mp4')
                    ? VideoPreviewWidget(url: photo)
                    : CachedNetworkImage(
                        imageUrl: photo,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey),
                        errorWidget: (context, url, error) =>
                            Container(color: Colors.red.shade400),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class PhotoViewPage extends StatelessWidget {
  final List<String> photos;
  final int index;

  const PhotoViewPage({
    Key? key,
    required this.photos,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PhotoViewGallery.builder(
        itemCount: photos.length,
        builder: (context, index) {
          if (photos[index].endsWith('.mp4')) {
            return PhotoViewGalleryPageOptions.customChild(
              child: VideoPlayerWidget(url: photos[index]),
              heroAttributes: PhotoViewHeroAttributes(tag: photos[index]),
            );
          } else {
            return PhotoViewGalleryPageOptions.customChild(
              child: CachedNetworkImage(
                imageUrl: photos[index],
                placeholder: (context, url) => Container(color: Colors.grey),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.red.shade400),
              ),
              minScale: PhotoViewComputedScale.covered,
              heroAttributes: PhotoViewHeroAttributes(tag: photos[index]),
            );
          }
        },
        pageController: PageController(initialPage: index),
        enableRotation: true,
      ),
    );
  }
}

class VideoPreviewWidget extends StatelessWidget {
  final String url;

  const VideoPreviewWidget({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CachedNetworkImage(
          imageUrl: _generateThumbnailUrl(url),
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey),
          errorWidget: (context, url, error) =>
              Container(color: Colors.red.shade400),
        ),
        const Icon(
          Icons.play_circle_fill,
          color: Colors.white,
          size: 50,
        ),
      ],
    );
  }

  String _generateThumbnailUrl(String videoUrl) {
    // Replace with your logic to generate or fetch video thumbnail URL
    // Here, we're just using a placeholder logic.
    return videoUrl.replaceAll('.mp4', '.jpg');
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
      });

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

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
            onTap: () {
              setState(() {
                _isPlaying ? _controller.pause() : _controller.play();
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                if (!_isPlaying)
                  Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 80,
                  ),
              ],
            ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
