// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:provider/provider.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../services/trial_service.dart';

// class TrialBanner extends StatelessWidget {
//   const TrialBanner({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<TrialService>(
//       builder: (context, trialService, child) {
//         // Don't show banner if trial is expired (handled by main app)
//         if (trialService.isTrialExpired) {
//           return const SizedBox.shrink();
//         }

//         final remainingDays = trialService.remainingDays;
//         final theme = Theme.of(context);
        
//         // Determine banner color based on remaining days
//         Color bannerColor;
//         Color textColor;
//         IconData icon;
        
//         if (remainingDays <= 1) {
//           bannerColor = AppColors.red;
//           textColor = Colors.white;
//           icon = Iconsax.warning_2;
//         } else if (remainingDays <= 3) {
//           bannerColor = AppColors.gold;
//           textColor = Colors.white;
//           icon = Iconsax.timer_1;
//         } else {
//           bannerColor = AppColors.primaryBlue;
//           textColor = Colors.white;
//           icon = Iconsax.info_circle;
//         }

//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             color: bannerColor,
//             boxShadow: [
//               BoxShadow(
//                 color: bannerColor.withOpacity(0.3),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 icon,
//                 color: textColor,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   trialService.getTrialStatusMessage(),
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: textColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               if (remainingDays <= 3)
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: textColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     remainingDays == 0 
//                         ? 'Today' 
//                         : remainingDays == 1 
//                             ? '1 day' 
//                             : '$remainingDays days',
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: textColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
