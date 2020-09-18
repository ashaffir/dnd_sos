import 'package:async/async.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/geo_helpers.dart';
import 'package:pickndell/login/image_uploaded_message.dart';
import 'package:pickndell/login/message_page.dart';
import 'package:pickndell/login/profile_updated.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/model/user_profile.NA.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../common/global.dart';
import 'dart:io';

File _image;
DateTime selectedDate = DateTime.now();
String _expiryDate;

class IdUpload extends StatefulWidget {
  final User user;
  final updateField;

  IdUpload({this.user, this.updateField});

  @override
  _IdUploadState createState() => _IdUploadState();
}

class _IdUploadState extends State<IdUpload> {
  File _imageFile;
  GlobalKey<FormState> _key = new GlobalKey();
  String firstName, lastName, email, mobile, password, confirmPassword;
  bool _validate = false;
  TextEditingController dateCtl = TextEditingController();

  var _idDocTypes = List<DropdownMenuItem>();
  String _idDocType;
  List<String> _idDocTypeList;

  _loadidDocTypes() {
    _idDocTypeList = ['ID', 'Passport', 'Drivers License'];

    _idDocTypeList.forEach((element) {
      setState(() {
        _idDocTypes.add(DropdownMenuItem(
          child: Text(element),
          value: element,
        ));
      });
    });
  }

  _openGallary(BuildContext context) async {
    var picture = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxHeight: 500.0,
        maxWidth: 500.0);
    this.setState(() {
      _imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxHeight: 500.0,
        maxWidth: 500.0);
    this.setState(() {
      _imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  Future<String> uploadImage(filename, url) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('image', filename));
    var res = await request.send();
    return res.reasonPhrase;
  }

  String state = "";

  Widget _decideImageView() {
    if (_imageFile == null) {
      return Text('No image selected');
    } else {
      Image.file(
        _imageFile,
        width: 400,
        height: 400,
      );
    }
  }

  @override
  void initState() {
    _loadidDocTypes();
    super.initState();
  }

  String orderUpdated;

  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);

    return new Scaffold(
      appBar: AppBar(
        // elevation: 0.0,
        title: Text('Upload Photo ID'),
        backgroundColor: mainBackground,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: new Container(
          // margin: new EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
          margin: new EdgeInsets.all(40),
          child: new Form(
            key: _key,
            autovalidate: _validate,
            child: formUI(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  _uploadImage({File imageFile, User user}) async {
    // open a bytestream
    var stream = new http.ByteStream(DelegatingStream(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse(serverDomain + "/api/user-photo-id/");

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${user.token}',
    };

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: imageFile.path.split("/").last);

    // add file to multipart
    request.files.add(multipartFile);

    //add headers
    request.headers.addAll(headers);

    //adding params
    String country = await getCountryName();
    request.fields['user_id'] = user.userId.toString();
    request.fields['is_employee'] = user.isEmployee == 1 ? "true" : "false";
    request.fields['country'] = country;
    request.fields['id_doc_expiry'] = _expiryDate;

    // send
    var response = await request.send();

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      if (value == "202") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ImageUploaded(uploadStatus: 'ok');
            },
          ),
          (Route<dynamic> route) => false, // No Back option for this page
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ImageUploaded(uploadStatus: 'fail');
            },
          ),
          (Route<dynamic> route) => false, // No Back option for this page
        );
      }
    });
  }

  _sendToServer() async {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      showProgress(context, 'Uploading to PickNdell, Please wait...', false);
      if (_image != null) {
        updateProgress('Uploading image, Please wait...');
        _uploadImage(imageFile: _image, user: widget.user);
      } else {
        print('false');
        setState(() {
          _validate = true;
        });
      }
    }
  }

  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        "Submit Photo ID",
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("Choose from gallery",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            var image = await ImagePicker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 50,
                maxHeight: 500.0,
                maxWidth: 500.0);
            setState(() {
              _image = image;
            });
          },
        ),
        CupertinoActionSheetAction(
          child: Text("Take a picture",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            var image = await ImagePicker.pickImage(
                source: ImageSource.camera,
                imageQuality: 50,
                maxHeight: 500.0,
                maxWidth: 500.0);
            setState(() {
              _image = image;
            });
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancel",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  Widget formUI() {
    return new Column(
      children: <Widget>[
        Padding(
          padding:
              // const EdgeInsets.only(left: 8.0, top: 32, right: 8, bottom: 8),
              const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: SizedBox(
                  width: 300,
                  height: 200,
                  child: _image == null
                      ? Image.asset(
                          'assets/images/id_card.jpg',
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          _image,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                left: 80,
                right: 0,
                child: FloatingActionButton(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.camera_alt),
                    mini: true,
                    onPressed: _onCameraClick),
              )
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
          ),
        ),

        //////////////// ID document type  ////////////////////////
        ///
        DropdownButtonFormField(
          decoration: InputDecoration(
              labelText: 'ID Document Type' + ":",
              prefixIcon: Icon(Icons.portrait)),
          value: _idDocType,
          items: _idDocTypes,
          // validator: (value) {
          //   if (dropdownMenue(value) == null) {
          //     return 'Please choose a valid expiry date';
          //   } else {
          //     return null;
          //   }
          // },
          onChanged: (value) {
            setState(() {
              print('dropdown: $value');
              _idDocType = value;
            });
          },
        ),
        //////////////// Expiry date for the document ///////////////
        ///
        TextFormField(
          controller: dateCtl,
          decoration: InputDecoration(
            icon: Icon(Icons.calendar_today),
            labelText: "Document Expiry Date",
            hintText: "When the ID document expires",
          ),
          onTap: () async {
            DateTime date = DateTime(1900);
            FocusScope.of(context).requestFocus(new FocusNode());

            date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2050),
              initialDatePickerMode: DatePickerMode.year,
              helpText: 'ID expiry date', // Can be used as title
              cancelText: 'Not now',
              confirmText: 'Select',
            );
            dateCtl.text =
                date != null ? date.toIso8601String().split("T")[0] : null;
          },
          validator: (value) {
            if (value == null) {
              return 'Please choose a valid expiry date';
            }
            _expiryDate = dateCtl.text;
            return null;
          },
        ),

        Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: RaisedButton(
              color: pickndellGreen,
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              textColor: Colors.white,
              splashColor: Colors.black,
              onPressed: () {
                if (!_key.currentState.validate()) {
                  print('FAILS');
                  return;
                } else {
                  if (_image == null) {
                    return;
                  } else {
                    _sendToServer();
                  }
                }
              },
              padding: EdgeInsets.only(top: 12, bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(color: Colors.green)),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 30)),
        new GestureDetector(
          onTap: () => Navigator.of(context).pop(false),
          child: Text("Cancel"),
        ),
      ],
    );
  }

  _selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDatePicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDatePicker(context);
    }
  }

  /// This builds material date picker in Android
  buildMaterialDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2028),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'ID expiry date', // Can be used as title
      cancelText: 'Not now',
      confirmText: 'Select',

      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  /// This builds cupertion date picker in iOS
  buildCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (picked) {
                if (picked != null && picked != selectedDate)
                  setState(() {
                    selectedDate = picked;
                  });
              },
              initialDateTime: selectedDate,
              minimumYear: 2000,
              maximumYear: 2025,
            ),
          );
        });
  }
}
