import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_food_screen.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({Key? key}) : super(key: key);

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Pagination
  static const int _itemsPerPage = 20;
  int _currentPage = 1; // 1-based for display
  DocumentSnapshot? _lastDocForCurrentPage;
  final List<DocumentSnapshot?> _pageCursors = [null]; // start cursor for each page
  bool _isLoading = false;
  bool _hasNextPage = true;

  // Data
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _foods = [];

  // Filtering
  String _selectedType = 'All';
  final List<String> _types = ['All'];

  @override
  void initState() {
    super.initState();
    _loadTypes();
    _loadPage(reset: true);
  }

  Future<void> _loadTypes() async {
    // Pull distinct "type" values; simple approach: fetch a chunk and dedupe.
    // (Good enough for your personal use; later you can maintain a "food_types" collection.)
    final snapshot = await _db
        .collection('users')
        .doc('ChrisPersonal')
        .collection('foods')
        .limit(500)
        .get();

    final set = <String>{};
    for (final doc in snapshot.docs) {
      final t = (doc.data()['type'] ?? '').toString().trim();
      if (t.isNotEmpty) set.add(t);
    }
    setState(() {
      _types
        ..clear()
        ..add('All')
        ..addAll(set.toList()..sort());
    });
  }

  Future<void> _loadPage({bool reset = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (reset) {
      _currentPage = 1;
      _foods.clear();
      _pageCursors
        ..clear()
        ..add(null);
      _lastDocForCurrentPage = null;
      _hasNextPage = true;
    }

    Query<Map<String, dynamic>> q = _db
        .collection('users')
        .doc('ChrisPersonal')
        .collection('foods')
        .orderBy('food')
        .limit(_itemsPerPage);

    if (_selectedType != 'All') {
      q = q.where('type', isEqualTo: _selectedType);
    }

    final startAfterDoc = _pageCursors[_currentPage - 1];
    if (startAfterDoc != null) {
      q = q.startAfterDocument(startAfterDoc);
    }

    final snap = await q.get();
    _foods = snap.docs; // current page’s docs

    // Determine if there is a next page
    _hasNextPage = snap.docs.length == _itemsPerPage;

    // Track the last doc (cursor) for the *next* page
    if (_pageCursors.length == _currentPage) {
      // add next page cursor
      _pageCursors.add(snap.docs.isNotEmpty ? snap.docs.last : null);
    } else {
      // update cursor for this page’s end
      _pageCursors[_currentPage] = snap.docs.isNotEmpty ? snap.docs.last : null;
    }
    _lastDocForCurrentPage =
        snap.docs.isNotEmpty ? snap.docs.last : _pageCursors[_currentPage - 1];

    setState(() => _isLoading = false);
  }

  Future<void> _nextPage() async {
    if (!_hasNextPage || _isLoading) return;
    setState(() => _currentPage += 1);
    await _loadPage();
  }

  Future<void> _prevPage() async {
    if (_currentPage == 1 || _isLoading) return;
    setState(() => _currentPage -= 1);
    await _loadPage();
  }

  Future<void> _openAddFood() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddFoodScreen()),
    );
    // After returning, refresh list and types
    await _loadTypes();
    await _loadPage(reset: true);
  }

  Future<void> _openEditFood(
  String docId,
  Map<String, dynamic> data,
) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddFoodScreen(
        docId: docId,
        initialData: data,
      ),
    ),
  );
  // Refresh when coming back
  await _loadTypes();
  await _loadPage(reset: true);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food List')),
      body: Column(
        children: [
          // Top controls: Filter & Add
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: _buildTypeFilter(),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _openAddFood,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Food'),
                ),
              ],
            ),
          ),
          // Header row
          _HeaderRow(),
          const Divider(height: 1),
          // List
          Expanded(
            child: _isLoading && _foods.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _foods.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade700),
                    itemBuilder: (context, index) {
                      final doc = _foods[index];
                      final data = doc.data();
                      final name = (data['food'] ?? '') as String;
                      final serving = (data['serving'] ?? {}) as Map<String, dynamic>;
                      final size = (serving['size'] ?? 0).toString();
                      final unit = (serving['unit'] ?? '').toString();

                      final nutrition =
                          (data['nutrition'] ?? {}) as Map<String, dynamic>;
                      final kcal = _numStr(nutrition['kcal']);
                      final p = _numStr(nutrition['protein']);
                      final c = _numStr(nutrition['carbs']);
                      final f = _numStr(nutrition['fat']);

                      return InkWell(
                        onTap: () => _openEditFood(doc.id, data),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Row(
                            children: [
                              _Cell(text: name, flex: 3),
                              _Cell(text: '$size $unit', flex: 2),
                              _Cell(text: kcal, flex: 1),
                              _Cell(text: p, flex: 1),
                              _Cell(text: c, flex: 1),
                              _Cell(text: f, flex: 1),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Pagination controls
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Previous page',
                  onPressed: _currentPage > 1 && !_isLoading ? _prevPage : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('Page $_currentPage'),
                IconButton(
                  tooltip: 'Next page',
                  onPressed: _hasNextPage && !_isLoading ? _nextPage : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          onChanged: (value) async {
            if (value == null) return;
            setState(() => _selectedType = value);
            await _loadPage(reset: true);
          },
          items: _types
              .map((t) => DropdownMenuItem<String>(
                    value: t,
                    child: Text(t),
                  ))
              .toList(),
        ),
      ),
    );
  }

  String _numStr(dynamic v) {
    if (v == null) return '-';
    if (v is int) return v.toString();
    if (v is double) {
      final s = v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1);
      return s;
    }
    // try parse
    final d = double.tryParse(v.toString());
    if (d == null) return v.toString();
    final s = d.toStringAsFixed(d.truncateToDouble() == d ? 0 : 1);
    return s;
  }
}

// Header row widget (Food | Serving | kcal | P | C | F)
class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          _Cell(text: 'Food', flex: 3, style: style),
          _Cell(text: 'Serving', flex: 2, style: style),
          _Cell(text: 'kcal', flex: 1, style: style),
          _Cell(text: 'P', flex: 1, style: style),
          _Cell(text: 'C', flex: 1, style: style),
          _Cell(text: 'F', flex: 1, style: style),
        ],
      ),
    );
  }
}

// Reusable cell for row layout
class _Cell extends StatelessWidget {
  final String text;
  final int flex;
  final TextStyle? style;

  const _Cell({
    Key? key,
    required this.text,
    this.flex = 1,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: style ?? Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
