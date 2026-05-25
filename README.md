# Mobile Backend UI



## Getting started

To make it easy for you to get started with GitLab, here's a list of recommended next steps.

Already a pro? Just edit this README.md and make it your own. Want to make it easy? [Use the template at the bottom](#editing-this-readme)!

## Add your files

* [Create](https://docs.gitlab.com/user/project/repository/web_editor/#create-a-file) or [upload](https://docs.gitlab.com/user/project/repository/web_editor/#upload-a-file) files
* [Add files using the command line](https://docs.gitlab.com/topics/git/add_files/#add-files-to-a-git-repository) or push an existing Git repository with the following command:

```
cd existing_repo
git remote add origin https://git.pidginhost.net/bapp-cloud/packages/mobile-backend-ui.git
git branch -M main
git push -uf origin main
```

## Integrate with your tools

* [Set up project integrations](https://git.pidginhost.net/bapp-cloud/packages/mobile-backend-ui/-/settings/integrations)

## Collaborate with your team

* [Invite team members and collaborators](https://docs.gitlab.com/user/project/members/)
* [Create a new merge request](https://docs.gitlab.com/user/project/merge_requests/creating_merge_requests/)
* [Automatically close issues from merge requests](https://docs.gitlab.com/user/project/issues/managing_issues/#closing-issues-automatically)
* [Enable merge request approvals](https://docs.gitlab.com/user/project/merge_requests/approvals/)
* [Set auto-merge](https://docs.gitlab.com/user/project/merge_requests/auto_merge/)

## Test and Deploy

Use the built-in continuous integration in GitLab.

* [Get started with GitLab CI/CD](https://docs.gitlab.com/ci/quick_start/)
* [Analyze your code for known vulnerabilities with Static Application Security Testing (SAST)](https://docs.gitlab.com/user/application_security/sast/)
* [Deploy to Kubernetes, Amazon EC2, or Amazon ECS using Auto Deploy](https://docs.gitlab.com/topics/autodevops/requirements/)
* [Use pull-based deployments for improved Kubernetes management](https://docs.gitlab.com/user/clusters/agent/)
* [Set up protected environments](https://docs.gitlab.com/ci/environments/protected_environments/)

***

# Editing this README

When you're ready to make this README your own, just edit this file and use the handy template below (or feel free to structure it however you want - this is just a starting point!). Thanks to [makeareadme.com](https://www.makeareadme.com/) for this template.

## Suggestions for a good README

Every project is different, so consider which of these sections apply to yours. The sections used in the template are suggestions for most open source projects. Also keep in mind that while a README can be too long and detailed, too long is better than too short. If you think your README is too long, consider utilizing another form of documentation rather than cutting out information.

## Name
Choose a self-explaining name for your project.

## Description
Let people know what your project can do specifically. Provide context and add a link to any reference visitors might be unfamiliar with. A list of Features or a Background subsection can also be added here. If there are alternatives to your project, this is a good place to list differentiating factors.

## Badges
On some READMEs, you may see small images that convey metadata, such as whether or not all the tests are passing for the project. You can use Shields to add some to your README. Many services also have instructions for adding a badge.

## Visuals
Depending on what you are making, it can be a good idea to include screenshots or even a video (you'll frequently see GIFs rather than actual videos). Tools like ttygif can help, but check out Asciinema for a more sophisticated method.

## Installation
Within a particular ecosystem, there may be a common way of installing things, such as using Yarn, NuGet, or Homebrew. However, consider the possibility that whoever is reading your README is a novice and would like more guidance. Listing specific steps helps remove ambiguity and gets people to using your project as quickly as possible. If it only runs in a specific context like a particular programming language version or operating system or has dependencies that have to be installed manually, also add a Requirements subsection.

## Usage
Use examples liberally, and show the expected output if you can. It's helpful to have inline the smallest example of usage that you can demonstrate, while providing links to more sophisticated examples if they are too long to reasonably include in the README.

## Support
Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap
If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing
State if you are open to contributions and what your requirements are for accepting them.

For people who want to make changes to your project, it's helpful to have some documentation on how to get started. Perhaps there is a script that they should run or some environment variables that they need to set. Make these steps explicit. These instructions could also be useful to your future self.

You can also document commands to lint the code or run tests. These steps help to ensure high code quality and reduce the likelihood that the changes inadvertently break something. Having instructions for running tests is especially helpful if it requires external setup, such as starting a Selenium server for testing in a browser.

## Authors and acknowledgment
Show your appreciation to those who have contributed to the project.

## License
For open source projects, say how it is licensed.

## Project status
If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.

## Localisation

The SDK ships with built-in UI strings (pickers, empty/error states, Save, NFC
status, connectivity defaults) localised into all 24 EU official languages:

`bg cs da de el en es et fi fr ga hr hu it lt lv mt nl pl pt ro sk sl sv`

Romanian (`ro`) and English (`en`) are the authoritative translations.
The remaining 22 languages are machine-provided — native-speaker corrections
are very welcome via merge request.

Pass `locale` in `BappMobileConfig` to force a specific language regardless of
the device locale (useful for testing):

```dart
BappMobileConfig(host: '…', project: '…', locale: Locale('ro'))
```

Server-defined labels (screen titles, field labels, action buttons) are
translated separately on the backend and are not affected by this setting.

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';

void main() => runApp(const BappMobileApp(
      config: BappMobileConfig(
        host: 'https://your-tenant.bapp.ro/api',
        project: 'vault', // your mobile app slug
      ),
    ));
```

The app boots from only a **host** + **project**: it logs in via `bapp_auth`
(Keycloak), fetches the mobile UI contract from the backend
(`mobile.bootstrap` / `mobile.listintrospect`), and renders the server-defined
screens. No screen-specific Dart is required.

### Extending

Register custom node-kinds or templates without forking:

```dart
BappMobileApp(
  config: BappMobileConfig(
    host: '...', project: '...',
    nodes: {'kanban_card': (ctx, node) => MyKanbanCard(node)},
    templates: {'kanban': (ctx, screen, api, nodes) => MyKanbanScreen(screen)},
  ),
);
```

See `example/` for a runnable host. Running it requires a live bapp_framework
backend with a matching mobile app (e.g. the `vault` sample).

## Device features & permissions

The SDK includes five built-in device-feature node kinds rendered by the
backend when it emits `scanner-button`, `scanner-stream`, `nfc-button`,
`nfc-stream`, or `connectivity` nodes. They depend on real device hardware
and **cannot be exercised in unit tests** (camera/NFC are stubbed out in the
test suite). You must add the following platform declarations to every host
app that consumes this package.

### Android — `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Camera (scanner nodes) -->
<uses-permission android:name="android.permission.CAMERA"/>

<!-- NFC nodes -->
<uses-permission android:name="android.permission.NFC"/>
<uses-feature android:name="android.hardware.nfc" android:required="false"/>
```

`mobile_scanner` also requires `minSdkVersion 21` in `android/app/build.gradle`.

### iOS — `ios/Runner/Info.plist`

```xml
<!-- Camera (scanner nodes) -->
<key>NSCameraUsageDescription</key>
<string>Used to scan barcodes and QR codes.</string>

<!-- NFC nodes -->
<key>NFCReaderUsageDescription</key>
<string>Used to read NFC tags.</string>
```

For NFC you also need the **Near Field Communication Tag Reading** capability
in Xcode (Signing & Capabilities tab) and the `com.apple.developer.nfc.readersession.formats`
entitlement in your `.entitlements` file:

```xml
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
  <string>TAG</string>
</array>
```

iOS NFC requires a physical device — the Simulator does not expose NFC hardware.

### Package versions

| Package | Version |
|---------|---------|
| `mobile_scanner` | ^7.2.0 |
| `nfc_manager` | ^4.0.0 |
| `connectivity_plus` | ^7.1.1 |
