// import 'package:flutter/material.dart';
//
// class SavingsGoalCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 5,
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Savings Goal',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Text('Save ₹50,000 in the next 6 months.'),
//             SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to goal details page
//               },
//               child: Text('Track Progress'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SavingsGoalCard extends StatelessWidget {
  const SavingsGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Savings Goal"),
            const SizedBox(height: 15),
            CircularPercentIndicator(
              radius: 60,
              lineWidth: 10,
              percent: 0.65,
              progressColor: Colors.greenAccent,
              backgroundColor: Colors.black12,
              center: const Text("65%"),
            ),
          ],
        ),
      ),
    );
  }
}
