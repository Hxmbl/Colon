import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(), // Default dark theme
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String _currentTime;
  late Timer _timer;
  bool _is24HourFormat = true;
  bool _showSeconds = true;
  bool _showMilliseconds = false;
  double _fontSize = 128;
  Color _backgroundColor = Colors.black;
  Color _textColor = Colors.white;
  String? _backgroundImagePath;
  double _blurIntensity = 0.0;

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (Timer timer) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    });

    // Prevent the device from sleeping
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _timer.cancel();

    // Allow the device to sleep again
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    String time;
    String period = '';

    if (_is24HourFormat) {
      time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
      period = now.hour >= 12 ? 'PM' : 'AM';
      time = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    }

    if (_showSeconds) {
      time += ':${now.second.toString().padLeft(2, '0')}';
    }

    if (_showMilliseconds && _showSeconds) {
      time += '.${now.millisecond.toString().padLeft(3, '0')}';
    }

    return _is24HourFormat ? time : '$time $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Show background image if set
          if (_backgroundImagePath != null)
            Positioned.fill(
              child: Image.file(
                File(_backgroundImagePath!),
                fit: BoxFit.cover, // Adjust the image to cover the entire screen
              ),
            ),
          // Apply blur effect with BackdropFilter if blur intensity is greater than 0
          if (_backgroundImagePath != null && _blurIntensity > 0)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurIntensity,
                  sigmaY: _blurIntensity,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0), // Transparent overlay to enable blur
                ),
              ),
            ),
          // Apply background color if no image is selected
          if (_backgroundImagePath == null)
            Container(
              color: _backgroundColor,
            ),
          // Centered clock text
          Center(
            child: Text(
              _currentTime,
              style: TextStyle(
                fontSize: _fontSize,
                color: _textColor,
              ),
            ),
          ),
          // Settings button in the top-right corner
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Open Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThemeSettingsPage(
                      backgroundColor: _backgroundColor,
                      textColor: _textColor,
                      onBackgroundColorChanged: (color) {
                        setState(() {
                          _backgroundColor = color;
                        });
                      },
                      onTextColorChanged: (color) {
                        setState(() {
                          _textColor = color;
                        });
                      },
                      blurIntensity: _blurIntensity,
                      onBlurIntensityChanged: (value) {
                        setState(() {
                          _blurIntensity = value;
                        });
                      },
                      backgroundImagePath: _backgroundImagePath,
                      onBackgroundImageChanged: (path) {
                        setState(() {
                          _backgroundImagePath = path;
                        });
                      },
                      is24HourFormat: _is24HourFormat,
                      onTimeFormatChanged: (value) {
                        setState(() {
                          _is24HourFormat = value;
                        });
                      },
                      showSeconds: _showSeconds,
                      onShowSecondsChanged: (value) {
                        setState(() {
                          _showSeconds = value;
                          if (!value) {
                            _showMilliseconds = false; // Turn off milliseconds if seconds are off
                          }
                        });
                      },
                      showMilliseconds: _showMilliseconds,
                      onShowMillisecondsChanged: (value) {
                        if (_showSeconds) {
                          setState(() {
                            _showMilliseconds = value;
                          });
                        }
                      },
                      fontSize: _fontSize,
                      onFontSizeChanged: (value) {
                        setState(() {
                          _fontSize = value;
                        });
                      },
                    ),
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

class ThemeSettingsPage extends StatefulWidget {
  final Color backgroundColor;
  final Color textColor;
  final ValueChanged<Color> onBackgroundColorChanged;
  final ValueChanged<Color> onTextColorChanged;
  final double blurIntensity;
  final ValueChanged<double> onBlurIntensityChanged;
  final String? backgroundImagePath;
  final ValueChanged<String?> onBackgroundImageChanged;
  final bool is24HourFormat;
  final ValueChanged<bool> onTimeFormatChanged;
  final bool showSeconds;
  final ValueChanged<bool> onShowSecondsChanged;
  final bool showMilliseconds;
  final ValueChanged<bool> onShowMillisecondsChanged;
  final double fontSize;
  final ValueChanged<double> onFontSizeChanged;

  const ThemeSettingsPage({
    super.key,
    required this.backgroundColor,
    required this.textColor,
    required this.onBackgroundColorChanged,
    required this.onTextColorChanged,
    required this.blurIntensity,
    required this.onBlurIntensityChanged,
    required this.backgroundImagePath,
    required this.onBackgroundImageChanged,
    required this.is24HourFormat,
    required this.onTimeFormatChanged,
    required this.showSeconds,
    required this.onShowSecondsChanged,
    required this.showMilliseconds,
    required this.onShowMillisecondsChanged,
    required this.fontSize,
    required this.onFontSizeChanged,
  });

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  late double _currentBlurIntensity;
  late double _currentFontSize;
  late bool _currentIs24HourFormat;
  late bool _currentShowSeconds;
  late bool _currentShowMilliseconds;
  String? _currentBackgroundImagePath;

  @override
  void initState() {
    super.initState();
    _currentBlurIntensity = widget.blurIntensity; // Initialize with the passed blur intensity
    _currentFontSize = widget.fontSize; // Initialize with the passed font size
    _currentIs24HourFormat = widget.is24HourFormat; // Initialize with the passed 24-hour format
    _currentShowSeconds = widget.showSeconds; // Initialize with the passed show seconds
    _currentShowMilliseconds = widget.showMilliseconds; // Initialize with the passed show milliseconds
    _currentBackgroundImagePath = widget.backgroundImagePath; // Initialize with the passed background image
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _currentBackgroundImagePath = image.path; // Update the local state
      });
      widget.onBackgroundImageChanged(image.path); // Notify the parent widget
    }
  }

  void _clearImage() {
    setState(() {
      _currentBackgroundImagePath = null; // Clear the local state
    });
    widget.onBackgroundImageChanged(null); // Notify the parent widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0), // Add padding for better spacing
        children: [
          // Background Color Setting
          ListTile(
            title: const Text('Background Color'),
            trailing: ElevatedButton(
              onPressed: () {
                _pickColor(context, widget.backgroundColor, widget.onBackgroundColorChanged);
              },
              child: const Text('Pick Color'),
            ),
          ),
          // Text Color Setting
          ListTile(
            title: const Text('Text Color'),
            trailing: ElevatedButton(
              onPressed: () {
                _pickColor(context, widget.textColor, widget.onTextColorChanged);
              },
              child: const Text('Pick Color'),
            ),
          ),
          // Background Image Setting
          ListTile(
            title: const Text('Background Image'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Select Image'),
                ),
                if (_currentBackgroundImagePath != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Clear Image',
                    onPressed: _clearImage,
                  ),
              ],
            ),
          ),
          // Blur Intensity Setting (only show if an image is selected)
          if (_currentBackgroundImagePath != null)
            ListTile(
              title: const Text('Blur Intensity'),
              subtitle: Slider(
                value: _currentBlurIntensity,
                min: 0.0,
                max: 20.0, // Increased maximum blur intensity
                divisions: 40,
                label: _currentBlurIntensity.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _currentBlurIntensity = value; // Update the local state
                  });
                  widget.onBlurIntensityChanged(value); // Notify the parent widget
                },
              ),
            ),
          // Toggle 24/12 Hour Format
          ListTile(
            title: const Text('Toggle 24/12 Hour Format'),
            trailing: Switch(
              value: _currentIs24HourFormat,
              onChanged: (value) {
                setState(() {
                  _currentIs24HourFormat = value; // Update the local state
                });
                widget.onTimeFormatChanged(value); // Notify the parent widget
              },
            ),
          ),
          // Show Seconds
          ListTile(
            title: const Text('Show Seconds'),
            trailing: Switch(
              value: _currentShowSeconds,
              onChanged: (value) {
                setState(() {
                  _currentShowSeconds = value; // Update the local state
                  if (!value) {
                    _currentShowMilliseconds = false; // Turn off milliseconds if seconds are off
                  }
                });
                widget.onShowSecondsChanged(value); // Notify the parent widget
              },
            ),
          ),
          // Show Milliseconds
          ListTile(
            title: const Text('Show Milliseconds'),
            trailing: Switch(
              value: _currentShowMilliseconds,
              onChanged: (value) {
                if (_currentShowSeconds) {
                  setState(() {
                    _currentShowMilliseconds = value; // Update the local state
                  });
                  widget.onShowMillisecondsChanged(value); // Notify the parent widget
                }
              },
            ),
          ),
          // Font Size Slider
          ListTile(
            title: const Text('Font Size'),
            subtitle: Slider(
              value: _currentFontSize,
              min: 50,
              max: 200,
              divisions: 15,
              label: _currentFontSize.round().toString(),
              onChanged: (value) {
                setState(() {
                  _currentFontSize = value; // Update the local state
                });
                widget.onFontSizeChanged(value); // Notify the parent widget
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pickColor(BuildContext context, Color currentColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
