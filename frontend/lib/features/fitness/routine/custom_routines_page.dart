import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine_models.dart';
import '../state/routines_provider.dart';
import 'routine_builder_page.dart';
import '../../../l10n/app_localizations.dart';

class CustomRoutinesPage extends ConsumerWidget {
  const CustomRoutinesPage({super.key});

  Future<void> _createRoutine(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await Navigator.of(context).push<RoutinePlan>(
      MaterialPageRoute(builder: (_) => const RoutineBuilderPage()),
    );
    if (result != null) {
      ref.read(routinesProvider.notifier).add(result);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.routineSaved)));
    }
  }

  Future<void> _editRoutine(
    BuildContext context,
    WidgetRef ref,
    RoutinePlan plan,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await Navigator.of(context).push<RoutinePlan>(
      MaterialPageRoute(builder: (_) => RoutineBuilderPage(initial: plan)),
    );
    if (result != null) {
      ref.read(routinesProvider.notifier).update(result);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.routineUpdated)));
    }
  }

  void _deleteRoutine(
    BuildContext context,
    WidgetRef ref,
    RoutinePlan plan,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteRoutineQuestion),
        content: Text(l10n.deleteRoutineContent(plan.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(routinesProvider.notifier).remove(plan.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.routineDeleted)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customPrograms)),
      body: routines.isEmpty
          ? Center(
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    l10n.addNewRoutine,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                onPressed: () => _createRoutine(context, ref),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: routines.length,
              itemBuilder: (context, i) => _RoutineCard(
                plan: routines[i],
                onEdit: () => _editRoutine(context, ref, routines[i]),
                onDelete: () => _deleteRoutine(context, ref, routines[i]),
              ),
            ),
      floatingActionButton: routines.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => _createRoutine(context, ref),
              child: const Icon(Icons.add),
              tooltip: 'Add routine',
            ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.plan,
    required this.onEdit,
    required this.onDelete,
  });
  final RoutinePlan plan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  void _showDetails(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...plan.dayPlans.map((d) {
                            if (d.exercises.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  ...d.exercises.map((e) => Padding(
                                        padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                                        child: Text('• ${e.name} — ${e.sets} sets, ${e.minReps}-${e.maxReps} reps'),
                                      )),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = plan.title.trim().isEmpty ? l10n.untitled : plan.title;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => _showDetails(context),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Routine title & exercises
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 207, 207, 207),
                    ),
                  ),
                ),

                // const SizedBox(height: 8),
                // ...plan.dayPlans.where((d) => d.exercises.isNotEmpty).map(
                //   (d) => Padding(
                //     padding: const EdgeInsets.only(bottom: 6),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text('- ${d.label}', style: const TextStyle(fontWeight: FontWeight.w600)),
                //         ...d.exercises.map(
                //           (e) => Padding(
                //             padding: const EdgeInsets.only(left: 12, top: 2),
                //             child: Text('• ${e.name} — ${e.sets} sets, ${e.minReps}-${e.maxReps} reps'),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ),

              // Right side: Edit & Delete buttons
              Row(
                children: [
                  // Edit icon with background
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27C7C9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Color.fromARGB(255, 255, 255, 255),
                        size: 20,
                      ),
                      onPressed: onEdit,
                    ),
                  ),
                  // Delete icon with red background
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 199, 59, 49),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: onDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
