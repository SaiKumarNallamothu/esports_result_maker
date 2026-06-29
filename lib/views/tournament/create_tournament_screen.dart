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
  String _selectedCategory = 'bgmi'; // 'bgmi', 'pubg', 'freefire', 'custom'
  String _selectedFormat = 'classic'; // 'classic' or 'group_fixtures'
  int _groupCount = 3; // Default to 3 groups (A, B, C) if group format chosen
  int _matchCount = 5;
  int _teamCount = 16;
  PointSystem? _selectedPointSystem;

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

              // Group Count Selector (Only shown if Group Fixtures is chosen)
              if (_selectedFormat == 'group_fixtures') ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NUMBER OF GROUPS',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 15,
                          letterSpacing: 1,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [2, 3, 4].map((count) {
                          final isSelected = _groupCount == count;
                          final groupNames = List.generate(count, (i) => String.fromCharCode(65 + i)).join(', ');
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: InkWell(
                                onTap: () => setState(() => _groupCount = count),
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
                                  child: Column(
                                    children: [
                                      Text(
                                        '$count Groups',
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 16,
                                          color: isSelected ? AppTheme.background : AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '($groupNames)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isSelected ? AppTheme.background.withOpacity(0.8) : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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

      await viewModel.createTournament(
        name: _nameController.text.trim(),
        numberOfMatches: _matchCount,
        numberOfTeams: _teamCount,
        pointSystem: _selectedPointSystem!,
        format: _selectedFormat,
        numberOfGroups: _selectedFormat == 'group_fixtures' ? _groupCount : null,
        gameCategory: _selectedCategory,
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
