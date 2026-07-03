import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/tournament_viewmodel.dart';
import '../../theme/theme.dart';
import '../../data/models.dart';
import 'team_management_screen.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalTeamsController = TextEditingController(text: '16');
  String _selectedCategory = 'bgmi'; // 'bgmi', 'pubg', 'freefire', 'custom'
  String _selectedFormat = 'classic'; // 'classic' or 'group_fixtures'
  int _groupCount = 3; // Default to 3 groups (A, B, C) if group format chosen
  int _matchCount = 5;
  int _teamCount = 16;
  PointSystem? _selectedPointSystem;

  // Group Fixture Options
  int _teamsPerMatch = 16;
  int _teamsPerGroup = 16;
  String _qualifyRule = 'Top 8'; // Top 4, Top 6, Top 8, Top 10, Custom
  int _customQualifyCount = 8;
  String _distributionType = 'auto'; // 'auto' or 'manual'

  final List<int> _teamCountOptions = [8, 12, 16, 20, 24];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<TournamentViewModel>(context, listen: false);
      vm.loadPresets();
      if (vm.presets.isNotEmpty) {
        setState(() {
          // Select default bgmi system initially
          _selectedPointSystem = vm.presets.firstWhere(
            (p) => p.id == 'bgmi_default',
            orElse: () => vm.presets.first,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalTeamsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = Provider.of<TournamentViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CREATE TOURNAMENT'),
      ),
      body: Form(
        key: _formKey,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tournament Name Input
                  Text(
                    'TOURNAMENT DETAILS',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 20,
                      letterSpacing: 1.5,
                      color: AppTheme.accentGold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Tournament Name',
                      hintText: 'e.g., BGMI Scrims Season 1',
                      prefixIcon: Icon(Icons.emoji_events, color: AppTheme.accentGold),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a tournament name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Game Category Selector
                  Text(
                    'GAME CATEGORY',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 20,
                      letterSpacing: 1.5,
                      color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildCategoryButton('bgmi', 'BGMI', const Color(0xFFF39C12))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildCategoryButton('pubg', 'PUBG', const Color(0xFFE74C3C))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildCategoryButton('freefire', 'FREE FIRE', const Color(0xFFE67E22))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildCategoryButton('custom', 'CUSTOM', const Color(0xFF3498DB))),
                ],
              ),
              const SizedBox(height: 24),

              // Tournament Format Selector
              Text(
                'TOURNAMENT FORMAT / FIXTURE TYPE',
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  letterSpacing: 1.5,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFormatButton('classic', 'CLASSIC (ALL-IN)', Icons.layers_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFormatButton('group_fixtures', 'GROUP FIXTURES', Icons.grid_view_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Group Fixtures Configuration (Only shown if Group Fixtures is chosen)
              if (_selectedFormat == 'group_fixtures') ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TEAMS PER MATCH',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 15,
                          letterSpacing: 1,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [12, 16, 20].map((tpm) {
                          final isSelected = _teamsPerMatch == tpm;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: InkWell(
                                onTap: () => setState(() => _teamsPerMatch = tpm),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.neonBlue : AppTheme.surface,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.neonBlue : AppTheme.dividerColor,
                                    ),
                                  ),
                                  child: Text(
                                    '$tpm Teams',
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 14,
                                      color: isSelected ? AppTheme.background : AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Qualification Rules
                      Text(
                        'QUALIFICATION RULES (QUALIFY PER GROUP)',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 15,
                          letterSpacing: 1,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _qualifyRule,
                        dropdownColor: AppTheme.surfaceCard,
                        style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: ['Top 4', 'Top 6', 'Top 8', 'Top 10', 'Custom'].map((rule) {
                          return DropdownMenuItem<String>(
                            value: rule,
                            child: Text(rule),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _qualifyRule = val;
                              if (val != 'Custom') {
                                _customQualifyCount = int.parse(val.split(' ')[1]);
                              }
                            });
                          }
                        },
                      ),
                      if (_qualifyRule == 'Custom') ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _customQualifyCount.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Custom Qualify Count',
                            hintText: 'e.g. 5',
                          ),
                          style: const TextStyle(color: AppTheme.textPrimary),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null && parsed > 0) {
                              _customQualifyCount = parsed;
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Distribution Type
                      Text(
                        'TEAM DISTRIBUTION TYPE',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 15,
                          letterSpacing: 1,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _distributionType == 'auto' ? AppTheme.accentGold : AppTheme.surface,
                                foregroundColor: _distributionType == 'auto' ? AppTheme.background : AppTheme.textPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => setState(() => _distributionType = 'auto'),
                              child: const Text('AUTO'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _distributionType == 'manual' ? AppTheme.accentGold : AppTheme.surface,
                                foregroundColor: _distributionType == 'manual' ? AppTheme.background : AppTheme.textPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => setState(() => _distributionType = 'manual'),
                              child: const Text('MANUAL'),
                            ),
                          ),
                        ],
                      ),
                      if (_distributionType == 'auto') ...[
                        const SizedBox(height: 16),
                        Text(
                          'TEAMS PER GROUP',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 13,
                            letterSpacing: 1,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _teamsPerGroup,
                          dropdownColor: AppTheme.surfaceCard,
                          style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                          items: [8, 12, 16, 20, 24].map((count) {
                            return DropdownMenuItem<int>(
                              value: count,
                              child: Text('$count Teams'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _teamsPerGroup = val);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Match Count Selector
              Text(
                'TOTAL MATCHES',
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  letterSpacing: 1.5,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_matchCount Matches',
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppTheme.neonBlue),
                          onPressed: _matchCount > 1 ? () => setState(() => _matchCount--) : null,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppTheme.neonBlue),
                          onPressed: _matchCount < 50 ? () => setState(() => _matchCount++) : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Team Count Selection
              Text(
                'NUMBER OF TEAMS',
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  letterSpacing: 1.5,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedFormat == 'group_fixtures') ...[
                TextFormField(
                  controller: _totalTeamsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Total Teams',
                    hintText: 'e.g., 16, 32, 64, 128, 256, 512, 1024',
                    prefixIcon: Icon(Icons.people, color: AppTheme.neonBlue),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter total number of teams';
                    }
                    final count = int.tryParse(value);
                    if (count == null || count <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) {
                      setState(() {
                        _teamCount = parsed;
                      });
                    }
                  },
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _teamCountOptions.map((count) {
                    final isSelected = _teamCount == count;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () => setState(() => _teamCount = count),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.accentGold : AppTheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? AppTheme.accentGold : AppTheme.dividerColor,
                              ),
                            ),
                            child: Text(
                              '$count',
                              style: GoogleFonts.bebasNeue(
                                fontSize: 18,
                                color: isSelected ? AppTheme.background : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),

              // Point System Preset Selector
              Text(
                'POINT SYSTEM',
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  letterSpacing: 1.5,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(height: 12),
              if (viewModel.presets.isNotEmpty)
                DropdownButtonFormField<PointSystem>(
                  value: _selectedPointSystem ?? viewModel.presets.first,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.rule, color: AppTheme.neonBlue),
                  ),
                  dropdownColor: AppTheme.surfaceCard,
                  items: viewModel.presets.map((preset) {
                    return DropdownMenuItem<PointSystem>(
                      value: preset,
                      child: Text(
                        preset.name,
                        style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedPointSystem = val;
                    });
                  },
                )
              else
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Loading scoring options...'),
                ),
              const SizedBox(height: 48),

              // Submit Button
              ElevatedButton(
                onPressed: () => _submitForm(viewModel),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('CONTINUE TO TEAM SETUP'),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _buildCategoryButton(String cat, String label, Color color) {
    final isSelected = _selectedCategory == cat;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = cat;
          final vm = Provider.of<TournamentViewModel>(context, listen: false);
          if (cat == 'bgmi') {
            final found = vm.presets.firstWhere((p) => p.id == 'bgmi_default', orElse: () => vm.presets.first);
            _selectedPointSystem = found;
          } else if (cat == 'pubg') {
            final found = vm.presets.firstWhere((p) => p.id == 'pubg_default', orElse: () => vm.presets.first);
            _selectedPointSystem = found;
          } else if (cat == 'freefire') {
            final found = vm.presets.firstWhere((p) => p.id == 'freefire_default', orElse: () => vm.presets.first);
            _selectedPointSystem = found;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppTheme.dividerColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.bebasNeue(
            fontSize: 13,
            letterSpacing: 0.5,
            color: isSelected ? color : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildFormatButton(String format, String label, IconData icon) {
    final isSelected = _selectedFormat == format;
    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGold : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : AppTheme.dividerColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppTheme.background : AppTheme.accentGold,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(
                fontSize: 14,
                letterSpacing: 1,
                color: isSelected ? AppTheme.background : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm(TournamentViewModel viewModel) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedPointSystem == null && viewModel.presets.isNotEmpty) {
        _selectedPointSystem = viewModel.presets.first;
      }
      if (_selectedPointSystem == null) return;

      List<String>? groupNames;
      if (_selectedFormat == 'group_fixtures') {
        if (_distributionType == 'auto') {
          final int numGroups = (_teamCount / _teamsPerGroup).ceil();
          final greekNames = ['Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon', 'Zeta', 'Eta', 'Theta', 'Iota', 'Kappa', 'Lambda', 'Mu', 'Nu', 'Xi', 'Omicron', 'Pi', 'Rho', 'Sigma', 'Tau', 'Upsilon', 'Phi', 'Chi', 'Psi', 'Omega'];
          groupNames = List.generate(numGroups, (i) {
            if (i < greekNames.length) {
              return 'Group ${greekNames[i]}';
            } else {
              return 'Group ${i + 1}';
            }
          });
        } else {
          groupNames = ['Group Alpha', 'Group Beta'];
        }
      }

      await viewModel.createTournament(
        name: _nameController.text.trim(),
        numberOfMatches: _matchCount,
        numberOfTeams: _teamCount,
        pointSystem: _selectedPointSystem!,
        format: _selectedFormat,
        numberOfGroups: _selectedFormat == 'group_fixtures' ? groupNames?.length : null,
        gameCategory: _selectedCategory,
        groupNames: groupNames,
        qualifyCount: _selectedFormat == 'group_fixtures' ? _customQualifyCount : null,
        teamsPerMatch: _selectedFormat == 'group_fixtures' ? _teamsPerMatch : null,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeamManagementScreen()),
        );
      }
    }
  }
}
