import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late SharedPreferences _prefs;
  bool _is24HourFormat = true;
  bool _showSeconds = true;
  bool _showMilliseconds = false;
  double _fontSize = 128; // Time font size
  double _millisecondsFontSize = 64; // Milliseconds font size
  double _dateFontSize = 32; // Date font size
  double _amPmFontSize = 32; // AM/PM font size
  Color _backgroundColor = Colors.black;
  Color _textColor = Colors.white;
  String? _backgroundImagePath = null; // Default to no image
  double _blurIntensity = 0.0;
  double _textHeight = 0.5; // Default height (centered vertically)


  @override
  void initState() {
    super.initState();
    _loadSettings();
    _currentTime = _getCurrentTime();
    _timer = Timer.periodic(const Duration(milliseconds: 1), (Timer timer) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    });

    // Prevent the device from sleeping
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _textHeight = _prefs.getDouble('textHeight') ?? 0.5; // Default to center
      _is24HourFormat = _prefs.getBool('is24HourFormat') ?? true;
      _showSeconds = _prefs.getBool('showSeconds') ?? true;
      _showMilliseconds = _prefs.getBool('showMilliseconds') ?? false;
      _fontSize = _prefs.getDouble('fontSize') ?? 128;
      _millisecondsFontSize = _prefs.getDouble('millisecondsFontSize') ?? 64;
      _dateFontSize = _prefs.getDouble('dateFontSize') ?? 32;
      _amPmFontSize = _prefs.getDouble('amPmFontSize') ?? 32;
      _backgroundColor = Color(_prefs.getInt('backgroundColor') ?? Colors.black.value);
      _textColor = Color(_prefs.getInt('textColor') ?? Colors.white.value);
      _backgroundImagePath = _prefs.getString('backgroundImagePath');
      _blurIntensity = _prefs.getDouble('blurIntensity') ?? 0.0;
    });
  }

  void _saveSetting(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    }
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

    // Format the date
    final dayOfWeek = [' Sun', ' Mon', ' Tue', ' Wed', ' Thu', ' Fri', ' Sat'][now.weekday % 7];
    final month = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ][now.month - 1];
    final date = '$dayOfWeek ${now.day} $month ${now.year}';

    // Format the time
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

    // Append milliseconds only if enabled
    final milliseconds = _showMilliseconds ? '.${now.millisecond.toString().padLeft(3, '0')}' : '';

    // Return the formatted string
    return _is24HourFormat
        ? '$date|$time$milliseconds'
        : '$date|$time$milliseconds|$period';
  }
  
  @override
  Widget build(BuildContext context) {
    final parts = _currentTime.split('|'); // Split date, time, and AM/PM
    final date = parts[0];
    final time = parts[1].split('.')[0]; // Extract time without milliseconds
    final milliseconds = parts[1].contains('.') ? parts[1].split('.')[1] : ''; // Extract milliseconds
    final amPm = parts.length > 2 ? parts[2] : '';

    return Scaffold(
      body: Stack(
        children: [
          if (_backgroundImagePath == null)
            Container(
              color: _backgroundColor == Colors.black ? Colors.grey[850] : _backgroundColor,
            )
          else
            Positioned.fill(
              child: Image.file(
                File(_backgroundImagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[850], // Fallback to default color
                    child: Center(
                      child: Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          // Apply blur effect with BackdropFilter if blur intensity is greater than 0
          if (_backgroundImagePath != null && _blurIntensity > 0)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurIntensity / 2, // Reduce blur intensity
                  sigmaY: _blurIntensity / 2,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.2), // Reduce overlay opacity
                ),
              ),
            ),
          // Centered clock text
          Positioned(
            top: MediaQuery.of(context).size.height * _textHeight,
            left: 16.0, // Always align to the left
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date, // Display the date
                  style: TextStyle(
                    fontSize: _dateFontSize,
                    color: _textColor,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: time, // Main time without milliseconds
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: _textColor,
                    ),
                    children: [
                      if (_showMilliseconds)
                        TextSpan(
                          text: '.$milliseconds', // Milliseconds
                          style: TextStyle(
                            fontSize: _millisecondsFontSize,
                            color: _textColor,
                          ),
                        ),
                      if (!_is24HourFormat && amPm.isNotEmpty)
                        TextSpan(
                          text: ' $amPm', // AM/PM
                          style: TextStyle(
                            fontSize: _amPmFontSize,
                            color: _textColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
                      textHeight: _textHeight,
                      onTextHeightChanged: (value) {
                        setState(() {
                          _textHeight = value;
                          _saveSetting('textHeight', value);
                        });
                      },
                      backgroundColor: _backgroundColor,
                      textColor: _textColor,
                      onBackgroundColorChanged: (color) {
                        setState(() {
                          _backgroundColor = color;
                          _saveSetting('backgroundColor', color.value);
                        });
                      },
                      onTextColorChanged: (color) {
                        setState(() {
                          _textColor = color;
                          _saveSetting('textColor', color.value);
                        });
                      },
                      blurIntensity: _blurIntensity,
                      onBlurIntensityChanged: (value) {
                        setState(() {
                          _blurIntensity = value;
                          _saveSetting('blurIntensity', value);
                        });
                      },
                      backgroundImagePath: _backgroundImagePath,
                      onBackgroundImageChanged: (path) {
                        setState(() {
                          _backgroundImagePath = path;
                          _saveSetting('backgroundImagePath', path ?? '');
                        });
                      },
                      is24HourFormat: _is24HourFormat,
                      onTimeFormatChanged: (value) {
                        setState(() {
                          _is24HourFormat = value;
                          _saveSetting('is24HourFormat', value);
                        });
                      },
                      showSeconds: _showSeconds,
                      onShowSecondsChanged: (value) {
                        setState(() {
                          _showSeconds = value;
                          _saveSetting('showSeconds', value);
                          if (!value) {
                            _showMilliseconds = false; // Turn off milliseconds if seconds are off
                            _saveSetting('showMilliseconds', false);
                          }
                        });
                      },
                      showMilliseconds: _showMilliseconds,
                      onShowMillisecondsChanged: (value) {
                        if (_showSeconds) {
                          setState(() {
                            _showMilliseconds = value;
                            _saveSetting('showMilliseconds', value);
                          });
                        }
                      },
                      fontSize: _fontSize,
                      onFontSizeChanged: (value) {
                        setState(() {
                          _fontSize = value;
                          _saveSetting('fontSize', value);
                        });
                      },
                      millisecondsFontSize: _millisecondsFontSize,
                      onMillisecondsFontSizeChanged: (value) {
                        setState(() {
                          _millisecondsFontSize = value;
                          _saveSetting('millisecondsFontSize', value);
                        });
                      },
                      dateFontSize: _dateFontSize,
                      onDateFontSizeChanged: (value) {
                        setState(() {
                          _dateFontSize = value;
                          _saveSetting('dateFontSize', value);
                        });
                      },
                      amPmFontSize: _amPmFontSize,
                      onAmPmFontSizeChanged: (value) {
                        setState(() {
                          _amPmFontSize = value;
                          _saveSetting('amPmFontSize', value);
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
  final double millisecondsFontSize;
  final ValueChanged<double> onMillisecondsFontSizeChanged;
  final double dateFontSize;
  final ValueChanged<double> onDateFontSizeChanged;
  final double amPmFontSize;
  final ValueChanged<double> onAmPmFontSizeChanged;
  final double textHeight;
  final ValueChanged<double> onTextHeightChanged;

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
    required this.millisecondsFontSize,
    required this.onMillisecondsFontSizeChanged,
    required this.dateFontSize,
    required this.onDateFontSizeChanged,
    required this.amPmFontSize,
    required this.onAmPmFontSizeChanged,
    required this.textHeight,
    required this.onTextHeightChanged,
  });

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  late double _currentBlurIntensity;
  late double _currentFontSize;
  late double _currentMillisecondsFontSize;
  late double _currentDateFontSize;
  late double _currentAmPmFontSize;
  late bool _currentIs24HourFormat;
  late bool _currentShowSeconds;
  late bool _currentShowMilliseconds;
  late double _currentTextHeight;
  String? _currentBackgroundImagePath;

  @override
  void initState() {
    super.initState();
    _currentBlurIntensity = widget.blurIntensity;
    _currentFontSize = widget.fontSize;
    _currentMillisecondsFontSize = widget.millisecondsFontSize;
    _currentDateFontSize = widget.dateFontSize;
    _currentAmPmFontSize = widget.amPmFontSize;
    _currentIs24HourFormat = widget.is24HourFormat;
    _currentShowSeconds = widget.showSeconds;
    _currentShowMilliseconds = widget.showMilliseconds;
    _currentTextHeight = widget.textHeight;
    _currentBackgroundImagePath = widget.backgroundImagePath;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _currentBackgroundImagePath = image.path;
      });
      widget.onBackgroundImageChanged(image.path);
    }
  }

  void _clearImage() {
    setState(() {
      _currentBackgroundImagePath = null;
    });
    widget.onBackgroundImageChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
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
          // Blur Intensity Setting
          if (_currentBackgroundImagePath != null)
            ListTile(
              title: const Text('Blur Intensity'),
              subtitle: Slider(
                value: _currentBlurIntensity,
                min: 0.0,
                max: 20.0,
                divisions: 40,
                label: _currentBlurIntensity.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _currentBlurIntensity = value;
                  });
                  widget.onBlurIntensityChanged(value);
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
                  _currentIs24HourFormat = value;
                });
                widget.onTimeFormatChanged(value);
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
                  _currentShowSeconds = value;
                  if (!value) {
                    _currentShowMilliseconds = false;
                  }
                });
                widget.onShowSecondsChanged(value);
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
                    _currentShowMilliseconds = value;
                  });
                  widget.onShowMillisecondsChanged(value);
                }
              },
            ),
          ),
          // Number Size Slider
          ListTile(
            title: const Text('Number Font Size'),
            subtitle: Slider(
              value: _currentFontSize,
              min: 50,
              max: 200,
              divisions: 15,
              label: _currentFontSize.round().toString(),
              onChanged: (value) {
                setState(() {
                  _currentFontSize = value;
                });
                widget.onFontSizeChanged(value);
              },
            ),
          ),
          // Milliseconds Font Size Slider
          ListTile(
            title: const Text('Milliseconds Font Size'),
            subtitle: Slider(
              value: _currentMillisecondsFontSize,
              min: 20,
              max: 100,
              divisions: 8,
              label: _currentMillisecondsFontSize.round().toString(),
              onChanged: (value) {
                setState(() {
                  _currentMillisecondsFontSize = value;
                });
                widget.onMillisecondsFontSizeChanged(value);
              },
            ),
          ),
          // Date Font Size Slider
          ListTile(
            title: const Text('Date Font Size'),
            subtitle: Slider(
              value: _currentDateFontSize,
              min: 20,
              max: 100,
              divisions: 8,
              label: _currentDateFontSize.round().toString(),
              onChanged: (value) {
                setState(() {
                  _currentDateFontSize = value;
                });
                widget.onDateFontSizeChanged(value);
              },
            ),
          ),
          // AM/PM Font Size Slider
          ListTile(
            title: const Text('AM/PM Font Size'),
            subtitle: Slider(
              value: _currentAmPmFontSize,
              min: 20,
              max: 100,
              divisions: 8,
              label: _currentAmPmFontSize.round().toString(),
              onChanged: (value) {
                setState(() {
                  _currentAmPmFontSize = value;
                });
                widget.onAmPmFontSizeChanged(value);
              },
            ),
          ),
          // Text Height Slider
          ListTile(
            title: const Text('Text Height'),
            subtitle: Slider(
              value: _currentTextHeight,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              label: (_currentTextHeight * 100).round().toString() + '%',
              onChanged: (value) {
                setState(() {
                  _currentTextHeight = value;
                });
                widget.onTextHeightChanged(value);
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
