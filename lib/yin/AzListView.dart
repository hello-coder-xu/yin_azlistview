
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:flustars/flustars.dart';
import 'package:yin_azlistview/yin/ListBean.dart';

class AzListView extends StatefulWidget {
  final List<ListBean> cityList;
  final bool displayRight;

  AzListView(this.cityList, {this.displayRight = true});

  @override
  AzListViewState createState() => new AzListViewState();
}

class AzListViewState extends State<AzListView> {
  List<ListBean> displayList = List();
  List<String> rightTags = new List();

  int tagHeight = 30;
  int itemHeight = 50;
  int diffHeight = 0;
  String headValue = "";
  String middletTag = "";

  List<int> listHeights = new List();
  List<int> listRights = new List();

  int toUpHeight = 0;
  int screenHeight = ScreenUtil.getInstance().screenHeight.toInt();
  bool displayMiddle = false;

  ScrollController controller;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(AzListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadData();
  }

  void init() {
    controller = ScrollController();
    controller.addListener(() {
      int offset = controller.offset.toInt();
      int curPosition = 0;
      for (var i = 1; i < listHeights.length - 1; ++i) {
        int top = listHeights[i];
        int bottom = listHeights[i] + (displayList[i].isHeader ? 30 : 50);
        if (offset >= top && offset < bottom) {
          curPosition = i;
          break;
        }
      }

      if (displayList[curPosition].isHeader) {
        setState(() {
          diffHeight = 0;
          headValue = displayList[curPosition].tagIndex;
        });
      } else if (displayList[curPosition + 1].isHeader) {
        int number = listHeights[curPosition] - offset;
        if (number < -30) {
          setState(() {
            diffHeight = number + 30;
            headValue = displayList[curPosition].tagIndex;
          });
        }
      } else {
        setState(() {
          diffHeight = 0;
          headValue = displayList[curPosition].tagIndex;
        });
      }
    });
  }

  void loadData() {
    sortList(widget.cityList);
    String curTag = "";
    listHeights.clear();
    rightTags.clear();
    displayList.clear();

    for (var i = 0; i < widget.cityList.length; ++i) {
      var bean = widget.cityList[i];
      if (bean.tagIndex != curTag) {
        curTag = bean.tagIndex;
        displayList.add(ListBean(tagIndex: curTag, isHeader: true));
      }
      displayList.add(bean);
      if (i == 0) {
        headValue = bean.tagIndex;
        listHeights.add(0);
      } else if (displayList[i - 1].isHeader) {
        listHeights.add(listHeights[i - 1] + tagHeight);
      } else {
        listHeights.add(listHeights[i - 1] + itemHeight);
      }

      if (!rightTags.contains(curTag)) {
        rightTags.add(curTag);
      }
    }

    for (var i = 0; i < rightTags.length; ++i) {
      if (i == 0) {
        listRights.add(0);
      } else {
        listRights.add(listRights[i - 1] + 20);
      }
    }
    toUpHeight = (screenHeight - listRights.length * 20) ~/ 2;
    setState(() {});
  }

  ///
  void sortList(List<ListBean> list) {
    if (list == null || list.isEmpty) return;
    list.forEach((it) {
      String pinyin = PinyinHelper.getPinyinE(it.name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      if (RegExp("[A-Z]").hasMatch(tag)) {
        it.tagIndex = tag;
      } else {
        it.tagIndex = "#";
      }
    });
    list.sort((left, right) => left.tagIndex.compareTo(right.tagIndex));
  }

  /// item-头部
  Widget itemHeaderView(String value) {
    return Container(
      height: tagHeight.toDouble(),
      width: double.infinity,
      color: Colors.grey[200],
      padding: EdgeInsets.only(left: 16, right: 16),
      alignment: Alignment.centerLeft,
      child: Text(value),
    );
  }

  /// item-内容
  Widget itemContentView(int position) {
    ListBean bean = displayList[position];
    return Container(
      height: itemHeight.toDouble(),
      child: new Text(bean.name),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 16, right: 16),
    );
  }

  ///列表-item
  Widget itemView(int position) {
    ListBean bean = displayList[position];
    if (bean.isHeader) {
      return itemHeaderView(bean.tagIndex);
    } else {
      return itemContentView(position);
    }
  }

  ///列表视图
  Widget listView() {
    return ListView.builder(
      itemBuilder: (context, itemIndex) => itemView(itemIndex),
      itemCount: displayList.length,
      controller: controller,
    );
  }

  /// 列表悬停视图
  Widget tagView() {
    return Positioned(
      top: diffHeight.toDouble(),
      left: 0,
      right: 0,
      child: itemHeaderView(headValue),
    );
  }

  ///右边视图
  Widget rightTagView() {
    List<Widget> views = new List();
    rightTags.forEach((it) {
      views.add(GestureDetector(
        onTapUp: (up) {
          setState(() {
            displayMiddle = false;
          });
        },
        onTapDown: (down) {
          setState(() {
            displayMiddle = true;
            headValue = it;
            middletTag = it;
          });
          scrollTo(it);
        },
        onVerticalDragUpdate: (DragUpdateDetails details) {
          rightItemPosition(details.globalPosition.dy.toInt());
        },
        onVerticalDragEnd: (DragEndDetails details) {
          setState(() {
            displayMiddle = false;
          });
        },
        child: Container(
          width: 20,
          height: 20,
          color: Colors.grey[200],
          child: Text(
            it,
            textAlign: TextAlign.center,
          ),
        ),
      ));
    });

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        children: views,
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  ///中间视图
  Widget middleView() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 60,
        width: 60,
        alignment: Alignment.center,
        color: Colors.green,
        child: Text(
          middletTag,
          style: TextStyle(fontSize: 32, color: Colors.white),
        ),
      ),
    );
  }

  ///内容视图
  Widget contentView() {
    List<Widget> views = new List();
    //列表视图
    views.add(listView());

    //列表悬停视图
    views.add(tagView());

    //右边视图
    if (widget.displayRight) {
      views.add(rightTagView());
    }

    //中间视图
    if (displayMiddle) {
      views.add(middleView());
    }

    return Stack(children: views);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: contentView(),
    );
  }

  ///判定右侧位置
  void rightItemPosition(int scrollDy) {
    int index = (scrollDy - toUpHeight - 40) ~/ 20;
    if (index >= 0 && index < rightTags.length) {
      setState(() {
        middletTag = rightTags[index];
        headValue = middletTag;
        displayMiddle = true;
      });

      scrollTo(rightTags[index]);
    } else {
      setState(() {
        displayMiddle = false;
      });
    }
  }

  ///滚动到指定位置
  void scrollTo(String tag) {
    int index = 0;
    for (int i = 0; i < displayList.length; i++) {
      if (displayList[i].tagIndex == tag) {
        index = i;
        break;
      }
    }
    controller.jumpTo(listHeights[index].toDouble());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
