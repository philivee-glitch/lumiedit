import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/purchase_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  bool _isLoading = false;
  String _selectedProductId = PurchaseService.lifetimeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Go Premium',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Premium icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Remove All Ads',
                  style: AppTheme.displayMedium.copyWith(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enjoy a clean, ad-free editing experience',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Benefits
                _buildBenefit(Icons.block, 'No banner ads'),
                _buildBenefit(Icons.skip_next, 'No interstitial ads'),
                _buildBenefit(Icons.speed, 'Faster experience'),
                _buildBenefit(Icons.favorite, 'Support development'),
                
                const SizedBox(height: 32),
                
                // Subscription options
                _buildPurchaseOption(
                  title: 'Monthly',
                  price: _purchaseService.getProduct(PurchaseService.monthlyId)?.price ?? '\$4.99',
                  subtitle: 'per month',
                  productId: PurchaseService.monthlyId,
                ),
                const SizedBox(height: 12),
                _buildPurchaseOption(
                  title: 'Annual',
                  price: _purchaseService.getProduct(PurchaseService.annualId)?.price ?? '\$24.99',
                  subtitle: 'per year • Save 58%',
                  productId: PurchaseService.annualId,
                  badge: 'POPULAR',
                ),
                const SizedBox(height: 12),
                _buildPurchaseOption(
                  title: 'Lifetime',
                  price: _purchaseService.getProduct(PurchaseService.lifetimeId)?.price ?? '\$49.99',
                  subtitle: 'one-time purchase',
                  productId: PurchaseService.lifetimeId,
                  badge: 'BEST VALUE',
                ),
                
                const SizedBox(height: 24),
                
                // Purchase button
                GestureDetector(
                  onTap: _isLoading ? null : () => _purchase(_selectedProductId),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Continue',
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Restore purchases
                TextButton(
                  onPressed: _restorePurchases,
                  child: Text(
                    'Restore Purchases',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryOrange),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Terms
                Text(
                  'Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period. Manage subscriptions in your Apple ID settings.',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.textTertiary,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryOrange, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOption({
    required String title,
    required String price,
    required String subtitle,
    required String productId,
    String? badge,
  }) {
    final isSelected = _selectedProductId == productId;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedProductId = productId),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: AppTheme.surfaceLight),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : AppTheme.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTheme.bodyLarge.copyWith(
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withOpacity(0.2) : AppTheme.primaryOrange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: AppTheme.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.labelSmall.copyWith(
                      color: isSelected ? Colors.white70 : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: AppTheme.headlineMedium.copyWith(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(String productId) async {
    final product = _purchaseService.getProduct(productId);
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product not available. Please set up products in App Store Connect first.'),
          backgroundColor: AppTheme.primaryOrange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await _purchaseService.buyProduct(product);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: \$e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);
    
    try {
      await _purchaseService.restorePurchases();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchases restored!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: \$e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
