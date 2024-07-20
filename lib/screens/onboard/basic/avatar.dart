import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

class Avatar extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  const Avatar({super.key, this.onNext, this.onBack});

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends ConsumerState<Avatar> {
  bool _isLoading = false;
  bool _isImageUploaded = false;
  bool _isImageUploading = false;
  File _image = File('');

  Future<File> _compressImage(String imagePath, String imageName) async {
    var result = await FlutterImageCompress.compressWithFile(
      imagePath,
      minWidth: 1024,
      minHeight: 1024,
      quality: 80,
    );

    final newFilePath = await getTemporaryDirectory();
    final compressedImageFile =
        File('${newFilePath.path}/${imageName}duplicate.jpg');
    await compressedImageFile.writeAsBytes(result!);

    return compressedImageFile;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.onboardScaffold,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.035),
                Container(
                  height: 56,
                  width: 56,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondaryGray1,
                  ),
                  child: SvgPicture.asset("assets/icons/image-upload.svg"),
                ),
                SizedBox(height: size.height * 0.05),
                Text(
                  "Upload your profile picture.",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w600,
                    height: 1.32,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0x338BCDF8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Your photo will be verified by one of our team members. Please ensure that your face is clearly visible",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.32,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                _isImageUploaded
                    ? Center(
                        child: Container(
                          width: 204,
                          height: 204,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(300),
                            child: Image.file(
                              _image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Container(
                          padding: EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondaryGray1,
                          ),
                          width: size.width * 0.5,
                          child: SvgPicture.asset("assets/icons/big-user.svg"),
                        ),
                      ),
                SizedBox(height: 32),
                Center(
                  child: PressEffect(
                    onPressed: () async {
                      setState(() {
                        _isImageUploading = true;
                      });
                      // upload image
                      // FilePickerResult? result = await FilePicker.platform
                      //     .pickFiles(type: FileType.image);
                      final ImagePicker picker = ImagePicker();
                      final XFile? result =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (result != null) {
                        File file = File(result.path);
                        var compressedImage =
                            await _compressImage(file.path, result.name);

                        var profile = ref.read(profileProvider.notifier);

                        profile.updateAvatar(compressedImage);
                        setState(() {
                          _image = compressedImage;
                          _isImageUploaded = true;
                        });
                      }
                      setState(() {
                        _isImageUploading = false;
                      });
                    },
                    child: Container(
                      padding: _isImageUploading
                          ? EdgeInsets.all(8)
                          : EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: _isImageUploaded
                            ? Colors.transparent
                            : Colors.black,
                        border: Border.all(
                          color: Colors.black,
                          width: 0.5,
                        ),
                      ),
                      child: _isImageUploading
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  _isImageUploaded
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _isImageUploaded
                                  ? "Replace image"
                                  : "Upload image",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'General Sans',
                                fontWeight: FontWeight.w600,
                                height: 1.32,
                                color: _isImageUploaded
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          width: size.width * 0.9,
          child: Row(
            children: [
              PressEffect(
                onPressed: () {
                  widget.onBack!();
                },
                child: Container(
                  width: 36,
                  height: 36,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: SvgPicture.asset("assets/icons/arrow-left.svg"),
                ),
              ),
              Spacer(),
              PressEffect(
                onPressed: () {
                  if (_isImageUploaded) {
                    widget.onNext!();
                  }
                },
                child: Container(
                  width: 102,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: _isImageUploaded ? Colors.black : Color(0xffa3a3a3),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color:
                          _isImageUploaded ? Colors.black : Color(0xffa3a3a3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 0.85,
                        ),
                      ),
                      SizedBox(width: 4),
                      !_isLoading
                          ? SvgPicture.asset("assets/icons/arrow-r.svg")
                          : Container(
                              padding: EdgeInsets.all(4),
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
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
    );
  }
}
