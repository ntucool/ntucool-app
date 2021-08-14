import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:ntucool_app/css.dart' as css;

class NodeTable extends StatelessWidget {
  const NodeTable({Key? key, required this.node}) : super(key: key);

  final dom.Node node;

  @override
  Widget build(BuildContext context) {
    var elements = [
      for (var element in node.nodes)
        if (element is dom.Element && element.localName == 'tr') element
    ];
    var children = <TableRow>[];
    for (var element in elements) {
      var c = [
        for (var e in element.nodes)
          if (e is dom.Element && e.localName == 'td')
            Container(
              padding: EdgeInsets.all(12),
              child: NodeWidget(node: e),
            )
      ];
      children.add(
        TableRow(
          children: c,
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        children: children,
        defaultColumnWidth: IntrinsicColumnWidth(flex: 1),
        border: TableBorder.all(),
      ),
    );
  }
}

class NodeWidget extends StatelessWidget {
  NodeWidget({Key? key, required this.node}) : super(key: key);

  final dom.Node node;

  @override
  Widget build(BuildContext context) {
    var node = this.node;
    Widget widget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (var element in node.nodes) NodeWidget(node: element)],
    );
    switch (node.nodeType) {
      case dom.Node.ELEMENT_NODE:
        if (node is dom.Element) {
          TextStyle? style;
          var tmp = node.attributes['style'];
          if (tmp != null) {
            var styleMap = css.parseStyle(tmp);
            var fontSize = styleMap['font-size'];
            if (fontSize != null) {
              double? value;
              if (fontSize.endsWith('pt')) {
                value =
                    double.tryParse(fontSize.substring(0, fontSize.length - 2));
              }
              if (value != null) {
                if (style == null) {
                  style = DefaultTextStyle.of(context).style;
                }
                style = style.copyWith(fontSize: value);
              }
            }
          }
          switch (node.localName) {
            case 'table':
              var elements = [
                for (var element in node.nodes)
                  if (element is dom.Element && element.localName == 'tbody')
                    element
              ];
              if (elements.isNotEmpty) {
                widget = Container(
                  child: NodeWidget(node: elements.first),
                );
              }
              break;
            case 'tbody':
              widget = NodeTable(node: node);
              break;
            case 'strong':
              if (style == null) {
                style = DefaultTextStyle.of(context).style;
              }
              style = style.copyWith(
                fontWeight: FontWeight.bold,
              );
              break;
            case 'p':
              widget = Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: widget,
              );
              break;
            case 'div':
              break;
            case 'span':
              break;
            case 'td':
              break;
            case 'br':
              widget = Container();
              break;
            default:
              print(node.localName);
              widget = Container(
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Text(
                            'Undisplayable Content (localName: ${node.localName})'),
                      ],
                    ),
                    Positioned.fill(child: Placeholder()),
                  ],
                ),
              );
          }
          if (style != null) {
            widget = DefaultTextStyle(style: style, child: widget);
          }
          break;
        }
        break;
      case dom.Node.TEXT_NODE:
        var text = node.text;
        if (text != null) {
          text = text.trim();
          if (text.isNotEmpty) {
            widget = Text(text);
            break;
          }
        }
        widget = Container();
        break;
      case dom.Node.DOCUMENT_FRAGMENT_NODE:
        break;
      default:
    }
    return widget;
  }
}

class Html extends StatelessWidget {
  Html({Key? key, required this.input}) : super(key: key) {
    documentFragment = parser.parseFragment(input);
    widget = NodeWidget(node: documentFragment);
  }

  final input;
  late final dom.DocumentFragment documentFragment;
  late final Widget widget;

  @override
  Widget build(BuildContext context) {
    return widget;
  }
}
