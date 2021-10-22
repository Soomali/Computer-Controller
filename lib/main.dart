import 'package:flutter/material.dart';
import 'package:server_app/client.dart';
import 'package:server_app/utils.dart';
import 'entities.dart';
import 'loadingIndicator.dart';
import 'TextEdit.dart';

void main() {
  runApp(ControllerApp());
}

const String root = 'C:\\';

class ControllerApp extends StatelessWidget {
  const ControllerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: DirectoryWidget(),
      ),
    );
  }
}

class DirectoryWidget extends StatefulWidget {
  const DirectoryWidget({
    Key? key,
  }) : super(key: key);

  @override
  _DirectoryWidgetState createState() => _DirectoryWidgetState();
}

class _DirectoryWidgetState extends State<DirectoryWidget> {
  var data = ComputerFileData(name: root, extension: '.', path: root);
  void _rebuild(ComputerFileData newData) {
    setState(() {
      this.data = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DirectoryHolderWidget(
      rebuild: _rebuild,
      currentDirectoryData: data,
      child: DirectoryWidgetBuilder(),
    );
  }
}

class DirectoryWidgetBuilder extends StatelessWidget {
  const DirectoryWidgetBuilder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = DirectoryHolderWidget.of(context)!.currentDirectoryData;
    var path = data.path == root ? data.path : data.path + '\\' + data.name;
    return FutureBuilder(
      future: Client.getFileList(path: path),
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Scaffold(body: Center(child: Text('No connection')));
          case ConnectionState.waiting:
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          case ConnectionState.active:
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          case ConnectionState.done:
            if (snapshot.data == null) {
              return Center(
                child: Text('No data is received'),
              );
            }
            var compFileDatas = snapshot.data!
                .map((e) => ComputerFileData.fromPath(e))
                .toList();
            return MainContentWidget(datas: compFileDatas);
        }
      },
    );
  }
}

class MainContentWidget extends StatefulWidget {
  final List<ComputerFileData> datas;
  const MainContentWidget({
    required this.datas,
    Key? key,
  }) : super(key: key);

  @override
  _MainContentWidgetState createState() => _MainContentWidgetState();
}

class _MainContentWidgetState extends State<MainContentWidget> {
  void _delete(ComputerFileData data) {
    Navigator.of(context)
        .push(FutureLoader(Client.deleteFile(data)))
        .then((value) => setState(() {
              widget.datas.removeWhere((element) => element == data);
            }));
  }

  RegExp? searchRegexp = null;
  void _search() {
    setState(() {
      if (controller.text != '') {
        searchRegexp = createSearchRegex(controller.text);
        if (searchRegexp != null) {
          searchData = widget.datas
              .where((element) => searchRegexp!.hasMatch('$element'))
              .toList();
        }
      } else {
        searchData = widget.datas;
      }
    });
  }

  late List<ComputerFileData> searchData;

  final TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      _search();
    });
    searchData = widget.datas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListenerAppBar(
            controller: controller,
            startValue: false,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchData.length,
              itemBuilder: (context, index) {
                return Container(
                  child: ComputerFileDisplayWidget(
                    data: searchData[index],
                    onDelete: _delete,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

abstract class ComputerFileWidget extends StatelessWidget {
  const ComputerFileWidget({Key? key, required this.data}) : super(key: key);
  abstract final bool canEdited;
  final ComputerFileData data;
  final updateIcon = Icons.update;
  final deleteIcon = Icons.delete;
  FileListener get listener;
}

class ComputerFileDisplayWidget extends ComputerFileWidget {
  final void Function(ComputerFileData) onDelete;
  ComputerFileDisplayWidget(
      {Key? key, required ComputerFileData data, required this.onDelete})
      : super(key: key, data: data);
  @override
  Widget build(BuildContext context) {
    final extension = extensionToEnum(data.extension);

    var icon = Icons.file_copy;
    switch (extension) {
      case ComputerFileExtension.TXT:
        icon = Icons.text_fields;
        break;
      case ComputerFileExtension.PNG:
        icon = Icons.filter;
        break;
      case ComputerFileExtension.JPEG:
        icon = Icons.filter;
        break;
      case ComputerFileExtension.NONE:
        icon = Icons.folder;
        break;
      case ComputerFileExtension.DART:
        icon = Icons.code;
        break;
      case ComputerFileExtension.IML:
        icon = Icons.wifi;
        break;
      case ComputerFileExtension.UNKNOWN:
        icon = Icons.file_copy;
        break;
    }
    return Card(
      child: GestureDetector(
        onTap: () {
          listener.onClick(extension, context);
        },
        child: Row(
          children: [
            Padding(
              child: Icon(icon),
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
            Expanded(
              child: Text(data.toString()),
              flex: 10,
            ),
            if (canEdited)
              IconButton(
                  onPressed: () => listener.onUpdate(extension, data, context),
                  icon: Icon(updateIcon)),
            IconButton(
                onPressed: () => onDelete(this.data), icon: Icon(deleteIcon))
          ],
        ),
      ),
    );
  }

  @override
  bool get canEdited =>
      extensionToEnum(data.extension) != ComputerFileExtension.UNKNOWN;

  void onClick(ComputerFileExtension extension, BuildContext context) {
    switch (extension) {
      case ComputerFileExtension.NONE:
        DirectoryHolderWidget.of(context)?.rebuild(this.data);
        break;
      default:
        print(extension);
    }
  }

  void onUpdate(
    ComputerFileExtension extension,
    ComputerFileData data,
    BuildContext context,
  ) {
    if (extension == ComputerFileExtension.TXT) {
      Navigator.of(context)
          .push<String>(FutureLoader(Client.getFileContent(data)))
          .then((value) => {
                print(value),
                if (value != null)
                  {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            TextEditorPage(fileData: data, fileContent: value)))
                  }
              });
    }
  }

  @override
  FileListener get listener =>
      FileListener(onClick: onClick, onUpdate: onUpdate);
}

class ListenerAppBar extends StatefulWidget {
  const ListenerAppBar(
      {Key? key, required this.startValue, required this.controller})
      : super(key: key);
  final bool startValue;
  final TextEditingController controller;
  @override
  _ListenerAppBarState createState() => _ListenerAppBarState();
}

class _ListenerAppBarState extends State<ListenerAppBar> {
  var shouldShowBack = false;
  var searching = false;
  var count = 0;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (widget.controller.text == '' && searching) {
        if (count != 0) {
          setState(() {
            searching = false;
          });
        } else {
          count = 1;
        }
      }
    });
  }

  var focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var currentParentCompData =
        DirectoryHolderWidget.of(context)?.currentDirectoryData;

    shouldShowBack = currentParentCompData?.path != root;

    return AppBar(
      title: Row(children: [
        if (shouldShowBack)
          IconButton(
              onPressed: () {
                final parent = DirectoryHolderWidget.of(context)!;
                parent.rebuild(ComputerFileData.getParentDirectoryData(
                    parent.currentDirectoryData));
              },
              icon: Icon(Icons.arrow_back)),
        Expanded(
            child: searching
                ? TextField(
                    focusNode: focusNode,
                    controller: widget.controller,
                  )
                : Text('Computer Control App')),
        IconButton(
            onPressed: () =>
                setState(() => {searching = true, focusNode.requestFocus()}),
            icon: Icon(Icons.search))
      ]),
    );
  }
}

class DirectoryHolderWidget extends InheritedWidget {
  final ComputerFileData currentDirectoryData;
  final Function(ComputerFileData) rebuild;
  DirectoryHolderWidget(
      {required Widget child,
      required this.currentDirectoryData,
      required this.rebuild})
      : super(child: child);

  @override
  bool updateShouldNotify(covariant DirectoryHolderWidget oldWidget) {
    return this.currentDirectoryData != oldWidget.currentDirectoryData;
  }

  static DirectoryHolderWidget? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DirectoryHolderWidget>();
}

typedef OnClickFile = void Function(
    ComputerFileExtension extension, BuildContext context);
typedef OnUpdateFile = void Function(ComputerFileExtension extension,
    ComputerFileData data, BuildContext context);

class FileListener {
  final OnClickFile onClick;
  final OnUpdateFile onUpdate;
  const FileListener({required this.onClick, required this.onUpdate});
}
