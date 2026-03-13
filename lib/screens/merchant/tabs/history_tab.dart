import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../config/theme.dart';
import '../../../services/app_state.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/glass_card.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (SupabaseService.user != null) {
      final data = await SupabaseService.loadResponseHistory();
      if (mounted) {
        setState(() {
          _history = data;
          _loading = false;
        });
      }
    } else {
      setState(() {
        _history = [];
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _displayHistory {
    return _history;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final history = _displayHistory;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.t('historyTitle'),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appState.t('historySubtitle'),
                      style: TextStyle(fontSize: 14, color: AppColors.slate400),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        hintStyle: TextStyle(color: AppColors.slate600),
                        filled: true,
                        fillColor: AppColors.slate800,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Export PDF bientôt disponible — fonctionnalité en développement'),
                            backgroundColor: AppColors.slate800,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      icon: const FaIcon(FontAwesomeIcons.filePdf, size: 12),
                      label: const Text('PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppColors.brand),
            ))
          else ...[
            // History list
            ...history.map((entry) {
              final author = (entry['author_name'] ?? entry['author'] ?? '') as String;
              final response = (entry['response_text'] ?? entry['response'] ?? '') as String;
              final search = _searchController.text.toLowerCase();
              if (search.isNotEmpty &&
                  !author.toLowerCase().contains(search) &&
                  !response.toLowerCase().contains(search)) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HistoryCard(entry: entry),
              );
            }),

            if (history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    'Aucune réponse publiée pour le moment',
                    style: TextStyle(color: AppColors.slate500),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> entry;

  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final rating = (entry['rating'] as num?)?.toInt() ?? 0;
    final author = (entry['author_name'] ?? entry['author'] ?? '') as String;
    final response = (entry['response_text'] ?? entry['response'] ?? '') as String;
    final date = (entry['created_at'] ?? entry['date'] ?? '') as String;
    final published = entry['published'] == true;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                author,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 1),
                    child: FaIcon(
                      FontAwesomeIcons.solidStar,
                      size: 10,
                      color: i < rating ? const Color(0xFFFACC15) : AppColors.slate700,
                    ),
                  );
                }),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (published ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  published ? 'Publiée' : 'Brouillon',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: published ? AppColors.success : AppColors.warning),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            response,
            style: TextStyle(fontSize: 13, color: AppColors.slate300, height: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            date.length >= 10 ? date.substring(0, 10) : date,
            style: TextStyle(fontSize: 10, color: AppColors.slate500),
          ),
        ],
      ),
    );
  }
}
