import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:ayurvedic_doctor_crm/models/patient.dart';
import 'package:ayurvedic_doctor_crm/models/treatment.dart';
import 'package:ayurvedic_doctor_crm/models/medicine.dart';

class PdfService {
  static const String _clinicName = 'Ayurvedic Wellness Clinic';
  static const String _doctorName = 'Dr. Ayurveda Specialist';
  static const String _clinicAddress = '123 Wellness Street, Health City, HC 12345';
  static const String _clinicPhone = '+91 98765 43210';
  static const String _clinicEmail = 'info@ayurvedicwellness.com';

  // Generate treatment report PDF
  static Future<File> generateTreatmentReport({
    required Patient patient,
    required Treatment treatment,
  }) async {
    final pdf = pw.Document();

    // Load font for better text rendering
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(font, fontBold),
            pw.SizedBox(height: 20),
            _buildPatientInfo(patient, font, fontBold),
            pw.SizedBox(height: 20),
            _buildTreatmentDetails(treatment, font, fontBold),
            pw.SizedBox(height: 20),
            _buildPrescribedMedicines(treatment.prescribedMedicines, font, fontBold),
            if (treatment.notes != null && treatment.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildNotes(treatment.notes!, font, fontBold),
            ],
            pw.SizedBox(height: 40),
            _buildFooter(treatment, font, fontBold),
          ];
        },
      ),
    );

    // Save PDF to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'treatment_report_${patient.fullName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(treatment.visitDate)}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Generate patient history report PDF
  static Future<File> generatePatientHistoryReport({
    required Patient patient,
    required List<Treatment> treatments,
  }) async {
    final pdf = pw.Document();

    // Load font for better text rendering
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(font, fontBold),
            pw.SizedBox(height: 20),
            _buildPatientHistoryHeader(patient, font, fontBold),
            pw.SizedBox(height: 20),
            _buildPatientInfo(patient, font, fontBold),
            pw.SizedBox(height: 20),
            _buildTreatmentHistory(treatments, font, fontBold),
            pw.SizedBox(height: 40),
            _buildHistoryFooter(font, fontBold),
          ];
        },
      ),
    );

    // Save PDF to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'patient_history_${patient.fullName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildHeader(pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _clinicName,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 24,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _doctorName,
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
              color: PdfColors.green700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      _clinicAddress,
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                    pw.Text(
                      'Phone: $_clinicPhone',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                    pw.Text(
                      'Email: $_clinicEmail',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPatientHistoryHeader(Patient patient, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'PATIENT HISTORY REPORT',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 20,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.blue600,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPatientInfo(Patient patient, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PATIENT INFORMATION',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 16,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Name:', patient.fullName, font, fontBold),
                    _buildInfoRow('Gender:', patient.gender, font, fontBold),
                    _buildInfoRow('Age:', '${patient.displayAge} years', font, fontBold),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (patient.phone != null)
                      _buildInfoRow('Phone:', patient.phone!, font, fontBold),
                    if (patient.email != null)
                      _buildInfoRow('Email:', patient.email!, font, fontBold),
                    if (patient.dateOfBirth != null)
                      _buildInfoRow(
                        'Date of Birth:',
                        DateFormat('dd/MM/yyyy').format(patient.dateOfBirth!),
                        font,
                        fontBold,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (patient.address != null) ...[
            pw.SizedBox(height: 8),
            _buildInfoRow('Address:', patient.address!, font, fontBold),
          ],
          if (patient.medicalHistory != null && patient.medicalHistory!.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _buildInfoRow('Medical History:', patient.medicalHistory!, font, fontBold),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildTreatmentDetails(Treatment treatment, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TREATMENT DETAILS',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 16,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildInfoRow(
            'Visit Date:',
            DateFormat('dd MMMM yyyy').format(treatment.visitDate),
            font,
            fontBold,
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow('Symptoms:', treatment.symptoms, font, fontBold),
          pw.SizedBox(height: 8),
          _buildInfoRow('Diagnosis:', treatment.diagnosis, font, fontBold),
        ],
      ),
    );
  }

  static pw.Widget _buildPrescribedMedicines(List<Medicine> medicines, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PRESCRIBED MEDICINES',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 16,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          if (medicines.isEmpty)
            pw.Text(
              'No medicines prescribed',
              style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey600),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(2),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _buildTableCell('Medicine Name', fontBold, isHeader: true),
                    _buildTableCell('Type', fontBold, isHeader: true),
                    _buildTableCell('Dosage', fontBold, isHeader: true),
                    _buildTableCell('Duration', fontBold, isHeader: true),
                    _buildTableCell('Notes', fontBold, isHeader: true),
                  ],
                ),
                // Medicine rows
                ...medicines.map((medicine) => pw.TableRow(
                  children: [
                    _buildTableCell(medicine.name, font),
                    _buildTableCell(medicine.typeDisplayName, font),
                    _buildTableCell(medicine.dosage, font),
                    _buildTableCell(medicine.duration, font),
                    _buildTableCell(medicine.notes ?? '-', font),
                  ],
                )),
              ],
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildTreatmentHistory(List<Treatment> treatments, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TREATMENT HISTORY',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 16,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          if (treatments.isEmpty)
            pw.Text(
              'No treatment records found',
              style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey600),
            )
          else
            ...treatments.map((treatment) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Visit: ${DateFormat('dd MMM yyyy').format(treatment.visitDate)}',
                    style: pw.TextStyle(font: fontBold, fontSize: 14),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Symptoms: ${treatment.symptoms}',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Diagnosis: ${treatment.diagnosis}',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                  if (treatment.prescribedMedicines.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Medicines: ${treatment.prescribedMedicines.map((m) => m.name).join(', ')}',
                      style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.blue600),
                    ),
                  ],
                ],
              ),
            )),
        ],
      ),
    );
  }

  static pw.Widget _buildNotes(String notes, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ADDITIONAL NOTES',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 16,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            notes,
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(Treatment treatment, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Doctor\'s Signature',
                  style: pw.TextStyle(font: fontBold, fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  _doctorName,
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Report Generated',
                  style: pw.TextStyle(font: fontBold, fontSize: 12),
                ),
                pw.Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
                  style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildHistoryFooter(pw.Font font, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Doctor\'s Signature',
                  style: pw.TextStyle(font: fontBold, fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  _doctorName,
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Report Generated',
                  style: pw.TextStyle(font: fontBold, fontSize: 12),
                ),
                pw.Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
                  style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: fontBold, fontSize: 12),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // Share PDF file
  static Future<void> sharePdf(File pdfFile) async {
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      text: 'Treatment Report',
    );
  }

  // Print PDF file
  static Future<void> printPdf(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
    );
  }
}

