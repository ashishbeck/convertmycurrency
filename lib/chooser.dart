import 'package:currencyconverter/constants.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

class _chooserState extends State<chooser> {
//  ScrollController _controller = new ScrollController(initialScrollOffset: widget.offset);
  double position = 10001;
  List payload = List();
  Map items;

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
        print("$key and $value");
        if(key.toString().toLowerCase().contains(query) || value.toString().toLowerCase().contains(query) || widget.symbols[key].toString().toLowerCase().contains(query)){
          print("$query and $key and $value");
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

  @override
  void initState() {
    super.initState();
    items = widget.names;
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = new ScrollController(initialScrollOffset: (widget.offset * 200) - (MediaQuery.of(context).size.height/2) + 100 > 0 ? (widget.offset * 200) - (MediaQuery.of(context).size.height/2) + 100 : 0);
    // =  widget.offset != null ? 0 : widget.offset;
//    print(_controller.offset);
//    position = _controller.offset;
    return Scaffold(
      body: Stack(
          children: [DraggableScrollbar.arrows(
            initialScrollOffset: MediaQuery.of(context).size.height * widget.offset / items.length,
            labelTextBuilder: (double offset) {
              return Text(offset~/200 < items.keys.toList().length ? items.keys.toList()[offset~/200] : items.keys.toList()[items.keys.toList().length-1], style: TextStyle(color: Colors.white),);
            },
            backgroundColor: Colors.lightBlue,
            controller: _controller,
            child: ListView(
//            onSelectedItemChanged: (_) => print('huhu?'),
              controller: _controller,
//          perspective: 0.001,
              itemExtent: 200,
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
                          Navigator.pop(context, index);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              color: Theme.of(context).primaryColor.withOpacity(0.8),
                            ),
                            child: Center(
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
                                ))),
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
            Align(
              alignment: Alignment(0,0.95),
              child: Container(
                height: MediaQuery.of(context).size.height*0.095,
//              decoration: BoxDecoration(
//                  border: Border.all(color: Colors.blueAccent)
//              ),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(width: 1, color: Colors.black.withOpacity(0.2))
                  ),
                  elevation: 0,
                  margin: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: TextField(
                    style: TextStyle(fontSize: 15, color: Theme.of(context).accentColor),
                    decoration: searchDecoration.copyWith(hintStyle: TextStyle(color: Theme.of(context).accentColor.withOpacity(0.3))),
                    onChanged: (val){
                      filterSearchResults(val.toLowerCase());
                    },
                  ),
                ),
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
}
