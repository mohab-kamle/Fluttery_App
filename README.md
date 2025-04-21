# AkiraMenai Team

# 🕒 Time Management App

## ✅ Basic Features

1. **User Authentication**
   - Email/password login
   - Google/Facebook sign-in (optional)

2. **Task Management**
   - Add, edit, delete tasks
   - Set due dates and priorities
   - Task categorization (work, personal, etc.)

3. **Daily/Weekly Planner**
   - Calendar view
   - Today’s task list
   - Weekly overview

4. **Reminders & Notifications**
   - Push notifications for upcoming tasks
   - Custom reminder times

5. **Simple Timer/Pomodoro**
   - 25-min focus + 5-min break
   - Manual start/stop/reset

6. **Dark Mode & Theming**
   - Toggle light/dark themes
   - Simple UI customization

---

## 🚀 Advanced Features

1. **Statistics Dashboard**
   - Time spent on tasks
   - Task completion trends (weekly/monthly)

2. **Goal Setting**
   - Define personal goals
   - Track progress toward them

3. **Time Tracking**
   - Track how long tasks take in real time
   - Auto-start timer when task begins

4. **AI Task Suggestions**
   - Suggest task timings based on past behavior
   - Auto-scheduling tasks in empty time blocks

5. **Sync with Calendar**
   - Integrate with Google Calendar or Apple Calendar

6. **Offline Mode + Sync**
   - Work offline and sync data when back online

7. **Gamification**
   - Reward points for completing tasks
   - Daily streaks and achievements

8. **Collaboration Tools**
   - Share tasks with others
   - Assign tasks within a small team

9. **Voice Assistant Integration**
   - Use voice commands to create tasks

---

## 🛠️ Required Technologies

### 🔧 Flutter Packages & SDKs

- `firebase_auth`, `cloud_firestore`: Auth + real-time database
- `provider` or `riverpod`: State management
- `flutter_local_notifications`: Notifications
- `table_calendar`: Calendar UI
- `intl`: Date/time formatting
- `shared_preferences` or `Hive`: Local storage
- `flutter_native_timezone` + `timezone`: Reminder accuracy
- `google_sign_in`, `flutter_facebook_auth`: Social auth
- `charts_flutter` or `syncfusion_flutter_charts`: Stats/graphs
- `flutter_launcher_icons`, `flutter_native_splash`: Branding

### 🌐 Backend (if needed)

- **Firebase**: Easiest option for small apps
  - Firestore (database), Auth, Cloud Functions
- **Supabase** (alternative to Firebase)
- **Node.js/Express + MongoDB/MySQL** (for custom backend)

### 🎨 Design Tools

- Figma or Adobe XD for wireframes/UI
- Icons: `flutter_vector_icons`, `font_awesome_flutter`

