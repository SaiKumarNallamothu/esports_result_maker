import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/tournament_viewmodel.dart';
import '../../theme/theme.dart';
import '../../data/models.dart';
import 'match_entry_screen.dart';
import 'result_table_screen.dart';

class TeamManagementScreen extends StatelessWidget {
  const TeamManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = Provider.of<TournamentViewModel>(context);
    final tournament = viewModel.activeTournament;

    if (tournament == null) {
      return const Scaffold(
        body: Center(child: Text('No active tournament loaded.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tournament.name.toUpperCase()),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: AppTheme.accentGold),
            tooltip: 'View Leaderboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResultTableScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.surface,
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Drag & drop to reorder. Tap name to edit. Tap logo to upload.',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: tournament.teams.length,
              onReorder: (oldIndex, newIndex) {
                viewModel.reorderTeams(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final team = tournament.teams[index];
                return _buildTeamCard(context, viewModel, team, index);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.dividerColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ResultTableScreen()),
                      );
                    },
                    child: Text(
                      'PREVIEW LEADERBOARD',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 16,
                        letterSpacing: 1.2,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MatchEntryScreen()),
                      );
                    },
                    child: const Text('ENTER MATCH RESULTS'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(
    BuildContext context,
    TournamentViewModel viewModel,
    Team team,
    int index,
  ) {

    return Card(
      key: ValueKey(team.id),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkCardGradient),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            // Reorder Handle
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(Icons.drag_indicator, color: AppTheme.textSecondary),
              ),
            ),

            // Team Logo Selector
            GestureDetector(
              onTap: () => _pickLogo(context, viewModel, team),
              child: Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.5), width: 1.5),
                      gradient: team.logoPath == null ? AppTheme.getGradientForTeam(team.name) : null,
                    ),
                    child: team.logoPath != null
                        ? ClipOval(
                            child: Image.file(
                              File(team.logoPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildInitialsPlaceholder(team.name);
                              },
                            ),
                          )
                        : _buildInitialsPlaceholder(team.name),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 10, color: AppTheme.background),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Team Name Text Button (Inline editing)
            Expanded(
              child: InkWell(
                onTap: () => _showEditNameDialog(context, viewModel, team),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          team.name.toUpperCase(),
                          style: GoogleFonts.bebasNeue(
                            fontSize: 18,
                            letterSpacing: 1,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.edit, size: 14, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsPlaceholder(String name) {
    final initials = name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').join();
    final displayText = initials.length > 2
        ? initials.substring(0, 2).toUpperCase()
        : initials.toUpperCase();
    return Center(
      child: Text(
        displayText.isEmpty ? 'T' : displayText,
        style: GoogleFonts.bebasNeue(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  void _pickLogo(BuildContext context, TournamentViewModel viewModel, Team team) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      viewModel.updateTeamLogo(team.id, pickedFile.path);
    }
  }

  void _showEditNameDialog(BuildContext context, TournamentViewModel viewModel, Team team) {
    final controller = TextEditingController(text: team.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.dividerColor),
        ),
        title: Text(
          'RENAME TEAM',
          style: GoogleFonts.bebasNeue(
            letterSpacing: 1.5,
            color: AppTheme.accentGold,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Team Name',
            hintText: 'e.g., GodLike',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('SAVE'),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                viewModel.updateTeamName(team.id, controller.text.trim());
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
