import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class VoiceRecordingScreen extends StatefulWidget {
  final String disorderTitle;
  final Map<String, dynamic> user;
  final String apiEndpoint;

  const VoiceRecordingScreen({
    super.key,
    required this.disorderTitle,
    required this.user,
    required this.apiEndpoint,
  });

  @override
  _VoiceRecordingScreenState createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends State<VoiceRecordingScreen> {
  late FlutterSoundRecorder _audioRecorder;
  late AudioPlayer _audioPlayer;
  bool _isRecording = false;
  String? _recordedFilePath;
  bool _isPlaying = false;
  int _recordDuration = 0;
  Timer? _timer;
  String? _uploadedFilePath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecorder();
    _audioPlayer = AudioPlayer();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    try {
      await _audioRecorder.openRecorder();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize audio recorder: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission is required to record audio.')),
      );
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/sample.wav'; // Use .wav for pcm16

    try {
      await _audioRecorder.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16, // Use a supported codec
      );
      setState(() {
        _isRecording = true;
        _recordedFilePath = filePath;
        _recordDuration = 0;
      });

      _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
        if (_recordDuration < 60) {
          setState(() {
            _recordDuration++;
          });
        } else {
          _stopRecording();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: ${e.toString()}')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
      _timer?.cancel();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording: ${e.toString()}')),
      );
    }
  }

  Future<void> _playRecording() async {
    if (_recordedFilePath != null) {
      await _audioPlayer.play(UrlSource(_recordedFilePath!));
      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<void> _stopPlaying() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        _uploadedFilePath = result.files.single.path;
      });
    }
  }

  Future<void> _submitRecording() async {
    String? filePath = _recordedFilePath ?? _uploadedFilePath;
    if (filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please record a voice clip or upload a file first.')),
      );
      return;
    }

    final file = File(filePath);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(widget.apiEndpoint),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // Key for the file
        file.path,
        filename: 'sample.wav',
      ),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice clip submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit voice clip.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.disorderTitle, style: GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Disorder: ${widget.disorderTitle}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 50,
                      color: _isRecording ? Colors.red : Colors.blue,
                    ),
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                  ),
                  Text(
                    _isRecording ? 'Recording... $_recordDuration seconds' : 'Tap to Record',
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 20),
                  if (_recordedFilePath != null)
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.stop : Icons.play_arrow,
                            size: 50,
                            color: Colors.green,
                          ),
                          onPressed: _isPlaying ? _stopPlaying : _playRecording,
                        ),
                        Text(
                          _isPlaying ? 'Playing...' : 'Tap to Play',
                          style: GoogleFonts.poppins(),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _recordedFilePath = null;
                            });
                          },
                          child: Text(
                            'Re-record',
                            style: GoogleFonts.poppins(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: Text(
                      'Upload MP3',
                      style: GoogleFonts.poppins(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitRecording,
                    child: Text(
                      'Submit',
                      style: GoogleFonts.poppins(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}