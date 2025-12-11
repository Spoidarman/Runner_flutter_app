import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardEntry {
  final String username;
  final int score;
  final int rank;
  final String avatarUrl;

  LeaderboardEntry({
    required this.username,
    required this.score,
    required this.rank,
    required this.avatarUrl,
  });
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Demo data - Replace with Firebase Firestore data
  final List<LeaderboardEntry> _globalLeaderboard = [
    LeaderboardEntry(
      username: 'SpeedRunner',
      score: 5420,
      rank: 1,
      avatarUrl: '',
    ),
    LeaderboardEntry(
      username: 'ProGamer99',
      score: 4890,
      rank: 2,
      avatarUrl: '',
    ),
    LeaderboardEntry(
      username: 'JumpMaster',
      score: 4235,
      rank: 3,
      avatarUrl: '',
    ),
    LeaderboardEntry(username: 'FastFeet', score: 3890, rank: 4, avatarUrl: ''),
    LeaderboardEntry(
      username: 'RunnerKing',
      score: 3654,
      rank: 5,
      avatarUrl: '',
    ),
    LeaderboardEntry(username: 'You', score: 2847, rank: 15, avatarUrl: ''),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0f0f1e),
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildTopThree(),
              _buildTabBar(),
              Expanded(child: _buildLeaderboardList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Text(
            'Leaderboard',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumItem(_globalLeaderboard[1], 2, 100),
          const SizedBox(width: 16),
          _buildPodiumItem(_globalLeaderboard[0], 1, 120),
          const SizedBox(width: 16),
          _buildPodiumItem(_globalLeaderboard[2], 3, 80),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(LeaderboardEntry entry, int rank, double height) {
    Color rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
        ? const Color(0xFFC0C0C0)
        : const Color(0xFFCD7F32);

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1a1a2e),
            border: Border.all(color: rankColor, width: 3),
          ),
          child: Center(
            child: Text(
              entry.username[0],
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.username,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${entry.score}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: rankColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [rankColor.withOpacity(0.8), rankColor.withOpacity(0.3)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF6C63FF),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.5),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Global'),
          Tab(text: 'Weekly'),
          Tab(text: 'Friends'),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildList(_globalLeaderboard),
        _buildList(_globalLeaderboard),
        _buildList(_globalLeaderboard),
      ],
    );
  }

  Widget _buildList(List<LeaderboardEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isCurrentUser = entry.username == 'You';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? const Color(0xFF6C63FF).withOpacity(0.2)
                : const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isCurrentUser
                  ? const Color(0xFF6C63FF)
                  : Colors.white.withOpacity(0.1),
              width: isCurrentUser ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              _buildRankBadge(entry.rank),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF6C63FF),
                child: Text(
                  entry.username[0],
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  entry.username,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '${entry.score}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(int rank) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: rank <= 3
            ? const Color(0xFFFFD700).withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: rank <= 3 ? const Color(0xFFFFD700) : Colors.white,
          ),
        ),
      ),
    );
  }
}
