// lib/widgets/prescription_detail_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:medicare_app/pages/prescriptions/prescription_request.dart';
import 'package:medicare_app/theme/text_styles.dart';

class PrescriptionDetailDialog extends StatefulWidget {
  final PrescriptionRequest request;
  const PrescriptionDetailDialog({super.key, required this.request});

  @override
  State<PrescriptionDetailDialog> createState() =>
      _PrescriptionDetailDialogState();
}

class _PrescriptionDetailDialogState extends State<PrescriptionDetailDialog> {
  Future<void> _fakeSaveBarcode() async {
    final barcode = widget.request.barcodeData ?? 'RX-0000000000';

    // 1️⃣ Copia il barcode negli appunti
    await Clipboard.setData(ClipboardData(text: barcode));

    // 2️⃣ Mostra conferma
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Barcode saved to your files',
          style: AppTextStyles.body(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final barcode = widget.request.barcodeData ?? 'RX-0000000000';

    return AlertDialog(
      title: Text(
        'Prescription: ${widget.request.name}',
        style: AppTextStyles.title2(color: Colors.black),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BarcodeWidget(
            data: barcode,
            barcode: Barcode.code128(),
            width: 200,
            height: 80,
            drawText: false,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fakeSaveBarcode,
            icon: const Icon(Icons.copy, color: Colors.white),
            label: Text(
              'Save barcode',
              style: AppTextStyles.buttons(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Close',
            style: AppTextStyles.buttons(color: Colors.deepPurple),
          ),
        ),
      ],
    );
  }
}
