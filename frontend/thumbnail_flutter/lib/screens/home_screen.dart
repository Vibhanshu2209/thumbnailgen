import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../widgets/common_widgets.dart';
import 'create_job_screen.dart';
import 'job_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().loadJobs();
      context.read<JobProvider>().startAutoRefresh();
    });
  }

  @override
  void dispose() {
    context.read<JobProvider>().stopAutoRefresh();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, String jobId) {
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
              context.read<JobProvider>().deleteJob(jobId);
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Thumbnail Generator'),
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '✨',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.jobs.isEmpty) {
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LoadingShimmer(height: 16),
                        SizedBox(height: 12),
                        LoadingShimmer(height: 20),
                        SizedBox(height: 12),
                        LoadingShimmer(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          if (provider.error != null && provider.jobs.isEmpty) {
            return ErrorWidget(
              message: provider.error ?? 'Unknown error occurred',
              onRetry: () => provider.loadJobs(),
            );
          }

          if (provider.jobs.isEmpty) {
            return EmptyState(
              icon: Icons.work_outline,
              title: 'No Jobs Yet',
              description:
                  'Create your first thumbnail generation job to get started',
              onActionPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateJobScreen()),
                );
              },
              actionLabel: 'Create Job',
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadJobs(),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: provider.jobs.length,
              itemBuilder: (context, index) {
                final job = provider.jobs[index];
                return JobCard(
                  jobId: job.id,
                  prompt: job.prompt,
                  status: job.status,
                  imageUrl: job.imageUrl,
                  numThumbnails: job.numThumbnails,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobDetailsScreen(jobId: job.id),
                      ),
                    );
                  },
                  onDelete: () => _showDeleteConfirmation(context, job.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateJobScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Create New Job',
      ),
    );
  }
}
