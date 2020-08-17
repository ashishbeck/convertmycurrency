import 'package:currencyconverter/constants.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
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
  @override
  Widget build(BuildContext context) {
    ScrollController _controller = new ScrollController(initialScrollOffset: widget.offset != null ? (widget.offset * 200) - (MediaQuery.of(context).size.height/2) + 100 : 0);
     // =  widget.offset != null ? 0 : widget.offset;
//    print(_controller.offset);
//    position = _controller.offset;
    return Scaffold(
      body: DraggableScrollbar.arrows(
          initialScrollOffset: MediaQuery.of(context).size.height * widget.offset / widget.names.length,
          labelTextBuilder: (double offset) {
            return Text(offset~/200 < 171 ? widget.names.keys.toList()[offset~/200] : widget.names.keys.toList()[170], style: TextStyle(color: Colors.white),);
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
            List.generate(widget.names.keys.length, (int index){
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Hero(
                    tag: widget.names.keys.toList()[index],
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
                                  '${widget.names.keys.toList()[index]} (${widget.symbols[widget.names.keys.toList()[index]]})',
                                  style: chooserStyle.copyWith(fontSize: 25),
                                ),
                                Text(
                                  widget.names.values.toList()[index],
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
//        Center(
//          child: Icon(
//            Icons.add,
//            size: 50,
//          ),
//        ),
    );
  }
}
