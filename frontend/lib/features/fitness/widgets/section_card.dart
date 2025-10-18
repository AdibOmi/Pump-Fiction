//import 'package:flutter/material.dart'; import '../models/hub_item.dart'; class SectionCard extends StatelessWidget { const SectionCard({super.key, required this.item}); final HubItem item; @override Widget build(BuildContext context) { return InkWell( borderRadius: BorderRadius.circular(20), onTap: () async { try { await Navigator.of(context, rootNavigator: true).push( MaterialPageRoute(builder: (_) => item.page), ); } catch (e, st) { debugPrint('Navigation error: $e\n$st'); } }, child: Ink( decoration: BoxDecoration( borderRadius: BorderRadius.circular(20), color: Theme.of(context).colorScheme.surface, boxShadow: const [ BoxShadow(blurRadius: 8, offset: Offset(0, 4), color: Colors.black12), ], ), child: Padding( padding: const EdgeInsets.all(16), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(item.icon, size: 40), const SizedBox(height: 12), Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)), const SizedBox(height: 6), Text( 'Tap to open', style: TextStyle( fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(.6), ), ), ], ), ), ), ); } }
// import 'package:flutter/material.dart';
// import '../models/hub_item.dart';

// class SectionCard extends StatelessWidget {
//   const SectionCard({super.key, required this.item});
//   final HubItem item;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(20),
//       onTap: () async {
//   try {
//     await Navigator.of(context, rootNavigator: true).push(
//       MaterialPageRoute(builder: (_) => item.page),
//     );
//   } catch (e, st) {
//     debugPrint('Navigation error: $e\n$st');
//   }
// },

//       child: Ink(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           color: Theme.of(context).colorScheme.surface,
//           boxShadow: const [
//             BoxShadow(blurRadius: 8, offset: Offset(0, 4), color: Colors.black12),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(item.icon, size: 40),
//               const SizedBox(height: 12),
//               Text(item.title,
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//               const SizedBox(height: 6),
//               Text(
//                 'Tap to open',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Theme.of(context).colorScheme.onSurface.withOpacity(.6),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/hub_item.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.item});
  final HubItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: () async {
        try {
          await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => item.page),
          );
        } catch (e, st) {
          debugPrint('Navigation error: $e\n$st');
        }
      },
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Circular pink icon area
                  Container(
                    width: 55,
                    height: 55,
                    decoration: const BoxDecoration(
                      color: Color(0xFF27C7C9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title text
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Right arrow button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
