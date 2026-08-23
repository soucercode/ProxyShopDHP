# Proxy SHOP DHP

SwiftUI iOS app source with GitHub Actions build pipeline.

## Build on Windows using GitHub Actions

1. Create a GitHub repository.
2. Upload all files from this folder to the repository.
3. Open **Actions**.
4. Select **Build Proxy SHOP DHP IPA**.
5. Click **Run workflow**.
6. Download the artifact named **ProxyShopDHP-unsigned-ipa**.

The workflow uses a GitHub-hosted macOS runner because Xcode/iOS device builds require macOS. GitHub currently provides macOS runners including `macos-15`. 

The produced IPA is **unsigned**. For installing on a physical iPhone, you still need a valid Apple signing method/provisioning profile or your signing app/workflow.

The app UI flow:
Home -> tap Free Fire/Free Fire Max -> functions.
Home also shows iOS, model, app-scoped UID, key status, Copy UID and Change Key.

Device ID note: the displayed UID is `identifierForVendor`, not the hardware UDID.
