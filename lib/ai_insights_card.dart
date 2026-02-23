// import 'package:flutter/material.dart';
//
// class AIInsightsCard extends StatelessWidget {
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
//               'AI Spending Insights',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Text('Prediction: You will spend ₹5000 more on food this month.'),
//             SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to insights detail page
//               },
//               child: Text('View Details'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class AIInsightsCard extends StatelessWidget {
  const AIInsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "AI Insights 🤖",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "You spent 18% more on food this month. Consider reducing dining expenses.",
            ),
          ],
        ),
      ),
    );
  }
}
