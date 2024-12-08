import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _photoFiles = [];
  List<File> _videoFiles = [];
  Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      await _requestPermission(Permission.storage);
      await _requestPermission(Permission.manageExternalStorage);
    } else if (Platform.isIOS) {
      await _requestPermission(Permission.photos);
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status != PermissionStatus.granted) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text('Storage/Photo access is required to upload files. Please grant permissions in app settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<String> _getLocalStoragePath(bool isVideo) async {
    final directory = await getApplicationDocumentsDirectory();
    final targetDirectory = Directory('${directory.path}/${isVideo ? 'videos' : 'photos'}');
    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }
    return targetDirectory.path;
  }

  Future<void> _uploadFile(bool isVideo) async {
    try {
      final XFile? pickedFile = isVideo
          ? await _picker.pickVideo(source: ImageSource.gallery)
          : await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final storagePath = await _getLocalStoragePath(isVideo);
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
                              (isVideo ? '.mp4' : '.jpg');
      final String localPath = '$storagePath/$fileName';

      final file = await File(pickedFile.path).copy(localPath);

      setState(() {
        if (isVideo) {
          _videoFiles.add(file);
          _videoControllers[_videoFiles.length - 1] = VideoPlayerController.file(file)
            ..initialize().then((_) => setState(() {}));
        } else {
          _photoFiles.add(file);
        }
      });

      _showUploadSuccessDialog(isVideo);
    } catch (e) {
      _showUploadErrorDialog(e.toString());
    }
  }

  void _viewSavedFiles(bool isVideo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Saved ${isVideo ? 'Videos' : 'Photos'}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[600],
                  ),
                ),
              ),
              Expanded(
                child: isVideo ? _buildVideoGrid(controller) : _buildPhotoGrid(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoGrid(ScrollController scrollController) {
    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _videoFiles.length,
      itemBuilder: (context, index) {
        final videoController = _videoControllers[index];
        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: AspectRatio(
                    aspectRatio: videoController?.value.aspectRatio ?? 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        VideoPlayer(videoController ?? VideoPlayerController.file(_videoFiles[index])),
                        Center(
                          child: IconButton(
                            icon: Icon(
                              videoController?.value.isPlaying ?? false 
                                ? Icons.pause_circle 
                                : Icons.play_circle,
                              size: 50,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            onPressed: () {
                              setState(() {
                                videoController?.value.isPlaying ?? false
                                    ? videoController?.pause()
                                    : videoController?.play();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Video ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[600],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoGrid(ScrollController scrollController) {
    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _photoFiles.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _showFullScreenImage(_photoFiles[index]);
          },
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    _photoFiles[index],
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black54,
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Photo ${index + 1}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullScreenImage(File imageFile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUploadSuccessDialog(bool isVideo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload Successful'),
        content: Text('${isVideo ? 'Video' : 'Photo'} saved successfully!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showUploadErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload Failed'),
        content: Text('Error: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap,
      required VoidCallback onView}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: Colors.purple[600],
                  ),
                  SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.upload, color: Colors.grey),
                    onPressed: onTap,
                  ),
                  IconButton(
                    icon: Icon(Icons.visibility, color: Colors.grey),
                    onPressed: onView,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Media Gallery',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCard(
              context,
              title: 'Photos',
              icon: Icons.photo_library,
              onTap: () => _uploadFile(false),
              onView: () => _viewSavedFiles(false),
            ),
            SizedBox(height: 20),
            _buildCard(
              context,
              title: 'Videos',
              icon: Icons.video_library,
              onTap: () => _uploadFile(true),
              onView: () => _viewSavedFiles(true),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.photo),
                      title: Text('Upload Photo'),
                      onTap: () {
                        Navigator.pop(context);
                        _uploadFile(false);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.video_library),
                      title: Text('Upload Video'),
                      onTap: () {
                        Navigator.pop(context);
                        _uploadFile(true);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple[600],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}