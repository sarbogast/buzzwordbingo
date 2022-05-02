/*
 * Copyright (c) 2022.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'app_config.dart';
import 'buzzword.dart';

class BuzzwordBingoScreen extends StatefulWidget {
  const BuzzwordBingoScreen({Key? key}) : super(key: key);

  @override
  State<BuzzwordBingoScreen> createState() => _BuzzwordBingoScreenState();
}

class _BuzzwordBingoScreenState extends State<BuzzwordBingoScreen> {
  // TODO: Add Firestore properties here
  final _firestore = FirebaseFirestore.instance;
  late CollectionReference<Map<String, dynamic>> _buzzwordsCollection;
  late Stream<List<Buzzword>> _buzzwordsStream;
  final _wordController = TextEditingController();

  @override
  void initState() {
    _buzzwordsStream = _watchBuzzwords();
    super.initState();
  }

  Stream<List<Buzzword>> _watchBuzzwords() {
    // 1
    _buzzwordsCollection = _firestore.collection('buzzwords');
    // 2
    return _buzzwordsCollection.orderBy('word').snapshots().map((snapshot) {
      // 3
      return snapshot.docs.map((document) {
        // 4
        final documentData = document.data();
        return Buzzword(
          word: documentData['word'] as String,
          count: documentData['count'] as int,
        );
      }).toList();
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  void _addWord(String word) async {
    // 1
    _wordController.clear();

    // 2
    final buzzwords = await _buzzwordsCollection
        .where(
          'word',
          isEqualTo: word,
        )
        .get();
    if (buzzwords.size == 0) {
      // 3
      await _buzzwordsCollection.add(<String, dynamic>{
        'word': word,
        'count': 1,
      });
    } else {
      // 4
      final buzzwordDocument = buzzwords.docs.first;
      final oldCount = buzzwordDocument.data()['count'] as int;
      await buzzwordDocument.reference.update({'count': oldCount + 1});
    }
  }

  Widget _buildBuzzwordCard(Buzzword buzzword) {
    return Card(
      child: InkWell(
        onTap: () => _addWord(buzzword.word),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  '${buzzword.count}',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(buzzword.word),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TODO: replace with AppConfig-extracted app title
        title: Text(AppConfig.of(context).appTitle),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Type a buzzword here',
                ),
                controller: _wordController,
                onEditingComplete: () {
                  _addWord(_wordController.value.text);
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Buzzword>>(
                stream: _buzzwordsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Could not load buzzwords'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return GridView.count(
                    crossAxisCount: 3,
                    children: snapshot.data!.map(
                      (buzzword) {
                        return _buildBuzzwordCard(buzzword);
                      },
                    ).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
