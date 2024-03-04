import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ai/api_key.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late GenerativeModel _generativeModel;
  TextEditingController _controller = TextEditingController();
  List responses = [];
  @override
  void initState() {
    super.initState();
    initModel();
  }

  initModel() {
    _generativeModel =
        GenerativeModel(model: "gemini-pro", apiKey: GoogleApi.apiKey);
  }

  bool isLoading = false;
  generate() async {
    isLoading = true;
    setState(() {});
    var prompt = [Content.text(_controller.text)];
    _controller.clear();
    var response = await _generativeModel.generateContent(prompt);
    responses.add({"ai": response.text ?? ''});
    setState(() {
      isLoading = false;
    });
    Logger().e(responses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GOOGLE AI CHAT BOT"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ...List.generate(
                  responses.length,
                  (index) => SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: responses[index].containsKey("my")
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: Get.width * 0.65,
                          child: Align(
                            child: Card(
                                color: !responses[index].containsKey("my")
                                    ? Colors.black
                                    : Colors.white,
                                child: responses[index].containsKey("my")
                                    ? ListTile(
                                        title: Text("Me"),
                                        titleTextStyle: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w900),
                                        subtitle: Text(responses[index]["my"]),
                                        subtitleTextStyle:
                                            TextStyle(color: Colors.black),
                                      )
                                    : ListTile(
                                        title: Text("Google AI"),
                                        titleTextStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900),
                                        subtitle: Text(responses[index]["ai"]),
                                        subtitleTextStyle:
                                            TextStyle(color: Colors.white),
                                      )),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
      bottomNavigationBar: Container(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: Get.width * 0.68,
                ),
                child: TextFormField(
                  controller: _controller,
                  readOnly: isLoading,
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder()),
                ),
              ),
              Spacer(),
              ElevatedButton(
                  onPressed: isLoading
                      ? () {}
                      : () async {
                          responses.add({"my": _controller.text});
                          await generate();
                        },
                  child: Text(isLoading ? "Loading..." : "Search"))
            ],
          ),
        ),
      ),
    );
  }
}
