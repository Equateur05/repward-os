import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../config/theme.dart';
import '../../../services/app_state.dart';
import '../../../services/supabase_service.dart';
import '../../../models/review.dart';
import '../../../widgets/glass_card.dart';

class TriageTab extends StatefulWidget {
  const TriageTab({super.key});

  @override
  State<TriageTab> createState() => _TriageTabState();
}

class _TriageTabState extends State<TriageTab> {
  Review? _selectedReview;
  final _draftController = TextEditingController();
  final _voiceInstructionController = TextEditingController();
  String _selectedWinBack = 'none';

  final _platforms = [
    {'id': 'all', 'label': 'Tous', 'icon': null, 'color': null},
    {'id': 'google', 'label': 'Google', 'icon': FontAwesomeIcons.google, 'color': AppColors.google},
    {'id': 'airbnb', 'label': 'Airbnb', 'icon': FontAwesomeIcons.airbnb, 'color': AppColors.airbnb},
    {'id': 'thefork', 'label': 'TheFork', 'icon': FontAwesomeIcons.utensils, 'color': AppColors.thefork},
    {'id': 'booking', 'label': 'Booking', 'icon': FontAwesomeIcons.hotel, 'color': const Color(0xFF003580)},
    {'id': 'tripadvisor', 'label': 'TripAdvisor', 'icon': FontAwesomeIcons.mapLocationDot, 'color': AppColors.tripadvisor},
    {'id': 'trustpilot', 'label': 'Trustpilot', 'icon': FontAwesomeIcons.star, 'color': AppColors.trustpilot},
    {'id': 'facebook', 'label': 'Facebook', 'icon': FontAwesomeIcons.facebook, 'color': AppColors.facebook},
    {'id': 'instagram', 'label': 'Instagram', 'icon': FontAwesomeIcons.instagram, 'color': AppColors.instagram},
  ];

  final _winBackOptions = [
    {'id': 'none', 'label': 'Aucun'},
    {'id': '10', 'label': '-10%'},
    {'id': '15', 'label': '-15%'},
    {'id': '20', 'label': '-20%'},
    {'id': 'special', 'label': 'Offre speciale'},
  ];

  final _quickTemplates = [
    {'id': 'thanks', 'label': 'Merci standard', 'emoji': '\u2764\ufe0f'},
    {'id': 'apology', 'label': 'Excuses', 'emoji': '\ud83d\ude4f'},
    {'id': 'invite', 'label': 'Invitation retour', 'emoji': '\ud83d\udc4b'},
    {'id': 'offer', 'label': 'Offre speciale', 'emoji': '\ud83c\udf81'},
  ];

  @override
  void dispose() {
    _draftController.dispose();
    _voiceInstructionController.dispose();
    super.dispose();
  }

  void _selectReview(Review review) {
    setState(() {
      _selectedReview = review;
      _draftController.text = _generateDraft(review);
    });
  }

  String _generateDraft(Review review) {
    final appState = context.read<AppState>();
    final bizName = appState.merchant.businessName.isNotEmpty ? appState.merchant.businessName : 'notre etablissement';
    if (review.rating >= 4) {
      return 'Cher(e) ${review.author},\n\nMerci infiniment pour votre avis elogieux ! Toute l\'equipe de $bizName est ravie que votre experience ait ete a la hauteur de vos attentes.\n\nVotre satisfaction est notre priorite et nous esperons vous accueillir a nouveau tres prochainement.\n\nCordialement,\nL\'equipe $bizName';
    } else if (review.rating >= 3) {
      return 'Cher(e) ${review.author},\n\nMerci pour votre retour constructif. Nous prenons bonne note de vos remarques et travaillons activement a ameliorer notre service.\n\nNous esperons avoir l\'occasion de vous faire vivre une meilleure experience lors de votre prochaine visite.\n\nCordialement,\nL\'equipe $bizName';
    } else {
      String winBackText = '';
      if (_selectedWinBack != 'none') {
        if (_selectedWinBack == 'special') {
          winBackText = '\n\nPour nous faire pardonner, nous aimerions vous offrir une attention speciale lors de votre prochaine visite.';
        } else {
          winBackText = '\n\nPour nous faire pardonner, nous vous offrons -$_selectedWinBack% sur votre prochaine visite avec le code WINBACK$_selectedWinBack.';
        }
      }
      return 'Cher(e) ${review.author},\n\nNous sommes sincerement desoles pour cette experience decevante. Ce n\'est pas le niveau de service que nous souhaitons offrir.\n\nNous aimerions en discuter avec vous pour comprendre ce qui s\'est passe et trouver une solution. N\'hesitez pas a nous contacter directement.$winBackText\n\nCordialement,\nL\'equipe $bizName';
    }
  }

  void _applyQuickTemplate(String templateId) {
    final appState = context.read<AppState>();
    final bizName = appState.merchant.businessName.isNotEmpty ? appState.merchant.businessName : 'notre etablissement';
    final author = _selectedReview?.author ?? 'Client';

    String template;
    switch (templateId) {
      case 'thanks':
        template = 'Cher(e) $author,\n\nMerci beaucoup pour votre avis ! Toute l\'equipe de $bizName est ravie de votre retour positif.\n\nA tres bientot !\nL\'equipe $bizName';
        break;
      case 'apology':
        template = 'Cher(e) $author,\n\nNous vous presentons nos sinceres excuses pour cette experience. Nous prenons vos remarques tres au serieux et mettons tout en oeuvre pour nous ameliorer.\n\nCordialement,\nL\'equipe $bizName';
        break;
      case 'invite':
        template = 'Cher(e) $author,\n\nMerci pour votre retour. Nous aimerions vous inviter a revenir decouvrir nos ameliorations. N\'hesitez pas a nous contacter pour organiser votre prochaine visite.\n\nAu plaisir,\nL\'equipe $bizName';
        break;
      case 'offer':
        template = 'Cher(e) $author,\n\nPour vous remercier de votre fidelite, nous avons le plaisir de vous offrir une remise speciale lors de votre prochaine visite. Contactez-nous pour en beneficier !\n\nCordialement,\nL\'equipe $bizName';
        break;
      default:
        template = '';
    }
    setState(() {
      _draftController.text = template;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isWide = MediaQuery.of(context).size.width >= 1024;
    final reviews = appState.reviews;
    final filtered = appState.currentFilter == 'all'
        ? reviews
        : reviews.where((r) => r.platform == appState.currentFilter).toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
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
                      appState.t('triageTitle'),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appState.t('triageSubtitle'),
                      style: TextStyle(fontSize: 14, color: AppColors.slate400),
                    ),
                  ],
                ),
              ),
              _buildAddManualButton(appState),
            ],
          ),
          const SizedBox(height: 24),

          // Content
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildMessageList(appState, filtered)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildAIPanel(appState)),
                  ],
                )
              : Column(
                  children: [
                    _buildMessageList(appState, filtered),
                    const SizedBox(height: 24),
                    _buildAIPanel(appState),
                  ],
                ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showAddReviewDialog(AppState appState) {
    final authorCtrl = TextEditingController();
    final textCtrl = TextEditingController();
    int selectedRating = 5;
    String selectedPlatform = 'google';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.slate800,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ajouter un avis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: authorCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nom du client',
                    labelStyle: TextStyle(color: AppColors.slate400),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.brand),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Plateforme', style: TextStyle(fontSize: 12, color: AppColors.slate400)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['google', 'airbnb', 'thefork', 'booking', 'tripadvisor', 'trustpilot', 'facebook'].map((p) {
                    final active = selectedPlatform == p;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedPlatform = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: active ? AppColors.brand.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                          border: Border.all(color: active ? AppColors.brand : Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Text(p, style: TextStyle(fontSize: 11, color: active ? AppColors.brandLight : AppColors.slate400, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text('Note', style: TextStyle(fontSize: 12, color: AppColors.slate400)),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(5, (i) => GestureDetector(
                    onTap: () => setDialogState(() => selectedRating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: FaIcon(
                        FontAwesomeIcons.solidStar,
                        size: 24,
                        color: i < selectedRating ? const Color(0xFFFACC15) : AppColors.slate700,
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Texte de l\'avis',
                    labelStyle: TextStyle(color: AppColors.slate400),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.brand),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler', style: TextStyle(color: AppColors.slate400)),
            ),
            ElevatedButton(
              onPressed: () {
                if (authorCtrl.text.trim().isEmpty || textCtrl.text.trim().isEmpty) return;
                final review = Review(
                  platform: selectedPlatform,
                  author: authorCtrl.text.trim(),
                  rating: selectedRating,
                  text: textCtrl.text.trim(),
                );
                appState.addReview(review);
                SupabaseService.saveReview(review);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddManualButton(AppState appState) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAddReviewDialog(appState),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.brand.withValues(alpha: 0.2),
            border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(FontAwesomeIcons.plus, size: 12, color: AppColors.brandLight),
              const SizedBox(width: 8),
              Text(
                appState.t('addManualReview'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(AppState appState, List<Review> filtered) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Filter bar with platform-colored active buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.slate800.withValues(alpha: 0.3),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _platforms.map((p) {
                  final active = appState.currentFilter == p['id'];
                  final platformColor = p['color'] as Color?;
                  final activeColor = platformColor ?? AppColors.brand;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => appState.setFilter(p['id'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: active
                              ? activeColor.withValues(alpha: 0.15)
                              : Colors.transparent,
                          border: Border.all(
                            color: active
                                ? activeColor.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (p['icon'] != null) ...[
                              FaIcon(
                                p['icon'] as IconData,
                                size: 10,
                                color: active
                                    ? activeColor
                                    : AppColors.slate500,
                              ),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              p['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: active ? activeColor : AppColors.slate400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Messages
          SizedBox(
            height: 500,
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.inbox, size: 40, color: AppColors.slate700),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun avis pour le moment',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Connectez vos plateformes ou ajoutez un avis manuellement pour commencer.',
                            style: TextStyle(fontSize: 12, color: AppColors.slate400),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final review = filtered[index];
                      final selected = _selectedReview?.id == review.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ReviewCard(
                          review: review,
                          selected: selected,
                          onTap: () => _selectReview(review),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPanel(AppState appState) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.brand.withValues(alpha: 0.1),
                    ),
                    child: const Center(
                      child: FaIcon(FontAwesomeIcons.robot, size: 14, color: AppColors.brand),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Assistant IA',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  if (_selectedReview != null) {
                    setState(() {
                      _draftController.text = _generateDraft(_selectedReview!);
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.slate800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(FontAwesomeIcons.rotateRight, size: 10, color: Colors.white),
                      const SizedBox(width: 6),
                      const Text('Regenerer', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Auto-pilot toggle
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.slate900.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.brand.withValues(alpha: 0.2),
                        AppColors.brand.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.bolt, size: 14, color: AppColors.brand),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilote Automatique',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        "L'IA repond et publie seule",
                        style: TextStyle(fontSize: 10, color: AppColors.slate400),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: appState.autoPilot,
                  onChanged: (v) => appState.setAutoPilot(v),
                  activeThumbColor: AppColors.brand,
                  activeTrackColor: AppColors.brand.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tone selector
          Row(
            children: [
              Text('Ton :', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.slate500)),
              const SizedBox(width: 8),
              ..._buildToneButtons(appState),
            ],
          ),
          const SizedBox(height: 14),

          // Win-Back selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WIN-BACK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate500,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _winBackOptions.map((opt) {
                  final active = _selectedWinBack == opt['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedWinBack = opt['id']!;
                        if (_selectedReview != null) {
                          _draftController.text = _generateDraft(_selectedReview!);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: active
                            ? AppColors.success.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        border: Border.all(
                          color: active
                              ? AppColors.success.withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        opt['label']!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: active ? AppColors.successLight : AppColors.slate400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quick Templates
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TEMPLATES RAPIDES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate500,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _quickTemplates.map((tmpl) {
                  return GestureDetector(
                    onTap: () => _applyQuickTemplate(tmpl['id']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.brand.withValues(alpha: 0.08),
                        border: Border.all(color: AppColors.brand.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tmpl['emoji']!, style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            tmpl['label']!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Voice instruction input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INSTRUCTION VOCALE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate500,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _voiceInstructionController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Ex: Mentionne notre nouveau chef',
                  hintStyle: TextStyle(color: AppColors.slate600, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.slate900.withValues(alpha: 0.5),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: FaIcon(FontAwesomeIcons.microphone, size: 12, color: AppColors.slate500),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.brand),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Draft textarea
          TextField(
            controller: _draftController,
            maxLines: 10,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
            decoration: InputDecoration(
              hintText: "L'IA genere votre reponse...",
              hintStyle: TextStyle(color: AppColors.slate600),
              filled: true,
              fillColor: AppColors.slate900.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.brand),
              ),
            ),
          ),

          // Character counter
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_draftController.text.length} caracteres',
              style: TextStyle(
                fontSize: 10,
                color: _draftController.text.length > 500
                    ? AppColors.warningLight
                    : AppColors.slate500,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _draftController.text));
                    },
                    icon: const FaIcon(FontAwesomeIcons.copy, size: 12),
                    label: const Text('Copier la reponse'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: (_selectedReview != null && _draftController.text.isNotEmpty)
                        ? () async {
                            final review = _selectedReview!;
                            final responseText = _draftController.text;
                            await SupabaseService.saveResponseHistory({
                              'supabase_review_id': review.supabaseReviewId,
                              'author': review.author,
                              'rating': review.rating,
                              'platform': review.platform,
                              'response': responseText,
                              'published': true,
                            });
                            if (context.mounted) {
                              await context.read<AppState>().refreshStats();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('R\u00e9ponse publi\u00e9e avec succ\u00e8s !'),
                                  backgroundColor: AppColors.success,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              setState(() {
                                _selectedReview = null;
                                _draftController.clear();
                              });
                            }
                          }
                        : null,
                    icon: const Text('Publier'),
                    label: const FaIcon(FontAwesomeIcons.paperPlane, size: 12),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.slate700,
                      disabledForegroundColor: AppColors.slate500,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildToneButtons(AppState appState) {
    final tones = [
      {'id': 'professional', 'emoji': '\ud83c\udfa9', 'label': 'Pro'},
      {'id': 'casual', 'emoji': '\ud83d\ude0e', 'label': 'Decontracte'},
      {'id': 'warm', 'emoji': '\ud83e\udd17', 'label': 'Chaleureux'},
      {'id': 'humor', 'emoji': '\ud83d\ude04', 'label': 'Humour'},
    ];
    return tones.map((t) {
      final active = appState.aiTone == t['id'];
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: GestureDetector(
          onTap: () => appState.setAiTone(t['id']!),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: active ? AppColors.brand.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: active ? AppColors.brand.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              '${t['emoji']} ${t['label']}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: active ? AppColors.brandLight : AppColors.slate400,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final bool selected;
  final VoidCallback onTap;

  const _ReviewCard({
    required this.review,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final platformColor = AppColors.platformColor(review.platform);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? AppColors.brand.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
          border: Border.all(
            color: selected ? AppColors.brand.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Platform icon with color
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: platformColor.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: FaIcon(review.platformIcon, size: 10, color: platformColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  review.author,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Spacer(),
                // Stars
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 1),
                      child: FaIcon(
                        FontAwesomeIcons.solidStar,
                        size: 10,
                        color: i < review.rating ? const Color(0xFFFACC15) : AppColors.slate700,
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.text,
              style: TextStyle(fontSize: 12, color: AppColors.slate300, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              review.timeAgo,
              style: TextStyle(fontSize: 10, color: AppColors.slate500),
            ),
          ],
        ),
      ),
    );
  }
}
