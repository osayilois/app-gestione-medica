// lib/util/pdf_generator.dart (o dove lo tieni)
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';

class PdfResult {
  final Uint8List data;
  final String barcodeData;
  PdfResult({required this.data, required this.barcodeData});
}

Future<PdfResult> generatePrescriptionPdfData({
  required String patientName,
  required String medicineOrVisit,
  required String dosageOrDetails,
}) async {
  final pdf = pw.Document();

  // Generiamo un codice univoco: RX-{timestamp}
  final barcodeData = 'RX-${DateTime.now().millisecondsSinceEpoch}';
  final barcode = Barcode.code128();
  final barcodeSvg = barcode.toSvg(barcodeData, width: 200, height: 80);

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Medical Prescription',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Patient: $patientName'),
            pw.Text('Medication/Visit: $medicineOrVisit'),
            pw.Text('Details: $dosageOrDetails'),
            pw.SizedBox(height: 32),
            pw.Text('Prescription barcode:', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 8),
            pw.SvgImage(svg: barcodeSvg),
          ],
        );
      },
    ),
  );

  final data = await pdf.save();
  return PdfResult(data: data, barcodeData: barcodeData);
}
