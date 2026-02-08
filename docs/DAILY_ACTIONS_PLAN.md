# Daily Action Engine & Networking Features - Implementation Plan

## Summary

After reviewing the existing codebase, the proposed **Daily Action Engine** and **Networking & Follow-ups** features are **NEW features** that cannot be simple upgrades to existing functionality.

### Current State Analysis

| Existing Feature | Purpose | Relation to Proposed Features |
|------------------|---------|-------------------------------|
| `daily_engagement` | LinkedIn activities (commenting, liking, connections) | **Different** - Static predefined tasks, not job-aware |
| `job_model.followUpDate` | Basic date field | **Unused** - No logic or UI around it |
| `jobs_provider` | CRUD for job applications | **Foundation** - Can be queried for action generation |

---

## Proposed Changes

### Feature 1: Daily Action Engine

#### [NEW] `lib/features/daily_actions/daily_action_model.dart`
Data models for the action engine:
```dart
enum ActionType {
  sendFollowUp,      // Jobs applied 5-7+ days ago
  recruiterOutreach, // No networking in 3+ days
  cvImprovement,     // Low response rate suggestion
}

class DailyAction {
  String id;
  ActionType type;
  String title;
  String? jobId;        // Linked job (optional)
  String? jobTitle;
  String? companyName;
  bool isCompleted;
  DateTime generatedAt;
  DateTime? completedAt;
}
```

#### [NEW] `lib/features/daily_actions/daily_action_repository.dart`
Firestore persistence:
- Collection: `users/{uid}/daily_actions/{date}`
- Store actions per calendar day
- Methods: `getTodayActions()`, `markComplete()`, `regenerateActions()`

#### [NEW] `lib/features/daily_actions/action_generator_service.dart`
Core logic to generate 3-5 daily actions based on:

| Trigger | Action Type | Logic |
|---------|-------------|-------|
| Jobs applied 5-7+ days ago with no status change | `sendFollowUp` | Query jobs where `status == 'applied'` AND `appliedDate < today - 5 days` |
| No networking activity in 3+ days | `recruiterOutreach` | Check `daily_engagement` history |
| Low response rate (<10%) | `cvImprovement` | Calculate `(interviewing + offer) / total` |

**Generation Trigger**: Automatic on first daily app open (checked via stored date).

#### [NEW] `lib/features/daily_actions/daily_action_provider.dart`
Riverpod state management:
- `dailyActionsStreamProvider` - Real-time actions for today
- `actionGeneratorProvider` - Triggers action generation
- `dailyActionsControllerProvider` - Mark complete, regenerate

#### [NEW] `lib/features/daily_actions/daily_actions_screen.dart`
UI screen with:
- Action cards with type-specific icons and colors
- Job link for job-related actions
- Swipe or tap to complete
- Progress indicator (e.g., "2/4 actions completed")

#### [MODIFY] `lib/features/dashboard/dashboard_screen.dart`
Add a "Today's Actions" card widget linking to `DailyActionsScreen`

#### [MODIFY] `lib/router.dart`
Add route for `/daily-actions`

---

### Feature 2: Networking & Follow-ups Tracking

#### [NEW] `lib/features/networking/networking_model.dart`
Track networking activities tied to jobs:
```dart
class NetworkingActivity {
  String id;
  NetworkingType type; // followUp, recruiterMessage, reply
  String? jobId;       // Optional job link
  String? contactName;
  String? notes;
  bool replyReceived;  // Manual toggle
  DateTime createdAt;
}
```

#### [NEW] `lib/features/networking/networking_repository.dart`
Firestore persistence:
- Collection: `users/{uid}/networking`
- Methods: `addActivity()`, `getActivitiesForJob()`, `toggleReply()`, `getStats()`

#### [NEW] `lib/features/networking/networking_provider.dart`
Riverpod providers for:
- Stream of all networking activities
- Filtered by job
- Stats (follow-ups sent, replies received)

#### [MODIFY] `lib/features/jobs/job_detail_screen.dart`
Add "Networking" section showing:
- Follow-ups sent for this job
- Button to log new follow-up/recruiter message
- Reply received toggle

---

## Firestore Schema

```
users/{uid}/
├── daily_actions/
│   └── {YYYY-MM-DD}/
│       └── actions: [{ type, title, jobId, isCompleted, ... }]
│
└── networking/
    └── {activityId}/
        └── { type, jobId, contactName, notes, replyReceived, createdAt }
```

---

## Implementation Phases

1. **Phase 1**: Daily Action Engine (model, repository, generator, provider, screen)
2. **Phase 2**: Router and dashboard integration
3. **Phase 3**: Networking & Follow-ups (model, repository, provider)
4. **Phase 4**: Job detail screen integration
5. **Phase 5**: Testing and polish
