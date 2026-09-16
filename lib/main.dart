
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SyncState { synced, pending, conflict, error }

class FieldRecord {
  final String id;
  String title;
  DateTime updatedAt;
  SyncState syncState;
  int version;

  FieldRecord({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.syncState,
    required this.version,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'updatedAt': updatedAt.toIso8601String(),
    'syncState': syncState.name,
    'version': version,
  };

  factory FieldRecord.fromJson(Map<String, dynamic> json) => FieldRecord(
    id: json['id'],
    title: json['title'],
    updatedAt: DateTime.parse(json['updatedAt']),
    syncState: SyncState.values.firstWhere(
      (s) => s.name == json['syncState'],
      orElse: () => SyncState.pending,
    ),
    version: json['version'] ?? 1,
  );
}

class LocalStore {
  static const _key = 'field_records_v1';

  Future<List<FieldRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) {
      final seed = [
        FieldRecord(
          id: 'FR-001',
          title: 'Campus survey',
          updatedAt: DateTime.parse('2026-08-01T09:30:00Z'),
          syncState: SyncState.synced,
          version: 1,
        ),
        FieldRecord(
          id: 'FR-002',
          title: 'Library inspection',
          updatedAt: DateTime.parse('2026-08-02T11:15:00Z'),
          syncState: SyncState.pending,
          version: 2,
        ),
        FieldRecord(
          id: 'FR-003',
          title: 'Lab inventory',
          updatedAt: DateTime.parse('2026-08-02T11:18:00Z'),
          syncState: SyncState.conflict,
          version: 3,
        ),
      ];
      await save(seed);
      return seed;
    }

    final list = jsonDecode(raw) as List;
    return list
        .map((e) => FieldRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> save(List<FieldRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );
  }
}

class RecordRepository extends ChangeNotifier {
  final LocalStore store = LocalStore();
  List<FieldRecord> records = [];
  bool loading = true;
  bool online = true;
  String? errorMessage;

  Future<void> init() async {
    try {
      loading = true;
      notifyListeners();
      records = await store.load();
    } catch (e) {
      errorMessage = 'Could not load local records.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateRecord(String id, String title) async {
    final record = records.firstWhere((r) => r.id == id);
    record.title = title.trim().isEmpty ? record.title : title.trim();
    record.updatedAt = DateTime.now();
    record.version += 1;
    record.syncState = online ? SyncState.synced : SyncState.pending;

    await store.save(records);
    notifyListeners();
  }

  Future<void> retry(String id) async {
    if (!online) {
      errorMessage = 'Retry queued: device is offline.';
      notifyListeners();
      return;
    }

    final record = records.firstWhere((r) => r.id == id);
    await Future.delayed(const Duration(milliseconds: 700));

    // Conflict is never silently overwritten.
    if (record.syncState == SyncState.conflict) {
      errorMessage =
          'Conflict remains. Choose “Keep local” or “Keep server”.';
      notifyListeners();
      return;
    }

    record.syncState = SyncState.synced;
    record.updatedAt = DateTime.now();
    await store.save(records);
    notifyListeners();
  }

  Future<void> resolveConflict(String id, bool keepLocal) async {
    final record = records.firstWhere((r) => r.id == id);
    if (record.syncState != SyncState.conflict) return;

    // In a real backend, keepLocal would upload the local version and
    // keepServer would download the server version after a version check.
    record.syncState = SyncState.synced;
    record.updatedAt = DateTime.now();

    if (keepLocal) {
      record.version += 1;
    }

    await store.save(records);
    notifyListeners();
  }

  void setOnline(bool value) {
    online = value;
    if (!online) {
      for (final r in records) {
        if (r.syncState == SyncState.synced) {
          // Existing synced data stays synced; only future edits are pending.
        }
      }
    }
    notifyListeners();
  }

  Future<void> syncPending() async {
    if (!online) {
      errorMessage = 'Cannot sync while offline.';
      notifyListeners();
      return;
    }

    final pending = records.where((r) => r.syncState == SyncState.pending);
    for (final r in pending) {
      await Future.delayed(const Duration(milliseconds: 300));
      r.syncState = SyncState.synced;
    }

    await store.save(records);
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OfflineFirstApp());
}

class OfflineFirstApp extends StatefulWidget {
  const OfflineFirstApp({super.key});

  @override
  State<OfflineFirstApp> createState() => _OfflineFirstAppState();
}

class _OfflineFirstAppState extends State<OfflineFirstApp> {
  final repo = RecordRepository();

  @override
  void initState() {
    super.initState();
    repo.init();
  }

  @override
  void dispose() {
    repo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repo,
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Offline Field Records',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: HomeScreen(repo: repo),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final RecordRepository repo;
  const HomeScreen({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Records'),
        actions: [
          Row(
            children: [
              Icon(repo.online ? Icons.wifi : Icons.wifi_off),
              Switch(
                value: repo.online,
                onChanged: repo.setOnline,
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: repo.loading
            ? const Center(child: CircularProgressIndicator())
            : repo.errorMessage != null && repo.records.isEmpty
                ? ErrorState(
                    message: repo.errorMessage!,
                    onRetry: () {
                      repo.clearError();
                      repo.init();
                    },
                  )
                : RefreshIndicator(
                    onRefresh: repo.syncPending,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        StatusBanner(online: repo.online),
                        const SizedBox(height: 12),
                        if (repo.records.isEmpty)
                          const EmptyState()
                        else
                          ...repo.records.map(
                            (r) => RecordCard(record: r, repo: repo),
                          ),
                        if (repo.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ErrorBanner(
                              message: repo.errorMessage!,
                              onClose: repo.clearError,
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class RecordCard extends StatelessWidget {
  final FieldRecord record;
  final RecordRepository repo;

  const RecordCard({super.key, required this.record, required this.repo});

  Color stateColor(BuildContext context) {
    switch (record.syncState) {
      case SyncState.synced:
        return Colors.green;
      case SyncState.pending:
        return Colors.orange;
      case SyncState.conflict:
        return Colors.red;
      case SyncState.error:
        return Colors.deepPurple;
    }
  }

  String stateText() {
    switch (record.syncState) {
      case SyncState.synced:
        return 'Synced';
      case SyncState.pending:
        return 'Pending sync';
      case SyncState.conflict:
        return 'Conflict';
      case SyncState.error:
        return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = stateColor(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(record.title),
        subtitle: Text(
          '${record.id} • v${record.version}\n'
          'Updated ${record.updatedAt.toLocal()}',
        ),
        isThreeLine: true,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(Icons.description, color: color),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              await showEditDialog(context, repo, record);
            } else if (value == 'retry') {
              await repo.retry(record.id);
            } else if (value == 'local') {
              await repo.resolveConflict(record.id, true);
            } else if (value == 'server') {
              await repo.resolveConflict(record.id, false);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit locally')),
            if (record.syncState == SyncState.pending ||
                record.syncState == SyncState.error)
              const PopupMenuItem(value: 'retry', child: Text('Retry sync')),
            if (record.syncState == SyncState.conflict) ...[
              const PopupMenuItem(
                value: 'local',
                child: Text('Resolve: Keep local'),
              ),
              const PopupMenuItem(
                value: 'server',
                child: Text('Resolve: Keep server'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> showEditDialog(
  BuildContext context,
  RecordRepository repo,
  FieldRecord record,
) async {
  final controller = TextEditingController(text: record.title);

  await showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Edit record'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Title',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => Navigator.pop(dialogContext),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await repo.updateRecord(record.id, controller.text);
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );

  controller.dispose();
}

class StatusBanner extends StatelessWidget {
  final bool online;
  const StatusBanner({super.key, required this.online});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(online ? Icons.cloud_done : Icons.cloud_off),
        title: Text(online ? 'Online' : 'Offline mode'),
        subtitle: Text(
          online
              ? 'Local changes can be synced.'
              : 'Edits are saved locally and marked pending.',
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 56),
            SizedBox(height: 12),
            Text('No field records'),
            SizedBox(height: 4),
            Text('Records will appear here when available.'),
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const ErrorBanner({
    super.key,
    required this.message,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(message),
      leading: const Icon(Icons.warning_amber),
      actions: [
        TextButton(onPressed: onClose, child: const Text('Dismiss')),
      ],
    );
  }
}
