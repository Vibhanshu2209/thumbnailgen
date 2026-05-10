import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/job_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;

  const JobDetailsScreen({
    Key? key,
    required this.jobId,
  }) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Future<JobResponse> _jobFuture;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _jobFuture = context.read<JobProvider>().getJobDetails(widget.jobId);
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Job'),
        content: Text(
          'Are you sure you want to delete this job and all associated thumbnails?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<JobProvider>().deleteJob(widget.jobId).then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Job deleted successfully')),
                );
              });
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _retryJob() async {
    setState(() => _isRetrying = true);
    try {
      await context.read<JobProvider>().retryJob(widget.jobId);
      _jobFuture = context.read<JobProvider>().getJobDetails(widget.jobId);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job retry initiated'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error retrying job: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppTheme.error),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Delete Job',
          ),
        ],
      ),
      body: FutureBuilder<JobResponse>(
        future: _jobFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading job details...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return ErrorWidget(
              message: 'Error: ${snapshot.error}',
              onRetry: () {
                setState(() {
                  _jobFuture =
                      context.read<JobProvider>().getJobDetails(widget.jobId);
                });
              },
            );
          }

          if (!snapshot.hasData) {
            return EmptyState(
              icon: Icons.info_outline,
              title: 'No Data',
              description: 'Job details not available',
            );
          }

          final job = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _jobFuture =
                    context.read<JobProvider>().getJobDetails(widget.jobId);
              });
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Header Card
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              StatusBadge(status: job.status),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Prompt',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            job.prompt,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thumbnails',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${job.numThumbnails}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Generated',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${job.thumbnails?.where((t) => t.status == 'processed').length ?? 0}/${job.numThumbnails}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Reference Image
                  if (job.imageUrl.isNotEmpty) ...[
                    Text(
                      'Reference Image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: job.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],

                  // Thumbnails Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Generated Thumbnails',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (job.isFailed && !_isRetrying)
                        ElevatedButton.icon(
                          onPressed: _retryJob,
                          icon: Icon(Icons.refresh, size: 16),
                          label: Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.warning,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      if (_isRetrying)
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Thumbnails Grid
                  if (job.thumbnails != null && job.thumbnails!.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: job.thumbnails!.length,
                      itemBuilder: (context, index) {
                        final thumbnail = job.thumbnails![index];
                        return _buildThumbnailCard(thumbnail);
                      },
                    )
                  else
                    EmptyState(
                      icon: Icons.image_not_supported,
                      title: 'No Thumbnails Yet',
                      description: 'Thumbnails will appear here as they are generated',
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnailCard(ThumbnailResponse thumbnail) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: thumbnail.imageUrl != null && thumbnail.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: thumbnail.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.grey[400]),
                          SizedBox(height: 8),
                          Text(
                            'Load failed',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        thumbnail.styleName.replaceAll('_', ' ').toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    StatusBadge(status: thumbnail.status),
                  ],
                ),
                if (thumbnail.errorMessage != null) ...[
                  SizedBox(height: 8),
                  Text(
                    thumbnail.errorMessage!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
