import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'crud_service.dart';

// TODO: put YOUR last name here – it must be visible in the screenshot.
const String kLastName = 'DALANDANGAN';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CrudService service = CrudService();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();
  bool showFavoritesOnly = false; // Favorites filter state

  @override
  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    super.dispose();
  }

  void openAddDialog() {
    nameCtrl.clear();
    qtyCtrl.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Item'),
        content: _fields(),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && qtyCtrl.text.isNotEmpty) {
                service.addItem(
                    nameCtrl.text.trim(), int.tryParse(qtyCtrl.text) ?? 0);
                Navigator.pop(context);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void openEditDialog(QueryDocumentSnapshot item) {
    final data = item.data() as Map<String, dynamic>;
    nameCtrl.text = data['name'] ?? '';
    qtyCtrl.text = '${data['quantity'] ?? 0}';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Item'),
        content: _fields(),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              service.updateItem(item.id, nameCtrl.text.trim(),
                  int.tryParse(qtyCtrl.text) ?? 0);
              Navigator.pop(context);
            },
            child: const Text('Edit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _fields() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
                labelText: 'Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Quantity', border: OutlineInputBorder()),
          ),
        ],
      );

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              service.deleteItem(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text('Firebase | $kLastName'),
        actions: [
          IconButton(
            tooltip: 'Show favorites only',
            icon: Icon(
                showFavoritesOnly ? Icons.favorite : Icons.favorite_border),
            onPressed: () =>
                setState(() => showFavoritesOnly = !showFavoritesOnly),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var docs = snapshot.data!.docs;
          if (showFavoritesOnly) {
            docs = docs.where((d) {
              final m = d.data() as Map<String, dynamic>;
              return (m['isFavorite'] ?? false) == true;
            }).toList();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final item = docs[index];
              final data = item.data() as Map<String, dynamic>;
              final isFav = (data['isFavorite'] ?? false) == true;
              return Card(
                child: ListTile(
                  title: Text(data['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Quantity ${data['quantity'] ?? 0}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey),
                        onPressed: () =>
                            service.toggleFavorite(item.id, !isFav),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => openEditDialog(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => confirmDelete(item.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: openAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}