import 'utils.dart';

class ComputerFileData {
  final String extension;
  final String name;
  final String path;
  const ComputerFileData(
      {required this.name, required this.extension, required this.path});

  @override
  String toString() {
    return '$name$extension';
  }

  static ComputerFileData fromPath(String path) {
    final extension = extensionFromRawPath(path);
    final name = nameFromRawPath(path);
    final filePath = pathFromRawPath(path);
    return ComputerFileData(name: name, extension: extension, path: filePath);
  }

  static ComputerFileData getParentDirectoryData(ComputerFileData fileData) {
    final extension = '.';
    final name = nameFromRawPath(fileData.path);
    final path = pathFromRawPath(fileData.path);
    return ComputerFileData(name: name, extension: extension, path: path);
  }
}

enum ComputerFileExtension { TXT, PNG, JPEG, NONE, DART, IML, UNKNOWN }
