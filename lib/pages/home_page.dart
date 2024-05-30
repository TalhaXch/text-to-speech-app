import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:typed_data';
import 'dart:io';
import 'speak_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Text to Speech',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey; // Disabled color
                }
                return Color(0xFF64B5F6); // Default color
              },
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.white; // Disabled text color
                }
                return Colors.white; // Default text color
              },
            ),
            padding: MaterialStateProperty.all<EdgeInsets>(
              EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0), // Button padding
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(
              TextStyle(fontSize: 18.0), // Button text style
            ),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // Button border radius
              ),
            ),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      String text = await extractTextFromPDF(filePath);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpeakPage(extractedText: text),
        ),
      );
    }
  }

  Future<String> extractTextFromPDF(String filePath) async {
    // Read the PDF document.
    final Uint8List bytes = File(filePath).readAsBytesSync();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    // Extract text from all the pages.
    String extractedText = '';
    for (int i = 0; i < document.pages.count; i++) {
      final PdfPage page = document.pages[i];
      extractedText += PdfTextExtractor(document).extractText();
    }

    return extractedText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Text to Speech'),
        backgroundColor: Color(0xFF455A64), // App bar color
      ),
      body: Stack(
        children: [
          // Background animation
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF64B5F6),
                    Color(0xFF1976D2),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: pickPDF,
              child: Text('Pick PDF'),
            ),
          ),
        ],
      ),
    );
  }
}
