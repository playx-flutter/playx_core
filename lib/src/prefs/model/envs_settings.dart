import 'package:flutter_dotenv/flutter_dotenv.dart';


///Settings for [PlayxEnvSettings].
class PlayxEnvSettings {
  final String fileName;
  final Parser parser;

  final Map<String, String> mergeWith;
  final bool isOptional;

  const PlayxEnvSettings(
      {this.fileName = '.env',
      this.parser = const Parser(),
      this.mergeWith = const {},
      this.isOptional = true});
}
