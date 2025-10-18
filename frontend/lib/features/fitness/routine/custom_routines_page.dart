import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine_models.dart';
import '../state/routines_provider.dart';
import 'routine_builder_page.dart';

class CustomRoutinesPage extends ConsumerWidget {
  const CustomRoutinesPage({super.key});

  Future<void> _createRoutine(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<RoutinePlan>(
      MaterialPageRoute(builder: (_) => const RoutineBuilderPage()),
    );
    if (result != null) {
      ref.read(routinesProvider.notifier).add(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine saved')),
      );
    }
  }

  Future<void> _editRoutine(BuildContext context, WidgetRef ref, RoutinePlan plan) async {
    final result = await Navigator.of(context).push<RoutinePlan>(
      MaterialPageRoute(builder: (_) => RoutineBuilderPage(initial: plan)),
    );
    if (result != null) {
      ref.read(routinesProvider.notifier).update(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine updated')),
      );
    }
  }

  void _deleteRoutine(BuildContext context, WidgetRef ref, RoutinePlan plan) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete routine?'),
        content: Text('This will remove "${plan.title}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      ref.read(routinesProvider.notifier).remove(plan.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Custom Programs')),
      body: routines.isEmpty
          ? Center(
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Text('Add New Routine', style: TextStyle(fontSize: 16)),
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
          : FloatingActionButton.extended(
              onPressed: () => _createRoutine(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Routine'),
            ),
    );
  }
}

// class _RoutineCard extends StatelessWidget {
//   const _RoutineCard({required this.plan, required this.onEdit, required this.onDelete});
//   final RoutinePlan plan;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   @override
//   Widget build(BuildContext context) {
//     final title = plan.title.trim().isEmpty ? '(Untitled)' : plan.title;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 14),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
//             const SizedBox(height: 8),
//             ...plan.dayPlans.where((d) => d.exercises.isNotEmpty).map((d) => Padding(
//               padding: const EdgeInsets.only(bottom: 6),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('- ${d.label}', style: const TextStyle(fontWeight: FontWeight.w600)),
//                   ...d.exercises.map((e) => Padding(
//                         padding: const EdgeInsets.only(left: 12, top: 2),
//                         child: Text('• ${e.name} — ${e.sets} sets, ${e.minReps}-${e.maxReps} reps'),
//                       )),
//                 ],
//               ),
//             )),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit), label: const Text('Edit')),
//                 const SizedBox(width: 8),
//                 TextButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_outline), label: const Text('Delete')),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.plan, required this.onEdit, required this.onDelete});
  final RoutinePlan plan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = plan.title.trim().isEmpty ? '(Untitled)' : plan.title;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {}, // optional: maybe open routine details
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
                child: 

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0,top:4.0),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 207, 207, 207)
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
                      icon: const Icon(Icons.edit, color: Color.fromARGB(255, 255, 255, 255), size: 20),
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
                      icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
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
