import 'package:flutter/material.dart';
import 'package:ilaba/booking_success.dart';

class BookingServiceScreen extends StatefulWidget {
  const BookingServiceScreen({super.key});

  @override
  State<BookingServiceScreen> createState() => _BookingServiceScreenState();
}

class _BookingServiceScreenState extends State<BookingServiceScreen> {
  // State variables
  int washCount = 1;
  int dryCount = 1;
  int ecoBagCount = 0;

  bool washPremium = false;
  bool dryPremium = false;
  bool fold = false;
  bool iron = false;
  bool ecoBagPremium = false;

  int selectedWeight = 8;
  String paymentMethod = "Cash";

  final TextEditingController notesController = TextEditingController();

  // --- Pastel colors ---
  final Color pastelPink = const Color.fromARGB(255, 253, 132, 174);
  final Color pastelGreen = const Color(0xFFC8E6C9);
  final Color pastelBlue = const Color(0xFFBBDEFB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking - Service"),
        backgroundColor: pastelPink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weight dropdown
            DropdownButtonFormField<int>(
              value: selectedWeight,
              items: [for (var i = 8; i <= 40; i += 8) i]
                  .map((w) => DropdownMenuItem(value: w, child: Text("$w kg")))
                  .toList(),
              onChanged: (val) => setState(() => selectedWeight = val!),
              decoration: InputDecoration(
                labelText: "Weight",
                filled: true,
                fillColor: pastelBlue.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Wash
            _buildCounterRow(
              label: "Wash",
              count: washCount,
              onDecrement: () {
                if (washCount > 0) setState(() => washCount--);
              },
              onIncrement: () => setState(() => washCount++),
              premiumValue: washPremium,
              onPremiumChanged: (val) => setState(() => washPremium = val!),
            ),

            // Dry
            _buildCounterRow(
              label: "Dry",
              count: dryCount,
              onDecrement: () {
                if (dryCount > 0) setState(() => dryCount--);
              },
              onIncrement: () => setState(() => dryCount++),
              premiumValue: dryPremium,
              onPremiumChanged: (val) => setState(() => dryPremium = val!),
            ),

            // Fold
            _buildCheckboxRow(
              "Fold",
              fold,
              (val) => setState(() => fold = val!),
            ),

            // Iron
            _buildCheckboxRow(
              "Iron",
              iron,
              (val) => setState(() => iron = val!),
            ),

            // Eco bag
            _buildCounterRow(
              label: "Eco bag",
              count: ecoBagCount,
              onDecrement: () {
                if (ecoBagCount > 0) setState(() => ecoBagCount--);
              },
              onIncrement: () => setState(() => ecoBagCount++),
              premiumValue: ecoBagPremium,
              onPremiumChanged: (val) => setState(() => ecoBagPremium = val!),
            ),
            const SizedBox(height: 16),

            // Additional notes
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Additional notes",
                filled: true,
                fillColor: pastelGreen.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment method
            const Text(
              "Payment Method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RadioListTile(
              title: const Text("Cash"),
              activeColor: pastelPink,
              value: "Cash",
              groupValue: paymentMethod,
              onChanged: (val) => setState(() => paymentMethod = val!),
            ),
            RadioListTile(
              title: Row(
                children: [
                  const Text("GCash"),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.upload),
                    color: pastelPink,
                    onPressed: () {
                      // TODO: Upload receipt logic
                    },
                  ),
                ],
              ),
              activeColor: pastelPink,
              value: "GCash",
              groupValue: paymentMethod,
              onChanged: (val) => setState(() => paymentMethod = val!),
            ),
            const SizedBox(height: 16),

            // Totals section
            const Divider(),
            _buildSummaryRow("Subtotal", "₱0.00"),
            _buildSummaryRow("Delivery Fee", "₱0.00"),
            _buildSummaryRow("VAT (inclusive)", "₱0.00"),
            const Divider(),
            _buildSummaryRow("Total", "₱0.00", isBold: true),
            const SizedBox(height: 20),

            // Book button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookingSuccessScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Book Service",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildCounterRow({
    required String label,
    required int count,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required bool premiumValue,
    required ValueChanged<bool?> onPremiumChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 16)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 28),
              color: pastelPink,
              onPressed: onDecrement,
            ),
            Text("$count", style: const TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add, size: 28),
              color: pastelPink,
              onPressed: onIncrement,
            ),
            Row(
              children: [
                const Text("Premium"),
                Checkbox(
                  value: premiumValue,
                  onChanged: onPremiumChanged,
                  activeColor: pastelPink,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckboxRow(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 16)),
        Checkbox(value: value, onChanged: onChanged, activeColor: pastelPink),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
