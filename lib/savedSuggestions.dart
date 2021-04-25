import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'manageSavedSuggestions.dart';

class SavedSuggestions extends StatefulWidget {
  @override
  _SavedSuggestionsState createState() => _SavedSuggestionsState();
}

class _SavedSuggestionsState extends State<SavedSuggestions> {
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    final ManageSavedSuggestions manager =
        Provider.of<ManageSavedSuggestions>(context);

    if (manager.isEmpty())
      return Scaffold(
          appBar: AppBar(title: Text('Saved Suggestions')),
          body: Container(
              alignment: Alignment.center,
              child: Text('No Saved Suggestions available to show',
                  style: _biggerFont)));

    final tiles = manager.saved.map((WordPair pair) {
      return ListTile(
          title: Text(
            pair.asPascalCase,
            style: _biggerFont,
          ),
          trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              onPressed: () {
                manager.removeSuggestion(pair);
              }));
    });
    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return Scaffold(
        appBar: AppBar(title: Text('Saved Suggestions')),
        body: ListView(children: divided));
  }
}
