import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4C9E57), // Green Header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "FAQ",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- QUESTIONS LIST ---

            const _FaqItem(
              question: "Where do you Deliver?",
              answer: "We currently deliver to most areas in Attock and Islamabad. You can check availability by entering your pincode at checkout."
            ),

            const _FaqItem(
              question: "How can I order at MYBasket?",
              answer: "Placing an order is very simple. Just register on the MYBasket mobile application, pick your choice of products with a wide range of selection in the online store, proceed to checkout, and place your order."
            ),

            const _FaqItem(
              question: "How do I know my delivery time?",
              answer: "Once your order is confirmed, you will receive an SMS and email with the estimated delivery slot. You can also track your order status in the 'My Orders' section."
            ),

            const _FaqItem(
              question: "What is minimum order value?",
              answer: "Good news! There is no minimum order value for standard delivery. However, orders below \$10 may incur a small delivery fee."
            ),

            const _FaqItem(
              question: "What if I want to return something?",
              answer: "We have a 'no questions asked' return policy at the time of delivery. If you are not satisfied with the quality of any product, you can return it immediately to the delivery partner."
            ),

            const SizedBox(height: 30),

            // --- QUERY FORM SECTION ---
            const Text(
              "Not Listed Your Question/Query?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const TextField(
                maxLines: 5, // Makes it a taller text box
                decoration: InputDecoration(
                  hintText: "Write Your Question/Query Here",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- SUBMIT BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C9E57),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  // Simulation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Query submitted! We will contact you soon.")),
                  );

                },
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- HELPER WIDGET FOR EXPANDABLE QUESTIONS ---
class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FBF4), // Light green background for the box
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(

        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          textColor: Colors.black, // Color of title when expanded
          iconColor: Colors.black, // Color of arrow when expanded
          collapsedIconColor: Colors.black,
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(color: Colors.black54, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}