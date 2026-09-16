# STATE_FLOW.md

```text
START
  |
  v
Loading local data
  |--------------------|
  v                    v
Success              Error
  |                    |
  v                    +--> Retry
Records
  |--------------------------|
  |                          |
  v                          v
Empty                     Existing records
                             |
                 +-----------+-----------+
                 |           |           |
              Synced      Pending     Conflict
                 |           |           |
                 |           v           v
                 |        Retry      Keep Local
                 |           |        / Keep Server
                 |           v           |
                 +-------> Synced <-----+
                              ^
                              |
                         Edit locally
                              |
                     Online -> Synced
                     Offline -> Pending
```

## Lifecycle behaviour
- Every edit is persisted before the UI reports it as saved.
- Rotation/process recreation reloads records from SharedPreferences.
- Back from the edit dialog closes the dialog without deleting stored data.
- The keyboard is contained by the dialog and normal Flutter view insets.
- Offline edits become `pending`.
- Conflicts require an explicit resolution; they are never silently overwritten.
