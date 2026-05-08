# Pricing Configuration

## Monetization Model: Subscription (IAP)

## Subscription Group

- **Group Name**: PantrySync Premium
- **Group ID**: Auto-generated

## Subscription Tiers

### 1. Monthly Subscription

- **Reference Name**: Monthly Premium
- **Product ID**: `com.zzoutuo.PantrySync.monthly`
- **Price**: $4.99 per month
- **Display Name**: PantrySync Premium Monthly
- **Description**: Full kitchen management, monthly
- **Localization**: English (US)

### 2. Yearly Subscription

- **Reference Name**: Yearly Premium
- **Product ID**: `com.zzoutuo.PantrySync.yearly`
- **Price**: $29.99 per year (50% savings vs monthly)
- **Display Name**: PantrySync Premium Yearly
- **Description**: Full kitchen management, yearly
- **Localization**: English (US)

### 3. Lifetime Purchase

- **Reference Name**: Lifetime Access
- **Product ID**: `com.zzoutuo.PantrySync.lifetime`
- **Price**: $79.99 one-time
- **Display Name**: PantrySync Lifetime
- **Description**: Full access forever, one-time
- **Localization**: English (US)

## Free Tier Features

- Pantry inventory (up to 30 items)
- Grocery list (up to 15 items)
- Recipes (up to 3)
- Manual item entry
- Basic expiration alerts (fixed 3 days)
- Basic nutrition tracking (daily view only)

## Premium Features

- Unlimited pantry items
- Unlimited grocery items
- Unlimited recipes
- Receipt OCR scanning
- Barcode scanning with nutrition lookup
- Full meal planning calendar
- Nutrition tracking with weekly charts
- iCloud sync across devices
- Custom expiration alert days (1-14 days)
- Family sharing support

## Free Trial (Premium)

- **Duration**: 7 days
- **Type**: Free trial (auto-converts to paid)
- **Configuration Location**: App Store Connect (NOT in code or price.md)
- **Setup Steps**:
  1. Go to App Store Connect → Your App → Subscriptions
  2. Select "PantrySync Premium" subscription group
  3. Click "Subscription Prices" → "Introductory Offers"
  4. Add "Free Trial" for 7 days
  5. Apply to both Monthly and Yearly subscriptions
- **Note**: Users can experience all Premium features for 7 days before deciding to subscribe

## Free Tier (Forever Free)

- **Price**: Free
- **Duration**: Unlimited (no expiration)
- **Features**: Limited access to basic features (see Free Tier Features above)
- **Upgrade**: Users can upgrade to Premium anytime to unlock all features

## Policy Pages Required

- Support Page: Yes (Must include subscription management info)
- Privacy Policy: Yes
- Terms of Use: Yes (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist

- [x] Auto-renewal terms included in Terms
- [x] Cancellation instructions included
- [x] Pricing clearly stated
- [x] Free trial terms included
- [x] Restore purchases functionality implemented
