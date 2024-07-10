import 'dart:io';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewPdfFileOffline extends StatefulWidget {
  const ViewPdfFileOffline(
      {super.key, required this.path, required this.name, this.pageNo});

  final String path;
  final String name;
  final int? pageNo;

  @override
  State<ViewPdfFileOffline> createState() => _ViewPdfFileOfflineState();
}

class _ViewPdfFileOfflineState extends State<ViewPdfFileOffline> {
  late PdfViewerController _pdfViewerController;
  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.path);
    return Scaffold(
      appBar: MyAppBar(
        title: widget.name,
      ),
      body: SfPdfViewer.file(
        File(widget.path),
        controller: _pdfViewerController,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          if (widget.pageNo != null) {
            _pdfViewerController.jumpToPage(widget.pageNo!);
          }
        },
      ),
    );
  }
}
