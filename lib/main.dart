import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:js' as js;

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Task', home: const HomePage());
  }
}

/// [Widget] displaying the home page consisting of an image the the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  var renderOverlay = true;
  var visible = true;
  var switchLabelPosition = false;
  var extend = false;
  var mini = false;
  var rmicons = false;
  var customDialRoot = false;
  var closeManually = false;
  var useRAnimation = true;
  var isDialOpen = ValueNotifier<bool>(false);
  var speedDialDirection = SpeedDialDirection.up;
  var buttonSize = const Size(56.0, 56.0);
  var childrenButtonSize = const Size(56.0, 56.0);

  String? imageUrl;
  bool isFullScreenImage = false;
  final TextEditingController urlController = TextEditingController();

  void toggleImageFullScreen() {
    js.context.callMethod("toggleFullScreenImage", [imageUrl]);
  }

  @override
  Widget build(BuildContext context) {
    String htmlContent = """
  <div style="width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; overflow: hidden;">
    <img src="$imageUrl" alt="Image">
  </div>
""";
    return Scaffold(
      appBar: AppBar(),
      body: imageUrl != null && isFullScreenImage
          ? SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Html(
                  data: htmlContent,
                  style: {
                    "div": Style(
                      width: Width(100, Unit.auto),
                      height: Height(100, Unit.auto),
                      display: Display.block,
                      alignment: Alignment.center,
                    ),
                  },
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: imageUrl != null
                        ? InkWell(
                            onDoubleTap: toggleImageFullScreen,
                            child: Html(
                              data: htmlContent,
                              shrinkWrap: true,
                              style: {
                                "div": Style(
                                  width: Width(500, Unit.percent), // Full width
                                  height:
                                      Height(500, Unit.percent), // Full height
                                  display: Display.block,
                                  alignment: Alignment.center,
                                ),
                              },
                            ),
                          )
                        : AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: urlController,
                          decoration: InputDecoration(hintText: 'Image URL'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            imageUrl = urlController.value.text.toString();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                          child: Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        mini: mini,
        openCloseDial: isDialOpen,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        dialRoot: customDialRoot
            ? (ctx, open, toggleChildren) {
                return ElevatedButton(
                  onPressed: toggleChildren,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 18),
                  ),
                  child: const Text(
                    "Custom Dial Root",
                    style: TextStyle(fontSize: 17),
                  ),
                );
              }
            : null,
        buttonSize: buttonSize,
        label: extend ? const Text("Open") : null,
        activeLabel: extend ? const Text("Close") : null,
        childrenButtonSize: childrenButtonSize,
        visible: visible,
        direction: speedDialDirection,
        switchLabelPosition: switchLabelPosition,
        closeManually: closeManually,
        renderOverlay: renderOverlay,
        useRotationAnimation: useRAnimation,
        elevation: 8.0,
        animationCurve: Curves.elasticInOut,
        isOpenOnStart: false,
        shape: customDialRoot
            ? const RoundedRectangleBorder()
            : const StadiumBorder(),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.fullscreen),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            label: 'Enter fullscreen',
            onTap: () {
              setState(() {
                isFullScreenImage = true;
              });
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.fullscreen_exit),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            label: 'Exit fullscreen',
            onTap: () {
              setState(() {
                isFullScreenImage = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
