import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/tournament_viewmodel.dart';
import '../../theme/theme.dart';
import '../../data/models.dart';

class MatchEntryScreen extends StatefulWidget {
  const MatchEntryScreen({super.key});

  @override
  State<MatchEntryScreen> createState() => _MatchEntryScreenState();
}

class _MatchEntryScreenState extends State<MatchEntryScreen> {
  int _selectedMatchNumber = 1;
  final Map<String, int?> _selectedPlacements = {};
  final Map<String, TextEditingController> _finishesControllers = {};
  final Map<String, TextEditingController> _bonusControllers = {};
  final Map<String, TextEditingController> _penaltyControllers = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadMatchResults();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (var c in _finishesControllers.values) {
      c.dispose();
    }
    for (var c in _bonusControllers.values) {
      c.dispose();
    }
    for (var c in _penaltyControllers.values) {
      c.dispose();
    }
    _finishesControllers.clear();
    _bonusControllers.clear();
    _penaltyControllers.clear();
    _selectedPlacements.clear();
  }

  void _loadMatchResults() {
    _disposeControllers();

    final viewModel = Provider.of<TournamentViewModel>(context, listen: false);
    final tournament = viewModel.activeTournament;
    if (tournament == null) return;

    // Find if match already exists
    final match = tournament.matches.firstWhere(
      (m) => m.matchNumber == _selectedMatchNumber,
      orElse: () => Match(matchNumber: _selectedMatchNumber, results: []),
    );

    for (var team in tournament.teams) {
      // Find team's result in this match
      final result = match.results.firstWhere(
        (r) => r.teamId == team.id,
        orElse: () => MatchResult(
          teamId: team.id,
          placement: 0,
          finishes: 0,
          bonusPoints: 0,
          penaltyPoints: 0,
        ),
      );

      // Set values
      _selectedPlacements[team.id] = result.placement == 0 ? null : result.placement;
      _finishesControllers[team.id] = TextEditingController(
        text: result.finishes.toString(),
      );
      _bonusControllers[team.id] = TextEditingController(
        text: result.bonusPoints.toString(),
      );
      _penaltyControllers[team.id] = TextEditingController(
        text: result.penaltyPoints.toString(),
      );
    }
  }

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

    // Determine active match and filter teams by playing groups if it is a group fixture
    final match = tournament.matches.firstWhere(
      (m) => m.matchNumber == _selectedMatchNumber,
      orElse: () => Match(matchNumber: _selectedMatchNumber, results: []),
    );
    final playingGroups = match.playingGroups;
    final List<Team> filteredTeams = (tournament.format == 'group_fixtures' && playingGroups != null)
        ? tournament.teams.where((team) => playingGroups.contains(team.group)).toList()
        : tournament.teams;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MATCH RESULTS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppTheme.accentGold),
            tooltip: 'Save Results',
            onPressed: () => _saveResults(viewModel, filteredTeams),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          // Match Selector bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SELECT MATCH',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 18,
                    letterSpacing: 1.2,
                    color: AppTheme.accentGold,
                  ),
                ),
                DropdownButton<int>(
                  value: _selectedMatchNumber,
                  dropdownColor: AppTheme.surfaceCard,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  underline: Container(height: 1.5, color: AppTheme.accentGold),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMatchNumber = val;
                        _loadMatchResults();
                      });
                    }
                  },
                  items: List.generate(tournament.numberOfMatches, (index) => index + 1).map((mNum) {
                    final m = tournament.matches.firstWhere(
                      (matchItem) => matchItem.matchNumber == mNum,
                      orElse: () => Match(matchNumber: mNum, results: []),
                    );
                    final groupsText = (tournament.format == 'group_fixtures' && m.playingGroups != null)
                        ? ' (${m.playingGroups!.join(' vs ')})'
                        : '';
                    return DropdownMenuItem<int>(
                      value: mNum,
                      child: Text('MATCH #$mNum$groupsText'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Main data entry list
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredTeams.length,
                itemBuilder: (context, index) {
                  final team = filteredTeams[index];
                  return _buildTeamInputRow(context, filteredTeams.length, team, index + 1);
                },
              ),
            ),
          ),

          // Bottom Action Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _saveResults(viewModel, filteredTeams),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('SAVE MATCH $_selectedMatchNumber RESULTS'),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamInputRow(BuildContext context, int totalActiveTeams, Team team, int displayIndex) {
    final theme = Theme.of(context);
    final tournament = Provider.of<TournamentViewModel>(context, listen: false).activeTournament!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkCardGradient),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Team index indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$displayIndex',
                    style: GoogleFonts.bebasNeue(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(width: 10),
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
                if (team.group != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.neonBlue.withOpacity(0.15),
                      border: Border.all(color: AppTheme.neonBlue, width: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'GROUP ${team.group}',
                      style: GoogleFonts.bebasNeue(fontSize: 10, color: AppTheme.neonBlue, letterSpacing: 0.5),
                    ),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank Dropdown Selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLACEMENT',
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int?>(
                        value: _selectedPlacements[team.id],
                        dropdownColor: AppTheme.surfaceCard,
                        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('-', style: TextStyle(color: AppTheme.textSecondary)),
                          ),
                          ...List.generate(totalActiveTeams, (i) {
                            final rank = i + 1;
                            return DropdownMenuItem<int?>(
                              value: rank,
                              child: Text('#$rank'),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedPlacements[team.id] = val;
                          });
                        },
                        validator: (val) {
                          if (val != null && val > 0) {
                            final count = _selectedPlacements.values.where((v) => v == val).length;
                            if (count > 1) {
                              return 'Dup';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Finishes Input
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.gameCategory == 'bgmi'
                            ? 'FINISHES'
                            : tournament.gameCategory == 'freefire'
                                ? 'ELIMS'
                                : 'KILLS',
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _finishesControllers[team.id],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: '0',
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          final f = int.tryParse(value);
                          if (f == null || f < 0) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Bonus Points
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BONUS PTS',
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _bonusControllers[team.id],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: '0',
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          final b = int.tryParse(value);
                          if (b == null || b < 0) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Penalty Points
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PENALTY PTS',
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _penaltyControllers[team.id],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: '0',
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          final p = int.tryParse(value);
                          if (p == null || p < 0) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveResults(TournamentViewModel viewModel, List<Team> filteredTeams) {
    if (_formKey.currentState?.validate() ?? false) {
      final List<MatchResult> results = [];
      final tournament = viewModel.activeTournament;
      if (tournament == null) return;

      for (var team in tournament.teams) {
        final isPlaying = filteredTeams.any((t) => t.id == team.id);
        if (isPlaying) {
          final placement = _selectedPlacements[team.id] ?? 0;
          final finishesText = _finishesControllers[team.id]?.text.trim() ?? '';
          final bonusText = _bonusControllers[team.id]?.text.trim() ?? '';
          final penaltyText = _penaltyControllers[team.id]?.text.trim() ?? '';

          final finishes = finishesText.isEmpty ? 0 : int.parse(finishesText);
          final bonus = bonusText.isEmpty ? 0 : int.parse(bonusText);
          final penalty = penaltyText.isEmpty ? 0 : int.parse(penaltyText);

          results.add(MatchResult(
            teamId: team.id,
            placement: placement,
            finishes: finishes,
            bonusPoints: bonus,
            penaltyPoints: penalty,
          ));
        } else {
          // Carry over or save empty results for non-participating teams
          results.add(MatchResult(
            teamId: team.id,
            placement: 0,
            finishes: 0,
            bonusPoints: 0,
            penaltyPoints: 0,
          ));
        }
      }

      viewModel.updateMatchResults(_selectedMatchNumber, results);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Match $_selectedMatchNumber results saved successfully!'),
          backgroundColor: AppTheme.accentGold,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Please resolve duplicate placements before saving.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
