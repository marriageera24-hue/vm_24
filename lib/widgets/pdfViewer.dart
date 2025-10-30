import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart'; // Import the package

class PdfViewerDialogContent extends StatelessWidget {
  final String pdfUrl;

  const PdfViewerDialogContent({required this.pdfUrl, super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Define the Controller
    final PdfController pdfController = PdfController(
      document: PdfDocument.openAsset(pdfUrl), // Loads PDF from the 'assets/' path
    );

    // 2. Define the size of the PDF viewer within the dialog
    // We use a FractionallySizedBox to ensure the PDF viewer takes up a
    // reasonable portion of the dialog, making it easy to read.
    return FractionallySizedBox(
      heightFactor: 0.8, // Take 80% of the available vertical space in the dialog
      child: PdfView(
        controller: pdfController,
        // Optional: Add a loading indicator while the PDF loads
        onDocumentLoaded: (document) => const Center(child: Text("Loading PDF...")),
        // Optional: Customize page orientation, scroll, etc.
        // scrollDirection: Axis.vertical,
      ),
    );
  }
}