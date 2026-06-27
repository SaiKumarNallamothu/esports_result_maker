import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/tournament_viewmodel.dart';
import '../../theme/theme.dart';

class PresetsDialog extends StatefulWidget {
  const PresetsDialog({super.key});

  @override
  State<PresetsDialog> createState() => _PresetsDialogState();
}

class _PresetsDialogState extends State<PresetsDialog> {
  bool _isCreating = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _killPointsController = TextEditingController(text: '1');

  // Custom tiebreaker hierarchy state
  String _tiebreaker1 = 'wwcd';
  String _tiebreaker2 = 'finishes';
  String _tiebreaker3 = 'placementPoints';

  // We will configure positions 1 to 16 by default in the custom creator
  final Map<int, TextEditingController> _positionControllers = {
    for (int i = 1; i <= 16; i++)
      i: TextEditingController(
        text: i == 1
            ? '15'
            : i == 2
                ? '12'
                : i == 3
                    ? '10'
                    : i == 4
                        ? '8'
                        : i == 5
                            ? '6'
                            : i == 6
                                ? '4'
                                : i == 7
                                    ? '2'
                                    : i <= 12
                                        ? '1'
                                        : '0',
      ),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TournamentViewModel>(context, listen: false).loadPresets();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _killPointsController.dispose();
    for (var controller in _positionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = Provider.of<TournamentViewModel>(context);

    return Dialog(
      backgroundColor: AppTheme.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.dividerColor),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: _isCreating ? _buildCreatePresetView(theme, viewModel) : _buildPresetsListView(theme, viewModel),
      ),
    );
  }

  Widget _buildPresetsListView(ThemeData theme, TournamentViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SCORING PRESETS',
              style: GoogleFonts.bebasNeue(
                fontSize: 24,
                letterSpacing: 1.5,
                color: AppTheme.accentGold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.textSecondary),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const Divider(color: AppTheme.dividerColor),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: viewModel.presets.length,
            itemBuilder: (context, index) {
              final preset = viewModel.presets[index];
              final isDefault =
                  preset.id == 'bgmi_default' || preset.id == 'bgis_new' || preset.id == 'pubg_default';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1 Kill = ${preset.finishPoints} Pt | 1st Place = ${preset.positionPoints[1] ?? 0} Pts',
                            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tiebreaker hierarchy: ${preset.tiebreakerOrder.map((e) => e == 'wwcd' ? 'WWCD' : e == 'finishes' ? 'Kills' : 'Placement Pts').join(' > ')}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 10,
                              color: AppTheme.accentGold.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                        ),
                        child: Text(
                          'SYSTEM',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 12,
                            letterSpacing: 1,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => viewModel.deleteCustomPreset(preset.id),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isCreating = true;
            });
          },
          child: const Text('CREATE NEW PRESET'),
        ),
      ],
    );
  }

  Widget _buildCreatePresetView(ThemeData theme, TournamentViewModel viewModel) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NEW PRESET',
                style: GoogleFonts.bebasNeue(
                  fontSize: 24,
                  letterSpacing: 1.5,
                  color: AppTheme.accentGold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary),
                onPressed: () {
                  setState(() {
                    _isCreating = false;
                  });
                },
              ),
            ],
          ),
          const Divider(color: AppTheme.dividerColor),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Preset Name',
                        hintText: 'e.g., Local Tournament v2',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a preset name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _killPointsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Points Per Finish (Kill)',
                        hintText: '1',
                      ),
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Tiebreaker selection
                    Text(
                      'TIEBREAKER PRIORITY',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 18,
                        letterSpacing: 1.2,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTiebreakerDropdown('1st Tiebreaker (Primary)', _tiebreaker1, (val) {
                      if (val != null) {
                        setState(() {
                          _tiebreaker1 = val;
                        });
                      }
                    }),
                    const SizedBox(height: 12),
                    _buildTiebreakerDropdown('2nd Tiebreaker (Secondary)', _tiebreaker2, (val) {
                      if (val != null) {
                        setState(() {
                          _tiebreaker2 = val;
                        });
                      }
                    }),
                    const SizedBox(height: 12),
                    _buildTiebreakerDropdown('3rd Tiebreaker (Tertiary)', _tiebreaker3, (val) {
                      if (val != null) {
                        setState(() {
                          _tiebreaker3 = val;
                        });
                      }
                    }),
                    const SizedBox(height: 24),

                    Text(
                      'POSITION POINTS',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 18,
                        letterSpacing: 1.2,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 16,
                      itemBuilder: (context, index) {
                        final rank = index + 1;
                        return Row(
                          children: [
                            Container(
                              width: 45,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.dividerColor),
                              ),
                              child: Text(
                                '#$rank',
                                style: GoogleFonts.bebasNeue(
                                  color: rank == 1 ? AppTheme.accentGold : AppTheme.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _positionControllers[rank],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                validator: (value) {
                                  if (value == null || int.tryParse(value) == null) {
                                    return 'Err';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    setState(() {
                      _isCreating = false;
                    });
                  },
                  child: Text(
                    'CANCEL',
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
                  onPressed: () => _savePreset(viewModel),
                  child: const Text('SAVE PRESET'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTiebreakerDropdown(String label, String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppTheme.surfaceCard,
      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      items: const [
        DropdownMenuItem(value: 'wwcd', child: Text('WWCD (Chicken Dinners)')),
        DropdownMenuItem(value: 'finishes', child: Text('Finishes (Total Kills)')),
        DropdownMenuItem(value: 'placementPoints', child: Text('Placement Points Only')),
      ],
      onChanged: onChanged,
    );
  }

  void _savePreset(TournamentViewModel viewModel) {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final killPoints = int.parse(_killPointsController.text.trim());

      final Map<int, int> positionPoints = {};
      _positionControllers.forEach((rank, controller) {
        positionPoints[rank] = int.parse(controller.text.trim());
      });

      // Save custom tiebreaker hierarchy
      final tiebreakerHierarchy = [_tiebreaker1, _tiebreaker2, _tiebreaker3];

      viewModel.saveCustomPreset(name, positionPoints, killPoints, tiebreakerHierarchy);

      setState(() {
        _isCreating = false;
        _nameController.clear();
        _killPointsController.text = '1';
        _tiebreaker1 = 'wwcd';
        _tiebreaker2 = 'finishes';
        _tiebreaker3 = 'placementPoints';
      });
    }
  }
}
