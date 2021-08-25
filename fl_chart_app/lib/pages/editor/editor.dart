import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart_app/pages/editor/editor_dialogs.dart';
import 'package:fl_chart_app/pages/widgets/treeview.dart';
import 'package:flutter/material.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({Key? key}) : super(key: key);

  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  ScatterChartData data = ScatterChartData(
    minX: 0,
    minY: 0,
    maxY: 10,
    maxX: 10,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 300,
            color: Colors.white10,
            child: TreeViewer(
              root: createScatterChartDataNode(data, (node, newScatterChartData) {
                setState(() {
                  data = newScatterChartData;
                });
              }),
            ),
          ),
          Expanded(
            child: Container(
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: ScatterChart(data),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

TreeNode<ScatterChartData> createScatterChartDataNode(
  ScatterChartData data,
  SuggestToChangeMe<ScatterChartData> suggestToChangeMe,
) {
  final scatterChartDataNode = TreeNode<ScatterChartData>(
    nodeId: 'scatterChartData',
    widget: NodeWidget('scatterChartData'),
    parentNode: null,
    data: data,
  );

  return scatterChartDataNode.copyWith(children: [
    createScatterSpotsNode(scatterChartDataNode, data.scatterSpots, (node, newScatterSpots) {
      suggestToChangeMe(scatterChartDataNode, data.copyWith(scatterSpots: newScatterSpots));
    }),
    createTitlesDataNode(scatterChartDataNode, data.titlesData, (node, newTitlesData) {
      suggestToChangeMe(scatterChartDataNode, data.copyWith(titlesData: newTitlesData));
    }),
  ]);
}

TreeNode<List<ScatterSpot>> createScatterSpotsNode(
  TreeNode parent,
  List<ScatterSpot> data,
  SuggestToChangeMe<List<ScatterSpot>> suggestToChangeMe,
) {
  final scatterSpotsNode = TreeNode<List<ScatterSpot>>(
    nodeId: 'scatterSpots',
    widget: NodeWidget('scatterSpots'),
    data: data,
    parentNode: parent,
  );
  final childNOdes = data.asMap().entries.map((entry) {
    final index = entry.key;
    final spot = entry.value;
    return createScatterSpotNode(scatterSpotsNode, index, spot, (node, newScatterSpot) {
      final newData = List.of(data);
      newData[index] = newScatterSpot;
      suggestToChangeMe(scatterSpotsNode, newData);
    });
  }).toList();
  return scatterSpotsNode.copyWith(
    children: childNOdes +
        [
          TreeNode<ScatterSpot>(
            parentNode: parent,
            nodeId: 'addNode',
            widget: AddNodeWidget('Add ScatterSpot'),
            data: null,
            onClick: (context, node, depth) {
              final newSpot = ScatterSpot(1, 1);
              suggestToChangeMe(scatterSpotsNode, data + [newSpot]);
            },
          )
        ],
  );
}

TreeNode<FlTitlesData> createTitlesDataNode(
    TreeNode parent, FlTitlesData data, SuggestToChangeMe<FlTitlesData> suggestToChangeMe) {
  final id = 'titlesData';
  final titlesDataNode = TreeNode(
    nodeId: id,
    widget: NodeWidget(id),
    data: data,
    parentNode: parent,
  );

  return titlesDataNode.copyWith(children: [
    createBooleanNode(titlesDataNode, 'show', data.show, (node, newShow) {
      suggestToChangeMe(titlesDataNode, data.copyWith(show: newShow));
    }),
    createSideTitlesNode(titlesDataNode, 'left', data.leftTitles, (node, newSideTitles) {
      suggestToChangeMe(titlesDataNode, data.copyWith(leftTitles: newSideTitles));
    }),
    createSideTitlesNode(titlesDataNode, 'top', data.topTitles, (node, newSideTitles) {
      suggestToChangeMe(titlesDataNode, data.copyWith(topTitles: newSideTitles));
    }),
    createSideTitlesNode(titlesDataNode, 'right', data.rightTitles, (node, newSideTitles) {
      suggestToChangeMe(titlesDataNode, data.copyWith(rightTitles: newSideTitles));
    }),
    createSideTitlesNode(titlesDataNode, 'bottom', data.bottomTitles, (node, newSideTitles) {
      suggestToChangeMe(titlesDataNode, data.copyWith(bottomTitles: newSideTitles));
    }),
  ]);
}

TreeNode<ScatterSpot> createScatterSpotNode(
  TreeNode parent,
  int index,
  ScatterSpot data,
  SuggestToChangeMe<ScatterSpot> suggestToChangeMe,
) {
  var id = 'scatterSpot${index}';
  return TreeNode(
    nodeId: id,
    widget: ScatterSpotNodeWidget(data),
    parentNode: parent,
    data: data,
    onClick: (context, node, depth) async {
      final newSpot = await showScatterSpotDialog(context, data);
      if (newSpot == data) {
        return;
      }
      suggestToChangeMe(
        node,
        newSpot,
      );
    },
  );
}

TreeNode<SideTitles> createSideTitlesNode(
  TreeNode parent,
  String side,
  SideTitles data,
  SuggestToChangeMe<SideTitles> suggestToChangeMe,
) {
  return TreeNode<SideTitles>(
      nodeId: '${side}Titles',
      widget: NodeWidget('${side}Titles'),
      data: data,
      parentNode: parent,
      onClick: (context, node, depth) {});
}

TreeNode<bool> createBooleanNode(
  TreeNode parent,
  String id,
  bool data,
  SuggestToChangeMe<bool> suggestToChangeMe,
) {
  final boolNode = TreeNode<bool>(
      nodeId: id,
      widget: BoolNodeWidget(id, data),
      parentNode: parent,
      data: data,
      onClick: (context, node, depth) {
        suggestToChangeMe(node, !data);
      });
  return boolNode;
}

TreeNode<List<int>> createIntListNode(
  TreeNode parent,
  String id,
  List<int> values,
  SuggestToChangeMe<List<int>> suggestToChangeMe,
) {
  return TreeNode<List<int>>(
      nodeId: id, widget: NodeWidget(values.toString()), parentNode: parent, data: values, onClick: (context, node, depth) {});
}
