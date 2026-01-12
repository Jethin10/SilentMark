import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import '../models/user_model.dart';
import '../components/app_background.dart';
import '../utils/theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Class Leaderboard", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'student')
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: FadeIn(child: const Text("No data yet!")));
              }

              final users = snapshot.data!.docs
                  .map((doc) => UserModel.fromFirestore(doc))
                  .toList();
              
              // Sort client-side
              users.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isMe = user.email == currentUserEmail;
                  final rank = index + 1;
                  
                  // Staggered Animation
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 50),
                    duration: const Duration(milliseconds: 500),
                    child: rank <= 3 
                      ? _buildTopRankCard(user, rank, isMe) 
                      : _buildStandardRankCard(user, rank, isMe),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopRankCard(UserModel user, int rank, bool isMe) {
    Color rankColor;
    IconData rankIcon;

    switch (rank) {
      case 1:
        rankColor = Colors.amber;
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = Colors.grey.shade400;
        rankIcon = Icons.military_tech;
        break;
      case 3:
        rankColor = Colors.brown.shade400;
        rankIcon = Icons.military_tech;
        break;
      default:
        rankColor = AppTheme.primary;
        rankIcon = Icons.star;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMe 
            ? [AppTheme.primary.withOpacity(0.1), AppTheme.surface] 
            : [AppTheme.surface, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: rankColor.withOpacity(0.5), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: rankColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(rankIcon, color: rankColor, size: 28),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary),
        ),
        subtitle: Text("${user.className ?? 'No Class'} • ${user.role.toUpperCase()}", style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${user.currentStreak}",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: rankColor),
            ),
            Text("STREAK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardRankCard(UserModel user, int rank, bool isMe) {
    return Card(
      color: isMe ? AppTheme.primary.withOpacity(0.05) : AppTheme.surface.withOpacity(0.9),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMe ? const BorderSide(color: AppTheme.primary, width: 1) : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          foregroundColor: AppTheme.primary,
          radius: 16,
          child: Text("$rank", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        title: Text(
          user.name, 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isMe ? AppTheme.primary : AppTheme.textPrimary
          )
        ),
        subtitle: Text(user.className ?? "No Class", style: const TextStyle(color: AppTheme.textSecondary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
            const SizedBox(width: 4),
            Text(
              "${user.currentStreak}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
