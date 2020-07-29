import 'package:bloc_login/bloc/order_bloc.dart';
import 'package:bloc_login/home/bottom_nav_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color(0xFF202020),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 0.0,
                vertical: 10.0,
              ),
              child: InkWell(
                  child: SizedBox(
                height: 165,
                child: Container(
                  color: Color(0xFF333333),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                    child: Text(
                      ordersList.orders[index].order_id,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w100,
                          fontFamily: 'Roboto'),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              )));
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
