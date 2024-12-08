import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Image and Video Picker
  final ImagePicker _picker = ImagePicker();
  
  // Lists to store local file paths
  List<String> _photoFiles = [];
  List<String> _videoFiles = [];

  // Comprehensive permission request method
  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    }

    final result = await permission.request();
    return result == PermissionStatus.granted;
  }

  // Method to handle multiple permission requests
  Future<bool> _handlePermissions() async {
    if (Platform.isAndroid) {
      // For Android, request storage permissions
      final storagePermission = await _requestPermission(Permission.storage);
      final manageStoragePermission = await _requestPermission(Permission.manageExternalStorage);

      if (!storagePermission || !manageStoragePermission) {
        _showPermissionDeniedDialog();
        return false;
      }
    } else if (Platform.isIOS) {
      // For iOS, request photo library permissions
      final photoPermission = await _requestPermission(Permission.photos);
      if (!photoPermission) {
        _showPermissionDeniedDialog();
        return false;
      }
    }

    return true;
  }

  // Method to show permission denied dialog
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
              openAppSettings(); // Opens app settings
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

  // Get secure local storage path
  Future<String> _getLocalStoragePath(bool isVideo) async {
    // Ensure permissions are granted
    final permissionsGranted = await _handlePermissions();
    if (!permissionsGranted) {
      throw Exception('Permissions not granted');
    }

    // Get app-specific secure directory
    final directory = await getApplicationDocumentsDirectory();
    
    // Create subdirectory for photos or videos
    final targetDirectory = Directory('${directory.path}/${isVideo ? 'videos' : 'photos'}');
    
    // Create directory if it doesn't exist
    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }

    return targetDirectory.path;
  }

  // File upload method
  Future<void> _uploadFile(bool isVideo) async {
    try {
      // Ensure permissions are granted before attempting to pick file
      final permissionsGranted = await _handlePermissions();
      if (!permissionsGranted) return;

      // Pick file from gallery
      final XFile? pickedFile = isVideo
          ? await _picker.pickVideo(source: ImageSource.gallery)
          : await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      // Get secure local storage path
      final storagePath = await _getLocalStoragePath(isVideo);

      // Generate unique filename
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString() + 
                               (isVideo ? '.mp4' : '.jpg');
      final String localPath = '$storagePath/$fileName';

      // Copy file to secure location
      await File(pickedFile.path).copy(localPath);

      // Update state to reflect new file
      setState(() {
        if (isVideo) {
          _videoFiles.add(localPath);
        } else {
          _photoFiles.add(localPath);
        }
      });

      // Show success dialog
      _showUploadSuccessDialog(isVideo);
    } catch (e) {
      // Show detailed error dialog
      _showUploadErrorDialog(e.toString());
    }
  }

  // View saved files method
  void _viewSavedFiles(bool isVideo) {
    final files = isVideo ? _videoFiles : _photoFiles;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Saved ${isVideo ? 'Videos' : 'Photos'}'),
        content: files.isEmpty
            ? Text('No ${isVideo ? 'videos' : 'photos'} saved yet.')
            : SizedBox(
                height: 300,
                width: 300,
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text('File ${index + 1}'),
                    subtitle: Text(files[index]),
                  ),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Success upload dialog
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

  // Error upload dialog
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

  // Build method for card widget
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

  // Main build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
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
          // Show a bottom sheet to choose upload type
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