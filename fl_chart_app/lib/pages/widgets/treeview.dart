import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart_app/pages/widgets/color_indicator.dart';
import 'package:flutter/material.dart';

class NodeWidget extends StatelessWidget {
  final String text;

  const NodeWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: Colors.white),
    );
  }
}

class ScatterSpotNodeWidget extends StatelessWidget {
  final ScatterSpot spot;

  const ScatterSpotNodeWidget(this.spot);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ColorIndicator(color: spot.color),
        SizedBox(width: 8,),
        Text(
          'x: ${spot.x}, y: ${spot.y}, radius: ${spot.radius}',
          style: TextStyle(color: Colors.white),
        )
      ],
    );
  }
}

class AddNodeWidget extends StatelessWidget {
  final String text;

  const AddNodeWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.add),
        Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class BoolNodeWidget extends StatelessWidget {
  final String title;
  final bool value;

  const BoolNodeWidget(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: (newValue) {}),
        Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class TreeViewer<T> extends StatefulWidget {
  final TreeNode<T> root;
  final double initialPadding;
  final double depthPadding;
  final double nodeHeight;

  const TreeViewer({
    Key? key,
    required this.root,
    this.initialPadding = 16.0,
    this.depthPadding = 20.0,
    this.nodeHeight = 48.0,
  }) : super(key: key);

  @override
  _TreeViewerState createState() => _TreeViewerState();
}

class _TreeViewerState extends State<TreeViewer> {
  late Map<String, bool> _expansionState;

  @override
  void initState() {
    _expansionState = {};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var rows = <Widget>[];

    void appendRowRecursively(TreeNode node, int depth) {
      rows.add(
        InkWell(
          onTap: () {
            setState(() {
              if (node.children.isEmpty) {
                if (node.onClick != null) {
                  node.onClick!(context, node, depth);
                }
                return;
              }
              if (_expansionState[node.nodeId] == true) {
                _expansionState[node.nodeId] = false;
              } else {
                _expansionState[node.nodeId] = true;
              }
            });
          },
          child: Container(
            height: widget.nodeHeight,
            padding: EdgeInsets.only(left: widget.initialPadding + (widget.depthPadding * depth)),
            child: Row(
              children: [
                if (node.children.isNotEmpty)
                  Icon(
                    _expansionState[node.nodeId] == true ? Icons.expand_more : Icons.chevron_right_outlined,
                    size: 20,
                  ),
                const SizedBox(width: 4),
                node.widget,
              ],
            ),
          ),
        ),
      );

      if (_expansionState[node.nodeId] == true) {
        for (final child in node.children) {
          appendRowRecursively(child, depth + 1);
        }
      }
    }

    appendRowRecursively(widget.root, 0);

    return SingleChildScrollView(
      child: Column(
        children: rows,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );
  }
}

typedef SuggestToChangeMe<T> = void Function(TreeNode node, T data);

typedef NodeClickListener = void Function(BuildContext context, TreeNode node, int depth);

/// Node of a tree, representing one Widget
class TreeNode<T> {
  final String nodeId;

  final Widget widget;

  /// Descendant nodes.
  final List<TreeNode> children;

  final NodeClickListener? onClick;

  final TreeNode? parentNode;

  final T? data;

  String get universalId {
    var universalId = nodeId;
    var parent = parentNode;
    while (parent != null) {
      universalId = '${parent.nodeId}.$universalId';
      parent = parent.parentNode;
    }
    return universalId;
  }

  TreeNode({
    required this.nodeId,
    required this.widget,
    required this.parentNode,
    required this.data,
    this.children = const [],
    this.onClick,
  });

  TreeNode<T> addChild(TreeNode child) => copyWith(children: children + [child]);

  TreeNode<T> copyWith({
    String? nodeId,
    Widget? widget,
    List<TreeNode>? children,
    NodeClickListener? onClick,
    TreeNode? parentNode,
    T? data,
  }) {
    return TreeNode<T>(
      nodeId: nodeId ?? this.nodeId,
      widget: widget ?? this.widget,
      children: children ?? this.children,
      onClick: onClick ?? this.onClick,
      parentNode: parentNode ?? this.parentNode,
      data: data ?? this.data,
    );
  }
}
