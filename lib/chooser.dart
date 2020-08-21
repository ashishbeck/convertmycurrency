import 'package:currencyconverter/constants.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class chooser extends StatefulWidget {
  Map symbols;
  List currencies;
  Map names;
  int offset;
  bool from;
  chooser({this.symbols, this.currencies, this.names, this.offset, this.from});
  @override
  _chooserState createState() => _chooserState();
}

class _chooserState extends State<chooser> with TickerProviderStateMixin {
//  ScrollController _controller = new ScrollController(initialScrollOffset: widget.offset);
  double extent = 150;
  final _scaffoldKey1 = GlobalKey<ScaffoldState>();
  double screenHeight;
  List payload = List();
  Map items;
  List<String> fav = [];
  ScrollController _controller = new ScrollController();
//  AnimationController _controller2;
  List<AnimationController> controllers = List<AnimationController>();
  Tween<double> _tween = Tween(begin: 1, end: 1.5);
  var _animatedWidget;
  int asdf = 0;

  void filterSearchResults(String query) {
    if(query.isNotEmpty){
      print("$query");
//      items = widget.names.keys.where((element) {
////        if(element.contains(query)){
////          print("$element and $query");
////        }
//        return element.toLowerCase().contains(query);
//      });
      items = new Map();
      widget.names.forEach((key, value) {
//        print("$key and $value");
        if(key.toString().toLowerCase().contains(query) || value.toString().toLowerCase().contains(query) || widget.symbols[key].toString().toLowerCase().contains(query)){
//          print("$query and $key and $value");
          try {
            items.putIfAbsent(key, () => value);
          }catch(e){
            print(e);
          }
        };
      });
      setState(() {
//        items = widget.names;
      });
    }else{
      setState(() {
        items = widget.names;
      });
    }
  }

  Future loadFav() async{
    var prefs = await SharedPreferences.getInstance();
    var savedFav = prefs.getStringList('fav');
    if(savedFav != null){
      setState(() {
        fav = savedFav;
      });
    }
  }

  List<Widget> favourited() {
//    List fav = ['USD', 'INR', 'EUR', 'DKK']; // temp list
    List<Widget> list = [];
    for (var item in fav){
      list.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).accentColor,
            ),
            child: IconButton(
              icon: Text(item, style: TextStyle(color: Colors.white),),
              onPressed: (){
                int actualIndex = widget.names.keys.toList().indexOf(item);
                Navigator.pop(context, actualIndex);
              },
            ),
          )
      );
    }
    return list;
  }

  void _showSnack(BuildContext context, String text){
    final snackBar = SnackBar(
      content: Text('$text', style: TextStyle(color: Theme.of(context).accentColor)),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.white,
    );
    _scaffoldKey1.currentState.showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    items = widget.names;
    loadFav();
//    _controller2 = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    for (var item in items.keys){
      controllers.add(AnimationController(duration: const Duration(milliseconds: 200), vsync: this));
    }
//    _controller2.forward();
    _animatedWidget = searchButton();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if((widget.offset * extent) - (MediaQuery.of(context).size.height/2) + (extent/2) < 0){
        _controller.jumpTo(0);
      }else if((widget.offset * extent) - (MediaQuery.of(context).size.height/2) + (extent/2) > _controller.position.maxScrollExtent) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }else{
        _controller.jumpTo((widget.offset * extent) - (MediaQuery.of(context).size.height/2) + (extent/2));
      }
    });
//    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {


    // =  widget.offset != null ? 0 : widget.offset;
//    print(_controller.offset);
//    position = _controller.offset;
    print(MediaQuery.of(context).size.height * widget.offset / items.length);
    return Scaffold(
      key: _scaffoldKey1,
//      bottomNavigationBar: Container(
//        margin: EdgeInsets.symmetric(horizontal: 24),
//        decoration: ShapeDecoration(
//          shape: RoundedRectangleBorder(
//              borderRadius: new BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))),
//          color: Colors.red,
//        ),
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.spaceAround,
//          children: favourited(),
//        ),
//      ),
      body: Stack(
          children: [Column(
            children: [
//              Expanded(
//                  flex: 1,
//                  child: SafeArea(
//                    child: Row(
//                      mainAxisAlignment: MainAxisAlignment.spaceAround,
//                      children: favourited(),
//                    )
//                  )
//              ),
//              Divider(
//                color: Theme.of(context).accentColor,
//                thickness: 2,
//              ),
              Expanded(
                flex: 10,
                child: DraggableScrollbar.arrows(
//            initialScrollOffset: MediaQuery.of(context).size.height * widget.offset / items.length,
                  labelTextBuilder: (double offset) {
                    return Text(offset~/extent < items.keys.toList().length ? items.keys.toList()[offset~/extent] : items.keys.toList()[items.keys.toList().length-1], style: TextStyle(color: Colors.white),);
                  },
                  backgroundColor: Colors.lightBlue,
                  controller: _controller,
                  child: ListView(
//            onSelectedItemChanged: (_) => print('huhu?'),
                    controller: _controller,
//          perspective: 0.001,
                    itemExtent: extent,
//        useMagnifier: true,
//            diameterRatio: 1.4,
//            magnification: 1,
                    children:
                    List.generate(items.keys.length, (int index){
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Hero(
                          tag: items.keys.toList()[index],
                          child: Material(
                            child: InkWell(
                              splashColor: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                    onTap: ()=> Navigator.pop(context, item),
                              onTap: () {
//                    payload.add(widget.from);
//                    payload.add(widget.names.keys.toList()[index]);
                                payload.add(index);
                                int actualIndex = widget.names.keys.toList().indexOf(items.keys.toList()[index]);
                                print(_controller.offset);
                                print(MediaQuery.of(context).size.height);
                                Navigator.pop(context, actualIndex);
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${items.keys.toList()[index]} (${widget.symbols[items.keys.toList()[index]]})',
                                              style: chooserStyle.copyWith(fontSize: 25),
                                            ),
                                            Text(
                                              items.values.toList()[index],
                                              style: chooserStyle,
                                            ),
                                          ],
                                        )),
                                      Align(
                                        alignment: Alignment(1,1),
                                        child: ScaleTransition(
                                          scale: _tween.animate(CurvedAnimation(parent: controllers[index], curve: Curves.easeInOutCubic)),
//                                          alignment: Alignment.center,
                                          child: IconButton(
                                            icon: Icon(fav.contains(items.keys.toList()[index]) ? Icons.favorite : Icons.favorite_border, color: Theme.of(context).accentColor,),
                                            onPressed: ()async{
                                              var prefs = await SharedPreferences.getInstance();
                                              if(!fav.contains(items.keys.toList()[index]) && fav.length < 4){
                                                controllers[index].forward().then((value) => controllers[index].reverse());
                                                setState(() {
                                                  fav.add(items.keys.toList()[index]);
                                                  prefs.setStringList('fav', fav);
                                                });
                                              }else if(fav.contains(items.keys.toList()[index])){
                                                controllers[index].forward().then((value) => controllers[index].reverse());
                                                setState(() {
                                                  fav.remove(items.keys.toList()[index]);
                                                  prefs.setStringList('fav', fav);
                                                });
                                              }else if(fav.length > 3){
                                                _showSnack(context, 'Favourites slot is full!');
                                              }
//                                            setState(() {
//
//                                            });
                                            },
                                          ),
                                        ),
                                      )
                              ]
                                  )),
                            ),
                          ),
                        ),
                      );
//            ...widget.currencies.map((dynamic name) {
//              return Padding(
//                padding: EdgeInsets.symmetric(horizontal: 10),
//                child: Container(
//                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0)), color: Theme.of(context).primaryColor),
//                    child: Center(child: Text(name, style: chooserStyle,))),
//              );
//            })
                    }),
                  ),
                ),
              ),
            ],
          ),
            Align(
              alignment: Alignment(0,0.95),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedSwitcher(
                    child: _animatedWidget,
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (Widget child2, Animation<double> animation2) {
                      return ScaleTransition(child: child2, scale: animation2,);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: favourited(),
                  )
                ],
              ),
            )
          ]
      ),
//        Center(
//          child: Icon(
//            Icons.add,
//            size: 50,
//          ),
//        ),
    );
  }
  Widget searchBox(){
    return Container(
      key: Key('box'),
      height: MediaQuery.of(context).size.height*0.095,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(width: 1, color: Colors.black.withOpacity(0.2))
        ),
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 32),

//                      color: Colors.white.withOpacity(0.9),
        child: TextField(
          autofocus: true,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Theme.of(context).accentColor),
          decoration: searchDecoration.copyWith(hintStyle: TextStyle(color: Theme.of(context).accentColor.withOpacity(0.5))),
          onChanged: (val){
            filterSearchResults(val.toLowerCase());
          },
        ),
      ),
    );
  }

  Widget searchButton(){
    return Container(
      key: Key('icon'),
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50)
          )
      ),
      child: IconButton(
        iconSize: 34,
        icon: Icon(Icons.search, color: Colors.lightBlue,),
        onPressed: () {
          setState(() {
            _animatedWidget = searchBox();
          });
        },
      ),
    );
  }
}
