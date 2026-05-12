import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/analysis_result.dart';

class ResultSection extends StatelessWidget {
  final AnalysisResult result;

  const ResultSection({super.key, required this.result});

  void _downloadJson(BuildContext context) {
    final jsonString = const JsonEncoder.withIndent('  ').convert(result.toJson());

    // Copy JSON to clipboard on all platforms.
    // On web, kIsWeb is true but clipboard still works.
    Clipboard.setData(ClipboardData(text: jsonString));

    final label = kIsWeb
        ? 'JSON listo — pega con Ctrl+V'
        : 'JSON copiado al portapapeles';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2D2D3A)),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF3ECFCF), size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Text(
                'Resultados',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            _DownloadButton(onTap: () => _downloadJson(context)),
          ],
        ),
        const SizedBox(height: 20),

        // ── Text card ───────────────────────────────────────────────
        _ResultCard(
          icon: Icons.text_fields_rounded,
          iconColor: const Color(0xFF6C63FF),
          title: 'Texto extraído',
          child: result.text.isEmpty
              ? _EmptyState(label: 'No se encontró texto')
              : _TextContent(text: result.text),
        ),
        const SizedBox(height: 16),

        // ── Objects card ────────────────────────────────────────────
        _ResultCard(
          icon: Icons.category_rounded,
          iconColor: const Color(0xFF3ECFCF),
          title: 'Objetos detectados',
          child: result.objects.isEmpty
              ? _EmptyState(label: 'No se detectaron objetos')
              : _ObjectsGrid(objects: result.objects),
        ),
      ],
    );
  }
}

// ── Download button ──────────────────────────────────────────────────────────

class _DownloadButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DownloadButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.download_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              'Descargar JSON',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable result card ─────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _ResultCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2D2D3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(
              height: 1, color: const Color(0xFF2D2D3A), indent: 0, endIndent: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── Text content ─────────────────────────────────────────────────────────────

class _TextContent extends StatefulWidget {
  final String text;

  const _TextContent({required this.text});

  @override
  State<_TextContent> createState() => _TextContentState();
}

class _TextContentState extends State<_TextContent> {
  bool _expanded = false;
  static const int _previewLines = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: Text(
            widget.text,
            maxLines: _expanded ? null : _previewLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.fade,
            style: GoogleFonts.sourceCodePro(
              color: const Color(0xFFCBD5E1),
              fontSize: 13,
              height: 1.7,
            ),
          ),
        ),
        if (widget.text.split('\n').length > _previewLines) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Ver menos' : 'Ver más',
              style: GoogleFonts.inter(
                color: const Color(0xFF6C63FF),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Objects grid ─────────────────────────────────────────────────────────────

class _ObjectsGrid extends StatelessWidget {
  final List<String> objects;

  const _ObjectsGrid({required this.objects});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: objects
          .map(
            (obj) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF3ECFCF).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF3ECFCF).withValues(alpha: 0.25)),
              ),
              child: Text(
                obj,
                style: GoogleFonts.inter(
                  color: const Color(0xFF3ECFCF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String label;

  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        color: const Color(0xFF4B5563),
        fontSize: 13,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
