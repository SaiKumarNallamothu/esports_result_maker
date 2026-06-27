import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:esports_result_maker/viewmodels/tournament_viewmodel.dart';
import 'package:esports_result_maker/theme/theme.dart';
import 'package:esports_result_maker/views/tournament/create_tournament_screen.dart';
import 'package:esports_result_maker/views/tournament/team_management_screen.dart';
import 'package:esports_result_maker/views/presets_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          if (viewModel.tournaments.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accentGold.withOpacity(0.5), width: 2),
                      ),
                      child: const Icon(
                        Icons.emoji_events_outlined,
                        size: 60,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Tournaments Created Yet',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the button below to build your first professional BGMI result table in seconds.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToCreateTournament(context),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('CREATE TOURNAMENT'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                child: Text(
                  'YOUR TOURNAMENTS',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary.withOpacity(0.9),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: viewModel.tournaments.length,
                  itemBuilder: (context, index) {
                    final tournament = viewModel.tournaments[index];
                    final dateStr =
                        '${tournament.createdAt.day}/${tournament.createdAt.month}/${tournament.createdAt.year}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
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
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tournament.name.toUpperCase(),
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 22,
                                          letterSpacing: 1.2,
                                          color: AppTheme.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tournament.pointSystem.name,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.accentGold.withOpacity(0.8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
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
                  },
                ),
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
