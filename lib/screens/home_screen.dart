import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/vision_provider.dart';
import '../widgets/image_source_sheet.dart';
import '../widgets/result_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 85);
    if (xFile == null) return;

    final bytes = await xFile.readAsBytes();
    if (!context.mounted) return;
    context.read<VisionProvider>().setImage(bytes);
  }

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ImageSourceSheet(
        onCamera: () async {
          Navigator.pop(context);
          await _pickImage(context, ImageSource.camera);
        },
        onGallery: () async {
          Navigator.pop(context);
          await _pickImage(context, ImageSource.gallery);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Consumer<VisionProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              slivers: [
                // ── Header ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.visibility_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'App Vision',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Analiza\ntu imagen',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Extrae texto y detecta objetos al instante.',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6B7280),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Image preview / upload zone ────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: _ImageZone(
                      provider: provider,
                      onTap: () => _showSourceSheet(context),
                    ),
                  ),
                ),

                // ── Analyze button ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: _AnalyzeButton(provider: provider),
                  ),
                ),

                // ── Results ────────────────────────────────────────────
                if (provider.state == AppState.success &&
                    provider.result != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                      child: ResultSection(result: provider.result!),
                    ),
                  ),

                // ── Error ──────────────────────────────────────────────
                if (provider.state == AppState.error)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                      child: _ErrorCard(message: provider.errorMessage ?? ''),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Image drop zone ──────────────────────────────────────────────────────────

class _ImageZone extends StatelessWidget {
  final VisionProvider provider;
  final VoidCallback onTap;

  const _ImageZone({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = provider.imageBytes != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasImage
                ? const Color(0xFF6C63FF).withValues(alpha: 0.6)
                : const Color(0xFF2D2D3A),
            width: 1.5,
          ),
          color: hasImage ? Colors.transparent : const Color(0xFF12121A),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(provider.imageBytes!, fit: BoxFit.cover),
                  // Overlay gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                  // Change image button
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.swap_horiz_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Cambiar',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6C63FF).withValues(alpha: 0.15),
                          const Color(0xFF3ECFCF).withValues(alpha: 0.15),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Color(0xFF6C63FF),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Toca para seleccionar',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cámara o galería',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Analyze button ───────────────────────────────────────────────────────────

class _AnalyzeButton extends StatelessWidget {
  final VisionProvider provider;

  const _AnalyzeButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    final canAnalyze =
        provider.imageBytes != null && provider.state != AppState.loading;

    return AnimatedOpacity(
      opacity: provider.imageBytes != null ? 1.0 : 0.35,
      duration: const Duration(milliseconds: 250),
      child: GestureDetector(
        onTap: canAnalyze ? () => provider.analyze() : null,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: canAnalyze
                ? [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: provider.state == AppState.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Analizar imagen',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Error card ───────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFFF453A).withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFFF453A), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: const Color(0xFFFF7B72),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
