# DEVICE_TEST_MATRIX.md

| Test | Condition | Expected result |
|---|---|---|
| Narrow viewport | Android narrow screen | Content remains scrollable and usable |
| Offline load | Network unavailable | Existing local records still display |
| Offline edit | Online switch OFF | Edit persists and state becomes Pending sync |
| Retry offline | Offline + Retry | No data loss; retry remains queued |
| Retry online | Online + Pending | Pending record becomes Synced |
| Conflict | FR-003 | Conflict is visible and offers explicit resolution |
| Keep local | Conflict -> Keep local | Conflict clears without silent overwrite |
| Keep server | Conflict -> Keep server | Conflict clears after explicit choice |
| Rotation | Rotate device | Record data remains after rebuild |
| Process death | Stop/relaunch app | Local records are restored |
| Back navigation | Back from edit | Dialog closes; saved data remains |
| Keyboard | Open edit field | Dialog stays usable with keyboard |
