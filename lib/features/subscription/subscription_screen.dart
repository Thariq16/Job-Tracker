import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Plan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Upgrade to unlock powerful features',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Free Tier
            _PricingCard(
              title: 'Free',
              price: '\$0',
              period: 'forever',
              isRecommended: false,
              features: const [
                FeatureItem('Track up to 25 jobs', true),
                FeatureItem('Basic URL parsing', true),
                FeatureItem('Manual job entry', true),
                FeatureItem('Hiring manager tracking', false),
                FeatureItem('Analytics dashboard', false),
                FeatureItem('AI-powered suggestions', false),
                FeatureItem('Export to CSV', false),
              ],
              buttonText: 'Current Plan',
              onPressed: null,
              backgroundColor: Colors.grey[100]!,
              borderColor: Colors.grey[300]!,
            ),
            
            const SizedBox(height: 16),
            
            // Pro Tier (Recommended)
            _PricingCard(
              title: 'Pro',
              price: '\$9',
              period: '/month',
              annualPrice: '\$79/year (save 27%)',
              isRecommended: true,
              features: const [
                FeatureItem('Unlimited job tracking', true),
                FeatureItem('Advanced URL parsing', true),
                FeatureItem('Hiring manager tracking', true),
                FeatureItem('Follow-up reminders', true),
                FeatureItem('Analytics dashboard', true),
                FeatureItem('Export to CSV/PDF', true),
                FeatureItem('AI resume suggestions', false, partial: true),
                FeatureItem('AI interview prep', false),
              ],
              buttonText: 'Upgrade to Pro',
              onPressed: () => _showPaymentDialog(context, 'Pro'),
              backgroundColor: const Color(0xFFEEF2FF),
              borderColor: Colors.indigo,
            ),
            
            const SizedBox(height: 16),
            
            // Premium Tier
            _PricingCard(
              title: 'Premium',
              price: '\$19',
              period: '/month',
              annualPrice: '\$149/year (save 35%)',
              isRecommended: false,
              features: const [
                FeatureItem('Everything in Pro', true),
                FeatureItem('AI resume tailoring', true),
                FeatureItem('AI cover letter generator', true),
                FeatureItem('AI interview preparation', true),
                FeatureItem('Smart job matching', true),
                FeatureItem('Priority support', true),
                FeatureItem('Early access to features', true),
              ],
              buttonText: 'Go Premium',
              onPressed: () => _showPaymentDialog(context, 'Premium'),
              backgroundColor: const Color(0xFFFDF4FF),
              borderColor: Colors.purple,
            ),
            
            const SizedBox(height: 32),
            
            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _FAQItem(
              question: 'Can I cancel anytime?',
              answer: 'Yes! You can cancel your subscription at any time. Your access will continue until the end of your billing period.',
            ),
            _FAQItem(
              question: 'Is there a free trial?',
              answer: 'The Free tier is always available. Pro and Premium features can be tried for 7 days before committing.',
            ),
            _FAQItem(
              question: 'What payment methods do you accept?',
              answer: 'We accept all major credit cards, PayPal, and Apple Pay.',
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, String plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade to $plan'),
        content: Text('Payment integration coming soon! You selected the $plan plan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class FeatureItem {
  final String text;
  final bool included;
  final bool partial;

  const FeatureItem(this.text, this.included, {this.partial = false});
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? annualPrice;
  final bool isRecommended;
  final List<FeatureItem> features;
  final String buttonText;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color borderColor;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    this.annualPrice,
    required this.isRecommended,
    required this.features,
    required this.buttonText,
    required this.onPressed,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isRecommended ? 2 : 1),
        boxShadow: isRecommended
            ? [BoxShadow(color: borderColor.withAlpha(51), blurRadius: 12, offset: const Offset(0, 4))]
            : null,
      ),
      child: Stack(
        children: [
          if (isRecommended)
            Positioned(
              top: 0,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  'RECOMMENDED',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isRecommended ? Colors.indigo : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      period,
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (annualPrice != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    annualPrice!,
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.green[700]),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                ...features.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        f.included 
                            ? Icons.check_circle 
                            : (f.partial ? Icons.remove_circle : Icons.cancel),
                        size: 18,
                        color: f.included 
                            ? Colors.green 
                            : (f.partial ? Colors.orange : Colors.grey[400]),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          f.text,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: f.included ? Colors.black87 : Colors.grey[500],
                            decoration: f.included ? null : TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onPressed != null 
                          ? (isRecommended ? Colors.indigo : Colors.purple)
                          : Colors.grey[300],
                      foregroundColor: onPressed != null ? Colors.white : Colors.grey[600],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      buttonText,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: GoogleFonts.inter(color: Colors.grey[600])),
        ),
      ],
    );
  }
}
