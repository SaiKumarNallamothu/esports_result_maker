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
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
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
                        tournament.format == 'group_fixtures'
                            ? 'Manage custom groups. Drag & drop teams or tap badges to move.'
                            : 'Drag & drop to reorder. Tap name to edit. Tap logo to upload.',
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: tournament.format == 'group_fixtures'
                    ? _buildGroupFixturesView(context, viewModel, tournament)
                    : _buildClassicView(context, viewModel, tournament),
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
        ),
      ),
    );
  }

  Widget _buildClassicView(
    BuildContext context,
    TournamentViewModel viewModel,
    Tournament tournament,
  ) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: tournament.teams.length,
      onReorder: (oldIndex, newIndex) {
        viewModel.reorderTeams(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final team = tournament.teams[index];
        return _buildTeamCard(context, viewModel, tournament, team, index);
      },
    );
  }

  Widget _buildGroupFixturesView(
    BuildContext context,
    TournamentViewModel viewModel,
    Tournament tournament,
  ) {
    final List<Team> unassignedTeams = tournament.teams.where((t) => t.group == null).toList();
    final List<String> groupsList = tournament.groupNames ?? [];

    return Column(
      children: [
        // Top static action and unassigned teams block
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('ADD GROUP'),
                    onPressed: () => _showAddGroupDialog(context, viewModel),
                  ),
                  if (groupsList.isNotEmpty)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('AUTO DISTRIBUTE'),
                      onPressed: () => _showAutoDistributeDialog(context, viewModel),
                    ),
                ],
              ),
              if (unassignedTeams.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.05),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'UNASSIGNED TEAMS (${unassignedTeams.length})',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 16,
                              letterSpacing: 1,
                              color: Colors.redAccent,
                            ),
                          ),
                          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: unassignedTeams.map((team) {
                          return Draggable<Team>(
                            data: team,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Chip(
                                label: Text(team.name),
                                backgroundColor: AppTheme.accentGold,
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: ActionChip(
                                label: Text(team.name),
                                onPressed: () => _showGroupSelectDialog(context, viewModel, tournament, team),
                              ),
                            ),
                            child: ActionChip(
                              avatar: team.logoPath != null
                                  ? ClipOval(child: Image.file(File(team.logoPath!), fit: BoxFit.cover, width: 16, height: 16))
                                  : null,
                              label: Text(team.name),
                              backgroundColor: AppTheme.surfaceCard,
                              onPressed: () => _showGroupSelectDialog(context, viewModel, tournament, team),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Scrollable Groups List
        Expanded(
          child: groupsList.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No groups created. Tap Add Group to start.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              : Theme(
                  data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: groupsList.length,
                    onReorder: (oldIndex, newIndex) {
                      viewModel.reorderGroups(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final groupName = groupsList[index];
                      final groupTeams = tournament.teams.where((t) => t.group == groupName).toList();

                      return DragTarget<Team>(
                        key: ValueKey(groupName),
                        onWillAccept: (data) => data?.group != groupName,
                        onAccept: (team) {
                          viewModel.updateTeamGroup(team.id, groupName);
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isOver = candidateData.isNotEmpty;
                          return Card(
                            key: ValueKey(groupName),
                            margin: const EdgeInsets.only(bottom: 16),
                            color: isOver ? AppTheme.neonBlue.withOpacity(0.1) : AppTheme.surfaceCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isOver ? AppTheme.neonBlue : AppTheme.dividerColor,
                                width: isOver ? 1.5 : 1.0,
                              ),
                            ),
                            child: ExpansionTile(
                              key: PageStorageKey(groupName),
                              initiallyExpanded: true,
                              title: Row(
                                children: [
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: const Icon(Icons.drag_handle, size: 20, color: AppTheme.textSecondary),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      groupName.toUpperCase(),
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 18,
                                        letterSpacing: 1,
                                        color: AppTheme.accentGold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.dividerColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${groupTeams.length} Teams',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18, color: AppTheme.textSecondary),
                                    onPressed: () => _showRenameGroupDialog(context, viewModel, groupName),
                                    tooltip: 'Rename Group',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                    onPressed: () => _showDeleteGroupConfirmDialog(context, viewModel, groupName),
                                    tooltip: 'Delete Group',
                                  ),
                                ],
                              ),
                              children: [
                                if (groupTeams.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'No teams in this group. Drag teams here or tap badge to assign.',
                                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
                                    ),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: groupTeams.length,
                                    itemBuilder: (context, teamIndex) {
                                      final team = groupTeams[teamIndex];
                                      return Draggable<Team>(
                                        data: team,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: Chip(
                                            label: Text(team.name),
                                            backgroundColor: AppTheme.accentGold,
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.3,
                                          child: _buildGroupTeamRow(context, viewModel, tournament, team),
                                        ),
                                        child: _buildGroupTeamRow(context, viewModel, tournament, team),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildGroupTeamRow(
    BuildContext context,
    TournamentViewModel viewModel,
    Tournament tournament,
    Team team,
  ) {
    return ListTile(
      dense: true,
      leading: GestureDetector(
        onTap: () => _pickLogo(context, viewModel, team),
        child: Stack(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentGold.withOpacity(0.3), width: 1),
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
                padding: const EdgeInsets.all(1.5),
                decoration: const BoxDecoration(
                  color: AppTheme.accentGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 7, color: AppTheme.background),
              ),
            ),
          ],
        ),
      ),
      title: InkWell(
        onTap: () => _showEditNameDialog(context, viewModel, team),
        child: Row(
          children: [
            Expanded(
              child: Text(
                team.name.toUpperCase(),
                style: GoogleFonts.bebasNeue(fontSize: 15, letterSpacing: 0.5, color: AppTheme.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit, size: 10, color: AppTheme.textSecondary),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _showGroupSelectDialog(context, viewModel, tournament, team),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.neonBlue.withOpacity(0.1),
                border: Border.all(color: AppTheme.neonBlue, width: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Move Group',
                style: const TextStyle(fontSize: 9, color: AppTheme.neonBlue, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 14, color: Colors.redAccent),
            onPressed: () => viewModel.updateTeamGroup(team.id, null),
            tooltip: 'Remove from group',
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(
    BuildContext context,
    TournamentViewModel viewModel,
    Tournament tournament,
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
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(Icons.drag_indicator, color: AppTheme.textSecondary),
              ),
            ),
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
            Expanded(
              child: Row(
                children: [
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
                            const SizedBox(width: 4),
                            const Icon(Icons.edit, size: 14, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (tournament.format == 'group_fixtures') ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showGroupSelectDialog(context, viewModel, tournament, team),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.neonBlue.withOpacity(0.15),
                          border: Border.all(color: AppTheme.neonBlue, width: 1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          team.group != null ? team.group!.toUpperCase() : 'NO GROUP',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 12,
                            letterSpacing: 0.5,
                            color: AppTheme.neonBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsPlaceholder(String name) {
    final initials = name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').join();
    final displayText = initials.length > 2 ? initials.substring(0, 2).toUpperCase() : initials.toUpperCase();
    return Center(
      child: Text(
        displayText.isEmpty ? 'T' : displayText,
        style: GoogleFonts.bebasNeue(
          fontSize: 14,
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
          style: const TextStyle(color: AppTheme.textPrimary),
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

  void _showGroupSelectDialog(
    BuildContext context,
    TournamentViewModel viewModel,
    Tournament tournament,
    Team team,
  ) {
    final List<String> groupsList = tournament.groupNames ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.dividerColor),
        ),
        title: Text(
          'ASSIGN GROUP',
          style: GoogleFonts.bebasNeue(
            letterSpacing: 1.5,
            color: AppTheme.accentGold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (team.group != null)
                ListTile(
                  title: const Text('None (Unassign)', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.clear, color: Colors.redAccent),
                  onTap: () {
                    viewModel.updateTeamGroup(team.id, null);
                    Navigator.pop(context);
                  },
                ),
              ...groupsList.map((g) {
                final isCurrent = team.group == g;
                return ListTile(
                  title: Text(g, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: isCurrent ? const Icon(Icons.check, color: AppTheme.neonBlue) : null,
                  onTap: () {
                    viewModel.updateTeamGroup(team.id, g);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context, TournamentViewModel viewModel) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.dividerColor),
        ),
        title: Text(
          'CREATE NEW GROUP',
          style: GoogleFonts.bebasNeue(letterSpacing: 1.5, color: AppTheme.accentGold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Group Name',
            hintText: 'e.g., Red Dragons',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('CREATE'),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                viewModel.addGroup(controller.text.trim());
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showRenameGroupDialog(BuildContext context, TournamentViewModel viewModel, String oldName) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.dividerColor),
        ),
        title: Text(
          'RENAME GROUP',
          style: GoogleFonts.bebasNeue(letterSpacing: 1.5, color: AppTheme.accentGold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'New Group Name',
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
                viewModel.renameGroup(oldName, controller.text.trim());
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupConfirmDialog(BuildContext context, TournamentViewModel viewModel, String groupName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.dividerColor),
        ),
        title: Text(
          'DELETE GROUP?',
          style: GoogleFonts.bebasNeue(letterSpacing: 1.5, color: Colors.redAccent),
        ),
        content: Text(
          'Are you sure you want to delete "$groupName"? All teams in this group will become unassigned. This action cannot be undone.',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('DELETE'),
            onPressed: () {
              viewModel.deleteGroup(groupName);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAutoDistributeDialog(BuildContext context, TournamentViewModel viewModel) {
    final controller = TextEditingController(text: '16');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.dividerColor),
        ),
        title: Text(
          'AUTO DISTRIBUTE TEAMS',
          style: GoogleFonts.bebasNeue(letterSpacing: 1.5, color: AppTheme.accentGold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Teams Per Group',
            hintText: 'e.g., 16',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('DISTRIBUTE'),
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                viewModel.distributeTeamsAutomatically(val);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
