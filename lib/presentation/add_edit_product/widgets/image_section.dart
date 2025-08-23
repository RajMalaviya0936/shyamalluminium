import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ImageSection extends StatefulWidget {
  final List<XFile> selectedImages;
  final ValueChanged<List<XFile>> onImagesChanged;

  const ImageSection({
    super.key,
    required this.selectedImages,
    required this.onImagesChanged,
  });

  @override
  State<ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<ImageSection> {
  final ImagePicker _picker = ImagePicker();
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final camera = kIsWeb
            ? _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras.first)
            : _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras.first);

        _cameraController = CameraController(
            camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }

        await _applySettings();
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          debugPrint('Flash mode not supported: $e');
        }
      }
    } catch (e) {
      debugPrint('Settings error: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  void _showImageSourceActionSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageSourceBottomSheet(
        onCameraSelected: _captureFromCamera,
        onGallerySelected: _selectFromGallery,
        hasImages: widget.selectedImages.isNotEmpty,
        onRemoveAll: _removeAllImages,
      ),
    );
  }

  Future<void> _captureFromCamera() async {
    Navigator.pop(context);

    if (!await _requestCameraPermission()) {
      _showPermissionDeniedDialog();
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photo != null) {
        final updatedImages = List<XFile>.from(widget.selectedImages)
          ..add(photo);
        widget.onImagesChanged(updatedImages);
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      _showErrorDialog('Failed to capture image. Please try again.');
    }
  }

  Future<void> _selectFromGallery() async {
    Navigator.pop(context);

    try {
      final List<XFile> photos = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photos.isNotEmpty) {
        final updatedImages = List<XFile>.from(widget.selectedImages)
          ..addAll(photos);
        widget.onImagesChanged(updatedImages);
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      _showErrorDialog('Failed to select images. Please try again.');
    }
  }

  void _removeAllImages() {
    Navigator.pop(context);
    widget.onImagesChanged([]);
    HapticFeedback.lightImpact();
  }

  void _removeImage(int index) {
    HapticFeedback.lightImpact();
    final updatedImages = List<XFile>.from(widget.selectedImages)
      ..removeAt(index);
    widget.onImagesChanged(updatedImages);
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
            'Please grant camera permission to capture product images.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Images',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        widget.selectedImages.isEmpty
            ? _buildEmptyImageState(theme)
            : _buildImageGrid(theme),
        SizedBox(height: 2.h),
        _buildAddImageButton(theme),
      ],
    );
  }

  Widget _buildEmptyImageState(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 20.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'add_photo_alternate',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            size: 48,
          ),
          SizedBox(height: 1.h),
          Text(
            'No images added',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Tap the button below to add product images',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(ThemeData theme) {
    return SizedBox(
      height: 25.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.selectedImages.length,
        separatorBuilder: (context, index) => SizedBox(width: 3.w),
        itemBuilder: (context, index) {
          final image = widget.selectedImages[index];
          return _buildImageThumbnail(theme, image, index);
        },
      ),
    );
  }

  Widget _buildImageThumbnail(ThemeData theme, XFile image, int index) {
    return Container(
      width: 40.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: kIsWeb
                ? Image.network(
                    image.path,
                    width: 40.w,
                    height: 25.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 40.w,
                      height: 25.h,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: CustomIconWidget(
                        iconName: 'broken_image',
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 32,
                      ),
                    ),
                  )
                : Image.file(
                    File(image.path),
                    width: 40.w,
                    height: 25.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 40.w,
                      height: 25.h,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: CustomIconWidget(
                        iconName: 'broken_image',
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 32,
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: 1.h,
            right: 2.w,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: theme.colorScheme.onError,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showImageSourceActionSheet,
        icon: CustomIconWidget(
          iconName: 'add_a_photo',
          color: theme.colorScheme.primary,
          size: 20,
        ),
        label: Text(
          widget.selectedImages.isEmpty ? 'Add Images' : 'Add More Images',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          side: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _ImageSourceBottomSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;
  final bool hasImages;
  final VoidCallback onRemoveAll;

  const _ImageSourceBottomSheet({
    required this.onCameraSelected,
    required this.onGallerySelected,
    required this.hasImages,
    required this.onRemoveAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              'Add Product Images',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'camera_alt',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            title: Text(
              'Take Photo',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Capture with camera',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            onTap: onCameraSelected,
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'photo_library',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            title: Text(
              'Choose from Gallery',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Select from photo library',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            onTap: onGallerySelected,
          ),
          if (hasImages) ...[
            Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete_outline',
                color: theme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Remove All Images',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: onRemoveAll,
            ),
          ],
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}