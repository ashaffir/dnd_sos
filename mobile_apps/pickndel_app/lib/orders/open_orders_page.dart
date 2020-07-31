import 'package:bloc_login/bloc/order_bloc.dart';
import 'package:bloc_login/home/bottom_nav_bar.dart';
import 'package:bloc_login/model/orders.dart';
import 'package:bloc_login/common/global.dart';
import 'package:bloc_login/orders/order_accepted.dart';
import 'package:flutter/material.dart';
import 'package:bloc_login/networking/Response.dart';
import 'package:bloc_login/model/open_orders.dart';

class GetOrders extends StatefulWidget {
  @override
  _GetOrdersState createState() => _GetOrdersState();
}

class _GetOrdersState extends State<GetOrders> {
  OrderBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = OrderBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        title: Text('Open Orders',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Color(0xFF333333),
      ),
      backgroundColor: Color(0xFF333333),
      body: RefreshIndicator(
        onRefresh: () => _bloc.fetchOrder(),
        child: StreamBuilder<Response<OpenOrders>>(
          stream: _bloc.orderDataStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot != null) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  // return OrdersList(ordersList: snapshot.orders);
                  return OrdersList(ordersList: snapshot.data.data);
                  break;
                case Status.ERROR:
                  return Error(
                    errorMessage: snapshot.data.message,
                    // onRetryPressed: () => _bloc.fetchOrder(),
                  );
                  break;
              }
            }
            return Container();
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

class OrdersList extends StatelessWidget {
  final OpenOrders ordersList;

  const OrdersList({Key key, this.ordersList}) : super(key: key);

// REFERENCE - Alert dialog: https://www.youtube.com/watch?v=FGfhnS6skMQ
  Future<String> orderAcceptAlert(BuildContext context, String order_id,
      String pick_up_address, String drop_off_address) {
    // To handle inputs from the dialiog, if there are any...
    TextEditingController customController = TextEditingController();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        'Are you sure?',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          // width: 320.0,
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.transparent,
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          // width: 320.0,
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderAccepted(
                                      order_id: order_id,
                                      pick_up_address: pick_up_address,
                                      drop_off_address: drop_off_address,
                                    ),
                                  ));
                            },
                            child: Text(
                              "Confirm",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
    // return showDialog(
    //     context: context,
    //     builder: (context) {
    //       // return Dialog()
    //       return AlertDialog(
    //         title: Center(child: Text('Are you sure?')),
    //         // content: TextField(
    //         //   controller: customController,
    //         // ),
    //         actions: <Widget>[
    //           // ButtonBar()
    //           FlatButton(
    //             child: Text("Close"),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //           RaisedButton(
    //             elevation: 5.0,
    //             child: Text('Confirm'),
    //             onPressed: () {
    //               Navigator.of(context).pop(customController.text.toString());
    //             },
    //           )
    //         ],
    //       );
    //     });
    // END ALERT
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color(0xFF202020),
      body: ListView.builder(
        itemCount: ordersList.orders.length,
        itemBuilder: (context, index) {
          Order order = ordersList.orders[index];
          return Center(
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    // leading: Icon(Icons.album),
                    leading: CircleAvatar(
                      radius: 25,
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueGrey,
                      child: Text(order.order_type.toString()),
                    ),
                    title: Text('From: ${order.pick_up_address}'),
                    subtitle: Text('To: ${order.drop_off_address}'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Fee: ${order.price}'),
                      ButtonBar(
                        children: <Widget>[
                          // FlatButton(
                          //   child: const Text('BUY TICKETS'),
                          //   onPressed: () {/* ... */},
                          // ),
                          Padding(padding: EdgeInsets.all(5.0)),
                          RaisedButton(
                            color: Colors.green,
                            child: Text(
                              "Accept",
                              style: whiteButtonTitle,
                            ),
                            onPressed: () {
                              orderAcceptAlert(
                                  context,
                                  order.order_id,
                                  order.pick_up_address,
                                  order.drop_off_address);

                              // Just move the "accept" screen
                              // Navigator.pushReplacementNamed(
                              //     context, '/order-accepted');

                              // orderAcceptAlert(context).then((onValue) {
                              //   Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => OrderAccepted(
                              //           order_id: order.order_id,
                              //           pick_up_address: order.pick_up_address,
                              //           drop_off_address:
                              //               order.drop_off_address,
                              //         ),
                              //       ));
                              // });

                              //Open the Alert dialog and swith to "accept" screen
                              // orderAcceptAlert(context).then((onValue) {
                              //   Navigator.pushReplacementNamed(
                              //       context, '/order-accepted');
                              // });

                              //Open the Alert dialog and show Snackbar with alert textmessage
                              // orderAcceptAlert(context).then((onValue) {
                              //   SnackBar confirmation = SnackBar(
                              //     content: Text('Confirmed: $onValue'),
                              //   );
                              //   Scaffold.of(context).showSnackBar(confirmation);
                              // });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        // itemCount: ordersList.length,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      ),
    );
  }
}

class Error extends StatelessWidget {
  final String errorMessage;

  final Function onRetryPressed;

  const Error({Key key, this.errorMessage, this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          RaisedButton(
            color: Colors.white,
            child: Text('Retry', style: TextStyle(color: Colors.black)),
            onPressed: onRetryPressed,
          )
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  final String loadingMessage;

  const Loading({Key key, this.loadingMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }
}
