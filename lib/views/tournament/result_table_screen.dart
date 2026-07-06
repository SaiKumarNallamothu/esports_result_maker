import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'team_management_screen.dart';
import '../../viewmodels/tournament_viewmodel.dart';
import '../../theme/theme.dart';
import '../../data/models.dart';
import '../../data/ad_service.dart';

enum ActiveTemplate { classicGold, bgmiTheme, neonDark, minimalLight }

class ResultTableScreen extends StatefulWidget {
  const ResultTableScreen({super.key});

  @override
  State<ResultTableScreen> createState() => _ResultTableScreenState();
}

class _ResultTableScreenState extends State<ResultTableScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  ActiveTemplate _selectedTemplate = ActiveTemplate.classicGold;
  int? _selectedMatchNumber; // null means Overall Standings
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TournamentViewModel>(context);
    final tournament = viewModel.activeTournament;

    if (tournament == null) {
      return const Scaffold(
        body: Center(child: Text('No active tournament loaded.')),
      );
    }

    final leaderboard = viewModel.calculateLeaderboard(matchNumber: _selectedMatchNumber);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RESULT TABLE'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scope & Match Selector Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.surfaceCard,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PREVIEW SCOPE:',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 16,
                    letterSpacing: 1,
                    color: AppTheme.accentGold,
                  ),
                ),
                DropdownButton<int?>(
                  value: _selectedMatchNumber,
                  dropdownColor: AppTheme.surfaceCard,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                  underline: Container(height: 1.5, color: AppTheme.accentGold),
                  onChanged: (val) {
                    setState(() {
                      _selectedMatchNumber = val;
                    });
                  },
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('OVERALL STANDINGS'),
                    ),
                    ...List.generate(tournament.numberOfMatches, (index) {
                      final mNum = index + 1;
                      return DropdownMenuItem<int?>(
                        value: mNum,
                        child: Text('MATCH #$mNum STATS'),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          // Template Selector
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: AppTheme.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTemplateChip(ActiveTemplate.classicGold, 'CLASSIC GOLD'),
                  const SizedBox(width: 8),
                  _buildTemplateChip(ActiveTemplate.bgmiTheme, 'BGMI BLUE'),
                  const SizedBox(width: 8),
                  _buildTemplateChip(ActiveTemplate.neonDark, 'NEON PURPLE'),
                  const SizedBox(width: 8),
                  _buildTemplateChip(ActiveTemplate.minimalLight, 'MINIMAL LIGHT'),
                ],
              ),
            ),
          ),

          // Scrollable Preview area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Screenshot(
                    controller: _screenshotController,
                    child: _buildLeaderboardTable(tournament, leaderboard),
                  ),
                ),
              ),
            ),
          ),

          // Share Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.dividerColor)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSharing ? null : () => _exportAndShare(tournament.name),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.accentGold,
                          foregroundColor: AppTheme.background,
                        ),
                        icon: _isSharing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.background),
                              )
                            : const Icon(Icons.share, size: 20),
                        label: Text(_isSharing ? 'GENERATING IMAGE...' : 'SHARE RESULT TABLE'),
                      ),
                    ),
                  ],
                ),
                if (tournament.format == 'group_fixtures' && _selectedMatchNumber == null) ...[
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _generateNextRound(context, viewModel, tournament, leaderboard),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.neonBlue,
                      foregroundColor: AppTheme.background,
                    ),
                    icon: const Icon(Icons.next_plan_outlined, size: 20),
                    label: const Text('GENERATE NEXT ROUND TOURNAMENT'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdService.getBannerAdWidget(),
    );
  }

  Widget _buildTemplateChip(ActiveTemplate template, String label) {
    final isSelected = _selectedTemplate == template;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTemplate = template;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGold : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.bebasNeue(
            fontSize: 14,
            letterSpacing: 1,
            color: isSelected ? AppTheme.background : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  // --- Templates Configurations ---

  Color _getBgColor() {
    switch (_selectedTemplate) {
      case ActiveTemplate.classicGold:
        return const Color(0xFF0F1015);
      case ActiveTemplate.bgmiTheme:
        return const Color(0xFF0B1424);
      case ActiveTemplate.neonDark:
        return const Color(0xFF050014);
      case ActiveTemplate.minimalLight:
        return Colors.white;
    }
  }

  BorderSide _getBorderSide() {
    switch (_selectedTemplate) {
      case ActiveTemplate.classicGold:
        return const BorderSide(color: Color(0xFFD4AF37), width: 1.5);
      case ActiveTemplate.bgmiTheme:
        return const BorderSide(color: Color(0xFF00E5FF), width: 1.5);
      case ActiveTemplate.neonDark:
        return const BorderSide(color: Color(0xFFB5179E), width: 1.5);
      case ActiveTemplate.minimalLight:
        return const BorderSide(color: Color(0xFF1E222D), width: 1.5);
    }
  }

  TextStyle _getHeaderStyle(double size) {
    final base = GoogleFonts.bebasNeue(fontSize: size, letterSpacing: 1.5);
    switch (_selectedTemplate) {
      case ActiveTemplate.classicGold:
        return base.copyWith(color: const Color(0xFFD4AF37));
      case ActiveTemplate.bgmiTheme:
        return base.copyWith(color: const Color(0xFF00E5FF));
      case ActiveTemplate.neonDark:
        return base.copyWith(color: const Color(0xFFF72585));
      case ActiveTemplate.minimalLight:
        return base.copyWith(color: const Color(0xFF1E222D));
    }
  }

  Color _getTableHeaderBg() {
    switch (_selectedTemplate) {
      case ActiveTemplate.classicGold:
        return const Color(0xFF1A1C23);
      case ActiveTemplate.bgmiTheme:
        return const Color(0xFF12243F);
      case ActiveTemplate.neonDark:
        return const Color(0xFF180A2B);
      case ActiveTemplate.minimalLight:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getRowColor(int index) {
    if (_selectedTemplate == ActiveTemplate.minimalLight) {
      return index % 2 == 0 ? Colors.white : const Color(0xFFF9FAFB);
    }
    return index % 2 == 0 ? _getBgColor() : _getTableHeaderBg().withOpacity(0.4);
  }

  Color _getTextColor() {
    return _selectedTemplate == ActiveTemplate.minimalLight ? Colors.black : Colors.white;
  }

  Color _getMutedTextColor() {
    return _selectedTemplate == ActiveTemplate.minimalLight ? Colors.grey[600]! : Colors.grey[400]!;
  }

  // --- Leaderboard Layout ---

  Widget _buildLeaderboardTable(Tournament tournament, List<TeamStats> leaderboard) {
    final bgColor = _getBgColor();
    final border = _getBorderSide();
    final textColor = _getTextColor();
    final mutedTextColor = _getMutedTextColor();

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: border.color, width: border.width),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section
          Center(
            child: Column(
              children: [
                Text(
                  tournament.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: _getHeaderStyle(36),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedMatchNumber == null
                      ? 'OVERALL STANDINGS'
                      : 'MATCH #$_selectedMatchNumber RESULTS' +
                          ((tournament.format == 'group_fixtures' &&
                                  tournament.matches
                                      .firstWhere((m) => m.matchNumber == _selectedMatchNumber)
                                      .playingGroups !=
                                  null)
                              ? ' (${tournament.matches.firstWhere((m) => m.matchNumber == _selectedMatchNumber).playingGroups!.join(' vs ')})'
                              : ''),
                  style: GoogleFonts.bebasNeue(
                    fontSize: 20,
                    letterSpacing: 2,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTableHeaderBg(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _selectedMatchNumber == null
                        ? 'TOTAL MATCHES: ${tournament.numberOfMatches}'
                        : 'SINGLE MATCH SCORES',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 14,
                      color: _selectedTemplate == ActiveTemplate.classicGold
                          ? const Color(0xFFD4AF37)
                          : textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Leaderboard Grid Header
          Container(
            color: _getTableHeaderBg(),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 25,
                  child: Text(
                    'RNK',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(color: textColor, fontSize: 13, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'TEAM NAME',
                    style: GoogleFonts.bebasNeue(color: textColor, fontSize: 13, letterSpacing: 0.5),
                  ),
                ),
                SizedBox(
                  width: 25,
                  child: Text(
                    'M',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(color: textColor, fontSize: 13, letterSpacing: 0.5),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'PLACE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(color: textColor, fontSize: 13, letterSpacing: 0.5),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    tournament.gameCategory == 'bgmi'
                        ? 'FINISH'
                        : tournament.gameCategory == 'freefire'
                            ? 'ELIMS'
                            : 'KILLS',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(color: textColor, fontSize: 13, letterSpacing: 0.5),
                  ),
                ),
                SizedBox(
                  width: 45,
                  child: Text(
                    'TOTAL',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                      color: _selectedTemplate == ActiveTemplate.classicGold
                          ? const Color(0xFFD4AF37)
                          : textColor,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

           // Team Rows
          Column(
            children: List.generate(leaderboard.length, (index) {
              final stats = leaderboard[index];
              final isWWCD = stats.wwcdCount > 0;
              final rowColor = _getRowColor(index);
              final isQualified = _isTeamQualified(tournament, leaderboard, stats.team.id, stats.team.group);

              return Container(
                color: rowColor,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Row(
                  children: [
                    // Rank badge
                    SizedBox(
                      width: 25,
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.bebasNeue(
                            fontSize: index < 3 ? 18 : 15,
                            color: index == 0
                                ? const Color(0xFFF1C40F)
                                : index == 1
                                    ? const Color(0xFFBDC3C7)
                                    : index == 2
                                        ? const Color(0xFFE67E22)
                                        : textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const SizedBox(width: 4),

                    // Team Logo & Name
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: stats.team.logoPath == null
                                  ? AppTheme.getGradientForTeam(stats.team.name)
                                  : null,
                            ),
                            child: stats.team.logoPath != null
                                ? ClipOval(
                                    child: Image.file(
                                      File(stats.team.logoPath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          _buildInitials(stats.team.name),
                                    ),
                                  )
                                : _buildInitials(stats.team.name),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                 Expanded(
                                   child: Text(
                                     stats.team.name.toUpperCase(),
                                     style: GoogleFonts.bebasNeue(
                                       fontSize: 15,
                                       letterSpacing: 0.5,
                                       color: textColor,
                                     ),
                                     maxLines: 1,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                 ),
                                 if (tournament.format == 'group_fixtures' && stats.team.group != null) ...[
                                   const SizedBox(width: 4),
                                   Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                     decoration: BoxDecoration(
                                       color: AppTheme.neonBlue.withOpacity(0.15),
                                       border: Border.all(color: AppTheme.neonBlue, width: 0.5),
                                       borderRadius: BorderRadius.circular(3),
                                     ),
                                     child: Text(
                                       stats.team.group!,
                                       style: const TextStyle(
                                         fontSize: 8,
                                         fontWeight: FontWeight.bold,
                                         color: AppTheme.neonBlue,
                                       ),
                                     ),
                                   ),
                                 ],
                                 if (isQualified) ...[
                                   const SizedBox(width: 4),
                                   Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                     decoration: BoxDecoration(
                                       color: Colors.green.withOpacity(0.15),
                                       border: Border.all(color: Colors.green, width: 0.5),
                                       borderRadius: BorderRadius.circular(3),
                                     ),
                                     child: const Text(
                                       'Q',
                                       style: TextStyle(
                                         fontSize: 8,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.green,
                                       ),
                                     ),
                                   ),
                                 ],
                                 if (isWWCD) ...[
                                   const SizedBox(width: 4),
                                   _buildWWCDIndicator(tournament, stats.wwcdCount),
                                 ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Matches Played / count
                    SizedBox(
                      width: 25,
                      child: Text(
                        '${stats.matchesPlayed}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: mutedTextColor, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Placement Points
                    SizedBox(
                      width: 35,
                      child: Text(
                        '${stats.placementPoints}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: mutedTextColor, fontSize: 13),
                      ),
                    ),

                    // Finishes Points
                    SizedBox(
                      width: 35,
                      child: Text(
                        '${stats.finishes}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: mutedTextColor, fontSize: 13),
                      ),
                    ),

                    // Total Points
                    SizedBox(
                      width: 45,
                      child: Text(
                        '${stats.totalPoints}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: _selectedTemplate == ActiveTemplate.classicGold
                              ? const Color(0xFFF1C40F)
                              : _selectedTemplate == ActiveTemplate.bgmiTheme
                                  ? const Color(0xFF00E5FF)
                                  : _selectedTemplate == ActiveTemplate.neonDark
                                      ? const Color(0xFFF72585)
                                      : textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Footer watermark / credit
          Center(
            child: Text(
              'GENERATED VIA ESPORTS RESULT MAKER',
              style: GoogleFonts.bebasNeue(
                fontSize: 10,
                letterSpacing: 1.5,
                color: mutedTextColor.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(String name) {
    final initials = name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').join();
    final displayText = initials.length > 2
        ? initials.substring(0, 2).toUpperCase()
        : initials.toUpperCase();
    return Center(
      child: Text(
        displayText.isEmpty ? 'T' : displayText,
        style: GoogleFonts.bebasNeue(
          fontSize: 11,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWWCDIndicator(Tournament tournament, int count) {
    final String label = tournament.gameCategory == 'freefire'
        ? 'BOOYAH'
        : tournament.gameCategory == 'custom'
            ? 'WIN'
            : 'WWCD';
    final Color badgeColor = tournament.gameCategory == 'freefire'
        ? const Color(0xFFE67E22)
        : const Color(0xFFF1C40F);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        border: Border.all(color: badgeColor, width: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tournament.gameCategory == 'freefire' ? Icons.local_fire_department : Icons.emoji_events,
            size: 8,
            color: badgeColor,
          ),
          const SizedBox(width: 2),
          Text(
            count > 1 ? '$label x$count' : label,
            style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: badgeColor),
          ),
        ],
      ),
    );
  }

  // --- Export and Share function ---

  void _exportAndShare(String tournamentName) async {
    setState(() {
      _isSharing = true;
    });

    AdService.showInterstitialAd(() async {
      try {
        final imageBytes = await _screenshotController.capture(
          delay: const Duration(milliseconds: 100),
        );

        if (imageBytes != null) {
          final directory = await getTemporaryDirectory();
          final formattedName = tournamentName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
          final scopeStr = _selectedMatchNumber == null ? 'overall' : 'match_$_selectedMatchNumber';
          final path = '${directory.path}/leaderboard_${formattedName}_${scopeStr}_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File(path);
          await file.writeAsBytes(imageBytes);

          // Share the image using share_plus package
          await Share.shareXFiles(
            [XFile(path)],
            text: _selectedMatchNumber == null
                ? 'Overall standings for $tournamentName #BGMI #Esports'
                : 'Match #$_selectedMatchNumber results for $tournamentName #BGMI #Esports',
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to generate table image: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSharing = false;
          });
        }
      }
    });
  }

  bool _isTeamQualified(Tournament tournament, List<TeamStats> leaderboard, String teamId, String? groupName) {
    if (tournament.format != 'group_fixtures' || groupName == null || tournament.qualifyCount == null) {
      return false;
    }
    final groupTeams = leaderboard.where((stats) => stats.team.group == groupName).toList();
    final index = groupTeams.indexWhere((stats) => stats.team.id == teamId);
    if (index != -1 && index < tournament.qualifyCount!) {
      return true;
    }
    return false;
  }

  void _generateNextRound(
    BuildContext context,
    TournamentViewModel viewModel,
    Tournament tournament,
    List<TeamStats> leaderboard,
  ) {
    final List<Team> qualifiedTeams = [];
    for (var stats in leaderboard) {
      if (_isTeamQualified(tournament, leaderboard, stats.team.id, stats.team.group)) {
        qualifiedTeams.add(Team(
          id: stats.team.id,
          name: stats.team.name,
          logoPath: stats.team.logoPath,
        ));
      }
    }

    if (qualifiedTeams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No teams qualified. Make sure groups have teams assigned and qualification count is set.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final controller = TextEditingController(text: '${tournament.name} - Next Round');
    String selectedFormat = 'classic';
    int matchCount = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppTheme.dividerColor),
            ),
            title: Text(
              'GENERATE NEXT ROUND',
              style: GoogleFonts.bebasNeue(letterSpacing: 1.5, color: AppTheme.accentGold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Qualified teams: ${qualifiedTeams.length}',
                    style: const TextStyle(color: AppTheme.neonBlue, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Tournament Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FORMAT',
                    style: GoogleFonts.bebasNeue(fontSize: 14, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedFormat == 'classic' ? AppTheme.accentGold : AppTheme.surface,
                            foregroundColor: selectedFormat == 'classic' ? AppTheme.background : AppTheme.textPrimary,
                          ),
                          onPressed: () => setDialogState(() => selectedFormat = 'classic'),
                          child: const Text('CLASSIC'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedFormat == 'group_fixtures' ? AppTheme.accentGold : AppTheme.surface,
                            foregroundColor: selectedFormat == 'group_fixtures' ? AppTheme.background : AppTheme.textPrimary,
                          ),
                          onPressed: () => setDialogState(() => selectedFormat = 'group_fixtures'),
                          child: const Text('GROUP STAGE'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Matches: $matchCount',
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppTheme.neonBlue),
                            onPressed: matchCount > 1 ? () => setDialogState(() => matchCount--) : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppTheme.neonBlue),
                            onPressed: matchCount < 50 ? () => setDialogState(() => matchCount++) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('GENERATE'),
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;

                  final uuid = const Uuid();
                  final List<Team> newTeams = qualifiedTeams.map((t) => Team(
                    id: uuid.v4(),
                    name: t.name,
                    logoPath: t.logoPath,
                  )).toList();

                  final List<String> groupsList = selectedFormat == 'group_fixtures' ? ['Group Alpha', 'Group Beta'] : [];
                  if (selectedFormat == 'group_fixtures') {
                    for (int i = 0; i < newTeams.length; i++) {
                      newTeams[i].group = groupsList[i % groupsList.length];
                    }
                  }

                  final List<List<String>> uniquePairs = [];
                  if (groupsList.isNotEmpty) {
                    for (int i = 0; i < groupsList.length; i++) {
                      for (int j = i + 1; j < groupsList.length; j++) {
                        uniquePairs.add([groupsList[i], groupsList[j]]);
                      }
                    }
                  }

                  final List<Match> matches = List.generate(
                    matchCount,
                    (index) {
                      List<String>? playingGroups;
                      if (selectedFormat == 'group_fixtures' && uniquePairs.isNotEmpty) {
                        playingGroups = uniquePairs[index % uniquePairs.length];
                      }
                      return Match(
                        matchNumber: index + 1,
                        results: [],
                        playingGroups: playingGroups,
                      );
                    },
                  );

                  await viewModel.createTournament(
                    name: name,
                    numberOfMatches: matchCount,
                    numberOfTeams: newTeams.length,
                    pointSystem: tournament.pointSystem,
                    format: selectedFormat,
                    numberOfGroups: selectedFormat == 'group_fixtures' ? groupsList.length : null,
                    gameCategory: tournament.gameCategory,
                    groupNames: selectedFormat == 'group_fixtures' ? groupsList : null,
                  );

                  viewModel.activeTournament!.teams = newTeams;
                  viewModel.activeTournament!.matches = matches;
                  await viewModel.saveActiveTournament();

                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const TeamManagementScreen()),
                      ModalRoute.withName('/'),
                    );
                  }
                },
              ),
            ],
          );
        }
      ),
    );
  }
}
