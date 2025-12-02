import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();

  String _definition = "";
  String _example = "";
  String _phonetic = "";
  String _partOfSpeech = "";
  String _wordsearch = "";
  bool _isLoading = false;
  List<dynamic> _meaning = [];

  String _sound = "";

  Future<void> fetchDefinition(String word) async {
    try {
      setState(() {
        _isLoading = true; // show loading
      });
      print(word);
      http.Response response = await http.get(
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
      );

      if (response.statusCode != 200) {
        print("Error: ${response.statusCode}");
        return;
      } else {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final firstEntry = data[0];
          setState(() {
            _wordsearch = firstEntry['word'] ?? '';
            _phonetic = firstEntry['phonetic'] ?? '';
            _meaning = firstEntry['meanings'] ?? [];
            _partOfSpeech = _meaning.isNotEmpty
                ? _meaning[0]['partOfSpeech'] ?? ''
                : '';
            _sound =
                firstEntry['phonetics'] != null &&
                    firstEntry['phonetics'].isNotEmpty
                ? firstEntry['phonetics'][0]['audio'] ?? ''
                : '';

            _isLoading = false; // hide loading
          });
        }
      }

      print(response.body);
      searchController.clear();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dictionary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 4, 37, 63),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(15, 30, 15, 0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Text("Search", style: TextStyle(fontSize: 17)),
                // const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                255,
                                142,
                                142,
                                142,
                              ).withOpacity(0.2),
                              blurRadius: 1.4,
                              spreadRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),

                        child: TextField(
                          // controller: titleController,r
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Input the word to search",
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 118, 118, 118),
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),

                    SizedBox(
                      width: 40,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color.fromARGB(
                            255,
                            62,
                            120,
                            164,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final word = searchController.text;
                          fetchDefinition(word);
                        },
                        // onPressed: fetchDefinition,
                        child: const Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: EdgeInsets.fromLTRB(12, 35, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_wordsearch != null && _wordsearch.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              _wordsearch,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                                final player = AudioPlayer();
                                player.play(UrlSource(_sound));
                              },
                              icon: Icon(Icons.volume_up, color: Colors.red),
                            ),
                          ],
                        ),
                      // SizedBox(height: 8),
                      Text(
                        _phonetic,
                        style: TextStyle(
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                if (_wordsearch != null && _wordsearch.isNotEmpty)
                  Divider(
                    thickness: 1,
                    color: const Color.fromARGB(255, 135, 135, 135),
                    height: 40,
                  ),

                Expanded(
                  child: ListView.builder(
                    itemCount: _meaning.length,
                    itemBuilder: (context, index) {
                      final meaning = _meaning[index];
                      final definitions = meaning["definitions"];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meaning['partOfSpeech'] ?? '',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 10),

                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: definitions.length,
                            itemBuilder: (context, defIndex) {
                              final def = definitions[defIndex]; // ✔ correct

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "• ${def["definition"]}",
                                      style: TextStyle(fontSize: 17),
                                    ), // show real

                                    SizedBox(height: 5),
                                    if (def["example"] != null)
                                      Text(
                                        "Example: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    if (def["example"] != null)
                                      Text(
                                        "${def["example"]}",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(1),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
