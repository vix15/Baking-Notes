import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImagePickerWidget extends StatefulWidget {
  final Function(String) onImageSelected;
  final String? initialImage;
  final bool isCircular;
  final double size;
  final bool allowGallery;
  final bool allowCamera;
  
  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.initialImage,
    this.isCircular = false,
    this.size = 200,
    this.allowGallery = true,
    this.allowCamera = true,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _imagePath;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImage;
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}${path.extension(pickedFile.path)}';
        final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
        
        setState(() {
          _imagePath = savedImage.path;
        });
        
        widget.onImageSelected(savedImage.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showImageSourceModal() {
    final options = <Widget>[];
    
    if (widget.allowCamera) {
      options.add(
        _buildOptionButton(
          icon: Icons.camera_alt,
          label: 'Cámara',
          onTap: () {
            Navigator.pop(context);
            _pickImage(ImageSource.camera);
          },
        ),
      );
    }
    
    if (widget.allowGallery) {
      options.add(
        _buildOptionButton(
          icon: Icons.photo_library,
          label: 'Galería',
          onTap: () {
            Navigator.pop(context);
            _pickImage(ImageSource.gallery);
          },
        ),
      );
    }
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seleccionar imagen',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: options,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    )
    );
  }
  
  Widget _buildImageWidget() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_imagePath == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.isCircular ? Icons.person : Icons.camera_alt,
            size: widget.size * 0.4,
            color: Colors.grey.shade600,
          ),
          if (!widget.isCircular) const SizedBox(height: 8),
          if (!widget.isCircular)
            Text(
              'Toca para agregar una foto',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
        ],
      );
    }
    
    return ClipRRect(
      borderRadius: widget.isCircular 
          ? BorderRadius.circular(widget.size)
          : BorderRadius.circular(16),
      child: Image.file(
        File(_imagePath!),
        fit: BoxFit.cover,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceModal,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.size,
            height: widget.isCircular ? widget.size : widget.size * 1.25,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: widget.isCircular 
                  ? BorderRadius.circular(widget.size)
                  : BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: _buildImageWidget(),
          ),
          if (_imagePath != null)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: _showImageSourceModal,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}