import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'voice_recording_screen.dart'; 
import '../global.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Information
            Text(
              'User Information',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Name: ${user['name']}',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${user['email']}',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'ID: ${user['id']}',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Cards Section
            Text(
              'Disorders',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildCard(context, 'Articulation', Icons.record_voice_over),
                _buildCard(context, 'Childhood Apraxia', Icons.child_care),
                _buildCard(context, 'Disfluency Disorder', Icons.speaker_notes),
                _buildCard(context, 'Phonological Disorder', Icons.volume_up),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Navigate to VoiceRecordingScreen when a card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceRecordingScreen(
              disorderTitle: title,
              user: user,
              apiEndpoint: endpoints[title] ?? '',
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}