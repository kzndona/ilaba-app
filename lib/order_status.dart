import 'package:flutter/material.dart';

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int currentStep = 2; // Example: status index

    List<String> steps = [
      "Order Placed",
      "Our rider is on their way",
      "Picked up",
      "Processing",
      "Ready for delivery",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Status"),
        backgroundColor: const Color.fromARGB(255, 253, 132, 174),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order #12345",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Timeline
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  bool isActive = index <= currentStep;
                  bool isCurrent = index == currentStep;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline indicator
                      Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isCurrent ? 26 : 20,
                            height: isCurrent ? 26 : 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? const Color.fromARGB(255, 253, 132, 174)
                                  : Colors.grey.shade300,
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: Colors.pink.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: isCurrent
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          // Line below (except last)
                          if (index != steps.length - 1)
                            Container(
                              width: 2,
                              height: 50,
                              color: isActive
                                  ? const Color.fromARGB(255, 253, 132, 174)
                                  : Colors.grey.shade300,
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Step text
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color.fromARGB(255, 253, 240, 246)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive
                                  ? const Color.fromARGB(255, 253, 132, 174)
                                  : Colors.grey.shade300,
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            steps[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isActive ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Confirm button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  backgroundColor: const Color.fromARGB(255, 253, 132, 174),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "Confirm",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
