import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Welcome to Flutter!",
      home: RandomWords(),
    );
  }
}

class RandomWordsState extends State<RandomWords> {
  List<Post> _posts = <Post>[];
  final Set<Post> _saved = Set();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  Widget _buildSuggestions() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _posts.length,
        itemBuilder: (context, i) {
          return _buildRow(_posts[i]);
        },
      ),
    );
  }

  Future<void> _refresh() {
    return fetchPost().then((posts) {
      setState(() {
        _posts = posts;
      });
    });
  }

  Widget _buildRow(Post post) {
    final bool saved = _saved.contains(post);
    return ListTile(
      title: Text(post.title, style: _biggerFont),
      trailing: Icon(
        saved ? Icons.favorite : Icons.favorite_border,
        color: saved ? Colors.red : null,
      ),
      onLongPress: () {
        setState(() {
          if (saved) {
            _saved.remove(post);
          } else {
            _saved.add(post);
          }
        });
      },
      onTap: () {
        _pushDetail(post.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Startup Name generator'), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.list),
          onPressed: _pushSaved,
        )
      ]),
      body: _buildSuggestions(),
    );
  }

  Future<List<Post>> fetchPost() async {
    final resp = await http.get('https://jsonplaceholder.typicode.com/posts');
    if (resp.statusCode == 200) {
      return (json.decode(resp.body) as List<dynamic>).map((e) {
        return Post.fromJson(e);
      }).toList();
    } else {
      throw Exception('Faild to load posts');
    }
  }

  void _pushDetail(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final postIndex = _posts.indexWhere((post) => post.id == index);
          final post = _posts[postIndex];
          return Scaffold(
            appBar: AppBar(title: Text(post.title)),
            body: Text(
              post.body,
              style: _biggerFont,
            ),
          );
        },
      ),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map((Post post) {
            return ListTile(
              title: Text(post.title, style: _biggerFont),
            );
          });
          final List<Widget> divided =
              ListTile.divideTiles(context: context, tiles: tiles).toList();

          return Scaffold(
            appBar: AppBar(title: const Text('Saved')),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => new RandomWordsState();
}

// {
//   "userId": 1,
//   "id": 1,
//   "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
//   "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
// },
class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post({this.userId, this.id, this.title, this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}
