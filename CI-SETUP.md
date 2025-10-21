# CI Setup for TestFlight (Windows-friendly)

This repository is configured to build and distribute the iOS app via GitHub Actions on a macOS runner using XcodeGen + Fastlane.

## What’s included
- `project.yml`: XcodeGen spec to generate the Xcode project.
- `fastlane/Fastfile`: lanes `build` and `beta` (uploads to TestFlight).
- `fastlane/Appfile`: Apple account, team, and bundle identifier via secrets.
- `.github/workflows/ios-ci.yml`: macOS workflow to generate, build, and upload.
- `Gemfile`: pins Fastlane via Bundler.

## Required GitHub Secrets
Add these secrets in your repo Settings → Secrets and variables → Actions:

- `APPLE_ID`: Your Apple ID email used for Developer account.
- `TEAM_ID`: Your 10-character Apple Developer Team ID.
- `APP_IDENTIFIER`: Bundle ID (e.g., `com.example.emojimaker`). Must match `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml`.
- `MATCH_GIT_URL`: Private repo URL storing certificates/profiles for `fastlane match`.
- `MATCH_PASSWORD`: Password for the match repo encryption.
- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API Key ID.
- `APP_STORE_CONNECT_ISSUER_ID`: App Store Connect Issuer ID.
- `APP_STORE_CONNECT_KEY`: Base64-encoded App Store Connect API private key content.

## One-time Apple side setup
1. Create the app in App Store Connect using your `APP_IDENTIFIER`.
2. Create an App Store Connect API key, download the `.p8` file and base64-encode its content for `APP_STORE_CONNECT_KEY`.
3. Set up `fastlane match`: create a private repo and run `fastlane match init` locally on a Mac to bootstrap certs.

## Workflow usage
- Push to `main` or trigger `Run workflow` via `Actions` → `iOS CI - Build and TestFlight`.
- The job will:
  - Install XcodeGen, generate the Xcode project.
  - Install gems and run `fastlane beta`.
  - Build, sign, and upload the build to TestFlight.

## Adjust project.yml
Update `PRODUCT_BUNDLE_IDENTIFIER` and `DEVELOPMENT_TEAM` in `project.yml` to match your secrets and account:

```yaml
settings:
  INFOPLIST_FILE: Info.plist
  PRODUCT_BUNDLE_IDENTIFIER: com.example.emojimaker
  CODE_SIGN_STYLE: Automatic
  DEVELOPMENT_TEAM: ABCDEFG123
```

Replace `com.example.emojimaker` with your `APP_IDENTIFIER`, and `ABCDEFG123` with your `TEAM_ID`.

## Troubleshooting
- Provisioning/signing errors: ensure `match` has generated App Store profiles for the bundle ID and that `DEVELOPMENT_TEAM` is correct.
- API key auth issues: verify all three API key secrets are set and the key has `Developer` role access.
- Missing project: ensure `xcodegen generate` succeeded; check Action logs for spec errors.