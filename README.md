# Part 3: Favorites Box (Flutter + Hive)

A Flutter application that caches fetched posts in Hive (`postsBox`) and lets users bookmark favorite posts in a dedicated local Hive box (`favoritesBox`) so favorites persist across refreshes, app restarts, and full offline/airplane mode.

---

## Features Implemented

- **Dedicated `FavoritesService` (`lib/services/favorites_service.dart`)**
  - `toggleFavorite(Post post)` — Adds a fresh copy of the post to `favoritesBox` keyed by `post.id`, or deletes it if already present.
  - `isFavorite(int id)` — Synchronously checks `box.containsKey(id)`.
  - `getFavorites()` — Synchronously returns `box.values.toList()`.
  - `listenable()` — Exposes `Hive.box<Post>('favoritesBox').listenable()` for reactive UI updates.
- **Interactive Star Toggle in `PostsScreen`**
  - Displays a filled amber star (`Icons.star`) for favorited posts and an outlined star (`Icons.star_border`) for non-favorites.
  - Updates immediately on tap via `ValueListenableBuilder` and stays synced when items are unfavorited from `FavoritesScreen`.
- **Dedicated `FavoritesScreen` (`lib/screens/favorites_screen.dart`)**
  - Accessible via the star action button in `PostsScreen`'s `AppBar`.
  - Uses the same `Card` + `ListTile` design as `PostsScreen`.
  - Displays a friendly `"No favorites yet"` empty state when `favoritesBox` is empty.
- **Offline & Refresh Persistence**
  - Favorites survive `postsBox.clear()` during pull-to-refresh/manual refresh.
  - Favorites remain accessible after fully closing the app, enabling **Airplane Mode**, and reopening.

---

## Project Structure

```text
lib/
├── main.dart
├── models/
│   ├── post.dart
│   └── post.g.dart
├── services/
│   ├── post_service.dart
│   └── favorites_service.dart    # NEW
└── screens/
    ├── posts_screen.dart         # UPDATED (star toggle + AppBar button)
    └── favorites_screen.dart     # NEW
```

---

## Technical Architecture & Design Decisions

1. **Why Favorites Live in a Separate Box (`favoritesBox`):**
   `PostService.getPosts()` clears `postsBox` on every refresh (`await _box.clear()`). Storing favorites in their own Hive box ensures refreshing posts from the API never wipes user favorites.
2. **Cloning `Post` Before Storing:**
   In Hive, a `HiveObject` instance can only belong to one box at a time. Saving a `Post` read from `postsBox` directly into `favoritesBox` throws a `HiveError`. `toggleFavorite()` constructs a new `Post(id: ..., title: ..., body: ..., userId: ...)` instance before calling `box.put(post.id, copy)`.
3. **Keying by `post.id`:**
   Using `post.id` as the Hive key makes membership checks (`containsKey(id)`) and removals (`delete(id)`) constant-time and avoids duplicate entries.
4. **Reactive UI with `ValueListenableBuilder`:**
   Listening to `Hive.box<Post>('favoritesBox').listenable()` rebuilds star icons and the favorites list immediately whenever the box changes, without manual state plumbing across screens.

---

## Getting Started

1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd favorites_box_assignment
   ```
2. Generate platform folders if needed (first run only):
   ```bash
   flutter create .
   ```
3. Install dependencies and run:
   ```bash
   flutter pub get
   flutter run
   ```

---

## Offline Persistence Verification (Airplane Mode Test)

1. Launch the app online and let posts load from the API.
2. Tap the star icon on 2–3 posts to mark them as favorites.
3. Open **Favorites** from the `AppBar` to confirm they are listed.
4. Completely close/kill the app from recent apps.
5. Enable **Airplane Mode** on the device/emulator (Wi-Fi and mobile data off).
6. Reopen the app and open **Favorites** — all previously saved favorites remain visible offline.

---

## Screenshots

| 1. Posts Screen (Default) | 2. Toggling Favorites (Filled Stars) | 3. Empty Favorites State |
| :---: | :---: | :---: |
| ![Posts Screen](screenshots/01_posts_screen.png) | ![Favorited Posts](screenshots/02_favorited_posts.png) | ![Empty Favorites](screenshots/03_empty_favorites.png) |

| 4. Favorites Screen (Saved Items) | 5. Offline Proof (Airplane Mode Reopen) |
| :---: | :---: |
| ![Favorites List](screenshots/04_favorites_list.png) | ![Offline Proof](screenshots/05_offline_airplane_mode.png) |
