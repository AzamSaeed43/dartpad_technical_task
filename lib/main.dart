import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
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
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Task',
        home: const HomePage());
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

  late html.DivElement imageContainer;

  late String viewType;

  @override
  void initState() {
    super.initState();
    setupHtmlElement();
  }

  void setupHtmlElement() {
    viewType = "web-image-element-${DateTime.now().millisecondsSinceEpoch}";

    // Register the HTML element with Flutter's view registry
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final div = html.DivElement()
        ..style.width = "100%"
        ..style.height = "100%"
        ..setInnerHtml("""
        <div id="image-container" style="width: 100%; height: 100%; display: flex; align-items: center; justify-content: center;">
          <img id="custom-image" src="${imageUrl}" alt="Image"
               style="cursor: pointer; max-width: 100%; max-height: 100%;">
        </div>
      """, treeSanitizer: html.NodeTreeSanitizer.trusted);

      return div;
    });
  }

  void runJavaScript() {
    js.context.callMethod("eval", [
      """
      (function() {
        document.addEventListener("DOMContentLoaded", function() {
          var image = document.getElementById("custom-image");
          if (image) {
            image.oncontextmenu = function(event) {
              console.log("Right-click detected on image");
            };
          }
        });
      })();
    """
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: imageUrl != null && isFullScreenImage
          ? Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: HtmlElementView(viewType: viewType),
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
                            child: HtmlElementView(viewType: viewType))
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
