import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    Key? key,
    required this.status,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.success;
      case 'processing':
      case 'not started':
        return AppTheme.warning;
      case 'failed':
        return AppTheme.error;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'processing':
      case 'not started':
        return Icons.schedule;
      case 'failed':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 14,
            color: _getStatusColor(),
          ),
          SizedBox(width: 6),
          Text(
            status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingShimmer extends StatelessWidget {
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    Key? key,
    this.height = 20,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String jobId;
  final String prompt;
  final String status;
  final String imageUrl;
  final int numThumbnails;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const JobCard({
    Key? key,
    required this.jobId,
    required this.prompt,
    required this.status,
    required this.imageUrl,
    required this.numThumbnails,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Job ID: ${jobId.substring(0, 8)}...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          prompt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                      onPressed: onDelete,
                      iconSize: 20,
                    ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: status),
                  Text(
                    '$numThumbnails Thumbnail${numThumbnails > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.onActionPressed,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[300],
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionLabel != null) ...[
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorWidget({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.error,
            ),
            SizedBox(height: 24),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
