import 'dart:io';
import 'dart:typed_data';

/// Generate video frames from frame bites
///
/// Input:
///   - List<List<int>> frames, a list with the bites of all frames
///   - String path where to save the generated images from the bites
Future<void> create_frames(List<List<int>> frames, String path) async {
  /// Iterate through the frames list
  /// Write to the image file the current frame and save to path
  for (int i = 0; i < frames.length; i++) {
    List<int> frame = frames[i];
    File imageFile = File('media/$path/frame_$i.png');

    String ppmHeader = 'P6\n3 1\n255\n';
    List<int> ppmData = ppmHeader.codeUnits + frame;
    await imageFile.writeAsBytes(Uint8List.fromList(ppmData));
  }
}

/// Generate video audio from audio samples
///
/// Input:
///   - List<List<int>> samples, lists of audio samples (16Hz)
///   - String audio outpath
Future<void> create_audio(List<List<int>> samples, String outputPath) async {
  /// Combine audio frames
  /// Generate pcm (array of samples, 16bits per sample 16Hz)
  List<int> audioData = samples.expand((sample) => sample).toList();
  File audioFile = File('media/$outputPath/audio.pcm');
  await audioFile.writeAsBytes(Uint8List.fromList(audioData));
}

/// Combine video and audio via ffmpeg
///
/// Input:
///   - String path, video ouput
void combine_video_audio(String path) {
  Process.run('ffmpeg', [
    '-framerate',
    '15',
    '-i',
    'media/$path/frame_%d.png',
    '-f',
    's16le',
    '-ar',
    '16',
    '-i',
    'audio.pcm',
    '-c:v',
    'libx264',
    '-pix_fmt',
    'yuv420p',
    'media/$path/output.mp4',
  ]).then((result) {
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });
}

/// Get the bites of the generated video
///
/// Input:
///   - String path, user
///
/// Returns:
///   - List<int> bites of generated video
List<int> get_video(String path) {
  String full_path = 'media/$path/output.mp4';
  List<int> video = [];

  File video_file = File(full_path);
  if (video_file.existsSync()) {
    video = video_file.readAsBytesSync();
  } else {
    print('File not found: $full_path');
  }

  return video;
}
