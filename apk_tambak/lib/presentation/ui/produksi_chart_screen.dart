import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/datasources/produksi_remote_datasource.dart';
import '../../domain/entities/kolam_entity.dart';
import '../../main.dart';

class ProduksiChartScreen extends StatefulWidget {
  final KolamEntity kolam;

  const ProduksiChartScreen({super.key, required this.kolam});

  @override
  State<ProduksiChartScreen> createState() => _ProduksiChartScreenState();
}

class _ProduksiChartScreenState extends State<ProduksiChartScreen> {
  bool _isLoading = true;
  String _error = '';
  List<Map<String, dynamic>> _logData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final dataSource = ProduksiRemoteDataSourceImpl(apiClient: globalApiClient);
      final logs = await dataSource.getLogs(widget.kolam.id);
      
      if (mounted) {
        setState(() {
          _logData = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Grafik Pertumbuhan', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error, style: const TextStyle(color: Colors.red)));
    }
    if (_logData.isEmpty) {
      return const Center(child: Text('Belum ada data log pertumbuhan.', style: TextStyle(color: AppColors.textSecondary)));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Mean Body Weight (MBW)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          // Constrained Chart Height
          SizedBox(
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
              ),
              padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 24),
              child: CustomPaint(
                painter: _LineChartPainter(logs: _logData),
                child: Container(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Riwayat Log Harian',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          // Log List
          Expanded(
            child: ListView.builder(
              itemCount: _logData.length,
              itemBuilder: (context, index) {
                final log = _logData[index];
                final dateRaw = log['created_at']?.toString() ?? '-';
                final dateStr = dateRaw.contains('T') ? dateRaw.split('T').first : dateRaw;
                
                final mbw = log['mbw_gram']?.toString() ?? '0';
                final pakan = log['pakan_kg']?.toString() ?? '0';
                final mortality = log['mortality_ekor']?.toString() ?? '0';

                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  shadowColor: Colors.black12,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tanggal: $dateStr', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16.0,
                          runSpacing: 4.0,
                          children: [
                            Text('MBW: $mbw g', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                            Text('Pakan: $pakan Kg', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                            Text('Mati: $mortality Ekor', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                          ],
                        )
                      ],
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

class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> logs;

  _LineChartPainter({required this.logs});

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.isEmpty) return;

    final List<double> data = logs.map((log) {
      final val = log['mbw_gram'];
      if (val == null) return 0.0;
      return double.tryParse(val.toString()) ?? 0.0;
    }).toList();

    final paintLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintGrid = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double maxData = data[0];
    double minData = data[0];
    for (var val in data) {
      if (val > maxData) maxData = val;
      if (val < minData) minData = val;
    }

    maxData = maxData + (maxData * 0.1);
    if (maxData == 0) maxData = 10;
    minData = 0; 

    final leftPadding = 35.0; // Space for Text Axis
    final graphWidth = size.width - leftPadding;
    final pointWidth = graphWidth / (data.length > 1 ? data.length - 1 : 1);

    final int gridLines = 5;
    for (int i = 0; i < gridLines; i++) {
      final y = size.height - (i * (size.height / (gridLines - 1)));
      _drawDashedLine(canvas, Offset(leftPadding, y), Offset(size.width, y), paintGrid);

      // Draw Y-Axis Labels safely
      double labelValue = minData + (i * ((maxData - minData) / (gridLines - 1)));
      final textSpan = TextSpan(
        text: labelValue.toStringAsFixed(0),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: leftPadding - 5);
      textPainter.paint(canvas, Offset(0, y - (textPainter.height / 2)));
    }

    final path = Path();
    List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      final x = leftPadding + (i * pointWidth);
      final ratio = (data[i] - minData) / (maxData - minData);
      final y = size.height - (ratio * size.height);
      points.add(Offset(x, y));
    }

    if (points.length == 1) {
      path.moveTo(leftPadding, points[0].dy);
      path.lineTo(size.width, points[0].dy);
    } else {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        
        final controlPoint1 = Offset(p0.dx + pointWidth / 2, p0.dy);
        final controlPoint2 = Offset(p0.dx + pointWidth / 2, p1.dy);

        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          p1.dx, p1.dy,
        );
      }
    }

    canvas.drawPath(path, paintLine);

    // Gradient Fill bounded correctly
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final paintFill = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.3),
          AppColors.primary.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(leftPadding, 0, graphWidth, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, paintFill);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final dashWidth = 5.0;
    final dashSpace = 5.0;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(Offset(startX, p1.dy), Offset(startX + dashWidth, p1.dy), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
