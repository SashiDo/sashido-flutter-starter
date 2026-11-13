# SashiDo Flutter starter

A Flutter app on a [SashiDo](https://www.sashido.io) backend (Parse Server): sign up and login, and a private todo list that updates live across devices. It runs on iOS, Android and the web.

What it shows, done the way it should be on Parse:

- **Users and sessions** with the Parse Flutter SDK; the session is kept on the device between launches.
- **Private data**: every todo gets an ACL for its owner in cloud code (`cloud/main.js`), so no client can read, change or delete someone else's, whatever it sends.
- **Locked-down class**: the `Todo` class allows only logged-in users and no new fields from clients (`scripts/setup-schema.mjs`).
- **Validation on the server**: titles are checked in `beforeSave`.
- **Live updates** with Live Queries (optional).

## 1. Create a SashiDo app

Create an app at [dashboard.sashido.io](https://dashboard.sashido.io). Then:

**Cloud code.** Copy `cloud/main.js` into your app's repository (**Core › Cloud Code**: link GitHub and clone it) and push to `master`. SashiDo deploys it.

**The Todo class.** From your machine (Node.js 18+), with the keys in **App Settings › Security & Keys**:

```bash
PARSE_SERVER_URL=https://pg-app-xxxxxxxx.scalabl.cloud/1 \
PARSE_APP_ID=<Application ID> PARSE_MASTER_KEY=<Master Key> \
node scripts/setup-schema.mjs
```

The master key stays on your machine: the app itself only uses the public keys.

**Live updates (optional).** In **App Settings › Live Queries** tick `Todo`.

## 2. Run the app

```bash
cp config.example.json config.json    # Application ID, Client Key, API URL (and the LiveQuery URL)
flutter pub get
flutter run --dart-define-from-file=config.json
```

Pick a device: an iOS simulator, an Android emulator, a phone, or Chrome.

## Notes

- **The Client Key, not the JavaScript Key.** The Dart SDK sends the **Client Key**.
- **Flutter web needs Parse Server 4.1 or newer.** The Dart SDK sends `X-Parse-Client-Key` and `X-Parse-Installation-Id`, which browsers only send when the server allows them (CORS). SashiDo allows both on Parse Server 4.1 and newer. iOS and Android apps don't need this.
- **Usernames only.** Sign-up uses usernames only (`allowWithoutEmail: true`). To offer password resets by email, add an email field and pass it to `ParseUser`.
- **Android release builds** need the `INTERNET` permission, which `android/app/src/main/AndroidManifest.xml` includes.
- **Public keys.** The Application ID and Client Key are public by design. What protects the data is the ACL and the class-level permissions, and the master key never goes into the app.
- **What's been tested:** the app in Chrome against Parse Server 8.6.117 (sign up, add, toggle, delete, session kept after a reload, live updates between two clients, two users kept apart), `flutter analyze`, `flutter test`, a release web build, and the backend's security rules on 8.6.117 and 6.5.11.

Docs: [SashiDo developer docs](https://www.sashido.io/en/docs/developers) · [Parse Flutter SDK](https://github.com/parse-community/Parse-SDK-Flutter)
