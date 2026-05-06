# Git Repositories

## Main App (iOS Application + Policy Pages)

| Item | Value |
|------|-------|
| **Repository Name** | PantrySync |
| **Git URL** | git@github.com:asunnyboy861/PantrySync.git |
| **Repo URL** | https://github.com/asunnyboy861/PantrySync |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | Enabled (from /docs folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/PantrySync/ | Active |
| Support | https://asunnyboy861.github.io/PantrySync/support.html | Active |
| Privacy Policy | https://asunnyboy861.github.io/PantrySync/privacy.html | Active |
| Terms of Use | https://asunnyboy861.github.io/PantrySync/terms.html | Active |

Note: Terms of Use required for IAP subscription apps.

## Repository Structure

```
PantrySync/
├── PantrySync/                       # iOS App Source Code
│   ├── PantrySync.xcodeproj/         # Xcode Project
│   ├── PantrySync/                   # Swift Source Files
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   ├── Views/
│   │   ├── Services/
│   │   ├── Utilities/
│   │   ├── PantrySyncApp.swift
│   │   └── ContentView.swift
│   ├── PantrySyncTests/
│   └── PantrySyncUITests/
├── docs/                             # Policy Pages (GitHub Pages)
│   ├── index.html                    # Landing Page
│   ├── support.html                  # Support Page
│   ├── privacy.html                  # Privacy Policy
│   └── terms.html                    # Terms of Use
├── screenshots/                      # App Store Screenshots
├── .github/workflows/
│   └── pages.yml                     # GitHub Pages Deployment
├── us.md                             # English Development Guide
├── keytext.md                        # App Store Metadata
├── capabilities.md                   # Capabilities Configuration
├── icon.md                           # App Icon Details
├── price.md                          # Pricing Configuration
└── nowgit.md                         # This File
```

## Monetization Model

| Item | Value |
|------|-------|
| **Model** | Subscription (IAP) |
| **Monthly** | $4.99/month (7-day free trial) |
| **Yearly** | $29.99/year (7-day free trial) |
| **Lifetime** | $79.99 one-time |
| **Product ID Prefix** | com.zzoutuo.PantrySync |

## SettingsView Policy Links

| Link | URL |
|------|-----|
| Support Page | https://asunnyboy861.github.io/PantrySync/support.html |
| Privacy Policy | https://asunnyboy861.github.io/PantrySync/privacy.html |
| Terms of Use | https://asunnyboy861.github.io/PantrySync/terms.html |
