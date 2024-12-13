import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:test_task/repositories/pexels_repository.dart';
import '../../models/pexels.dart';
import '../../models/section.dart';
import '../../models/user.dart';
import '../../repositories/randon_user_repository.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  List<PexelsModel>? _photosFuture;
  List<SectionModel>? _groupedPhotos;
  String _searchQuery = '';
  bool _isSearching = false;
  UserRepository userRepository = UserRepository();
  UserModel? user;

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _loadUser();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: "Roboto",
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            child: ClipOval(
                              child: Image.network(
                                user?.photo ?? '',
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.userName ?? 'Loading...',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Roboto",
                                  ),
                                ),
                                Text(
                                  user?.email ?? 'Loading...',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: "Roboto",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                _showLogoutDialog(context);
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.logout,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontFamily: "Roboto",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: (_photosFuture == null)
          ? const Center(child: CircularProgressIndicator())
          : _groupedPhotos!.isEmpty
              ? Center(
                  child: Text(
                    'No items found',
                    style: TextStyle(fontSize: 22, fontFamily: "Roboto"),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(
                      const Duration(seconds: 1),
                    );
                    //_loadUser();
                    _loadPexels();
                    setState(() {});
                  },
                  child: ListView.builder(
                    itemCount: _groupedPhotos!.length,
                    itemBuilder: (context, index) {
                      final section = _groupedPhotos![index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              section.letter,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(254, 0, 97, 166)),
                            ),
                          ),
                          ...section.photos.map((photo) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(8.0),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: photo.url,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.0),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                        Icons.error,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  title: Text(photo.namePhotographer),
                                  subtitle: Text(photo.description),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Future<void> _loadUser() async {
    user = await userRepository.getUser();
    setState(() {});
  }

  Future<void> _loadPexels() async {
    setState(() {});
    _photosFuture = await PexelsRepository().getPexels();
    _photosFuture
        ?.sort((a, b) => a.namePhotographer.compareTo(b.namePhotographer));

    _groupedPhotos = _groupPhotos(_photosFuture!);
    setState(() {});
  }

  List<SectionModel> _groupPhotos(List<PexelsModel> photos) {
    Map<String, List<PexelsModel>> grouped = {};

    for (var photo in photos) {
      String firstLetter = photo.namePhotographer[0].toUpperCase();
      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }
      grouped[firstLetter]?.add(photo);
    }

    return grouped.entries
        .map((e) => SectionModel(letter: e.key, photos: e.value))
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log out'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Log out'),
            ),
          ],
        );
      },
    );
  }
}
