import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '麻雀得点計算App',
      home: Scaffold(
        appBar: AppBar(
          title: Text("麻雀得点計算App"),
          centerTitle: true,
        ),
        body: Card(
          child: MahjongScore(),
        ),
      ),
    );
  }
}

class MahjongScore extends StatefulWidget {
  @override
  MahjongScoreState createState() => MahjongScoreState();
}

class MahjongScoreState extends State<MahjongScore> {
  int _selectedHu = 30;
  int _selectedHan = 2;

  int _hu;
  int _han;

  List<int> _childScore = List(3);
  List<int> _parentScore = List(2);

  final List<int> _listHu = [
    20,
    30,
    40,
    50,
    60,
    70,
    80,
    90,
    100,
    110,
  ];

  final List<int> _listHan = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _ScoreArea(),
        _DataArea(),
        _ButtonArea(),
      ],
    );
  }

  void fetchPosts(int hu, int han) {
    var url = 'http://192.168.11.105:8000/score?hu=${hu}&han=${han}';
    http.get(url).then((response) {
      setState(() {
        var data = jsonDecode(response.body)[0];
        _childScore = [data['c_ron'], data['c_draw_c'], data['c_draw_p']];
        _parentScore = [data['p_ron'], data['p_draw']];
      });
    });
  }

  @override
  void initState() {
    this._hu = this._selectedHu;
    this._han = this._selectedHan;
    fetchPosts(this._hu, this._han);

    super.initState();
  }

  Widget _ScoreArea() {
    final tableTextStyle =
        TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold);

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 30.0, bottom: 50.0),
          child: Text("${this._hu}符${this._han}翻", style: tableTextStyle),
        ),
        Table(
          children: [
            TableRow(
              children: [
                Center(
                  child: Text(""),
                ),
                Center(
                  child: Text("ロン", style: tableTextStyle),
                ),
                Center(
                  child: Text("ツモ", style: tableTextStyle),
                ),
              ],
            ),
            TableRow(
              children: [
                Center(
                  child: Text("親", style: tableTextStyle),
                ),
                Center(
                  // child: Text("${getScore(this._hu, this._han, false)[0]}",
                  child: Text("${_parentScore[0]}",
                      style: tableTextStyle),
                ),
                Center(
                  // child: Text("${getScore(this._hu, this._han, false)[1]}",
                  child: Text("${_parentScore[1]}A",
                      style: tableTextStyle),
                ),
              ],
            ),
            TableRow(
              children: [
                Center(
                  child: Text("子", style: tableTextStyle),
                ),
                Center(
                  child: Text("${_childScore[0]}", style: tableTextStyle),
                ),
                Center(
                  child: Text("${_childScore[1]}, ${_childScore[2]}",
                      style: tableTextStyle),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }


  Widget _pickerItem(int h) {
    return Text(h.toString(), style: TextStyle(fontSize: 32));
  }

  Widget _onSelectedHuChanged(int index) {
    setState(() {
      _selectedHu = _listHu[index];
    });
  }

  Widget _onSelectedHanChanged(int index) {
    setState(() {
      _selectedHan = _listHan[index];
    });
  }

  void _showModalPickerHu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CupertinoPicker(
              itemExtent: 40,
              children: _listHu.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedHuChanged,
            ),
          ),
        );
      },
    );
  }

  void _showModalPickerHan(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CupertinoPicker(
              itemExtent: 40,
              children: _listHan.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedHanChanged,
            ),
          ),
        );
      },
    );
  }

  Widget _DataArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            _showModalPickerHu(context);
          },
          child: Text("${_selectedHu}符"),
        ),
        RaisedButton(
          onPressed: () {
            _showModalPickerHan(context);
          },
          child: Text("${_selectedHan}翻"),
        ),
      ],
    );
  }

  void _handlePressed() {
    setState(() {
      this._hu = _selectedHu;
      this._han = _selectedHan;
      fetchPosts(this._hu, this._han);
    });
  }

  Widget _ButtonArea() {
    return Container(
      margin: EdgeInsets.only(top: 70.0, bottom: 30.0),
      child: FlatButton(
        onPressed: _handlePressed,
        color: Colors.blue,
        child: Text(
          "点数を表示",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }
}
