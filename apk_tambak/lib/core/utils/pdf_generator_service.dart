import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGeneratorService {
  static Future<void> generateAndPrintKolamReport(Map<String, dynamic> data) async {
    final doc = pw.Document();
    
    final kolam = data['kolam'];
    final summary = data['summary'];
    final List<dynamic> history = data['history'];

    final tealColor = PdfColor.fromHex('#008375');
    
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('LAPORAN SIKLUS TAMBAK', style: pw.TextStyle(color: tealColor, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Pengmas 2026', style: pw.TextStyle(color: PdfColors.grey700, fontSize: 14)),
                ]
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Kolam Details
            pw.Text('Kolam: ${kolam['nama_kolam']}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Target Panen: ${kolam['target_panen']}', style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            
            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: tealColor),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Total Pakan', '${summary['total_pakan_kg']} Kg'),
                  _buildSummaryItem('Total Panen', '${summary['total_panen_kg']} Kg'),
                  _buildSummaryItem('MBW Terakhir', '${summary['latest_mbw_gram']} gr'),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            
            // History Table
            pw.Text('Riwayat Log Harian', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: tealColor)),
            pw.SizedBox(height: 10),
            
            pw.TableHelper.fromTextArray(
              headers: ['Tanggal', 'Suhu (°C)', 'pH', 'DO', 'TDS', 'MBW (gr)'],
              data: history.map((e) => [
                e['tanggal'],
                e['suhu'].toString(),
                e['ph'].toString(),
                e['do'].toString(),
                e['tds'].toString(),
                e['mbw_gram'].toString()
              ]).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: tealColor),
              cellAlignment: pw.Alignment.center,
            ),
          ];
        },
      )
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Laporan_Kolam_${kolam['nama_kolam']}.pdf',
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      ]
    );
  }
}
