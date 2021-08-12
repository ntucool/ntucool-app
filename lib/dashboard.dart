import 'package:flutter/material.dart';
import 'package:ntucool/ntucool.dart' as ntucool;
import 'package:ntucool_app/client.dart';
import 'package:provider/provider.dart';

const sentinel = ntucool.sentinel;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var _dashboardCards = <ntucool.DashboardCard>[];
  var _customColors;

  @override
  void initState() {
    super.initState();
    var client = Provider.of<AppClient>(context, listen: false);
    client.api.users.getCustomColors(id: 'self').then((customColors) {
      _customColors = customColors;
      client.api.dashboards.getDashboardCards().then((value) {
        setState(() {
          _dashboardCards = value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        itemBuilder: (context, index) {
          return DashboardCardWidget(
            dashboardCard: _dashboardCards[index],
            customColors: _customColors,
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemCount: _dashboardCards.length);
  }
}

class DashboardCardSingleColorImage extends StatelessWidget {
  final Color? color;

  const DashboardCardSingleColorImage({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      height: 200,
    );
  }
}

class DashboardCardWidget extends StatelessWidget {
  static const defaultImage =
      DashboardCardSingleColorImage(color: Colors.black);

  final ntucool.DashboardCard dashboardCard;
  final customColors;

  const DashboardCardWidget({
    Key? key,
    required this.dashboardCard,
    required this.customColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget image = defaultImage;
    var imageSrc = dashboardCard.image;
    if (imageSrc == null || imageSrc == sentinel) {
      var assetString = dashboardCard.assetString;
      var tmp = customColors;
      if (assetString is String &&
          tmp is Map &&
          tmp.containsKey('custom_colors')) {
        var colors = tmp['custom_colors'];
        if (colors is Map && colors.containsKey(assetString)) {
          var hexColor = colors[assetString];
          if (hexColor is String &&
              hexColor.length == 7 &&
              hexColor.startsWith('#')) {
            var value = int.tryParse('FF' + hexColor.substring(1), radix: 16);
            if (value != null) {
              image = DashboardCardSingleColorImage(color: Color(value));
            }
          }
        }
      }
    } else {
      image = Image.network(dashboardCard.image.toString());
    }
    return Card(
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: image,
          ),
          SizedBox(
            height: 12,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SelectableText(
              dashboardCard.shortName.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SelectableText(
              dashboardCard.courseCode.toString(),
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SelectableText(
              dashboardCard.term.toString(),
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }
}
