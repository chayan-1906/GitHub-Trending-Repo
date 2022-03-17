import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatefulWidget {

  const ShimmerWidget({Key key}) : super(key: key);

  @override
  _ShimmerWidgetState createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: height ~/ 80.0,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 80.0,
            decoration: BoxDecoration(
              // color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                /// profile avatar
                Shimmer.fromColors(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: CircleAvatar(
                      radius: 25.0,
                    ),
                  ),
                  baseColor: Colors.grey.shade400,
                  highlightColor: Colors.white,
                ),
                const SizedBox(width: 20.0),

                /// username & repo name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// username
                    Shimmer.fromColors(
                      baseColor: Colors.grey,
                      highlightColor: Colors.white,
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 100.0) / 2,
                        height: 13.0,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(''),
                      ),
                    ),
                    const SizedBox(height: 10.0),

                    /// repo name
                    Shimmer.fromColors(
                      baseColor: Colors.grey,
                      highlightColor: Colors.white,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 100.0,
                        height: 13.0,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(''),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
