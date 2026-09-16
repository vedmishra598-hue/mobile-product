# Offline-First Mobile Product Slice

Flutter implementation of the supplied Offline field records dataset and the assignment requirements.

## Source data
The supplied JSON contains:
- FR-001 Campus survey — synced — v1
- FR-002 Library inspection — pending — v2
- FR-003 Lab inventory — conflict — v3

Expected behaviour: persist edits offline, expose sync state, and resolve version conflicts without silent data loss.

## Three-screen/state flow
1. Records/Home: loading -> success/empty/error
2. Edit Record: local edit -> saved locally -> pending when offline
3. Sync/Conflict: pending -> synced after retry; conflict -> explicit Keep local/Keep server

## Run
1. Install Flutter.
2. Create a Flutter project with `flutter create .` in this folder if platform folders are missing.
3. Run `flutter pub get`.
4. Run `flutter run`.

The app uses SharedPreferences for local persistence. Toggle the Online switch to simulate connectivity loss.
