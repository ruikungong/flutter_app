import 'package:flutter/material.dart';
import 'package:flutter_app/bean/qdaily.dart';
import 'package:flutter_app/bean/qdaily_web.dart';
import 'package:flutter_app/qdaily/column/special.dart';
import 'package:flutter_app/qdaily/ui/item_column.dart';
import 'package:flutter_app/service/api_service.dart';
import 'package:flutter_app/utils/loading_util.dart';
import 'package:flutter_app/utils/route_util.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class ColumnsPage extends StatefulWidget {
  ColumnsPage({Key key}) : super(key: key);

  @override
  createState() => _ColumnsPageState();
}

class _ColumnsPageState extends State<ColumnsPage> {
  int lastKey = 0;

  GlobalKey<EasyRefreshState> _easyRefreshKey = GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshFooterState> _footerKey = GlobalKey<RefreshFooterState>();

  bool isLoadComplete = false;

  DataBean dataBean;
  List<ColumnBean> columns = [];

  @override
  void initState() {
    super.initState();

    getColumnsData(lastKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(title: Text('栏目中心'), elevation: 0.0),
        body: columns.isEmpty ? getLoadingWidget() : _buildBodyView());
  }

  void getColumnsData(int lastKey) async {
    dataBean = await ApiService.getQdailyColumnList(lastKey);

    if (dataBean == null) {
      // 请求失败
    } else {
      this.lastKey = dataBean?.lastKey;
      columns.addAll(dataBean.columns);
      isLoadComplete = !dataBean.hasMore;

      print('${this.lastKey}=============$isLoadComplete');
      setState(() {});
    }
  }

  Widget _buildBodyView() {
    return EasyRefresh(
        key: _easyRefreshKey,
        refreshFooter: BallPulseFooter(
            key: _footerKey, color: Colors.red, backgroundColor: Colors.white),
        loadMore: isLoadComplete ? null : () async => getColumnsData(lastKey),
        child: ListView.builder(
            itemBuilder: (context, index) => ItemColumn(
                column: columns[index],
                onTap: () => pushNewPage(
                    context,
                    SpecialPage(
                        columnId: columns[index].id,
                        image: columns[index].imageLarge,
                        imageTag: 'cloumn-image-${columns[index].id}'))),
            itemCount: columns.length));
  }
}