import 'package:flutter/material.dart';
import 'package:ntucool/ntucool.dart' as ntucool;
import 'package:provider/provider.dart';

import 'client.dart';
import 'course.dart';

const sentinel = ntucool.sentinel;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<ntucool.DashboardCard>? _dashboardCards;
  var _customColors;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() {
    var client = Provider.of<AppClient>(context, listen: false);
    () async {
      var value = await client.api.users.getCustomColors(id: 'self');
      if (!mounted) {
        return;
      }
      setState(() {
        _customColors = value;
      });
    }();
    () async {
      var value = await client.api.dashboards.getDashboardCards();
      if (!mounted) {
        return;
      }
      setState(() {
        _dashboardCards = value;
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    var dashboardCards = _dashboardCards;
    if (dashboardCards == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        itemBuilder: (context, index) {
          return DashboardCardWidget(
            dashboardCard: dashboardCards[index],
            customColors: _customColors,
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemCount: dashboardCards.length);
  }
}

class DashboardCardSingleColorImage extends StatelessWidget {
  final Color? color;

  const DashboardCardSingleColorImage({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      color: color,
      height: 120,
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
      image = Center(
        child: Image.network(dashboardCard.image.toString()),
      );
      image = Ink.image(
        image: NetworkImage(
          dashboardCard.image.toString(),
        ),
        height: 120,
      );
    }
    return Card(
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image,
            SizedBox(
              height: 12,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
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
              child: Text(
                dashboardCard.courseCode.toString(),
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                dashboardCard.term.toString(),
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            SizedBox(
              height: 12,
            ),
          ],
        ),
        onTap: () {
          var id = dashboardCard.id;
          if (id == sentinel || id == null) {
            // TODO: Show something.
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) {
                return CoursePage(id: id);
              },
            ),
          );
        },
      ),
    );
  }
}
