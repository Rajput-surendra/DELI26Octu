import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:deli/Helper/ApiBaseHelper.dart';
import 'package:deli/Helper/Color.dart';
import 'package:deli/Helper/Session.dart';
import 'package:deli/Helper/String.dart';
import 'package:deli/Model/Section_Model.dart';
import 'package:deli/Model/response_recomndet_products.dart';
import 'package:deli/Provider/FavoriteProvider.dart';
import 'package:deli/Provider/HomeProvider.dart';
import 'package:deli/Provider/UserProvider.dart';
import 'package:deli/Screen/Login.dart';
import 'package:deli/Screen/ProductList.dart';
import 'package:deli/Screen/Product_Detail.dart';
import 'package:deli/Screen/Seller_Details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Add_Address.dart';

class SubCategory extends StatefulWidget {
  final String title;
  final sellerId;
  final catId;
  final sellerData;

  const SubCategory(
      {Key? key,
      required this.title,
      this.sellerId,
      this.sellerData,
      this.catId, String? catName, List<Product>? subId})
      : super(key: key);

  @override
  State<SubCategory> createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  dynamic subCatData = [];
  var recommendedProductsData = [];
  bool mount = false;
  late ResponseRecomndetProducts responseProducts;
  var newData;
  StreamController<dynamic> productStream = StreamController();
  var imageBase = "";
  List<TextEditingController> _controller = [];
  bool _isLoading = true, _isProgress = false;
  bool _isNetworkAvail = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSeller();
    print(widget.catId);
    print(widget.sellerId);
    getSubCategory(widget.sellerId, widget.catId);
    // getRecommended(widget.sellerId);
    getRecommended(widget.catId);
  }

  void getSeller() {
    String pin = context.read<UserProvider>().curPincode;
    Map parameter = {"lat": "$latitude", "lang": "$longitude"};
    print(parameter);
    // if (pin != '') {
    //   parameter = {
    //     "lat":"$latitude",
    //     "lang":"$longitude"
    //   };
    //   print(latitude);
    //   print(longitude);
    // }

    apiBaseHelper.postAPICall(getSellerApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        sellerList =
            (data as List).map((data) => new Product.fromSeller(data)).toList();
        setState(() {});
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSellerLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSellerLoading(false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    productStream.close();
  }

  @override
  Widget build(BuildContext context) {
    print(imageBase);
    return Scaffold(
      appBar: getAppBar(widget.title, context),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder<dynamic>(
                stream: productStream.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Container(
                      child: Text(snapshot.error.toString()),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator());
                  }
                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 90),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 60,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 40,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Recommended Products',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 150,
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: snapshot.data["data"].length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 1.0,
                            childAspectRatio: 1.0,
                            mainAxisSpacing: 4.5,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            dynamic model = snapshot.data["data"][index];
                            return InkWell(
                              onTap: () => onTapGoDetails(
                                  index: index, response: snapshot.data!),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width / 50),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  child: new Card(
                                      child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                        child: FadeInImage(
                                          image: CachedNetworkImageProvider(
                                            snapshot.data["data"][index]["image"].toString(),
                                          ),
                                          fadeInDuration:
                                              Duration(milliseconds: 120),
                                          fit: BoxFit.cover,
                                          height: 120,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          // width: 120,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) =>
                                                  erroWidget(120),
                                          placeholder: placeHolder(120),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding:
                                            EdgeInsets.only(top: 5, left: 5),
                                        child: Text(
                                          snapshot.data["data"][index]["name"]
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .lightBlack),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                        Row(
                                        children: [
                                          SizedBox(width: 5,),
                                          Text(MONEY_TYPE),
                                          Text("${snapshot.data["data"][index]["min_max_price"]["max_special_price"]}"),
                                          Text(" ${snapshot.data["data"][index]["min_max_price"]["max_price"]}" , style: TextStyle(
                                            decoration: TextDecoration.lineThrough , fontSize: 10
                                          ),),
                                        ],
                                      ),
                                    ],
                                  )),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                  // new
                }),
            // InkWell(
            //   onTap: () {
            //     Product model = Product.fromJson(newData["data"][0]);
            //     Navigator.of(context).push(MaterialPageRoute(
            //         builder: (context) => ProductDetail(
            //               index: 0,
            //               model: model,
            //               secPos: 0,
            //               list: false,
            //             )));
            //   },
            //   child: Container(
            //     height: 60.0,
            //     width: 60.0,
            //     color: Colors.orange,
            //     child: Text("dsddd"),
            //   ),
            // ),
            mount
                ? subCatData.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: subCatData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              onTap: () async {
                                /*Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductList(
                                        name: widget.title,
                                        id: widget.catId,
                                        tag: false,
                                        fromSeller: false,
                                      ),
                                    )
                                );*/
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SellerProfile(
                                              search: false,
                                              sellerID: sellerList[0].seller_id,
                                              subCatId: subCatData[index]["id"],
                                              sellerData: sellerList[0],
                                            )));
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    "$imageBase${subCatData[index]["image"] ?? ""}"),
                              ),
                              title: Text(subCatData[index]["name"] ?? ""),
                              trailing: Icon(Icons.arrow_forward_ios_rounded),
                            ),
                          );
                        },
                      )
                    : Center(child: Text("No Sub Category"))
                : Text(""),
          ],
        ),
      ),
    );
  }

  getSubCategory(sellerId, catId) async {
    var parm = {"cat_id": "$catId"};
    // if (catId != null) {
    //   parm = {"seller_id": "$sellerId", "cat_id": "$catId"};
    // } else {
    //   parm = {"seller_id": "$sellerId"};
    // }

    apiBaseHelper.postAPICall(getSubCatBySellerId, parm).then((value) {
      setState(() {
        subCatData = value["recommend_products"];
        imageBase = value["image_path"];
        mount = true;
      });
    });
  }

  getRecommended(catId) async {
    // var parm = {"seller_id": "$sellerId"};
    // try {
    var parm = {"cat_id": catId};
    print(parm);
    var data = await apiBaseHelper.postAPINew(recommendedProductapi, parm);
    newData = data;
    setState(() {});
    // responseProducts = ResponseRecomndetProducts.fromJson(newData);
    if (newData["data"].isNotEmpty) {
      productStream.sink.add(newData);
    } else {
      productStream.sink.addError("");
    }
    // } catch (e) {
    //   productStream.sink.addError('ddd');
    // }
  }

  onTapGoDetails({response, index}) {
    Product model = Product.fromJson(response["data"][index]);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProductDetail(
              index: index,
              model: model,
              secPos: 0,
              list: false,
            )));
  }

}
