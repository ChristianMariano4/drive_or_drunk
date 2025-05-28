import 'dart:io';

import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/utils/image_utils.dart' show base64ToFile;
import 'package:drive_or_drunk_app/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInputField extends StatefulWidget {
  final Function(File) onImageSelected;
  final String? initialImage;

  const ImageInputField(
      {super.key, required this.onImageSelected, this.initialImage});

  @override
  State<ImageInputField> createState() => _ImageInputFieldState();
}

class _ImageInputFieldState extends State<ImageInputField> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      widget.onImageSelected(File(pickedFile.path));
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      base64ToFile(widget.initialImage!, 'initial_image.png').then((file) {
        setState(() {
          _selectedImage = file;
        });
        widget.onImageSelected(file);
      }).catchError((error) {
        debugPrint('Error converting base64 to file: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          child: InkWell(
            onTap: _pickImage,
            child: Ink(
              height: _selectedImage != null
                  ? AppSizes.productImageHeight
                  : AppSizes.formFieldHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(AppSizes.sm),
                  color: isThemeDark(context)
                      ? AppColors.filledBackgroundColorDark
                      : AppColors.filledBackgroundColorLight),
              child: _selectedImage != null
                  ? renderSelectedImage(context)
                  : Padding(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Select Image',
                            style: TextStyle(
                              fontSize: AppSizes.md,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.image,
                            size: AppSizes.iconXl,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Stack renderSelectedImage(BuildContext context) {
    return Stack(
      children: [
        Ink.image(
          image: FileImage(_selectedImage!),
          fit: BoxFit.cover,
          width: double.infinity,
        ),
        Align(
            alignment: Alignment.topRight,
            child: IconButton(
              color: Theme.of(context).colorScheme.primary,
              icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  child: const Icon(Icons.close)),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                });
              },
            )),
      ],
    );
  }
}
