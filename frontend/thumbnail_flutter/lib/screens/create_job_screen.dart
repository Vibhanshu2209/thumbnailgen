import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../providers/job_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _promptController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedImageUrl; // Store the uploaded image URL
  String? _selectedImageFilePath; // Temporary local file for upload
  int _numThumbnails = 1;
  String? _selectedStyle;
  bool _isSubmitting = false;
  bool _isUploadingImage = false;

  final List<String> _styles = [
    'bold_dramatic',
    'clean_minimal',
    'vibrant_energy',
  ];

  final Map<String, String> _styleDescriptions = {
    'bold_dramatic':
        'High-contrast chiaroscuro lighting, cinematic atmosphere, intense colors',
    'clean_minimal':
        'Soft natural lighting, monochromatic palette, uncluttered aesthetic',
    'vibrant_energy': 'Saturated neon colors, dynamic motion blur, electric atmosphere',
  };

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _isUploadingImage = true;
          _selectedImageFilePath = pickedFile.path;
        });

        try {
          // Upload image to backend (works on both web and native)
          final uploadResponse = await ApiService.uploadImage(pickedFile);
          
          if (mounted) {
            setState(() {
              _selectedImageUrl = uploadResponse.url;
              _isUploadingImage = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Image uploaded successfully'),
                backgroundColor: AppTheme.success,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        } catch (uploadError) {
          if (mounted) {
            setState(() {
              _isUploadingImage = false;
              _selectedImageFilePath = null;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error uploading image: $uploadError'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _submitJob() async {
    if (_selectedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select and upload an image'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a prompt'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Create job request directly (image already uploaded)
      final jobRequest = CreateJobRequest(
        prompt: _promptController.text,
        numThumbnails: _numThumbnails,
        originalImageUrl: _selectedImageUrl!,
        style: _selectedStyle,
      );

      final createJobResponse = await ApiService.createJob(jobRequest);

      if (mounted) {
        // Reload jobs in provider
        await context.read<JobProvider>().loadJobs();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job created successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating job: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Job'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Selection
            Text(
              'Reference Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            GestureDetector(
              onTap: _selectedImageUrl == null && !_isUploadingImage ? _pickImage : null,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.primaryColor.withOpacity(0.05),
                ),
                child: _isUploadingImage
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppTheme.primaryColor),
                          SizedBox(height: 16),
                          Text(
                            'Uploading image...',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : _selectedImageUrl != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: _selectedImageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[300],
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.grey[600],
                                          size: 48,
                                        ),
                                        SizedBox(height: 8),
                                        Text('Failed to load image'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImageUrl = null;
                                      _selectedImageFilePath = null;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.error,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 48,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tap to select image',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'PNG, JPG up to 10MB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            SizedBox(height: 32),

            // Prompt Input
            Text(
              'Prompt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _promptController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe the style and content for your thumbnails',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 32),

            // Number of Thumbnails
            Text(
              'Number of Thumbnails',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: List.generate(
                3,
                (index) {
                  final num = index + 1;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text('$num'),
                        selected: _numThumbnails == num,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _numThumbnails = num);
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: _numThumbnails == num
                              ? Colors.white
                              : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 32),

            // Style Selection
            Text(
              'Style (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _styles.length,
              itemBuilder: (context, index) {
                final style = _styles[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedStyle = style);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedStyle == style
                              ? AppTheme.primaryColor
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: _selectedStyle == style
                            ? AppTheme.primaryColor.withOpacity(0.05)
                            : Colors.transparent,
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Radio(
                                value: style,
                                groupValue: _selectedStyle,
                                onChanged: (value) {
                                  setState(() => _selectedStyle = value);
                                },
                                activeColor: AppTheme.primaryColor,
                              ),
                              Text(
                                style.replaceAll('_', ' ').toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Padding(
                            padding: EdgeInsets.only(left: 40),
                            child: Text(
                              _styleDescriptions[style] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                );
              },
            ),
            SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitJob,
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Create Job'),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
