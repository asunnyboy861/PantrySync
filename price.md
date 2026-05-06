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
- Grocery list (up to 50 items)
- Manual item entry
- Basic expiration alerts (3 items)
- Basic recipe browsing

## Premium Features

- Unlimited pantry items
- Unlimited grocery items
- Receipt OCR scanning
- Barcode scanning with nutrition lookup
- Recipe recommendations based on inventory
- Full meal planning calendar
- Nutrition tracking with charts
- Waste analytics
- iCloud family sharing
- Widget customization
- All expiration alerts

## Free Trial

- **Duration**: 7 days
- **Type**: Free trial (auto-converts to paid)

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
