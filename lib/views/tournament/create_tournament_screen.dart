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
          _selectedPointSystem = vm.presets.first;
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
                          onPressed: _matchCount > 1
                              ? () => setState(() => _matchCount--)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppTheme.neonBlue),
                          onPressed: _matchCount < 50
                              ? () => setState(() => _matchCount++)
                              : null,
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
