import 'dart:io';
import 'dart:typed_data';

Future<void> create_frames(List<List<int>> frames, String path) async {
  for (int i = 0; i < frames.length; i++) {
    List<int> frame = frames[i];
    File imageFile = File('media/$path/frame_$i.png');

    String ppmHeader = 'P6\n3 1\n255\n';
    List<int> ppmData = ppmHeader.codeUnits + frame;
    await imageFile.writeAsBytes(Uint8List.fromList(ppmData));
  }
}

Future<void> create_audio(List<List<int>> samples, String outputPath) async {
  List<int> audioData = samples.expand((sample) => sample).toList();
  File audioFile = File('media/$outputPath');
  await audioFile.writeAsBytes(Uint8List.fromList(audioData));
}

void combine_video_audio(String path) {
  Process.run('ffmpeg', [
    '-framerate',
    '10',
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

List<int> get_video(String path) {
  String full_path = 'media/$path/output.mp4';
  List<int> video = [];
  // get buffer from file

  return video;
}
