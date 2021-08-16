import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ntucool/ntucool.dart' as ntucool;
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'client.dart' show AppClient;
import 'html.dart';

class Syllabus extends StatefulWidget {
  const Syllabus({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  final Object courseId;

  @override
  _SyllabusState createState() => _SyllabusState();
}

class _SyllabusState extends State<Syllabus> {
  Future<ntucool.Course>? _future;

  @override
  void initState() {
    super.initState();
    var client = Provider.of<AppClient>(context, listen: false);
    _future = client.api.courses
        .getCourse(id: widget.courseId, include: ['syllabus_body']);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, AsyncSnapshot<ntucool.Course> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // TODO: Show something helpful.
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied_rounded,
                    size: 240,
                  ),
                ],
              ),
            );
          } else {
            var course = snapshot.data!;
            var syllabusBody = course.syllabusBody;
            if (syllabusBody is String) {
              return Padding(
                padding: EdgeInsets.all(8),
                child: WebView(
                  initialUrl: Uri.dataFromString(
                    syllabusBody,
                    mimeType: 'text/html',
                    encoding: utf8,
                  ).toString(),
                ),
              );
              return SingleChildScrollView(
                padding: EdgeInsets.all(12),
                child: Html(input: syllabusBody),
              );
            } else {
              // TODO: Show something helpful.
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sentiment_dissatisfied_rounded,
                      size: 240,
                    ),
                    if (syllabusBody == null)
                      Text('There is no syllabus for this course.')
                  ],
                ),
              );
            }
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
