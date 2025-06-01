import 'dart:io';

import 'package:flutter/material.dart';

/// A reusable photo viewer widget that displays a photo with a nice UI
/// and allows opening it in full screen.
class PhotoViewer extends StatelessWidget {
  /// The path to the photo file.
  final String? photoPath;
  
  /// Optional file object if available instead of path.
  final File? imageFile;
  
  /// Height of the photo container. Default is 160.
  final double height;
  
  /// Whether to show a compact version (smaller size, less decorations)
  final bool compact;

  /// Shows a title above the photo
  final bool showTitle;

  const PhotoViewer({
    Key? key,
    this.photoPath,
    this.imageFile,
    this.height = 160,
    this.compact = false,
    this.showTitle = true,
  }) : assert(photoPath != null || imageFile != null),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imageFile != null || (photoPath != null && photoPath!.isNotEmpty);
    
    if (!hasImage) return const SizedBox.shrink();
    
    final File fileToShow = imageFile ?? File(photoPath!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[  
          Row(
            children: [
              Icon(
                Icons.photo,
                size: compact ? 14 : 18,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: compact ? 4 : 8),
              Text(
                'Photo',
                style: (compact 
                  ? theme.textTheme.bodySmall 
                  : theme.textTheme.titleSmall)?.copyWith(
                  fontWeight: compact ? FontWeight.w500 : FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 4 : 12),
        ],
        
        // Photo thumbnail with tap to zoom functionality
        GestureDetector(
          onTap: () => _openFullScreenImage(context, fileToShow),
          child: Container(
            height: compact ? 100 : height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(compact ? 8 : 12),
              image: DecorationImage(
                image: FileImage(fileToShow),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: compact ? 4 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Gradient overlay for readability
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // View full image hint
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: compact ? 14 : 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 10 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Opens the image in a full-screen dialog
  void _openFullScreenImage(BuildContext context, File imageFile) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FullScreenImage(imageFile: imageFile),
      ),
    );
  }
}

/// A widget to display an image in full-screen with zoom and pan capabilities
class FullScreenImage extends StatefulWidget {
  final File imageFile;

  const FullScreenImage({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      // If zoomed in, zoom out
      _controller.value = Matrix4.identity();
    } else {
      // If zoomed out, zoom in on tap point
      final position = _doubleTapDetails!.localPosition;
      _controller.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Photo', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
