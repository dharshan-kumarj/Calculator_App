import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ImagePicker _picker = ImagePicker();
  List<String> _photoPaths = [];
  List<String> _videoPaths = [];
  Map<int, VideoPlayerController> _videoControllers = {};
  bool _isSelectionMode = false;
  Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
    _loadSavedFiles();
  }

  Future<void> _loadSavedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _photoPaths = prefs.getStringList('savedPhotos') ?? [];
      _videoPaths = prefs.getStringList('savedVideos') ?? [];
    });
  }

  Future<void> _saveFilesList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('savedPhotos', _photoPaths);
    await prefs.setStringList('savedVideos', _videoPaths);
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
        content: Text('Storage access is required. Please grant permissions in app settings.'),
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

  Future<void> _uploadFile(bool isVideo) async {
    try {
      final XFile? pickedFile = isVideo
          ? await _picker.pickVideo(source: ImageSource.gallery)
          : await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final targetDirectory = Directory('${directory.path}/${isVideo ? 'videos' : 'photos'}');
      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
      }

      final String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
                              (isVideo ? '.mp4' : '.jpg');
      final String localPath = '${targetDirectory.path}/$fileName';

      await File(pickedFile.path).copy(localPath);

      setState(() {
        if (isVideo) {
          _videoPaths.add(localPath);
        } else {
          _photoPaths.add(localPath);
        }
      });

      await _saveFilesList();
      _showUploadSuccessDialog(isVideo);
    } catch (e) {
      _showUploadErrorDialog(e.toString());
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedIndices.clear();
    });
  }

  void _deleteSelectedFiles(bool isVideo) {
    setState(() {
      if (isVideo) {
        _selectedIndices.toList().reversed.forEach((index) {
          File(_videoPaths[index]).deleteSync();
          _videoPaths.removeAt(index);
        });
      } else {
        _selectedIndices.toList().reversed.forEach((index) {
          File(_photoPaths[index]).deleteSync();
          _photoPaths.removeAt(index);
        });
      }
      _saveFilesList();
      _toggleSelectionMode();
    });
  }

  void _exportToGallery(String filePath) async {
    try {
      final originalFile = File(filePath);
      final galleryDir = Directory('/storage/emulated/0/DCIM/Camera');
      if (!await galleryDir.exists()) {
        await galleryDir.create(recursive: true);
      }

      final newPath = '${galleryDir.path}/${DateTime.now().millisecondsSinceEpoch}${filePath.split('/').last}';
      await originalFile.copy(newPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File exported to gallery successfully')),
      );
    } catch (e) {
      _showUploadErrorDialog(e.toString());
    }
  }

  Widget _buildMediaGrid(bool isVideo) {
    final mediaFiles = isVideo ? _videoPaths : _photoPaths;
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: isVideo ? 0.8 : 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: mediaFiles.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPress: () {
            setState(() {
              _isSelectionMode = true;
              _selectedIndices.add(index);
            });
          },
          onTap: _isSelectionMode 
            ? () {
                setState(() {
                  if (_selectedIndices.contains(index)) {
                    _selectedIndices.remove(index);
                  } else {
                    _selectedIndices.add(index);
                  }
                });
              }
            : () {
                if (isVideo) {
                  _playVideo(mediaFiles[index]);
                } else {
                  _showFullScreenImage(File(mediaFiles[index]));
                }
              },
          child: Stack(
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: isVideo
                    ? _buildVideoThumbnail(mediaFiles[index])
                    : Image.file(
                        File(mediaFiles[index]),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                ),
              ),
              if (_isSelectionMode)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedIndices.contains(index) 
                        ? Colors.purple[600] 
                        : Colors.white54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _selectedIndices.contains(index) 
                        ? Icons.check_circle 
                        : Icons.circle_outlined,
                      color: _selectedIndices.contains(index) 
                        ? Colors.white 
                        : Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoThumbnail(String videoPath) {
    return FutureBuilder<VideoPlayerController>(
      future: _initializeVideoController(videoPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: snapshot.data!.value.aspectRatio,
            child: VideoPlayer(snapshot.data!),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<VideoPlayerController> _initializeVideoController(String videoPath) async {
    final controller = VideoPlayerController.file(File(videoPath));
    await controller.initialize();
    return controller;
  }

  void _playVideo(String videoPath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoPath: videoPath),
      ),
    );
  }

  void _showFullScreenImage(File imageFile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: Icon(Icons.download, color: Colors.white),
                onPressed: () => _exportToGallery(imageFile.path),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  // Show delete confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete Image'),
                      content: Text('Are you sure you want to delete this image?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Delete the image
                            int index = _photoPaths.indexOf(imageFile.path);
                            if (index != -1) {
                              setState(() {
                                File(imageFile.path).deleteSync();
                                _photoPaths.removeAt(index);
                                _saveFilesList();
                              });
                              // Close the full-screen view and go back to gallery
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            }
                          },
                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelectionMode ? 'Select Items' : 'Media Gallery',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple[600],
        actions: _isSelectionMode 
          ? [
              IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () => _showDeleteConfirmationDialog(),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: _toggleSelectionMode,
              ),
            ]
          : [],
      ),
      body: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.purple[600],
                    tabs: [
                      Tab(text: 'Photos'),
                      Tab(text: 'Videos'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildMediaGrid(false),
                        _buildMediaGrid(true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Files'),
        content: Text('Are you sure you want to delete the selected files?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteSelectedFiles(_isSelectionMode);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: () => _exportToGallery(widget.videoPath),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Video'),
                  content: Text('Are you sure you want to delete this video?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        int index = (context.findAncestorStateOfType<_DashboardPageState>()
                            as _DashboardPageState)._videoPaths.indexOf(widget.videoPath);
                        
                        if (index != -1) {
                          (context.findAncestorStateOfType<_DashboardPageState>()
                              as _DashboardPageState).setState(() {
                            File(widget.videoPath).deleteSync();
                            (context.findAncestorStateOfType<_DashboardPageState>()
                                as _DashboardPageState)._videoPaths.removeAt(index);
                            (context.findAncestorStateOfType<_DashboardPageState>()
                                as _DashboardPageState)._saveFilesList();
                          });
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      },
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller),
                  VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Colors.purple[600]!,
                      bufferedColor: Colors.purple[300]!,
                      backgroundColor: Colors.grey[300]!,
                    ),
                  ),
                  Center(
                    child: IconButton(
                      icon: Icon(
                        _controller.value.isPlaying 
                          ? Icons.pause_circle 
                          : Icons.play_circle,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying 
                            ? _controller.pause() 
                            : _controller.play();
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
          : CircularProgressIndicator(),
      ),
    );
  }

  void _exportToGallery(String filePath) async {
    try {
      final originalFile = File(filePath);
      final galleryDir = Directory('/storage/emulated/0/DCIM/Camera');
      if (!await galleryDir.exists()) {
        await galleryDir.create(recursive: true);
      }

      final newPath = '${galleryDir.path}/${DateTime.now().millisecondsSinceEpoch}${filePath.split('/').last}';
      await originalFile.copy(newPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File exported to gallery successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting file: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}