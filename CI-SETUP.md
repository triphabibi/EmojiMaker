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

# EmojiMaker CI Setup

This guide explains how to configure signing and CI so the `iOS CI - Build and TestFlight` workflow succeeds.

## Secrets Required
- `APPLE_ID`: Your Apple ID email.
- `TEAM_ID`: Apple Developer Team ID.
- `APP_IDENTIFIER`: Bundle identifier (e.g. com.triphabibi.EmojiMaker).
- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API Key ID.
- `APP_STORE_CONNECT_ISSUER_ID`: App Store Connect Issuer ID.
- `APP_STORE_CONNECT_KEY`: Base64 of the `.p8` API key file.
- `MATCH_PASSWORD`: Passphrase to encrypt/decrypt the certificates repo.
- `MATCH_GIT_URL`: URL to your match certificates repo.
- One of:
  - HTTPS: `MATCH_GIT_TOKEN` (fine-grained PAT with `Contents: Read`).
  - SSH: `MATCH_GIT_PRIVATE_KEY` or `MATCH_GIT_PRIVATE_KEY_B64` (OpenSSH format, no passphrase).
- Optional: `MATCH_READONLY` (default `true`). Set to `false` only if your account is Team Admin and you want CI to create assets.

## One-time Admin Bootstrap (recommended)
Only a Team Admin or Account Holder can create Distribution certificates. Do this once to seed the repo:

1. Ensure the Admin has access to the certs repo and the `MATCH_PASSWORD`.
2. On their Mac:
   - `brew install ruby`
   - `bundle install`
3. Export API key `.p8` and base64 it: `base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy`
4. Run match to create assets:
   - Set env:
     - `MATCH_GIT_URL`, `MATCH_PASSWORD`, `APPLE_ID`, `TEAM_ID`, `APP_IDENTIFIER`.
     - Either `MATCH_GIT_TOKEN` (HTTPS) or `MATCH_GIT_PRIVATE_KEY`/`MATCH_GIT_PRIVATE_KEY_B64` (SSH).
     - `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_KEY`.
   - Execute: `bundle exec fastlane match appstore --readonly false`
5. Verify assets committed to the certs repo (`certs`, `profiles/appstore`).

After this, CI will run with `MATCH_READONLY=true` and download assets.

## CI Behavior
- Preflight step checks:
  - Prints `Match readonly: ...`.
  - Verifies access to the certificates repo using token/SSH.
  - Fails early with guidance if access is denied.
- `fastlane beta` lane:
  - Uses App Store Connect API key for authentication.
  - Defaults to `readonly` unless `MATCH_READONLY=false`.
  - If `readonly=false`, CI attempts to create assets (requires Admin account). If your account is not Admin, Apple will reject creation.

## Troubleshooting
- Repo access failure:
  - HTTPS: Ensure `MATCH_GIT_TOKEN` has `Contents: Read` to the certs repo.
  - SSH: Ensure the private key matches the repo Deploy Key, and the key is OpenSSH (not PuTTY `.ppk`).
- No signing assets available and `readonly=true`:
  - Have an Admin run the one-time bootstrap above.
- Apple permission error (Only Team Admins can create Distribution certificates):
  - Set `MATCH_READONLY=true` for CI.
  - Or have your account promoted to Admin and set `MATCH_READONLY=false`.

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