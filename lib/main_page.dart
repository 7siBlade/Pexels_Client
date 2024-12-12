import 'package:flutter/material.dart';
import 'package:test_task/repositories/pexels_repository.dart';

import 'models/pexels.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  List<PexelsModel>? _photosFuture;
  List<Section>? _groupedPhotos;
  String _searchQuery = '';
  bool _isSearching = false;

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _loadPexels();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search photographer...",
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                    _filterPhotos();
                  });
                },
              )
            : Text('List page'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.clear : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                  _filterPhotos();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          'https://example.com/avatar.jpg',
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'example@email.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: (_photosFuture == null)
          ? const Center(child: CircularProgressIndicator())
          : _groupedPhotos!.isEmpty
              ? Center(child: Text('No items found'))
              : ListView.builder(
                  itemCount: _groupedPhotos!.length,
                  itemBuilder: (context, index) {
                    final section = _groupedPhotos![index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            section.letter,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...section.photos.map((photo) {
                          return ListTile(
                            contentPadding: EdgeInsets.all(8.0),
                            leading: Image.network(
                              photo.url,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(photo.namePhotographer),
                            subtitle: Text(photo.description),
                            onTap: () {},
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
    );
  }

  Future<void> _loadPexels() async {
    _photosFuture = await PexelsRepository().getPexels();
    _photosFuture
        ?.sort((a, b) => a.namePhotographer.compareTo(b.namePhotographer));

    _groupedPhotos = _groupPhotos(_photosFuture!);
    setState(() {});
  }

  List<Section> _groupPhotos(List<PexelsModel> photos) {
    Map<String, List<PexelsModel>> grouped = {};

    for (var photo in photos) {
      String firstLetter = photo.namePhotographer[0].toUpperCase();
      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }
      grouped[firstLetter]?.add(photo);
    }

    return grouped.entries
        .map((e) => Section(letter: e.key, photos: e.value))
        .toList()
      ..sort((a, b) => a.letter.compareTo(b.letter));
  }

  void _filterPhotos() {
    if (_searchQuery.isEmpty) {
      _groupedPhotos = _groupPhotos(_photosFuture!);
    } else {
      List<PexelsModel> filteredPhotos = _photosFuture!
          .where((photo) => photo.namePhotographer
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();

      _groupedPhotos = _groupPhotos(filteredPhotos);
    }
  }
}

class Section {
  final String letter;
  final List<PexelsModel> photos;

  Section({required this.letter, required this.photos});
}
