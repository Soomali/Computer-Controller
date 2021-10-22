import 'package:flutter/material.dart';
import 'package:server_app/client.dart';
import 'package:server_app/entities.dart';
import 'package:server_app/loadingIndicator.dart';

class TextEditorPage extends StatelessWidget {
  final ComputerFileData fileData;
  final String fileContent;
  const TextEditorPage(
      {Key? key, required this.fileData, required this.fileContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: fileContent);
    return Scaffold(
      appBar: AppBar(
          title: ControllerListener(
        data: fileData,
        controller: controller,
        valueBefore: fileContent,
      )),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.only(top: 25),
              child:
                  Align(alignment: Alignment.center, child: Text('$fileData'))),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: FileEditWidget(
                controller: controller,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ControllerListener extends StatefulWidget {
  final String valueBefore;
  final TextEditingController controller;
  final ComputerFileData data;
  const ControllerListener({
    Key? key,
    required this.data,
    required this.valueBefore,
    required this.controller,
  }) : super(key: key);

  @override
  _ControllerListenerState createState() => _ControllerListenerState();
}

class _ControllerListenerState extends State<ControllerListener> {
  late TextEditingController controller;
  @override
  void initState() {
    super.initState();

    controller = widget.controller;
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('Editing Texts')),
        if (controller.text != widget.valueBefore)
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(FutureLoader(
                      Client.updateFileContent(widget.data, controller.text)))
                  .then((value) => Navigator.of(context).pop()),
              icon: Icon(Icons.edit))
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}

class FileEditWidget extends StatefulWidget {
  final TextEditingController controller;
  const FileEditWidget({
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  _FileEditWidgetState createState() => _FileEditWidgetState();
}

class _FileEditWidgetState extends State<FileEditWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: null,
      controller: widget.controller,
      decoration: InputDecoration(),
    );
  }
}
