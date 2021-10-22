import 'package:server_app/entities.dart';

const _extensions = [
  '.txt',
  '.png',
  '.jpg',
  '.',
  '.dart',
  '.iml',
];
String pathFromRawPath(String path) {
  var splitted = path.split('\\');
  // print(splitted.length);
  if (splitted.length <= 1) return path + '\\';

  return splitted.sublist(0, splitted.length - 1).join('\\');
}

String extensionFromRawPath(String path) {
  final split = path.split('.');
  if (split.length <= 1) return '.';
  return '.' + split.last;
}

String nameFromRawPath(String path) {
  var splitted = path.split('\\');
  var dotSplitted = splitted.last.split('.');
  var name = dotSplitted.first;
  if (name == '') return path;
  return name;
}

ComputerFileExtension extensionToEnum(String extension) {
  if (!_extensions.contains(extension)) return ComputerFileExtension.UNKNOWN;
  return ComputerFileExtension.values[_extensions.indexOf(extension)];
}

const testComputerFileData = ComputerFileData(
    name: 'poytik', path: 'C:\\Users\\Mehme\\Desktop\\', extension: '.png');

RegExp createSearchRegex(String search) {
  if (search.startsWith('.')) {
    return RegExp('.*($search)');
  } else {
    return RegExp('$search($search)*');
  }
}

void main() {
  var path = 'C:\\'; //Users\\Mehme\\Desktop\\poytik.png';
  // print(pathFromRawPath(path));
  // print(extensionFromRawPath(path));
  // print(nameFromRawPath(path));
  var compfi = ComputerFileData.fromPath(path);
  var parent = ComputerFileData.getParentDirectoryData(compfi);
  var parents = ComputerFileData.getParentDirectoryData(parent);
  print(compfi);
  print(parent);
  print(parents);
  final data = [
    'data.txt',
    'data.',
    'data.jpeg',
    'dark.jpeg',
    'dark.',
    'mahmut.',
    'mahmut.txt',
  ];
  final daRegexp = createSearchRegex('da');
  final txtRegexp = createSearchRegex('.txt');
  for (String i in data) {
    if (daRegexp.hasMatch(i)) {
      print('da has match with $i');
    }
    if (txtRegexp.hasMatch(i)) {
      print('txt has match with $i');
    }
  }
}
