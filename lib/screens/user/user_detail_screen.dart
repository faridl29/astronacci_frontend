import 'package:astronacci/blocs/user/user_event.dart';
import 'package:astronacci/blocs/user/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../blocs/user/user_bloc.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;

  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(UserDetailRequested(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.status == UserStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state.status == UserStatus.failure) {
            return _buildErrorWidget(
                state.error ?? 'Failed to load user details');
          }

          if (state.selectedUser == null) {
            return _buildErrorWidget('User not found');
          }

          return _buildUserDetail(state.selectedUser!);
        },
      ),
    );
  }

  Widget _buildUserDetail(User user) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryLight,
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(75),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(75),
                      child: CachedNetworkImage(
                        imageUrl: user.avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.white.withOpacity(0.2),
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.white.withOpacity(0.2),
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Information
                _buildSectionTitle('Contact Information'),
                const SizedBox(height: 16),

                if (user.phone != null && user.phone!.isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.phone,
                    title: 'Phone',
                    value: user.phone!,
                    color: AppColors.success,
                  ),

                _buildInfoCard(
                  icon: Icons.email,
                  title: 'Email',
                  value: user.email,
                  color: AppColors.primary,
                ),

                const SizedBox(height: 24),

                // Personal Information
                _buildSectionTitle('Personal Information'),
                const SizedBox(height: 16),

                if (user.dateOfBirth != null)
                  _buildInfoCard(
                    icon: Icons.cake,
                    title: 'Date of Birth',
                    value:
                        DateFormat('MMMM dd, yyyy').format(user.dateOfBirth!),
                    color: AppColors.warning,
                  ),

                if (user.gender != null)
                  _buildInfoCard(
                    icon: Icons.person,
                    title: 'Gender',
                    value: user.gender!.toUpperCase(),
                    color: AppColors.info,
                  ),

                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('About'),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      user.bio!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Account Information
                _buildSectionTitle('Account Information'),
                const SizedBox(height: 16),

                _buildInfoCard(
                  icon: Icons.calendar_today,
                  title: 'Joined',
                  value: DateFormat('MMMM dd, yyyy').format(user.createdAt),
                  color: AppColors.secondary,
                ),

                _buildInfoCard(
                  icon: Icons.update,
                  title: 'Last Updated',
                  value: DateFormat('MMMM dd, yyyy').format(user.updatedAt),
                  color: AppColors.textSecondary,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops!',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
