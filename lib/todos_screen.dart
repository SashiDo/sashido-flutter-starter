import 'package:material_ui/material_ui.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'config.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key, required this.user, required this.onLogout});

  final ParseUser user;
  final VoidCallback onLogout;

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final _title = TextEditingController();
  final _focus = FocusNode();
  List<ParseObject> _todos = [];
  String? _error;
  LiveQuery? _liveQuery;
  Subscription<ParseObject>? _subscription;

  QueryBuilder<ParseObject> get _query => QueryBuilder<ParseObject>(ParseObject('Todo'))
    ..orderByDescending('createdAt')
    ..setLimit(100);

  @override
  void initState() {
    super.initState();
    _load();
    if (Config.liveQueries) _subscribe();
  }

  // the ACL set in cloud/main.js means a user only finds their own todos
  Future<void> _load() async {
    final response = await _query.query();
    if (!mounted) return;
    setState(() {
      if (response.success) {
        _todos = (response.results ?? []).cast<ParseObject>();
      } else {
        _error = response.error?.message;
      }
    });
  }

  Future<void> _subscribe() async {
    _liveQuery = LiveQuery();
    final subscription = await _liveQuery!.client.subscribe(_query);
    _subscription = subscription;
    void upsert(dynamic todo) {
      if (!mounted) return;
      final object = todo as ParseObject;
      setState(() => _todos = [object, ..._todos.where((t) => t.objectId != object.objectId)]);
    }

    subscription.on(LiveQueryEvent.create, upsert);
    subscription.on(LiveQueryEvent.update, (dynamic todo) {
      if (!mounted) return;
      final object = todo as ParseObject;
      setState(() => _todos = [for (final t in _todos) t.objectId == object.objectId ? object : t]);
    });
    subscription.on(LiveQueryEvent.delete, (dynamic todo) {
      if (!mounted) return;
      setState(() => _todos.removeWhere((t) => t.objectId == (todo as ParseObject).objectId));
    });
  }

  Future<void> _add() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final todo = ParseObject('Todo')
      ..set('title', title)
      ..set('done', false);
    final response = await todo.save();
    if (!mounted) return;
    if (response.success) {
      setState(() => _todos = [todo, ..._todos.where((t) => t.objectId != todo.objectId)]);
      _title.clear();
      _focus.requestFocus();
    } else {
      setState(() => _error = response.error?.message);
    }
  }

  Future<void> _toggle(ParseObject todo) async {
    todo.set('done', !(todo.get<bool>('done') ?? false));
    await todo.save();
    if (mounted) setState(() {});
  }

  Future<void> _delete(ParseObject todo) async {
    await todo.delete();
    if (mounted) setState(() => _todos.removeWhere((t) => t.objectId == todo.objectId));
  }

  Future<void> _logout() async {
    await widget.user.logout();
    widget.onLogout();
  }

  @override
  void dispose() {
    if (_subscription != null) _liveQuery?.client.unSubscribe(_subscription!);
    _title.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.user.username}'s todos"),
        actions: [TextButton(onPressed: _logout, child: const Text('Log out'))],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('newTodo'),
                        controller: _title,
                        focusNode: _focus,
                        decoration: const InputDecoration(hintText: 'What needs doing?'),
                        onSubmitted: (_) => _add(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(key: const Key('add'), onPressed: _add, child: const Text('Add')),
                  ],
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: _todos.isEmpty
                      ? const Center(child: Text('Nothing yet.'))
                      : ListView(
                          children: [
                            for (final todo in _todos)
                              CheckboxListTile(
                                key: Key('todo-${todo.objectId}'),
                                value: todo.get<bool>('done') ?? false,
                                onChanged: (_) => _toggle(todo),
                                controlAffinity: ListTileControlAffinity.leading,
                                title: Text(
                                  todo.get<String>('title') ?? '',
                                  style: (todo.get<bool>('done') ?? false)
                                      ? const TextStyle(decoration: TextDecoration.lineThrough)
                                      : null,
                                ),
                                secondary: IconButton(
                                  tooltip: 'Delete',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _delete(todo),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
