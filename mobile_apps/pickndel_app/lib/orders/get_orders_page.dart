import 'package:bloc_login/orders/order_bloc.dart';
import 'package:bloc_login/orders/order_delivered.dart';
import 'package:bloc_login/orders/order_rejected.dart';
import 'package:bloc_login/ui/bottom_nav_bar.dart';
import 'package:bloc_login/model/order.dart';
import 'package:bloc_login/common/global.dart';
import 'package:bloc_login/orders/order_accepted.dart';
import 'package:flutter/material.dart';
import 'package:bloc_login/networking/Response.dart';
import 'package:bloc_login/model/open_orders.dart';

class GetOrders extends StatefulWidget {
  final String ordersType;

  GetOrders(this.ordersType);

  @override
  _GetOrdersState createState() => _GetOrdersState();
}

class _GetOrdersState extends State<GetOrders> {
  OrdersBloc _bloc;
  String pageTitle;

  @override
  void initState() {
    super.initState();
    _bloc = OrdersBloc(widget.ordersType);
    pageTitle =
        widget.ordersType == 'openOrders' ? 'Open Orders' : 'Active Orders';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _bloc.fetchOrder(widget.ordersType);
        },
        backgroundColor: Colors.white,
        child: new Icon(Icons.refresh),
      ),
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        title: Text(pageTitle,
            style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Color(0xFF333333),
      ),
      backgroundColor: Color(0xFF333333),
      body: RefreshIndicator(
        onRefresh: () => _bloc.fetchOrder(widget.ordersType),
        child: StreamBuilder<Response<Orders>>(
          stream: _bloc.orderDataStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot != null) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return OrdersList(
                      ordersList: snapshot.data.data,
                      ordersType: widget.ordersType);
                  break;
                case Status.ERROR:
                  {
                    if (snapshot.data.data == null) {
                      return EmptyList();
                    } else {
                      return Error(
                        errorMessage: snapshot.data.message,
                        // onRetryPressed: () => _bloc.fetchOrder(),
                      );
                    }
                  }
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
  final Orders ordersList;
  final String ordersType;

  const OrdersList({Key key, this.ordersList, this.ordersType})
      : super(key: key);

// REFERENCE - Alert dialog: https://www.youtube.com/watch?v=FGfhnS6skMQ
  Future<String> orderAlert(
      BuildContext context, Order order, String newStatus) {
    // To handle inputs from the dialiog, if there are any...
    // TextEditingController customController = TextEditingController();

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
                        // Conditions for the new status
                        newStatus == "STARTED" // Order accepted
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderAccepted(order: order),
                                      ),
                                      (Route<dynamic> route) =>
                                          false, // No Back option for this page
                                    );
                                  },
                                  child: Text(
                                    "Confirm",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Colors.red,
                                ),
                              )
                            : newStatus == "COMPLETED" // Order delivered
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    child: RaisedButton(
                                      onPressed: () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OrderDelivered(order: order),
                                          ),
                                          (Route<dynamic> route) =>
                                              false, // No Back option for this page
                                        );
                                      },
                                      child: Text(
                                        "Confirm Delivery",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: Colors.green[800],
                                    ),
                                  )
                                // Order Rejected
                                : SizedBox(
                                    // width: 320.0,
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    child: RaisedButton(
                                      onPressed: () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OrderRejected(order: order),
                                          ),
                                          (Route<dynamic> route) =>
                                              false, // No Back option for this page
                                        );
                                      },
                                      child: Text(
                                        "Confirm Cancelation",
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
  }

  @override
  Widget build(BuildContext context) {
    print('TYPE: $ordersType');
    return new Scaffold(
      backgroundColor: Color(0xFF202020),
      body: ListView.builder(
        itemCount: ordersList.orders.length,
        itemBuilder: (context, index) {
          Order order = ordersList.orders[index];
          if (ordersType == 'openOrders') {
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
                            Padding(padding: EdgeInsets.all(5.0)),
                            RaisedButton(
                              color: Colors.green,
                              child: Text(
                                "Accept",
                                style: whiteButtonTitle,
                              ),
                              onPressed: () {
                                print('Accepted Order');
                                String newStatus = "STARTED";
                                orderAlert(context, order, newStatus);

                                // Just move the "accept" screen
                                // Navigator.pushReplacementNamed(
                                //     context, '/order-accepted');

                                // orderAlert(context).then((onValue) {
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
                                // orderAlert(context).then((onValue) {
                                //   Navigator.pushReplacementNamed(
                                //       context, '/order-accepted');
                                // });

                                //Open the Alert dialog and show Snackbar with alert textmessage
                                // orderAlert(context).then((onValue) {
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
          } else {
            if (order.status == 'STARTED') {
              // Order accepted
              return Center(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Go to pickup',
                              style: TextStyle(
                                backgroundColor: Colors.red[400],
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Text('Fee: ${order.price}'),
                          ButtonBar(
                            children: <Widget>[
                              Padding(padding: EdgeInsets.all(5.0)),
                              RaisedButton(
                                color: Colors.red,
                                child: Text(
                                  "Cancel Delivery",
                                  style: whiteButtonTitle,
                                ),
                                onPressed: () {
                                  print('Cancel Order');
                                  String newStatus = 'REJECTED';
                                  orderAlert(context, order, newStatus);
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
            } else {
              // In progress orders
              return Center(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Make Delivery',
                              style: TextStyle(
                                backgroundColor: Colors.green,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                          // Text('Fee: ${order.price}'),
                          ButtonBar(
                            children: <Widget>[
                              Padding(padding: EdgeInsets.all(5.0)),
                              RaisedButton(
                                color: Colors.green,
                                child: Text(
                                  "Report Delivered",
                                  style: whiteButtonTitle,
                                ),
                                onPressed: () {
                                  print('Delivered!!');
                                  String newStatus = "COMPLETED";
                                  orderAlert(context, order, newStatus);
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
            }
          }
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
          // RaisedButton(
          //   color: Colors.white,
          //   child: Text('Retry', style: TextStyle(color: Colors.black)),
          //   onPressed: onRetryPressed,
          // )
        ],
      ),
    );
  }
}

class EmptyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Order list is Empty.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
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
