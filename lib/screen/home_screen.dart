import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../report.dart';
import 'messages_screen.dart';

String shortDate(DateTime d) => '${d.month}/${d.day}/${d.year}';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final store = ReportStore();
  final queryController = TextEditingController();
  final locationController = TextEditingController();
  bool showHistory = false;
  String query = '', category = 'All', location = '';
  ReportKind? kind;
  DateTime? date;
  int tab = 0;
  @override
  void dispose() {
    store.dispose();
    queryController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> createReport(ReportKind type) async {
    final report = await Navigator.of(context).push<ItemReport>(
      MaterialPageRoute(builder: (_) => ReportForm(kind: type)));
    if (!mounted || report == null) return;
    store.add(report);
    setState(() => tab = 0);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Report added. You can find it in Home and My Reports.')));
  }

  Future<void> details(ItemReport r) async {
    await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(r.title),
      content: SizedBox(width: 460, child: SingleChildScrollView(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
        children: [ReportPhoto(report: r, height: 180), const SizedBox(height: 16),
          Text(r.description), const SizedBox(height: 12),
          Text('${r.kind.name.toUpperCase()} • ${r.category}'),
          Text('Location: ${r.location}'),
          Text('Item date: ${shortDate(r.occurredAt)}'),
          Text('Posted: ${r.createdAt.toLocal()}'),
          const SizedBox(height: 16), const Text('Meet at: $meetingPoint'),
          if (r.isReturned) Text('Returned: ${shortDate(r.returnedAt!)}'),
          if (!r.isReturned) const Padding(padding: EdgeInsets.only(top: 12),
            child: Text('Confirm only after the physical handoff. Claim verification and messaging come in a later milestone.')),
        ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
        if (!r.isReturned && r.ownerId == demoUserId)
          FilledButton(onPressed: () async {
            final confirmed = await showDialog<bool>(context: dialogContext,
              builder: (c) => AlertDialog(title: const Text('Has the item been returned?'),
                content: const Text('This removes it from the feed and keeps it in History.'),
                actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                  FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Yes, returned'))]));
            if (!mounted || !dialogContext.mounted || confirmed != true) return;
            store.markReturned(r.id, demoUserId);
            Navigator.pop(dialogContext);
          }, child: const Text('Mark returned')),
      ]));
  }

  Widget page(List<Widget> children, String name) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: ListView(
        key: PageStorageKey<String>(name),
        padding: const EdgeInsets.all(24),
        children: children,
      ),
    ),
  );

  Widget heading(String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(subtitle),
      ],
    ),
  );

  Widget reportGrid(List<ItemReport> reports, String emptyText) {
    if (reports.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(emptyText),
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 850 ? 3
          : constraints.maxWidth >= 550 ? 2 : 1;
      final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: reports.map((r) => SizedBox(
          width: width,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => details(r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReportPhoto(report: r),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.isReturned ? 'RETURNED' : r.kind.name.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(r.title, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(r.location),
                        Text(shortDate(r.occurredAt)),
                        const SizedBox(height: 12),
                        const Text('View details →'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )).toList(),
      );
    });
  }

  Widget homeContent() {
    final recent = store.search().take(6).toList();
    return page([
      heading('Lost something? Let’s find it.', 'Lost & found for the YSU community.'),
      Wrap(spacing: 12, runSpacing: 12, children: [
        FilledButton.icon(
          onPressed: () => createReport(ReportKind.lost),
          icon: const Icon(Icons.help_outline),
          label: const Text('Report Lost Item'),
        ),
        OutlinedButton.icon(
          onPressed: () => createReport(ReportKind.found),
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('Report Found Item'),
        ),
        TextButton.icon(
          onPressed: () => setState(() => tab = 1),
          icon: const Icon(Icons.search),
          label: const Text('Search Items'),
        ),
      ]),
      const SizedBox(height: 24),
      const Card(
        child: ListTile(
          leading: Icon(Icons.location_on_outlined),
          title: Text('Returning an item?'),
          subtitle: Text('Meet at: $meetingPoint. Confirm return after the handoff.'),
        ),
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Recent reports', style: Theme.of(context).textTheme.titleLarge),
          TextButton(
            onPressed: () => setState(() => tab = 1),
            child: const Text('Browse all'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      reportGrid(recent, 'No active reports yet. Report an item to get started.'),
    ], 'home');
  }

  void clearFilters() {
    queryController.clear();
    locationController.clear();
    setState(() {
      query = '';
      location = '';
      category = 'All';
      kind = null;
      date = null;
    });
  }

  Widget searchContent() {
    final results = store.search(
      query: query, category: category, location: location,
      kind: kind, date: date,
    );
    return page([
      heading('Search items', 'Find a report by keyword, category, location, or date.'),
      TextField(
        controller: queryController,
        onChanged: (v) => setState(() => query = v),
        decoration: const InputDecoration(
          labelText: 'Search item name or description',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      const SizedBox(height: 16),
      LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth >= 600
            ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
        return Wrap(spacing: 16, runSpacing: 16, children: [
          SizedBox(
            width: width,
            child: DropdownButtonFormField<String>(
              key: ValueKey(category),
              initialValue: category,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['All', ...categories].map((c) =>
                DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => category = v);
              },
            ),
          ),
          SizedBox(
            width: width,
            child: TextField(
              controller: locationController,
              onChanged: (v) => setState(() => location = v),
              decoration: const InputDecoration(labelText: 'Campus location'),
            ),
          ),
        ]);
      }),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [
        ChoiceChip(
          label: const Text('All items'), selected: kind == null,
          onSelected: (_) => setState(() => kind = null),
        ),
        for (final k in ReportKind.values)
          ChoiceChip(
            label: Text(k == ReportKind.lost ? 'Lost' : 'Found'),
            selected: kind == k,
            onSelected: (_) => setState(() => kind = k),
          ),
        OutlinedButton.icon(
          onPressed: () async {
            final value = await showDatePicker(
              context: context, initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020), lastDate: DateTime.now(),
            );
            if (mounted && value != null) setState(() => date = value);
          },
          icon: const Icon(Icons.calendar_today),
          label: Text(date == null ? 'Item date' : shortDate(date!)),
        ),
        if (date != null)
          TextButton(
            onPressed: () => setState(() => date = null),
            child: const Text('Clear date'),
          ),
        TextButton(onPressed: clearFilters, child: const Text('Clear all filters')),
      ]),
      const SizedBox(height: 24),
      Text('${results.length} matching reports',
          style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      reportGrid(results, 'No matching items. Try changing or clearing your filters.'),
    ], 'search');
  }

  Widget messagesContent() => page([
    heading('Messages', 'Conversations about lost and found items.'),
    const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.chat_bubble_outline, size: 40),
            SizedBox(height: 16),
            Text('Messaging is not connected yet.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('In the next messaging milestone, contact will start from an item report. '
                'The recipient can accept or decline the message request. '
                'Accepted requests will open a private conversation.'),
          ],
        ),
      ),
    ),
  ], 'messages');

  Widget profileContent() {
    final mine = store.search().where((r) => r.ownerId == demoUserId).toList();
    final history = store.search(history: true)
        .where((r) => r.ownerId == demoUserId).toList();
    return page([
      heading('Profile', 'Manage your reports and view returned items.'),
      const Card(
        child: ListTile(
          leading: CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text('Demo profile'),
          subtitle: Text('University sign-in and account details are not connected yet.'),
        ),
      ),
      const SizedBox(height: 24),
      Wrap(spacing: 12, runSpacing: 12, children: [
        ChoiceChip(
          label: Text('My Reports (${mine.length})'),
          selected: !showHistory,
          onSelected: (_) => setState(() => showHistory = false),
        ),
        ChoiceChip(
          label: Text('History (${history.length})'),
          selected: showHistory,
          onSelected: (_) => setState(() => showHistory = true),
        ),
      ]),
      const SizedBox(height: 16),
      Text(showHistory ? 'Returned items' : 'My active reports',
          style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(showHistory
          ? 'Your returned reports stay here, off the active feed.'
          : 'Reports created by the current demo user.'),
      const SizedBox(height: 16),
      reportGrid(
        showHistory ? history : mine,
        showHistory ? 'No returned reports yet.' : 'You have no active reports.',
      ),
    ], 'profile');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Penguin Search'),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Chip(label: Text('LOCAL DEMO')),
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (value) {
        setState(() => tab = value);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.search),
          label: 'Items',
        ),
        NavigationDestination(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Messages',
        ),
      ],
    ),
    body: AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        switch (tab) {
          case 1:
            return searchContent();
          case 2:
            return const MessagesScreen();
          case 3:
            return profileContent();
          default:
            return homeContent();
        }
      },
    ),
  );
}

class ReportPhoto extends StatelessWidget {
  const ReportPhoto({super.key, required this.report, this.height = 150});
  final ItemReport report;
  final double height;
  @override
  Widget build(BuildContext context) => report.photo != null
    ? Image.memory(report.photo!, height: height, width: double.infinity, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => SizedBox(height: height, child: const Center(child: Text('Photo unavailable'))))
    : Container(height: height, width: double.infinity, color: const Color(0xFFEDE8E4),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.inventory_2_outlined, size: 42), Text('Sample item • placeholder')]));
}

class ReportForm extends StatefulWidget {
  const ReportForm({super.key, required this.kind});
  final ReportKind kind;
  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController(), description = TextEditingController(), location = TextEditingController();
  String category = categories.first;
  DateTime occurredAt = DateTime.now();
  Uint8List? photo;
  bool picking = false;
  String? photoError;
  @override
  void dispose() { title.dispose(); description.dispose(); location.dispose(); super.dispose(); }
  Future<void> pickPhoto() async {
    setState(() { picking = true; photoError = null; });
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
      if (file == null) return;
      if (await file.length() > 8 * 1024 * 1024) throw Exception('Choose an image smaller than 8 MB.');
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => photo = bytes);
    } catch (_) {
      if (mounted) setState(() => photoError = 'Could not load photo. Try a JPG or PNG under 8 MB.');
    } finally { if (mounted) setState(() => picking = false); }
  }
  void submit() {
    final valid = formKey.currentState!.validate();
    setState(() => photoError = photo == null ? 'Item photo required.' : null);
    if (!valid || photo == null) return;
    final now = DateTime.now();
    Navigator.pop(context, ItemReport(id: now.microsecondsSinceEpoch.toString(), ownerId: demoUserId,
      title: title.text.trim(), description: description.text.trim(), location: location.text.trim(),
      category: category, kind: widget.kind, occurredAt: occurredAt, createdAt: now, photo: photo));
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.kind == ReportKind.lost ? 'Report Lost Item' : 'Report Found Item')),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 620),
      child: Form(key: formKey, child: ListView(padding: const EdgeInsets.all(24), children: [
        const Text('Demo only • use a sample object, not an ID card.'), const SizedBox(height: 20),
        if (photo != null) Image.memory(photo!, height: 180, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text('Image preview unavailable. Please choose another photo.')),
        OutlinedButton.icon(onPressed: picking ? null : pickPhoto, icon: const Icon(Icons.add_photo_alternate),
          label: Text(picking ? 'Loading…' : photo == null ? 'Choose item photo *' : 'Change photo')),
        if (photoError != null) Text(photoError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 16),
        TextFormField(controller: title, maxLength: 80, decoration: const InputDecoration(labelText: 'Item name *'),
          validator: (v) => v == null || v.trim().isEmpty ? 'Item name required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: description, maxLength: 1000, minLines: 3, maxLines: 5,
          decoration: const InputDecoration(labelText: 'Description *'),
          validator: (v) => v == null || v.trim().isEmpty ? 'Description required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: location, maxLength: 120,
          decoration: InputDecoration(labelText: widget.kind == ReportKind.found ? 'Where was it found? *' : 'Where was it last seen? *'),
          validator: (v) => v == null || v.trim().isEmpty ? 'Campus location required' : null),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(initialValue: category, decoration: const InputDecoration(labelText: 'Category'),
          isExpanded: true,
          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => category = v!)),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () async {
          final date = await showDatePicker(context: context, initialDate: occurredAt,
            firstDate: DateTime(2020), lastDate: DateTime.now());
          if (date != null && mounted) setState(() => occurredAt = date);
        }, icon: const Icon(Icons.calendar_today), label: Text('Item date: ${shortDate(occurredAt)}')),
        const SizedBox(height: 20), const Text('Return meeting point: $meetingPoint'),
        const SizedBox(height: 20), FilledButton(onPressed: picking ? null : submit, child: const Text('Post demo report')),
      ])))),
  );
}
