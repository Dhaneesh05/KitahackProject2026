# 🌊 HydroVision

HydroVision is a cutting-edge community-focused Flutter application designed to crowdsource and monitor flood reports in real-time. By leveraging a highly polished "Liquid Glassmorphism" UI and live Firebase data streams, HydroVision empowers citizens to report localized flooding, verifying safety conditions seamlessly and beautifully.

## 🏗️ 1. Technical Architecture

HydroVision is built heavily leveraging the Flutter framework for cross-platform fluid UI execution, tied directly into the Firebase ecosystem for scalable backend services.

- **Frontend Framework:** Flutter (Dart)
- **State Management:** Custom `PostStore` utilizing `ChangeNotifier` and `Provider` for robust, reactive local UI updates seamlessly blended with stream events.
- **Backend Infrastructure:** Firebase
  - **Firestore Database:** Serves as the primary real-time NoSQL database. Two main collections (`reports` and `users`) manage active flood reports and verification thresholds.
  - **Firebase Storage:** Handles the upload and retrival of user-submitted flood incident imagery.
  - **Firebase Authentication:** (Integrations applied to handle current localized user handles and admin verification routing).
- **Styling Architecture:** A centralized `AppColors` and `AppTheme` system heavily reliant on dynamic `context` lookups to handle frosted glass palettes, teal/oceanic gradients, and `GoogleFonts.outfit` typographies natively.

## 🛠️ 2. Implementation Details

- **Liquid Glassmorphism UI:** HydroVision steps away from standard Material Design by providing a custom `GlassPane` widget that uses `BackdropFilter` with Sigma X/Y blurs. This creates a frosted-glass, oceanic aesthetic across all cards, navigation bars, and modals.
- **Surgical Routing & Role Management:** The app utilizes a dual-interface system. Standard users access the `HomeScreen` and `FeedScreen` to submit and verify floods. Admin roles use `AdminFeedScreen` to monitor pending reports, verifying or rejecting high-severity incidents using completely distinct layouts but matching aesthetics.
- **Live Data Streams:** By converting static mock data into Firebase `StreamBuilder` streams, the application feed updates instantly across all connected clients the moment a new flood is reported or an existing severity is upgraded.
- **Graceful Error Handling:** Custom widgets safely catch missing network images or failed location parses, swapping them for frosted-glass placeholders utilizing local SVGs and smooth `CircularProgressIndicator` animations instead of crash states.

## 🧗 3. Challenges Faced

1. **Surgical Git Merging with Complex UI:** Integrating the V7 backend logic with the pre-existing, highly customized UI was incredibly challenging. Standard Git merges resulted in massive collisions between the new Firestore data mapping logic and the bespoke glassmorphic `ClipRRect` and `Positioned` UI wrappers. This was solved using careful `--no-commit` cherry-picks (`cherry-pick -n`) and manual line-by-line conflict resolution to ensure backend logic was adopted without overwriting the visual structure.
2. **Context-Dependent Styling in Async Gaps:** Moving to a dynamic `AppColors.of(context)` system required precise handling inside Firebase async callbacks to avoid Dart's `use_build_context_synchronously` limitations when rendering success/error snackbarspost-upload.
3. **Image Constraints:** Merging new image upload methodologies (`V8`) required meticulous tuning of `BoxFit` layout constraints to prevent infinite height rendering exceptions within `ListView.builder` widgets.

## 🗺️ 4. Future Roadmap

- **Push Notifications:** Integrating Firebase Cloud Messaging (FCM) to actively ping users when a high-severity flood report occurs within a 5km radius of their current geolocation.
- **Advanced Map Heatmaps:** Transitioning the map screen from basic plotting points to animated, weighted heatmaps utilizing the Google Maps Flutter plugin.
- **Expanded User Profiles:** Allowing users to track their historical report accuracy, earn verification badges, and upload custom avatars.
- **Offline Mode:** Caching recent Firestore snapshots locally so emergency services can view the last known flood status even when network conditions deteriorate.

---
*Built with 💙 and Flutter.*
