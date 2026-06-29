import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:esports_result_maker/viewmodels/tournament_viewmodel.dart';
import 'package:esports_result_maker/theme/theme.dart';
import 'package:esports_result_maker/views/tournament/create_tournament_screen.dart';
import 'package:esports_result_maker/views/tournament/team_management_screen.dart';
import 'package:esports_result_maker/views/presets_dialog.dart';
import 'package:esports_result_maker/data/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'all'; // 'all', 'bgmi', 'pubg', 'freefire', 'custom'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TournamentViewModel>(context, listen: false).loadTournaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ESPORTS RESULT MAKER',
          style: GoogleFonts.bebasNeue(
            fontSize: 28,
            letterSpacing: 2,
            color: AppTheme.accentGold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.accentGold),
            tooltip: 'Manage Presets',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const PresetsDialog(),
              );
            },
          ),
        ],
      ),
      body: Consumer<TournamentViewModel>(
        builder: (context, viewModel, child) {
          // Filter tournaments based on category selection
          final filteredTournaments = _selectedCategory == 'all'
              ? viewModel.tournaments
              : viewModel.tournaments.where((t) => t.gameCategory == _selectedCategory).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Buttons Row
              _buildCategorySelector(),

              // Standings count or header
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                child: Text(
                  _selectedCategory == 'all'
                      ? 'ALL TOURNAMENTS'
                      : '${_selectedCategory.toUpperCase()} TOURNAMENTS',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary.withOpacity(0.9),
                  ),
                ),
              ),

              // Renders empty state or tournament list
              Expanded(
                child: filteredTournaments.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildTournamentList(viewModel, filteredTournaments, theme),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTournament(context),
        backgroundColor: AppTheme.accentGold,
        foregroundColor: AppTheme.background,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'id': 'all', 'label': 'ALL', 'color': const Color(0xFF9CA3AF)},
      {'id': 'bgmi', 'label': 'BGMI', 'color': const Color(0xFFF39C12)}, // Yellow Orange
      {'id': 'pubg', 'label': 'PUBG', 'color': const Color(0xFFE74C3C)}, // Red
      {'id': 'freefire', 'label': 'FREE FIRE', 'color': const Color(0xFFE67E22)}, // Flame Orange
      {'id': 'custom', 'label': 'CUSTOM', 'color': const Color(0xFF3498DB)}, // Blue
    ];

    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: AppTheme.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final id = cat['id'] as String;
          final label = cat['label'] as String;
          final color = cat['color'] as Color;
          final isSelected = _selectedCategory == id;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = id;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.2) : AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? color : AppTheme.dividerColor,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.bebasNeue(
                    fontSize: 15,
                    letterSpacing: 1.2,
                    color: isSelected ? color : AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.3), width: 1.5),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  size: 50,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Tournaments Found',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedCategory == 'all'
                    ? 'Tap the button below to build your first professional BGMI, PUBG, or Free Fire result table.'
                    : 'No tournaments created under this category. Tap the button below to start one.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _navigateToCreateTournament(context),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('CREATE TOURNAMENT'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentList(
    TournamentViewModel viewModel,
    List<Tournament> list,
    ThemeData theme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;
        if (isWide) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.45,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final tournament = list[index];
              return _buildTournamentCard(context, viewModel, tournament, theme, false);
            },
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final tournament = list[index];
            return _buildTournamentCard(context, viewModel, tournament, theme, true);
          },
        );
      },
    );
  }

  Widget _buildTournamentCard(
    BuildContext context,
    TournamentViewModel viewModel,
    Tournament tournament,
    ThemeData theme,
    bool hasBottomMargin,
  ) {
    final dateStr = '${tournament.createdAt.day}/${tournament.createdAt.month}/${tournament.createdAt.year}';
    final categoryColor = _getCategoryColor(tournament.gameCategory);

    return Card(
      margin: hasBottomMargin ? const EdgeInsets.only(bottom: 12) : EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.darkCardGradient,
        ),
        child: InkWell(
          onTap: () {
            viewModel.setActiveTournament(tournament);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TeamManagementScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                tournament.name.toUpperCase(),
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 22,
                                  letterSpacing: 1.2,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.15),
                                  border: Border.all(color: categoryColor, width: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tournament.gameCategory.toUpperCase(),
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 9,
                                    color: categoryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          dateStr,
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildChip(
                          context,
                          Icons.people_outline,
                          '${tournament.numberOfTeams} Teams',
                        ),
                        const SizedBox(width: 8),
                        _buildChip(
                          context,
                          Icons.sports_esports_outlined,
                          '${tournament.numberOfMatches} Matches',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tournament.pointSystem.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.accentGold.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy_outlined, size: 20),
                          tooltip: 'Duplicate',
                          color: AppTheme.textSecondary,
                          onPressed: () => viewModel.duplicateTournament(tournament),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          tooltip: 'Delete',
                          color: Colors.redAccent,
                          onPressed: () => _confirmDelete(context, viewModel, tournament),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'bgmi':
        return const Color(0xFFF39C12);
      case 'pubg':
        return const Color(0xFFE74C3C);
      case 'freefire':
        return const Color(0xFFE67E22);
      case 'custom':
        return const Color(0xFF3498DB);
      default:
        return AppTheme.accentGold;
    }
  }

  Widget _buildChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.neonBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateTournament(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTournamentScreen()),
    );
  }

  void _confirmDelete(BuildContext context, TournamentViewModel viewModel, var tournament) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.dividerColor),
        ),
        title: Text(
          'DELETE TOURNAMENT?',
          style: GoogleFonts.bebasNeue(
            letterSpacing: 1.5,
            color: Colors.redAccent,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${tournament.name}"? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('DELETE', style: const TextStyle(color: Colors.white)),
            onPressed: () {
              viewModel.deleteTournament(tournament.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
