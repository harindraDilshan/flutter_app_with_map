import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:my_app/pages/PolyllineMarkersPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Collection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ImageCollectionScreen(),
    );
  }
}

class ImageCollection {
  String name;
  List<String> imagePaths;

  ImageCollection({required this.name, required this.imagePaths});
}

class ImageCollectionScreen extends StatefulWidget {
  const ImageCollectionScreen({super.key});

  @override
  State<ImageCollectionScreen> createState() => _ImageCollectionScreenState();
}

class _ImageCollectionScreenState extends State<ImageCollectionScreen> {
  final List<ImageCollection> collections = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _collectionNameController =
      TextEditingController();

  void _showCreateCollectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Collection'),
          content: TextField(
            controller: _collectionNameController,
            decoration: const InputDecoration(
              labelText: 'Collection Name',
              hintText: 'Enter a name for your collection',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _collectionNameController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_collectionNameController.text.isNotEmpty) {
                  _createCollection();
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _createCollection() {
    if (_collectionNameController.text.isNotEmpty) {
      setState(() {
        collections.add(
          ImageCollection(
            name: _collectionNameController.text,
            imagePaths: [],
          ),
        );
        _collectionNameController.clear();
      });
    }
  }

  Future<void> _addImagesToCollection(int collectionIndex) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          collections[collectionIndex].imagePaths.addAll(
                images.map((image) => image.path).toList(),
              );
        });
      }
    } catch (e) {
      print('Error picking images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting images: $e')),
      );
    }
  }

  void _deleteCollection(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Collection'),
          content: Text(
              'Are you sure you want to delete "${collections[index].name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  collections.removeAt(index);
                });
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Collections'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: collections.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_album_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No collections yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap + to create a new collection'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: collections.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          collections[index].name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${collections[index].imagePaths.length} images',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_photo_alternate),
                              onPressed: () => _addImagesToCollection(index),
                              tooltip: 'Add Images',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteCollection(index),
                              tooltip: 'Delete Collection',
                            ),
                            // Add a button to go to map
                            IconButton(
                              icon: const Icon(Icons.map),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PolyllineMarkersPage(
                                      collection: collections[index],
                                    ),
                                  ),
                                );
                              },
                              tooltip: 'View on Map',
                            ),
                          ],
                        ),
                      ),
                      if (collections[index].imagePaths.isNotEmpty)
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(8),
                            itemCount: collections[index].imagePaths.length,
                            itemBuilder: (context, imageIndex) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    children: [
                                      Image.file(
                                        File(collections[index]
                                            .imagePaths[imageIndex]),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              collections[index]
                                                  .imagePaths
                                                  .removeAt(imageIndex);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCollectionDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _collectionNameController.dispose();
    super.dispose();
  }
}
