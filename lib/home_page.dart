import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:currencyconverter/chooser.dart';
import 'package:currencyconverter/constants.dart';
import 'package:currencyconverter/key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  List<dynamic> currencies;

  Map symbols = new Map();
  Map rates;
  Map names;
  double offset;
  int from;
  int to;
  bool numPadVisibility = true;
  TextEditingController fromController = new TextEditingController();
  TextEditingController toController = new TextEditingController();
  final _scaffoldKey1 = GlobalKey<ScaffoldState>();


  Future _loadCurrencies() async {
    String uri = "https://openexchangerates.org/api/latest.json?app_id=$ratesKey";
    var response = await http.get(Uri.encodeFull(uri));
//    var responseBody = json.decode(response.body);
//    rates = responseBody['rates'];
//    setState(() {});
    return response.body;
  }

  Future _getCurrencies() async {
    String uri = "https://openexchangerates.org/api/currencies.json";
    var response = await http.get(Uri.encodeFull(uri));
//    var responseBody = json.decode(response.body);
//    names = responseBody;
//    currencies = names.values.toList();
//    symbols = names.keys.toList();
//
//    setState(() {});
////    print(currencies);
//    print(currencies.length);
    return response.body;
  }

  Future _loadSymbols() async {
    String uri = "https://gist.githubusercontent.com/ashishbeck/47370898072a6db061d5856aee1a65ea/raw/3fe0a8e8c19943da120189c24bafa83730cd1d04/currency_symbols.json";
    var response = await http.get(Uri.encodeFull(uri));
//    var responseBody = json.decode(response.body);
//    rates = responseBody['rates'];
//    setState(() {});
    return response.body;
  }

  config() async {
    var prefs = await SharedPreferences.getInstance();
    int configFrom = prefs.getInt('from');
    int configTo = prefs.getInt('to');
    setState(() {
      from = configFrom != null ? configFrom : 150;
      to = configTo != null ? configTo : 46;
    });
  }

  Future updateExchangeRates(bool force) async {
    var prefs = await SharedPreferences.getInstance();
    final directory = await getApplicationDocumentsDirectory();
    final currenciesFile = File('${directory.path}/currencies.json');
    final ratesFile = File('${directory.path}/rates.json');
    final symbolsFile = File('${directory.path}/symbols.json');
    int lastUpdate = prefs.getInt('lastUpdate');
    int now = DateTime.now().millisecondsSinceEpoch;
    var duration;
    try {
      var then = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      duration = DateTime.now().difference(then);
    }catch(e){
      print('error in datetime is $e');
    }

    // update from cached json unconditionally
    try {
      var currenciesRead = await currenciesFile.readAsString();
      var ratesRead = await ratesFile.readAsString();
      var symbolsRead = await symbolsFile.readAsString();
//      if (currenciesRead == null) {
        var currenciesDecoded = json.decode(currenciesRead);
        var ratesDecoded = json.decode(ratesRead);
        var symbolsDecoded = json.decode(symbolsRead);
        setState(() {
          names = currenciesDecoded;
          rates = ratesDecoded['rates'];
          symbols = symbolsDecoded;
        });
        print('currrrrr is ${rates['EUR']}');
//      }
    }catch(e){
      print(e);
    }

    Future updateNow() async{
      var currenciesResponse = await _getCurrencies();
      var ratesResponse = await _loadCurrencies();
      var symbolsResponse = await _loadSymbols();
      currenciesFile.writeAsString(currenciesResponse);
      ratesFile.writeAsString(ratesResponse);
      symbolsFile.writeAsString(symbolsResponse);
      var currenciesDecoded = json.decode(currenciesResponse);
      var ratesDecoded = json.decode(ratesResponse);
      var symbolsDecoded = json.decode(symbolsResponse);
//      Map curMap = symbolsDecoded['currencies'];
      prefs.setInt('lastUpdate', now);
      setState(() {
        names = currenciesDecoded;
        rates = ratesDecoded['rates'];
        symbols = symbolsDecoded;
      });
      _showSnack(context, 'updated successfully', false, 'mumbojumbo');
    }

    if(lastUpdate == null){
      updateNow();
//      print('time to update $now - $lastUpdate and file is ${currenciesDecoded['USD']} + ${rates['INR']}');
    }else if(now - lastUpdate > 86400000){
      updateNow();
      print('yeaaaah');
    }else if(force == true){
      updateNow();
    } else{
      if(duration.inMinutes < 60){
        _showSnack(context, duration.inMinutes > 1 ? 'last updated ${duration.inMinutes} minutes ago' : 'last updated just now', true, 'Update Now');
      }else if (duration.inHours < 24){
        _showSnack(context, duration.inHours > 1 ? 'last updated ${duration.inHours} hours ago' : 'last updated an hour ago', true, 'Update Now');
      }
    }
  }

  Future showInfo()async{
    await Future.delayed(Duration(seconds: 15));
//    if(_notification.index == 0) {
//      print('resumed');
      _showSnack(context, 'Made by Ashish Beck', true, '➤');
//    }
//    setState(() {
//
//    });

  }

  void _showSnack(BuildContext context, String text, bool showAction, String actionText){
    final snackBar = SnackBar(
      content: Text('$text', style: TextStyle(color: Theme.of(context).accentColor),),
      duration: Duration(seconds: 5),
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      action: showAction == true ? SnackBarAction(
        label: actionText,
        onPressed: ()async{
          if(actionText == '➤'){
            await launch('https://linktr.ee/ashishbeck');
          }else {
            await updateExchangeRates(true);
            _showSnack(context, 'updating..', false, 'mumbojumbo');
          }
        },
      ) : SnackBarAction(
        label: ' ',
        onPressed: (){},
      ),
    );
    _scaffoldKey1.currentState.showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
//    _getCurrencies();
    config();
    updateExchangeRates(false);
    showInfo();
//    fromController.text = '0';
//    toController.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey1,
      body: GestureDetector(
        onTap: () {
//          setState(() {
//            if(fromController.text == ''){
//              fromController.text = '0';
//            }
//            if(toController.text == ''){
//              toController.text = '0';
//            }
//          });
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    child: Stack(
                      children: [
                        Align(
                          child: AutoSizeTextField(
                            maxLines: 1,
                            minFontSize: 5,
                            controller: fromController,
//                                initialValue: '0',
                            keyboardType: TextInputType.number,
                            decoration: inputDecoration,
                            style: chooserStyle.copyWith(fontSize: 100),
                            textAlign: TextAlign.center,
                            onChanged: (val){
                              val = val.replaceAll(",", "");
                              var fromRate = rates[names.keys.toList()[from]];
                              var toRate = rates[names.keys.toList()[to]];
                              var text = val != '' ? (((((1/fromRate) * double.parse(val) * toRate)*100).toInt())/100).toString() : '';
                              toController.text = text;
                              setState(() {

                              });
                            },
                          ),
                          alignment: Alignment(0, -0.5),
                        ),
                        Align(
                          alignment: Alignment(0, 1.005),
                          child: Hero(
                            tag: names != null ? names.keys.toList()[from] : 'fromTag',
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.15,
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))),
                                color: Colors.white,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AutoSizeText(
                                      names != null ? '${names.keys.toList()[from]} (${symbols[names.keys.toList()[from]]})' : '...',
                                      style: chooserStyle.copyWith(fontSize: 50, color: Theme.of(context).primaryColor.withOpacity(0.8)),
                                      maxLines: 1,
                                      minFontSize: 5,
                                    ),
                                    AutoSizeText(
                                      names != null ? '${names.values.toList()[from]}' : '...',
                                      style: chooserStyle.copyWith(fontSize: 30, color: Theme.of(context).primaryColor.withOpacity(0.8)),
                                      maxLines: 1,
                                      minFontSize: 5,
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      new PageRouteBuilder(
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            var begin = Offset(-1, 0);
                                            var end = Offset.zero;
                                            var curve = Curves.easeInOutCubic;

                                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                          pageBuilder: (context, animation, animation2) => chooser(
                                                names: names,
                                                symbols: symbols,
                                                offset: from,
                                              ))).then((val) async {
//                                  print(val);
                                    if (val != null && val != to) {
                                      var prefs = await SharedPreferences.getInstance();
                                      prefs.setInt('from', val);

                                      var fromRate = rates[names.keys.toList()[val]];
                                      var toRate = rates[names.keys.toList()[to]];

                                      fromController.text = fromController.text.replaceAll(",", "");
                                      var text = fromController.text != '' ? (((((1/fromRate) * double.parse(fromController.text) * toRate)*100).toInt())/100).toString() : '';
                                      setState(() {
                                        toController.text = text;
                                        from = val;
                                      });
                                    }else if(val == to){
                                      _showSnack(context, 'Please choose unique currencies to convert to', false, 'actionText');
                                    }
                                  });
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    child: Stack(
                      children: [
                        Align(
                          child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 250),
                              child: AutoSizeTextField(
                                maxLines: 1,
                                minFontSize: 5,
                                controller: toController,
//                                initialValue: '0',
                                keyboardType: TextInputType.number,
                                decoration: inputDecoration,
                                style: chooserStyle.copyWith(fontSize: 100),
                                textAlign: TextAlign.center,
                                onChanged: (val){
                                  val = val.replaceAll(",", "");
                                  var fromRate = rates[names.keys.toList()[from]];
                                  var toRate = rates[names.keys.toList()[to]];
                                  var text = val != '' ? (((((1/toRate) * double.parse(val) * fromRate)*100).toInt())/100).toString() : '';
                                  fromController.text = text;
                                  setState(() {

                                  });
                                },
                              )),
                          alignment: Alignment(0, 0.5),
                        ),
                        Align(
                          alignment: Alignment(0, -1.005),
                          child: Hero(
                            tag: names != null ? names.keys.toList()[to] : 'toTag',
                            child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.15,
                                width: MediaQuery.of(context).size.width * 0.5,
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.only(bottomRight: Radius.circular(15), bottomLeft: Radius.circular(15))),
                                color: Colors.white,
                                child: Column(
//                                    mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AutoSizeText(
                                      names != null ? '${names.values.toList()[to]}' : '...',
                                      style: chooserStyle.copyWith(fontSize: 30, color: Theme
                                          .of(context)
                                          .primaryColor
                                          .withOpacity(0.8)),
                                      maxLines: 1,
                                      minFontSize: 5,
                                    ),
                                    AutoSizeText(
                                      names != null ? '${names.keys.toList()[to]} (${symbols[names.keys.toList()[to]]})' : '...',
                                      style: chooserStyle.copyWith(fontSize: 50, color: Theme
                                          .of(context)
                                          .primaryColor
                                          .withOpacity(0.8)),
                                      maxLines: 1,
                                      minFontSize: 5,
                                    ),
                                  ],
                                ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    new PageRouteBuilder(
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          var begin = Offset(1, 0);
                                          var end = Offset.zero;
                                          var curve = Curves.easeInOutCubic;

                                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: child,
                                          );
                                        },
                                        pageBuilder: (context, animation, animation2) =>
                                            chooser(
                                              names: names,
                                              symbols: symbols,
                                              offset: to,
                                            ))).then((val) async {
//                                  print(val);
                                  if (val != null && val != from) {
                                    var prefs = await SharedPreferences.getInstance();
                                    prefs.setInt('to', val);
                                    var fromRate = rates[names.keys.toList()[from]];
                                    var toRate = rates[names.keys.toList()[val]];
//                                    RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
//                                    Function mathFunc = (Match match) => '${match[1]},';.replaceAllMapped(reg, mathFunc)
                                    fromController.text = fromController.text.replaceAll(",", "");
                                    var text = fromController.text != '' ?
                                    (((((1 / fromRate) * double.parse(fromController.text) * toRate) * 100).toInt()) / 100)
                                        .toString() : '';
                                    setState(() {
                                      toController.text = text;
                                      to = val;
                                    });
                                  }else if (val == from){
                                    _showSnack(context, 'Please choose unique currencies to convert to', false, 'actionText');
                                  }
                                });
                                FocusScope.of(context).requestFocus(new FocusNode());
                              },
                              )

                              ),
                          ),
                          ),

                      ],
                    ),
                  ),
                ),
              ],
            ),
//            Visibility(
//              visible: numPadVisibility,
//              child: Container(
//                color: Colors.white,
//                height: MediaQuery.of(context).size.height * 0.50,
//                width: MediaQuery.of(context).size.width * 0.8,
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: [
//                    Expanded(
//                      child: Row(
//                        crossAxisAlignment: CrossAxisAlignment.stretch,
//                        children: [
//                          numPadCell('1'),
//                          numPadCell('2'),
//                          numPadCell('3'),
//                        ],
//                      ),
//                    ),
//                    Expanded(
//                      child: Row(
//                        crossAxisAlignment: CrossAxisAlignment.stretch,
//                        children: [
//                          numPadCell('4'),
//                          numPadCell('5'),
//                          numPadCell('6'),
//                        ],
//                      ),
//                    ),
//                    Expanded(
//                      child: Row(
//                        crossAxisAlignment: CrossAxisAlignment.stretch,
//                        children: [
//                          numPadCell('7'),
//                          numPadCell('8'),
//                          numPadCell('9'),
//                        ],
//                      ),
//                    ),
//                    Expanded(
//                      child: Row(
//                        crossAxisAlignment: CrossAxisAlignment.stretch,
//                        children: [
//                          numPadCell('.'),
//                          numPadCell('0'),
//                          numPadCell('X'),
//                        ],
//                      ),
//                    )
//                  ],
//                ),
//              ),
//            ),
//            Visibility(
//              visible: numPadVisibility,
//              child: Align(
//                alignment: Alignment(0, 0.65),
//                child: Container(
//                  decoration: BoxDecoration(
//                    borderRadius: BorderRadius.all(Radius.circular(70)),
//                    color: Theme.of(context).accentColor.withOpacity(1),
//                  ),
//                  child: IconButton(
////              alignment: Alignment(0, 100),
//                    icon: Icon(Icons.clear),
//                    color: Colors.white,
//                    iconSize: 50,
//                    onPressed: () {
//                      setState(() {
//                        numPadVisibility = false;
//                      });
//                    },
//                  ),
//                ),
//              ),
//            )
          ],
        ),
      ),
    );
  }

  Widget numPadCell(String pad) {
    return Expanded(
      child: FlatButton(
        color: Theme.of(context).accentColor.withOpacity(1),
        shape: CircleBorder(
          side: BorderSide(color: Colors.white, width: 5, style: BorderStyle.solid),
        ),
//        padding: EdgeInsets.all(20),
        child: Text(
          pad,
          style: chooserStyle.copyWith(fontSize: 28),
        ),
        onPressed: () {
          setState(() {
            pad == 'X' ? numPadVisibility = false : print(pad);
          });
        },
      ),
    );
  }
}
