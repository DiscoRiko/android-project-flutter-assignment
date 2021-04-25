import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/loginPage.dart';
import 'package:hello_me/manageSavedSuggestions.dart';
import 'package:hello_me/savedSuggestions.dart';
import 'package:hello_me/snappingSheet.dart';
import 'package:provider/provider.dart';
import 'auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthRepository>(
            create: (_) => AuthRepository.instance()),
        ChangeNotifierProxyProvider<AuthRepository, ManageSavedSuggestions>(
            create: (_) => ManageSavedSuggestions(),
            update: (_, authenticator, manager) =>
                manager!..update(authenticator))
      ],
      child: MaterialApp(
          title: 'Startup Name Generator',
          theme: ThemeData(primaryColor: Colors.red),
          home: RandomWords()),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Startup Name Generator'), actions: [
          IconButton(icon: Icon(Icons.favorite), onPressed: _pushSaved),
          Consumer<AuthRepository>(
              builder: (context, authenticator, _) => authenticator
                      .isAuthenticated
                  ? IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        Provider.of<ManageSavedSuggestions>(context,
                                listen: false)
                            .clearAtLogOut();
                        authenticator.signOut();
                      })
                  : IconButton(icon: Icon(Icons.login), onPressed: _pushLogin))
        ]),
        body: Consumer<AuthRepository>(
            builder: (context, authenticator, _) =>
                authenticator.isAuthenticated
                    ? MySnappingSheet(_buildSuggestions)
                    : _buildSuggestions()));
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }

          final int index = i ~/ 2;

          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    final ManageSavedSuggestions manager =
        Provider.of<ManageSavedSuggestions>(context);
    final alreadySaved = manager.contains(pair);

    return ListTile(
        title: Text(pair.asPascalCase, style: _biggerFont),
        trailing: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null),
        onTap: () {
          setState(() {
            if (alreadySaved) {
              manager.removeSuggestion(pair);
            } else {
              manager.addSuggestion(pair);
            }
          });
        });
  }

  void _pushSaved() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return SavedSuggestions();
    }));
  }

  void _pushLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return LoginPage();
    }));
  }
}
