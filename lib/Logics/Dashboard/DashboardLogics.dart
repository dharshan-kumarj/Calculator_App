// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_player/video_player.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../Static/Widgets/Dashboard/DashBoard.dart'; // Import the UI file

// class DashboardLogic {
//   final ImagePicker _picker = ImagePicker();
//   List<String> photoPaths = [];
//   List<String> videoPaths = [];
//   Map<int, VideoPlayerController> videoControllers = {};
//   bool isSelectionMode = false;
//   Set<int> selectedIndices = {};

//   final BuildContext context;

//   DashboardLogic(this.context) {
//     _checkAndRequestPermissions();
//     _loadSavedFiles();
//   }

//   Future<void> loadSavedFiles() async {
//     final prefs = await SharedPreferences.getInstance();
//     photoPaths = prefs.getStringList('savedPhotos') ?? [];
//     videoPaths = prefs.getStringList('savedVideos') ?? [];
//   }

//   Future<void> saveFilesList() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('savedPhotos', photoPaths);
//     await prefs.setStringList('savedVideos', videoPaths);
//   }

//   Future<void> checkAndRequestPermissions() async {
//     if (Platform.isAndroid) {
//       await _requestPermission(Permission.storage);
//       await _requestPermission(Permission.manageExternalStorage);
//     } else if (Platform.isIOS) {
//       await _requestPermission(Permission.photos);
//     }
//   }

//   Future<void> _requestPermission(Permission permission) async {
//     final status = await permission.request();
//     if (status != PermissionStatus.granted) {
//       _showPermissionDeniedDialog();
//     }
//   }

//   void showPermissionDeniedDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Permission Denied'),
//         content: Text('Storage access is required. Please grant permissions in app settings.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               openAppSettings();
//             },
//             child: Text('Open Settings'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   void showUploadSuccessDialog(bool isVideo) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Upload Successful'),
//         content: Text('${isVideo ? 'Video' : 'Photo'} saved successfully!'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   void showUploadErrorDialog(String error) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Upload Failed'),
//         content: Text('Error: $error'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> uploadFile(bool isVideo) async {
//     try {
//       final XFile? pickedFile = isVideo
//           ? await _picker.pickVideo(source: ImageSource.gallery)
//           : await _picker.pickImage(source: ImageSource.gallery);

//       if (pickedFile == null) return;

//       final directory = await getApplicationDocumentsDirectory();
//       final targetDirectory = Directory('${directory.path}/${isVideo ? 'videos' : 'photos'}');
//       if (!await targetDirectory.exists()) {
//         await targetDirectory.create(recursive: true);
//       }

//       final String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
//                               (isVideo ? '.mp4' : '.jpg');
//       final String localPath = '${targetDirectory.path}/$fileName';

//       await File(pickedFile.path).copy(localPath);

//       if (isVideo) {
//         videoPaths.add(localPath);
//       } else {
//         photoPaths.add(localPath);
//       }

//       await saveFilesList();
//       showUploadSuccessDialog(isVideo);
//     } catch (e) {
//       showUploadErrorDialog(e.toString());
//     }
//   }

//   void toggleSelectionMode() {
//     isSelectionMode = !isSelectionMode;
//     selectedIndices.clear();
//   }

//   void deleteSelectedFiles(bool isVideo) {
//     selectedIndices.toList().reversed.forEach((index) {
//       if (isVideo) {
//         File(videoPaths[index]).deleteSync();
//         videoPaths.removeAt(index);
//       } else {
//         File(photoPaths[index]).deleteSync();
//         photoPaths.removeAt(index);
//       }
//     });
//     saveFilesList();
//     toggleSelectionMode();
//   }

//   void exportToGallery(String filePath) async {
//     try {
//       final originalFile = File(filePath);
//       final galleryDir = Directory('/storage/emulated/0/DCIM/Camera');
//       if (!await galleryDir.exists()) {
//         await galleryDir.create(recursive: true);
//       }

//       final newPath = '${galleryDir.path}/${DateTime.now().millisecondsSinceEpoch}${filePath.split('/').last}';
//       await originalFile.copy(newPath);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('File exported to gallery successfully')),
//       );
//     } catch (e) {
//       showUploadErrorDialog(e.toString());
//     }
//   }

//   Future<VideoPlayerController> initializeVideoController(String videoPath) async {
//     final controller = VideoPlayerController.file(File(videoPath));
//     await controller.initialize();
//     return controller;
//   }

//   void playVideo(String videoPath) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => VideoPlayerScreen(videoPath: videoPath, dashboardLogic: this),
//       ),
//     );
//   }

//   void showFullScreenImage(File imageFile) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => ImageViewScreen(imageFile: imageFile, dashboardLogic: this),
//       ),
//     );
//   }
// }