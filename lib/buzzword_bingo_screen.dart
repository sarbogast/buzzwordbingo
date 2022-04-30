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
import 'package:flutter/material.dart';

import 'buzzword.dart';

class BuzzwordBingoScreen extends StatefulWidget {
  const BuzzwordBingoScreen({Key? key}) : super(key: key);

  @override
  State<BuzzwordBingoScreen> createState() => _BuzzwordBingoScreenState();
}

class _BuzzwordBingoScreenState extends State<BuzzwordBingoScreen> {
  // TODO: Add Firestore properties here
  final List<Buzzword> _buzzwords = [
    Buzzword(word: 'revolution', count: 3),
    Buzzword(word: 'amazing', count: 5),
    Buzzword(word: 'best', count: 2),
  ];
  late StreamController<List<Buzzword>> _buzzwordsStreamController;
  late Stream<List<Buzzword>> _buzzwordsStream;
  final _wordController = TextEditingController();

  @override
  void initState() {
    _buzzwordsStream = _watchBuzzwords();
    super.initState();
  }

  Stream<List<Buzzword>> _watchBuzzwords() {
    _buzzwordsStreamController = StreamController<List<Buzzword>>();
    _buzzwordsStreamController.add(_buzzwords);
    return _buzzwordsStreamController.stream;
  }

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  void _addWord(String word) {
    _wordController.clear();

    final existingBuzzwordIndex =
        List<Buzzword?>.from(_buzzwords).indexWhere((element) {
      return element!.word == word;
    });
    if (existingBuzzwordIndex < 0) {
      _buzzwords.add(Buzzword(
        word: word,
        count: 1,
      ));
    } else {
      _buzzwords[existingBuzzwordIndex] = Buzzword(
        word: word,
        count: _buzzwords[existingBuzzwordIndex].count + 1,
      );
    }

    _buzzwordsStreamController.add(_buzzwords);
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
        title: const Text('BuzzwordBingo'),
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
