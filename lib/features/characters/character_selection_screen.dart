import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({Key? key}) : super(key: key);

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  int selectedCharacter = 0;

  final List<Map<String, dynamic>> characters = [
    {
      'name': 'Runner',
      'color': Color(0xFF6C63FF),
      'price': 0,
      'unlocked': true,
    },
    {
      'name': 'Speedy',
      'color': Color(0xFFFF6584),
      'price': 500,
      'unlocked': false,
    },
    {
      'name': 'Flash',
      'color': Color(0xFFFFD700),
      'price': 1000,
      'unlocked': false,
    },
    {
      'name': 'Shadow',
      'color': Color(0xFF000000),
      'price': 1500,
      'unlocked': false,
    },
    {
      'name': 'Ninja',
      'color': Color(0xFF8E24AA),
      'price': 2000,
      'unlocked': false,
    },
    {
      'name': 'Cosmic',
      'color': Color(0xFF00BCD4),
      'price': 2500,
      'unlocked': false,
    },
  ];

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
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: characters.length,
                  itemBuilder: (context, index) => _buildCharacterCard(index),
                ),
              ),
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
            'Characters',
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

  Widget _buildCharacterCard(int index) {
    final character = characters[index];
    final isSelected = selectedCharacter == index;
    final isUnlocked = character['unlocked'] as bool;

    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          setState(() => selectedCharacter = index);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C63FF)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Character avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: character['color'] as Color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (character['color'] as Color).withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: isUnlocked
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : const Icon(Icons.lock, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  character['name'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                if (!isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Color(0xFFFFD700),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${character['price']}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isUnlocked && isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Selected',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
