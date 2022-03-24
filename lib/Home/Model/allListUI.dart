import 'package:esprit/Home/AppTheme/appthemeColors.dart';
import 'package:flutter/material.dart';
import 'package:esprit/SizeConfig.dart';

class AllCoursesUI extends StatelessWidget {
  final Function onTab;

  const AllCoursesUI({Key key, this.onTab}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66.1290322581 * SizeConfig1.heightMultiplier,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 0, left: 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: onTab,
                    child: Container(
                      decoration: BoxDecoration(
                          color: AppThemeColors.darkBlue.withOpacity(0.20),
                          borderRadius: BorderRadius.all(Radius.circular(
                              3.87096774194 * SizeConfig1.heightMultiplier))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                left: 15,
                                top: 1.3 * SizeConfig1.heightMultiplier,
                                right: 15),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 5,
                              top: 1.58064516129 * SizeConfig1.heightMultiplier,
                              right: 15,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
