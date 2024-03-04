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
  TextEditingController _controller = TextEditingController(text: "Hi");
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
    _scrollController.animateTo(
      _scrollController.position.extentTotal,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
    Logger().e(responses);
  }

  ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("GOOGLE AI CHAT BOT"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  // physics: NeverScrollableScrollPhysics(),
                  itemCount: responses.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
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
                                          subtitle:
                                              Text(responses[index]["my"]),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.black),
                                        )
                                      : ListTile(
                                          title: Text("Google AI"),
                                          titleTextStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900),
                                          subtitle:
                                              Text(responses[index]["ai"]),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.white),
                                        )),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: 60,
                child: TextFormField(
                  controller: _controller,
                  // readOnly: isLoading,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: isLoading
                            ? () {}
                            : () async {
                                _scrollController.animateTo(
                                  _scrollController.position.extentTotal,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                );
                                responses.add({"my": _controller.text});
                                await generate();
                              },
                        icon: Icon(
                          isLoading ? Icons.stop_circle_outlined : Icons.send,
                          color: Colors.black,
                        )),
                    // isDense: true,
                    // contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
