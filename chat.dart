import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:diemchat/Screens/widgets/get_credits.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:firebase_database/firebase_database.dart' as firebase;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:diemchat/Screens/contactinfo.dart';
import 'package:diemchat/Screens/fullScreenVideo.dart';
import 'package:diemchat/Screens/videoCall/call_utilities.dart';
import 'package:diemchat/Screens/videoCall/pickup_layout.dart';
import 'package:diemchat/Screens/videoCall/user.dart';
import 'package:diemchat/Screens/videoView.dart';
import 'package:diemchat/Screens/widgets/player_widget.dart';
import 'package:diemchat/constatnt/Constant.dart';
import 'package:diemchat/constatnt/global.dart';
import 'package:diemchat/helper/sizeconfig.dart';
import 'package:diemchat/models/starModel.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:timeago/timeago.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import 'package:file/local.dart';
import 'dart:math' as math;
import 'package:toast/toast.dart';
import 'package:diemchat/Screens/saveContact.dart';
import 'package:diemchat/Screens/viewImages.dart';
import 'package:linkable/linkable.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:diemchat/Screens/widgets/thumbnailImage.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:swipeable/swipeable.dart';
import '../../story/editor.dart';

// ignore: must_be_immutable
class Chat extends StatefulWidget {
  LocalFileSystem localFileSystem;
  String searchText;
  String searchTime;
  String peerID;
  bool archive;
  String pin;
  bool mute;
  Timestamp chatListTime;
  String currentUserId;
  String peerName;
  Chat(
      {this.searchText,
      this.searchTime,
      this.peerID,
      this.archive,
      this.peerName = "",
      @required this.currentUserId,
      this.pin,
      this.mute,
      this.chatListTime,
      localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _ChatState createState() => _ChatState(peerID: peerID);
}

class _ChatState extends State<Chat> {
  String peerID;
  String peerUrl = '';
  String peerToken = '';
  String peerChatIn = '';

  _ChatState({@required this.peerID});
  // ignore: unused_field
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dataKey = new GlobalKey();
//RECORDER ----------------------------------------------------------------

  bool record = false;
  bool running = false;
  bool button = false;
  File voiceRecording;
//RECORDER ----------------------------------------------------------------

  String groupChatId = "";
  QuerySnapshot listMessage;
  File videoFile;
  File videoInfo;
  VideoPlayerController _videoPlayerController;
  bool isLoading;
  String imageUrl;
  int limit = 20;

  final TextEditingController textEditingController = TextEditingController();

  TextEditingController reviewCode = TextEditingController();
  TextEditingController reviewText = TextEditingController();
  bool isInView = false;
  File _path;
  String filename;

  var check = [];
  var toSendname = [];
  var toSendphone = [];
  // ignore: non_constant_identifier_names
  double HEIGHT = 96;
  final ValueNotifier<double> notifier = ValueNotifier(0);
  Timestamp banner;
  var backImage = '';
  var blocksId = [];
  var peerblocksId = [];

  String _messageText = "";

  bool searchData = false;
  TextEditingController controller = new TextEditingController();
  TextEditingController forwardController = new TextEditingController();
  List chatMsgList;
  firebase.FirebaseDatabase database = new firebase.FirebaseDatabase();
  bool deleteButton = false;
  var deleteMsgTime = [];
  var deleteMsgID = [];
  var deleteMsgContent = [];
  //LocationResult _pickedLocation;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    isLapHours: true,
    onChange: (value) => print(''),
    onChangeRawSecond: (value) => print(''),
    onChangeRawMinute: (value) => print(''),
  );
  bool replyButton = false;
  String replyMsg = '';
  var replyTime;
  int replyType = 0;
  String replyName = '';
  var imageMedia = [];
  var videoMedia = [];
  var docsMedia = [];
  bool offline = false;
  var imageMediaTime = [];

  User sender = User();
  User receiver = User();

  var getContacts = [];
  var newgetContacts = [];
  // ignore: unused_field
  GiphyGif _gif;
  final textFieldFocusNode = FocusNode();
  final FocusNode focusNode = FocusNode();
//FORWARD

//FOR PERSON TO PERSON

  bool forwardButton = false;
  var forwardContent = [];
  var forwardTime = [];
  var forwardTypes = [];

  var forwardMsgId = [];
  var forwardMsgContent = [];
  var forwardMsgContact = [];
  var forwardMsgPeerName = [];
  var forwardMsgPeerImage = [];
  var forwardMsgType = [];

  //FOR GROUP
  var groupMsgId = [];
  var groupMsgUserId = [];
  var groupMsgContent = [];
  var groupMsgContact = [];
  var groupMsgPeerName = [];
  var groupMsgPeerImage = [];
  var groupMsgType = [];
  //FORWARD

  bool isButtonEnabled = false;

  String profilrPrivacy = '';
  String lastSeenPrivacy = '';
  bool loadPage = true;

  //EDIT IMAGE
  bool editImage = false;
  int _currentImage = 0;

  //Blink
  bool _showBlink = false;
  Timer _timerBlink;
  String contentBlink = '';

  Timer searchOnStoppedTyping;

  _onChangeHandler(value) {
    const duration = Duration(
        milliseconds:
            300); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() {
        typingFunction("typing");
        searchOnStoppedTyping.cancel();
      }); // clear timer
    }
    setState(() {
      searchOnStoppedTyping = new Timer(duration, () {
        search(value);
        typingFunction("Online");
      });
    });
  }

  search(value) {
    print('hello world from search . the value is $value');
  }

  typingFunction(status) {
    FirebaseDatabase.instance.reference().child("users").child(userID).update({
      "status": status,
    });
  }

  Future getPhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = widget.currentUserId;
    globalImage = prefs.getString("photo");
    globalName = prefs.getString("nick");
    setState(() {});
  }

  @override
  void initState() {
    readLocal();
    getPhoto();
    getPeerUser();
    listScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);

    _initVoiceRecorder();
    // checkInternet();

    chatInCall();

    getBlockId();

    super.initState();
    isLoading = false;
    imageUrl = '';

    removeBadge();
  }

  getPeerUser() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.peerID)
        .get()
        .then((snapshot) {
      setState(() {
        widget.peerName = snapshot["nick"];
        peerChatIn = snapshot["inChat"];
        peerToken = snapshot["token"];
        sender.uid = userID;
        sender.name = globalName;
        sender.profilePhoto = globalImage;

        receiver.uid = peerID;
        receiver.name = widget.peerName;
        receiver.profilePhoto = peerUrl;
        print(peerChatIn + "-" + widget.currentUserId);
      });
    });
  }

  String statusText = "";
  bool isComplete = false;
  //SCROLL TO SPECIFIC INDEX
  bool isScroll = true;
  final scrollDirection = Axis.vertical;
  int gotoindex;
  AutoScrollController listScrollController;
  List<List<int>> randomList;

  _scrollToIndex(index) async {
    print("👉" + widget.searchText.toString());
    print("👉" + widget.searchTime.toString());
    await listScrollController.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin);
  }
  //SCROLL TO SPECIFIC INDEX

  _initVoiceRecorder() async {
    try {
      if (await Permission.microphone.isGranted) {
        String customPath = '/flutter_audio_recorder_';
        Directory appDocDirectory;
        if (Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();
      } else {
        // ignore: deprecated_member_use
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _timerBlink?.cancel();
    super.dispose();
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  // void showNotification(String title, String body) async {
  //   await _demoNotification(title, body);
  // }

  // Future<void> _demoNotification(String title, String body) async {
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //       'channel_ID', 'channel name', 'channel description',
  //       importance: Importance.Max,
  //       playSound: true,
  //       showProgress: true,
  //       sound: RawResourceAndroidNotificationSound('custom'),
  //       priority: Priority.High,
  //       ongoing: true,
  //       enableVibration: true,
  //       enableLights: true,
  //       timeoutAfter: 1,
  //       color: Colors.green,
  //       ticker: '');

  //   var iOSChannelSpecifics = IOSNotificationDetails();
  //   var platformChannelSpecifics = NotificationDetails(
  //       androidPlatformChannelSpecifics, iOSChannelSpecifics);
  //   await flutterLocalNotificationsPlugin
  //       .show(0, title, body, platformChannelSpecifics, payload: 'test');
  // }

  // Future<bool> checkInternet() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile) {
  //     internet = true;
  //     return true;
  //   } else if (connectivityResult == ConnectivityResult.wifi) {
  //     internet = true;
  //     return true;
  //   } else {
  //     internet = false;
  //   }
  //   return false;
  // }

  chatInCall() {
    FirebaseFirestore.instance.collection("users").doc(userID).update({
      "inChat": peerID,
    }).then((_) {
      setState(() {});
    });
  }

  chatOutCall() {
    FirebaseFirestore.instance.collection("users").doc(userID).update({
      "inChat": "",
    }).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  goBackFunctionCall() {
    // setState(() {
    //     _scrollToIndex();
    // });
    // print(widget.searchTime);
    // Scrollable.ensureVisible(dataKey.currentContext);
    chatOutCall();
    Navigator.pop(context);
  }

  readMessage() async {
    await FirebaseFirestore.instance
        .collection("messages")
        .doc(groupChatId)
        .collection(groupChatId)
        .where("idTo", isEqualTo: userID)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((documentSnapshot) {
        documentSnapshot.reference.update({'read': true});
        // print("True");
      });
    });
  }

  //New Contacts for share

  //New Contacts for share

  // void _openFileExplorer() async {
  //   _path = await FilePicker.getFile();
  //   setState(() async {
  //     if (_path != null) {
  //       setState(() {
  //         isLoading = true;
  //       });
  //       filename = path.basename(_path.path);
  //       final StorageReference postImageRef =
  //           FirebaseStorage.instance.ref().child("User Document");
  //       var timeKey = new DateTime.now();
  //       final StorageUploadTask uploadTask =
  //           postImageRef.child(timeKey.toString()).putFile(_path);
  //       var fileUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
  //       onSendMessage(fileUrl, 5, '', '', '', '', 5);
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   });
  // }

  // addFile(BuildContext context) async {
  //   if (videoFile != null) {
  //     setState(() {
  //       isLoading = true;
  //     });

  //     var timeKey = new DateTime.now();
  //     final StorageReference ref =
  //         FirebaseStorage.instance.ref().child("Video" + timeKey.toString());

  //     StorageUploadTask uploadTask = ref.putFile(
  //         videoFile, StorageMetadata(contentType: timeKey.toString() + '.mp4'));

  //     await uploadTask.onComplete;
  //     String downloadUrl = await ref.getDownloadURL();

  //     onSendMessage(downloadUrl, 4, '', '', '');
  //     setState(() {
  //       isLoading = false;
  //       _videoPlayerController.dispose();
  //     });
  //   } else {}
  // }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  List<Asset> images = <Asset>[];
  List<File> allImages = [];

  Future<void> getImage() async {
    images = [];

    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Select Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      images.forEach((imageAsset) async {
        final filePath =
            await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);

        File tempFile = File(filePath);
        if (tempFile.existsSync()) {
          // sendImage(tempFile);
          if (allImages.contains(tempFile)) {
          } else {
            allImages.add(tempFile);
          }

          if (allImages.length > 0) {
            _currentImage = 0;
            editImage = true;
          }

          // allImages = [];
          // allImages.add(tempFile);
          // print(allImages);
          // print(allImages.length);
        }
      });

      print(error);
    });
  }

  getimageditor() {
    // // ignore: unused_local_variable
    // final geteditimage =
    //     Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return ImageEditorPro(
    //     appBarColor: Colors.white,
    //     bottomBarColor: Colors.white,
    //     image: allImages[_currentImage],
    //   );
    // })).then((geteditimage) {
    //   if (geteditimage != null) {
    //     setState(() {
    //       allImages[_currentImage] = geteditimage;
    //       if (allImages[_currentImage] != null) {
    //         // addPost(context, globalName, globalImage, _image);
    //       }
    //     });
    //   }
    // }).catchError((er) {
    //   print(er);
    // });
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper().cropImage(
        sourcePath: allImages[_currentImage].path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.grey,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: '',
        ));
    if (croppedFile != null) {
      allImages[_currentImage] = croppedFile;
      setState(() {
        // state = AppState.cropped;
      });
    }
  }

  Widget editImageWidget() {
    final double height = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
              initialPage: 0,
              height: height,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImage = index;
                  print(_currentImage);
                });
              }
              // autoPlay: false,
              ),
          items: allImages
              .map((item) =>
                  Container(color: appColorWhite, child: Image.file(item)))
              .toList(),
        ),
        allImages.length > 1
            ? Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: allImages.map((url) {
                    int index = allImages.indexOf(url);

                    return Container(
                      width: 15.0,
                      height: 15.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 20.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImage == index
                            ? appColorBlue
                            : Colors.grey[500],
                      ),
                    );
                  }).toList(),
                ),
              )
            : Container(),
      ],
    );
  }

  Future sendImage(_image) async {
    // File _image;

    // final picker = ImagePicker();
    // final imageFile = await picker.getImage(source: ImageSource.gallery);

    //   if (imageFile != null) {
    //  _image = File(imageFile.path);
    setState(() {
      isLoading = true;
    });
    final dir = await getTemporaryDirectory();
    final targetPath = dir.absolute.path +
        "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

    await FlutterImageCompress.compressAndGetFile(
      _image.absolute.path,
      targetPath,
      quality: 20,
    ).then((value) async {
      print("Compressed");
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      String imageLocation =
          'ChatImageMedia/${widget.currentUserId}/${DateTime.now()}.jpg';

      await firebase_storage.FirebaseStorage.instance
          .ref(imageLocation)
          .putFile(value);
      String downloadUrl = await firebase_storage.FirebaseStorage.instance
          .ref(imageLocation)
          .getDownloadURL();

      imageUrl = downloadUrl;
      if (replyButton == true) {
        onSendMessage(imageUrl, 9, '', replyName, replyMsg, replyTime, 1);
        setState(() {
          replyButton = false;
        });
      } else {
        onSendMessage(imageUrl, 1, '', '', '', '', 1);
      }

      setState(() {
        isLoading = false;
      });
    });
    //  }
  }

  Future getImageFromCam(bool boomshot) async {
    File _image;

    final picker = ImagePicker();
    final imageFile = await picker.getImage(source: ImageSource.camera);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
        _image = File(imageFile.path);
      });
      final dir = await getTemporaryDirectory();
      final targetPath = dir.absolute.path +
          "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

      await FlutterImageCompress.compressAndGetFile(
        _image.absolute.path,
        targetPath,
        quality: 20,
      ).then((value) async {
        print("Compressed");
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();

        String imageLocation =
            'ChatImageMedia/${widget.currentUserId}/${DateTime.now()}.jpg';

        await firebase_storage.FirebaseStorage.instance
            .ref(imageLocation)
            .putFile(value);
        String downloadUrl = await firebase_storage.FirebaseStorage.instance
            .ref(imageLocation)
            .getDownloadURL();

        imageUrl = downloadUrl;
        setState(() {
          isLoading = false;
          if (replyButton == true) {
            onSendMessage(
                imageUrl, 9, '', replyName, replyMsg, replyTime, 1, boomshot);
            setState(() {
              replyButton = false;
            });
          } else {
            onSendMessage(imageUrl, 1, '', '', '', '', 1, boomshot);
          }
        });
      });
    }
  }

  _pickVideo() async {
    setState(() {
      videoFile = null;
      Navigator.pop(context);
    });

    final picker = ImagePicker();
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        videoFile = File(pickedFile.path);
        addVideo(context);
      } else {
        print('No video selected.');
      }
    });

    _videoPlayerController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        //  _videoPlayerController.play();
      });
  }

  addVideo(BuildContext context) async {
    if (videoFile != null) {
      await VideoCompress.setLogLevel(0);
      setState(() {
        isLoading = true;
      });
      final videoInfo = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (videoInfo != null) {
        var timeKey = new DateTime.now();

        String imageLocation =
            'ChatImageMedia/${widget.currentUserId}/${DateTime.now()}.mp4';

        await firebase_storage.FirebaseStorage.instance
            .ref(imageLocation)
            .putFile(File(videoInfo.path));
        String downloadUrl = await firebase_storage.FirebaseStorage.instance
            .ref(imageLocation)
            .getDownloadURL();

        onSendMessage(downloadUrl, 4, '', '', '', '', 4);
        setState(() {
          isLoading = false;
          _videoPlayerController.dispose();
        });
        return videoInfo;
      } else {
        print("NULLLL");
        return videoInfo;
      }
    } else {}
  }

  removeBadge() async {
    FirebaseFirestore.instance
        .collection('chatList')
        .doc(widget.currentUserId)
        .collection(widget.currentUserId)
        .doc(widget.peerID)
        .update({'badge': '0'});
  }

  // ignore: unused_element
  void _scrollListener() {
    if (listScrollController.position.pixels ==
        listScrollController.position.maxScrollExtent) {
      startLoader();
    }
  }

  void startLoader() {
    setState(() {
      isLoading = true;
      fetchData();
    });
  }

  fetchData() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, onResponse);
  }

  void onResponse() {
    setState(() {
      isLoading = false;
      limit = limit + 20;
    });
  }

  readLocal() {
    if (widget.currentUserId.hashCode <= peerID.hashCode) {
      groupChatId = '${widget.currentUserId}-$peerID';
    } else {
      groupChatId = '$peerID-${widget.currentUserId}';
    }
  }

  // _animateToIndex(i) => listScrollController.animateTo(100,
  //     duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);

  @override
  Widget build(BuildContext context) {
    //getUserStatus();
    // listScrollController = new ScrollController()..addListener(_scrollListener);
    return WillPopScope(
      onWillPop: () async {
        goBackFunctionCall();
        return false;
      },
      child: PickupLayout(
        scaffold: Scaffold(
            // key: _scaffoldKey,
            appBar: editImage == true
                ? AppBar(
                    backgroundColor: Colors.white,
                    title: Text(
                      "",
                      style: TextStyle(
                          fontFamily: "MontserratBold",
                          fontSize: 17,
                          color: Colors.black),
                    ),
                    centerTitle: true,
                    leading: IconButton(
                        onPressed: () {
                          setState(() {
                            editImage = false;
                            allImages = [];
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.black,
                        )),
                    actions: [
                      IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            _cropImage();
                          },
                          icon: Icon(
                            Icons.crop,
                            color: Colors.black,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: IconButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: () {
                              getimageditor();
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Colors.black,
                            )),
                      ),
                      IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            allImages.forEach((send) async {
                              sendImage(send);
                            });
                            setState(() {
                              editImage = false;
                            });
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.black,
                          )),
                    ],
                  )
                : searchData == true
                    ? AppBar(
                        title: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 0, left: 0),
                            child: Container(
                              decoration: new BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: new BorderRadius.all(
                                    Radius.circular(15.0),
                                  )),
                              height: 40,
                              child: Center(
                                child: TextField(
                                  controller: controller,
                                  onChanged: onSearchTextChanged,
                                  style: TextStyle(color: Colors.grey),
                                  decoration: new InputDecoration(
                                    border: new OutlineInputBorder(
                                      borderSide: new BorderSide(
                                          color: Colors.grey[200]),
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(15.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: new BorderSide(
                                          color: Colors.grey[200]),
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(15.0),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: new BorderSide(
                                          color: Colors.grey[200]),
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(15.0),
                                      ),
                                    ),
                                    filled: true,
                                    hintStyle: new TextStyle(
                                        color: Colors.grey[600], fontSize: 14),
                                    hintText: "Search",
                                    contentPadding: EdgeInsets.only(top: 10.0),
                                    fillColor: Colors.grey[200],
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey[600],
                                      size: 25.0,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                        centerTitle: false,
                        elevation: 1,
                        backgroundColor: appColorWhite,
                        automaticallyImplyLeading: false,
                        leading: null,
                        actions: <Widget>[
                          Container(
                            width: 50,
                            child: IconButton(
                              padding: const EdgeInsets.all(0),
                              icon: CustomText(
                                alignment: Alignment.center,
                                text: "Cancel",
                                color: appColorBlue,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              onPressed: () {
                                setState(() {
                                  controller.clear();
                                  onSearchTextChanged("");
                                  searchData = false;
                                });
                              },
                            ),
                          ),
                          Container(width: 15),
                        ],
                      )
                    : AppBar(
                        centerTitle: false,
                        elevation: 1,
                        backgroundColor: appColorWhite,
                        title: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContactInfo(
                                      id: widget.peerID,
                                      currentUser: userID,
                                      imageMedia: imageMedia,
                                      videoMedia: videoMedia,
                                      docsMedia: docsMedia,
                                      imageMediaTime: imageMediaTime,
                                      blocksId: blocksId)),
                            );
                          },
                          child: Container(
                            // height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    goBackFunctionCall();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10, top: 5, bottom: 5, left: 5),
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: appColorBlue,
                                    ),
                                  ),
                                ),
                                imageWidget(),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 20,
                                        child: Text(
                                          widget.peerName,
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "MontserratBold",
                                              color: Colors.black),
                                        ),
                                      ),
                                      StreamBuilder<Event>(
                                          stream: FirebaseDatabase.instance
                                              .reference()
                                              .child('users')
                                              .child(widget.peerID)
                                              .onValue,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return Text(
                                                '',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              );
                                            }
                                            if (snapshot.hasData) {
                                              return snapshot
                                                      .data.snapshot.exists
                                                  ? lastSeenPrivacy != "nobody"
                                                      ? snapshot.data.snapshot
                                                                      .value[
                                                                  'status'] ==
                                                              "Online"
                                                          ? CustomText(
                                                              text: 'Çevrimiçi',
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              fontSize: 13,
                                                              color:
                                                                  appColorBlue,
                                                            )
                                                          : snapshot.data.snapshot
                                                                              .value[
                                                                          'status'] ==
                                                                      "typing" &&
                                                                  peerChatIn ==
                                                                      widget
                                                                          .currentUserId
                                                              ? CustomText(
                                                                  text:
                                                                      'yazıyor...',
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  fontSize: 13,
                                                                  color:
                                                                      appColorBlue,
                                                                )
                                                              : CustomText(
                                                                  text: snapshot
                                                                              .data
                                                                              .snapshot
                                                                              .value['status'] ==
                                                                          "typing"
                                                                      ? "yazıyor"
                                                                      : format(
                                                                          DateTime.parse(snapshot
                                                                              .data
                                                                              .snapshot
                                                                              .value['status']),
                                                                        ),
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  fontSize: 13,
                                                                  color:
                                                                      appColorGrey,
                                                                )
                                                      : Container()
                                                  : Container();
                                            }
                                            return Container();
                                          })
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        automaticallyImplyLeading: false,
                        // leading: false,
                        actions: <Widget>[
                          InkWell(
                            onTap: () {
                              sendCallNotification(
                                  peerToken, "PostKard Video Calling....");
                              CallUtils.dial(
                                  from: sender,
                                  to: receiver,
                                  context: context,
                                  status: "videocall");
                            },
                            child: Image.asset(
                              'assets/images/video.png',
                              height: 27,
                              width: 27,
                              color: appColorBlue,
                            ),
                          ),
                          Container(width: 15),
                          InkWell(
                            onTap: () {
                              sendCallNotification(
                                  peerToken, "PostKard Voice Calling....");
                              CallUtils.dial(
                                  from: sender,
                                  to: receiver,
                                  context: context,
                                  status: "voicecall");
                            },
                            child: Image.asset(
                              'assets/images/call.png',
                              height: 22,
                              width: 22,
                              color: appColorBlue,
                            ),
                          ),
                          Container(
                            width: 15,
                          ),
                          searchData == false
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          searchData = true;
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/images/search.png',
                                        height: 25,
                                        width: 25,
                                        color: appColorBlue,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          Container(
                            width: 15,
                          ),
                        ],
                      ),
            body: editImage == true
                ? editImageWidget()
                : Builder(
                    builder: (context) => Stack(
                      children: [
                        Container(
                          child: Column(
                            children: <Widget>[
                              // List of messages

                              buildListMessage(),

                              deleteButton == true
                                  ? buildDeleteInput()
                                  : forwardButton == true
                                      ? buildForwardInput()
                                      : peerblocksId.contains(userID)
                                          ? Container()
                                          : buildInput(),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: isLoading == true
                              ? Center(child: loader())
                              : Container(),
                        )
                      ],
                    ),
                  )),
      ),
    );
  }

  Widget buildListMessage() {
    print(groupChatId);
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(appColorGreen)))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  // .limit(limit)
                  .snapshots()
                  .asBroadcastStream(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(appColorGreen)));
                } else {
                  listMessage = snapshot.data;
                  listMessage.docs.forEach((message) {
                    if (message["read"] == false &&
                        message["idFrom"] != widget.currentUserId) {
                      if (!message.data().containsKey('boomshot')) {
                        message.reference.update({"read": true});
                      }
                    }
                  });

                  return Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: bgcolor,
                        image: backImage.length > 0
                            ? DecorationImage(
                                image: NetworkImage(backImage),
                                fit: BoxFit.cover,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 1.0,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          NotificationListener<ScrollNotification>(
                            onNotification: (n) {
                              if (n.metrics.pixels <= HEIGHT) {
                                notifier.value = n.metrics.pixels;
                              }
                              return false;
                            },
                            child: _searchResult.length != 0 ||
                                    controller.text.toLowerCase().isNotEmpty
                                ? ListView.builder(
                                    padding: EdgeInsets.all(10.0),
                                    itemCount: _searchResult.length,
                                    reverse: true,
                                    controller: listScrollController,
                                    itemBuilder: (context, index) {
                                      chatMsgList = snapshot.data.docs;

                                      return buildItem(
                                          index, _searchResult[index]);
                                    })
                                : ListView.builder(
                                    // key: dataKey,
                                    padding: EdgeInsets.all(10.0),
                                    itemCount: snapshot.data.size,
                                    reverse: true,
                                    controller: listScrollController,
                                    itemBuilder: (context, index) {
                                      chatMsgList = snapshot.data.docs;

                                      for (int i = 0;
                                          i < chatMsgList.length;
                                          i++) {
                                        if (chatMsgList[i]["timestamp"] ==
                                                widget.searchTime.toString() &&
                                            isScroll == true) {
                                          gotoindex = i;
                                          _scrollToIndex(gotoindex);
                                          isScroll = false;
                                        }
                                      }

                                      return AutoScrollTag(
                                        key: ValueKey(index),
                                        controller: listScrollController,
                                        index: index,
                                        child: offline == true
                                            ? buildItem(index, msgList[index])
                                            : buildItem(
                                                index, chatMsgList[index]),
                                      );
                                      //BACKUP
                                      // : offline == true
                                      //     ? buildItem(index, msgList[index])
                                      //     : buildItem(
                                      //         index, chatMsgList[index]);
                                      //BACKUP
                                    }),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: ValueListenableBuilder<double>(
                              valueListenable: notifier,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, value - HEIGHT),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        height: 35,
                                        // width: 120,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              banner == null
                                                  ? Container()
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0),
                                                      child: Text(
                                                        DateFormat(
                                                                'EEEE, d MMM')
                                                            .format(
                                                          banner.toDate(),
                                                        ),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: ValueListenableBuilder<double>(
                              valueListenable: notifier,
                              builder: (context, value, child) {
                                return Transform.translate(
                                    offset: Offset(0, 0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 0, right: 0),
                                      child: value < 1
                                          ? Container()
                                          : Align(
                                              alignment: Alignment.bottomRight,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft: Radius
                                                                .circular(10),
                                                            topLeft:
                                                                Radius.circular(
                                                                    10))),
                                                height: 40,
                                                width: 40,
                                                child: IconButton(
                                                  onPressed: () {
                                                    // _animateToIndex(20);

                                                    listScrollController
                                                        .animateTo(
                                                      listScrollController
                                                          .position
                                                          .minScrollExtent,
                                                      duration:
                                                          Duration(seconds: 1),
                                                      curve:
                                                          Curves.fastOutSlowIn,
                                                    );
                                                    setState(() {
                                                      //  icon = false;
                                                    });
                                                  },
                                                  icon: Icon(
                                                      Icons.arrow_circle_down),
                                                ),
                                              ),
                                            ),
                                    ));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['type'] == 1) {
      if (imageMedia.contains(document['content'])) {
      } else {
        imageMedia.add(document['content']);
        imageMediaTime.add(document['timestamp']);
      }
    }
    if (document['type'] == 4) {
      if (videoMedia.contains(document['content'])) {
      } else {
        videoMedia.add(document['content']);
      }
    }
    if (document['type'] == 5) {
      if (docsMedia.contains(document['content'])) {
      } else {
        docsMedia.add(document['content']);
      }
    }

    banner = document['timestamp'];
    if (document['idFrom'] == userID) {
      return document['delete'].contains(userID)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Text(
                        "you deleted this message",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 12),
                      )),
                      Row(
                        children: [
                          Text(
                            DateFormat('hh:mm')
                                .format(document['timestamp'].toDate()),
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.0,
                                fontStyle: FontStyle.normal),
                          ),
                          Container(width: 3),
                        ],
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(20.0, 10.0, 15.0, 10.0),
                  width: 230.0,
                  decoration: BoxDecoration(
                      color: chatRightColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 10.0 : 10.0,
                      right: 10.0),
                ),
              ],
            )
          : Swipeable(
              threshold: 60.0,
              onSwipeRight: () {
                setState(() {
                  replyMsg = document['content'];
                  replyType = document['type'];
                  replyTime = document['timestamp'];
                  replyName = "You";
                  replyButton = true;
                });
              },
              background: Container(),
              child: Row(
                children: [
                  deleteButton == true
                      ? Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: deleteMsgTime.contains(document['timestamp'])
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      deleteMsgTime
                                          .remove(document['timestamp']);
                                      deleteMsgID.remove(document['idFrom']);
                                      deleteMsgContent
                                          .remove(document['content']);
                                    });
                                  },
                                  child: Icon(
                                    Icons.check_circle,
                                    color: appColorBlue,
                                  ))
                              : InkWell(
                                  onTap: () {
                                    setState(() {
                                      deleteMsgTime.add(document['timestamp']);
                                      deleteMsgID.add(document['idFrom']);
                                      deleteMsgContent.add(document['content']);
                                    });
                                  },
                                  child: Icon(
                                    Icons.radio_button_unchecked,
                                    color: appColorGrey,
                                  )),
                        )
                      : forwardButton == true
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: forwardTime.contains(document['timestamp'])
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          forwardTime
                                              .remove(document['timestamp']);
                                          forwardTypes.remove(document['type']);
                                          forwardContent
                                              .remove(document['content']);
                                        });
                                      },
                                      child: Icon(
                                        Icons.check_circle,
                                        color: appColorBlue,
                                      ))
                                  : InkWell(
                                      onTap: () {
                                        setState(() {
                                          forwardTime
                                              .add(document['timestamp']);
                                          forwardTypes.add(document['type']);
                                          forwardContent
                                              .add(document['content']);
                                        });
                                      },
                                      child: Icon(
                                        Icons.radio_button_unchecked,
                                        color: appColorGrey,
                                      )),
                            )
                          : Container(),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          onLongPress: () {
                            replyMsg = document['content'];
                            replyType = document['type'];
                            replyTime = document['timestamp'];
                            replyName = "You";

                            openMessageBox(
                              document['timestamp'],
                              groupChatId,
                              document['idFrom'],
                              document['content'],
                              document['idTo'],
                              document['type'],
                            );
                          },
                          child: Row(
                            children: <Widget>[
                              document['type'] == 0
                                  // Text
                                  ? myTextMessage(
                                      document['content'],
                                      document['timestamp'],
                                      document['read'],
                                      index)
                                  : document['type'] == 9
                                      // Reply
                                      ? InkWell(
                                          onTap: () {
                                            // setState(() {
                                            //   contentBlink =
                                            //       document['replyTime'];
                                            //   _showBlink = true;
                                            // });
                                            if (document['replyTime'] != null) {
                                              for (int i = 0;
                                                  i < chatMsgList.length;
                                                  i++) {
                                                if (chatMsgList[i]
                                                        ["timestamp"] ==
                                                    document['replyTime']) {
                                                  gotoindex = i;
                                                  _scrollToIndex(gotoindex);
                                                }
                                              }
                                            }

                                            // _timerBlink = Timer.periodic(
                                            //     Duration(milliseconds: 1000),
                                            //     (_) {
                                            //   setState(() {
                                            //     _showBlink = false;
                                            //   });
                                            // });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 5),
                                                      child: Container(
                                                        width: double.infinity,
                                                        decoration: BoxDecoration(
                                                            color:
                                                                chatReplyRightColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20))),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 15,
                                                                  top: 8,
                                                                  bottom: 8),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                document['lat'],
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                              Text(
                                                                document['replyType'] !=
                                                                        null
                                                                    ? document['replyType'] ==
                                                                            1
                                                                        ? "📷 Photo"
                                                                        : document['replyType'] ==
                                                                                4
                                                                            ? "🎥 Video"
                                                                            : document['replyType'] == 5
                                                                                ? "📄 Document"
                                                                                : document['replyType'] == 6
                                                                                    ? "🔊 Audio"
                                                                                    : document['long']
                                                                    : document['long'],
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .grey[
                                                                        700],
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: document['contentType'] !=
                                                                  null &&
                                                              document[
                                                                      'contentType'] ==
                                                                  1
                                                          ? InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          ViewImages(
                                                                              images: [
                                                                                document['content']
                                                                              ],
                                                                              number: index)),
                                                                );
                                                              },
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      Container(
                                                                    width: 30.0,
                                                                    height:
                                                                        30.0,
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(0),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0xffE8E8E8),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            8.0),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(appColorBlue),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Material(
                                                                    child: Text(
                                                                        "Not Avilable"),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .all(
                                                                      Radius.circular(
                                                                          8.0),
                                                                    ),
                                                                    clipBehavior:
                                                                        Clip.hardEdge,
                                                                  ),
                                                                  imageUrl:
                                                                      document[
                                                                          'content'],
                                                                  width: 200.0,
                                                                  height: 200.0,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            )
                                                          : document['contentType'] !=
                                                                      null &&
                                                                  document[
                                                                          'contentType'] ==
                                                                      6
                                                              ? Container(
                                                                  child: PlayerWidget(
                                                                      url: document[
                                                                          'content']),
                                                                )
                                                              : Text(
                                                                  document[
                                                                      'content'],
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          13),
                                                                ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          DateFormat('hh:mm')
                                                              .format(document[
                                                                      'timestamp']
                                                                  .toDate()),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12.0,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal),
                                                        ),
                                                        Container(width: 3),
                                                        document['read'] == true
                                                            ? Icon(
                                                                Icons.done_all,
                                                                size: 17,
                                                                color:
                                                                    Colors.blue,
                                                              )
                                                            : Container()
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                padding: EdgeInsets.fromLTRB(
                                                    10.0, 10.0, 15.0, 10.0),
                                                width: 300.0,
                                                decoration: BoxDecoration(
                                                    color: chatRightColor,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    20),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    20),
                                                            topRight:
                                                                Radius.circular(
                                                                    20))),
                                                margin: EdgeInsets.only(
                                                    bottom: isLastMessageRight(
                                                            index)
                                                        ? 10.0
                                                        : 10.0,
                                                    right: 10.0),
                                              ),
                                            ],
                                          ),
                                        )
                                      : document['type'] == 4
                                          //Video
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  color: chatRightColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10,
                                                    bottom: 10,
                                                    left: 10),
                                                // ignore: deprecated_member_use
                                                child: FlatButton(
                                                  child: Material(
                                                    color: chatRightColor,
                                                    child: Row(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child: Container(
                                                            height: 70,
                                                            width: 70,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child: FittedBox(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  child:
                                                                      VideoView(
                                                                    url: document[
                                                                        'content'],
                                                                    play:
                                                                        isInView,
                                                                    // id: _orderList[index].key
                                                                  )),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 5,
                                                        ),
                                                        Container(
                                                          height: 70,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Container(
                                                                  height: 10),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  width: 120,
                                                                  child: Center(
                                                                    child: Text(
                                                                      "VIDEO_" +
                                                                          document['timestamp']
                                                                              .substring(document['timestamp'].length - 5)
                                                                              .split('')
                                                                              .reversed
                                                                              .join(''),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          color: Colors.green[
                                                                              700],
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    DateFormat(
                                                                            'hh:mm')
                                                                        .format(
                                                                            document['timestamp'].toDate()),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            12.0,
                                                                        fontStyle:
                                                                            FontStyle.normal),
                                                                  ),
                                                                  Container(
                                                                      width: 3),
                                                                  document['read'] ==
                                                                          true
                                                                      ? Icon(
                                                                          Icons
                                                                              .done_all,
                                                                          size:
                                                                              17,
                                                                          color:
                                                                              Colors.blue,
                                                                        )
                                                                      : Container(),
                                                                  Container(
                                                                      width: 5),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                    clipBehavior: Clip.hardEdge,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              FullScreenVideo(
                                                                  video: document[
                                                                      'content'])),
                                                    );
                                                  },
                                                  padding: EdgeInsets.all(0),
                                                ),
                                              ),
                                              margin: EdgeInsets.only(
                                                  bottom:
                                                      isLastMessageRight(index)
                                                          ? 20.0
                                                          : 10.0,
                                                  right: 10.0),
                                            )
                                          : document['type'] == 5
                                              //File
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                      color: chatRightColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(20),
                                                              bottomLeft: Radius
                                                                  .circular(20),
                                                              topRight: Radius
                                                                  .circular(
                                                                      20))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            bottom: 10,
                                                            left: 10),
                                                    // ignore: deprecated_member_use
                                                    child: FlatButton(
                                                      child: Material(
                                                        color: chatRightColor,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 10),
                                                              child: Row(
                                                                children: [
                                                                  ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                      child: Icon(
                                                                          Icons
                                                                              .note)),
                                                                  Container(
                                                                    width: 5,
                                                                  ),
                                                                  Container(
                                                                    width: 120,
                                                                    child: Text(
                                                                      "FILE_" +
                                                                          document['timestamp']
                                                                              .substring(document['timestamp'].length - 5)
                                                                              .split('')
                                                                              .reversed
                                                                              .join(''),
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          color: Colors.green[
                                                                              700],
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 5),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    DateFormat(
                                                                            'hh:mm')
                                                                        .format(
                                                                            document['timestamp'].toDate()),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            12.0,
                                                                        fontStyle:
                                                                            FontStyle.normal),
                                                                  ),
                                                                  Container(
                                                                      width: 3),
                                                                  document['read'] ==
                                                                          true
                                                                      ? Icon(
                                                                          Icons
                                                                              .done_all,
                                                                          size:
                                                                              17,
                                                                          color:
                                                                              Colors.blue,
                                                                        )
                                                                      : Container()
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8.0)),
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                      ),
                                                      onPressed: () {
                                                        _launchURL(
                                                          document['content'],
                                                        );
                                                      },
                                                      padding:
                                                          EdgeInsets.all(0),
                                                    ),
                                                  ),
                                                  margin: EdgeInsets.only(
                                                      bottom:
                                                          isLastMessageRight(
                                                                  index)
                                                              ? 20.0
                                                              : 10.0,
                                                      right: 10.0),
                                                )
                                              : document['type'] == 6
                                                  //Audio
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10),
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    chatRightColor,
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            20),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            20),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            20))),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              10),
                                                                  child: PlayerWidget(
                                                                      url: document[
                                                                          'content']),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              5,
                                                                          bottom:
                                                                              4),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Text(
                                                                        DateFormat('hh:mm')
                                                                            .format(document['timestamp'].toDate()),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .grey,
                                                                            fontSize:
                                                                                12.0,
                                                                            fontStyle:
                                                                                FontStyle.normal),
                                                                      ),
                                                                      Container(
                                                                          width:
                                                                              3),
                                                                      document['read'] ==
                                                                              true
                                                                          ? Icon(
                                                                              Icons.done_all,
                                                                              size: 17,
                                                                              color: Colors.blue,
                                                                            )
                                                                          : Container()
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            )),
                                                      ),
                                                    )
                                                  : document['type'] == 7
                                                      //contact
                                                      ? Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  chatRightColor,
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          20),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          20),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20))),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 10,
                                                                    bottom: 5,
                                                                    left: 10),
                                                            // ignore: deprecated_member_use
                                                            child: FlatButton(
                                                              child: Material(
                                                                color:
                                                                    chatRightColor,
                                                                child: Row(
                                                                  children: [
                                                                    CircleAvatar(
                                                                        backgroundColor:
                                                                            Colors.grey[
                                                                                300],
                                                                        child:
                                                                            Text(
                                                                          document['content']
                                                                              [
                                                                              0],
                                                                          style: TextStyle(
                                                                              color: Colors.green,
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold),
                                                                        )),
                                                                    Container(
                                                                      width: 10,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              120,
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                document['content'],
                                                                                maxLines: 1,
                                                                                style: TextStyle(color: Colors.green[700], fontSize: 15, fontWeight: FontWeight.w500),
                                                                              ),
                                                                              Container(
                                                                                height: 3,
                                                                              ),
                                                                              Text(
                                                                                document['contact'],
                                                                                maxLines: 1,
                                                                                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              right: 5),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Text(
                                                                                DateFormat('hh:mm').format(document['timestamp'].toDate()),
                                                                                style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.normal),
                                                                              ),
                                                                              Container(width: 3),
                                                                              document['read'] == true
                                                                                  ? Icon(
                                                                                      Icons.done_all,
                                                                                      size: 17,
                                                                                      color: Colors.blue,
                                                                                    )
                                                                                  : Container()
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8.0)),
                                                                clipBehavior:
                                                                    Clip.hardEdge,
                                                              ),
                                                              onPressed: () {},
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                            ),
                                                          ),
                                                          margin: EdgeInsets.only(
                                                              bottom:
                                                                  isLastMessageRight(
                                                                          index)
                                                                      ? 20.0
                                                                      : 10.0,
                                                              right: 10.0),
                                                        )
                                                      : document['type'] == 8
                                                          //location
                                                          ? Container(
                                                              decoration: BoxDecoration(
                                                                  color:
                                                                      chatRightColor,
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft:
                                                                          Radius.circular(
                                                                              20),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              20),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              20))),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top: 10,
                                                                        bottom:
                                                                            10,
                                                                        left:
                                                                            10),
                                                                // ignore: deprecated_member_use
                                                                child:
                                                                    // ignore: deprecated_member_use
                                                                    FlatButton(
                                                                  child:
                                                                      Material(
                                                                    color:
                                                                        chatRightColor,
                                                                    child: Row(
                                                                      children: [
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                          child:
                                                                              CachedNetworkImage(
                                                                            placeholder: (context, url) =>
                                                                                Container(
                                                                              width: 30.0,
                                                                              height: 30.0,
                                                                              padding: EdgeInsets.all(0),
                                                                              decoration: BoxDecoration(
                                                                                color: Color(0xffE8E8E8),
                                                                                borderRadius: BorderRadius.all(
                                                                                  Radius.circular(8.0),
                                                                                ),
                                                                              ),
                                                                              child: Center(
                                                                                child: CircularProgressIndicator(
                                                                                  valueColor: AlwaysStoppedAnimation<Color>(appColorBlue),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                Material(
                                                                              child: Text("Not Avilable"),
                                                                              borderRadius: BorderRadius.all(
                                                                                Radius.circular(8.0),
                                                                              ),
                                                                              clipBehavior: Clip.hardEdge,
                                                                            ),
                                                                            imageUrl:
                                                                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSX2G4R17Q2SpAVqRDQNcRmHw_8y0uCk2PW4A&usqp=CAU",
                                                                            width:
                                                                                70.0,
                                                                            height:
                                                                                70.0,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              70,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                            children: [
                                                                              Container(height: 10),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.only(top: 10),
                                                                                  child: Container(
                                                                                    width: 120,
                                                                                    child: Text(
                                                                                      document['content'],
                                                                                      maxLines: 2,
                                                                                      style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.w500),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                children: [
                                                                                  Text(
                                                                                    DateFormat('hh:mm').format(document['timestamp'].toDate()),
                                                                                    style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.normal),
                                                                                  ),
                                                                                  Container(width: 3),
                                                                                  document['read'] == true
                                                                                      ? Icon(
                                                                                          Icons.done_all,
                                                                                          size: 17,
                                                                                          color: Colors.blue,
                                                                                        )
                                                                                      : Container(),
                                                                                  Container(width: 5),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(8.0)),
                                                                    clipBehavior:
                                                                        Clip.hardEdge,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    MapsLauncher.launchCoordinates(
                                                                        double.parse(document[
                                                                            'lat']),
                                                                        double.parse(
                                                                            document['long']),
                                                                        'Location');
                                                                  },
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0),
                                                                ),
                                                              ),
                                                              margin: EdgeInsets.only(
                                                                  bottom: isLastMessageRight(
                                                                          index)
                                                                      ? 20.0
                                                                      : 10.0,
                                                                  right: 10.0),
                                                            )
                                                          : myImageWidget(
                                                              document[
                                                                  'content'],
                                                              document[
                                                                  'timestamp'],
                                                              document['read'],
                                                              index,
                                                              document
                                                                      .data()
                                                                      .containsKey(
                                                                          'boomshot')
                                                                  ? document[
                                                                      'boomshot']
                                                                  : false)
                            ],
                            mainAxisAlignment: MainAxisAlignment.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
    } else {
      // Left (peer message)
      return Container(
        child: document['delete'].contains(userID)
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                  child: Text(
                                "This message was deleted.",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12),
                              )),
                              Row(
                                children: [
                                  Text(
                                    DateFormat('hh:mm')
                                        .format(document['timestamp'].toDate()),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12.0,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  Container(width: 3),
                                ],
                              ),
                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(20.0, 10.0, 15.0, 10.0),
                          width: 230.0,
                          decoration: BoxDecoration(
                              color: chatLeftColor,
                              //Color(0XFFc4d1ec),
                              // border: Border.all(color: Color(0xffE8E8E8)),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          margin: EdgeInsets.only(left: 10.0),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Swipeable(
                threshold: 60.0,
                onSwipeRight: () {
                  setState(() {
                    replyMsg = document['content'];
                    replyType = document['type'];
                    replyTime = document['timestamp'];
                    replyName = widget.peerName;
                    replyButton = true;
                  });
                },
                background: Container(),
                child: Row(
                  children: [
                    deleteButton == true
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: deleteMsgTime.contains(document['timestamp'])
                                ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        deleteMsgTime
                                            .remove(document['timestamp']);
                                        deleteMsgContent
                                            .remove(document['content']);
                                        deleteMsgID.remove(document['idFrom']);
                                      });
                                    },
                                    child: Icon(Icons.check_circle))
                                : InkWell(
                                    onTap: () {
                                      setState(() {
                                        deleteMsgTime
                                            .add(document['timestamp']);
                                        deleteMsgID.add(document['idFrom']);
                                        deleteMsgContent
                                            .add(document['content']);
                                      });
                                    },
                                    child: Icon(Icons.radio_button_unchecked)),
                          )
                        : forwardButton == true
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: forwardTime
                                        .contains(document['timestamp'])
                                    ? InkWell(
                                        onTap: () {
                                          setState(() {
                                            forwardTime
                                                .remove(document['timestamp']);
                                            forwardTypes
                                                .remove(document['type']);
                                            forwardContent
                                                .remove(document['content']);
                                          });
                                        },
                                        child: Icon(
                                          Icons.check_circle,
                                          color: appColorBlue,
                                        ))
                                    : InkWell(
                                        onTap: () {
                                          setState(() {
                                            forwardTime
                                                .add(document['timestamp']);
                                            forwardTypes.add(document['type']);
                                            forwardContent
                                                .add(document['content']);
                                          });
                                        },
                                        child: Icon(
                                          Icons.radio_button_unchecked,
                                          color: appColorGrey,
                                        )),
                              )
                            : Container(),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                            onLongPress: () {
                              replyMsg = document['content'];
                              replyType = document['type'];
                              replyTime = document['timestamp'];
                              replyName = widget.peerName;
                              openMessageBox(
                                document['timestamp'],
                                groupChatId,
                                document['idFrom'],
                                document['content'],
                                document['idTo'],
                                document['type'],
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: <Widget>[
                                  document['type'] == 0
                                      ? peerTextMessage(
                                          document['content'],
                                          document['timestamp'],
                                          document['read'],
                                          index)
                                      : document['type'] == 9
                                          // Text
                                          ? InkWell(
                                              onTap: () {
                                                // setState(() {
                                                //   contentBlink =
                                                //       document['replyTime'];
                                                //   _showBlink = true;
                                                // });
                                                if (document['replyTime'] !=
                                                    null) {
                                                  for (int i = 0;
                                                      i < chatMsgList.length;
                                                      i++) {
                                                    if (chatMsgList[i]
                                                            ["timestamp"] ==
                                                        document['replyTime']) {
                                                      gotoindex = i;
                                                      _scrollToIndex(gotoindex);
                                                    }
                                                  }
                                                }

                                                // _timerBlink = Timer.periodic(
                                                //     Duration(
                                                //         milliseconds: 1000),
                                                //     (_) {
                                                //   setState(() {
                                                //     _showBlink = false;
                                                //   });
                                                // });
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 5),
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20))),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 15,
                                                                      top: 8,
                                                                      bottom:
                                                                          8),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    document[
                                                                        'lat'],
                                                                    maxLines: 1,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                  Text(
                                                                    document['replyType'] !=
                                                                            null
                                                                        ? document['replyType'] ==
                                                                                1
                                                                            ? "📷 Foto"
                                                                            : document['replyType'] == 4
                                                                                ? "🎥 Vidyo"
                                                                                : document['replyType'] == 5
                                                                                    ? "📄 Doküman"
                                                                                    : document['replyType'] == 6
                                                                                        ? "🔊 Ses"
                                                                                        : document['long']
                                                                        : document['long'],
                                                                    maxLines: 1,
                                                                    style: TextStyle(
                                                                        color: Colors.grey[
                                                                            700],
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                child: document['contentType'] !=
                                                                            null &&
                                                                        document['contentType'] ==
                                                                            1
                                                                    ? InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => ViewImages(images: [
                                                                                      document['content']
                                                                                    ], number: index)),
                                                                          );
                                                                        },
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                          child:
                                                                              CachedNetworkImage(
                                                                            placeholder: (context, url) =>
                                                                                Container(
                                                                              width: 30.0,
                                                                              height: 30.0,
                                                                              padding: EdgeInsets.all(0),
                                                                              decoration: BoxDecoration(
                                                                                color: Color(0xffE8E8E8),
                                                                                borderRadius: BorderRadius.all(
                                                                                  Radius.circular(8.0),
                                                                                ),
                                                                              ),
                                                                              child: Center(
                                                                                child: CircularProgressIndicator(
                                                                                  valueColor: AlwaysStoppedAnimation<Color>(appColorBlue),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                Material(
                                                                              child: Text("Not Avilable"),
                                                                              borderRadius: BorderRadius.all(
                                                                                Radius.circular(8.0),
                                                                              ),
                                                                              clipBehavior: Clip.hardEdge,
                                                                            ),
                                                                            imageUrl:
                                                                                document['content'],
                                                                            width:
                                                                                200.0,
                                                                            height:
                                                                                200.0,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : document['contentType'] !=
                                                                                null &&
                                                                            document['contentType'] ==
                                                                                6
                                                                        ? Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(top: 10),
                                                                            child:
                                                                                PlayerWidget(url: document['content']),
                                                                          )
                                                                        : Text(
                                                                            document['content'],
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 13),
                                                                          ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              DateFormat(
                                                                      'hh:mm')
                                                                  .format(document[
                                                                          'timestamp']
                                                                      .toDate()),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize:
                                                                      12.0,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .normal),
                                                            ),
                                                            Container(width: 3),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            10.0,
                                                            10.0,
                                                            15.0,
                                                            10.0),
                                                    width: 300.0,
                                                    decoration: BoxDecoration(
                                                        color: chatLeftColor,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            20),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        20),
                                                                topRight: Radius
                                                                    .circular(
                                                                        20))),
                                                    margin: EdgeInsets.only(
                                                        bottom:
                                                            isLastMessageRight(
                                                                    index)
                                                                ? 10.0
                                                                : 10.0,
                                                        right: 10.0),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : document['type'] == 4
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                      color: chatLeftColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(20),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          20),
                                                              topRight: Radius
                                                                  .circular(
                                                                      20))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            bottom: 10,
                                                            left: 10),
                                                    // ignore: deprecated_member_use
                                                    child: FlatButton(
                                                      child: Material(
                                                        color: chatLeftColor,
                                                        child: Row(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child: Container(
                                                                height: 70,
                                                                width: 70,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child: FittedBox(
                                                                      fit: BoxFit.cover,
                                                                      child: VideoView(
                                                                        url: document[
                                                                            'content'],
                                                                        play:
                                                                            isInView,
                                                                        // id: _orderList[index].key
                                                                      )),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 5,
                                                            ),
                                                            Container(
                                                              height: 70,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Container(
                                                                      height:
                                                                          10),
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          120,
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          "VIDEO_" +
                                                                              document['timestamp'].substring(document['timestamp'].length - 5).split('').reversed.join(''),
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          maxLines:
                                                                              1,
                                                                          style: TextStyle(
                                                                              color: Colors.green[700],
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Text(
                                                                        DateFormat('hh:mm')
                                                                            .format(document['timestamp'].toDate()),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .grey,
                                                                            fontSize:
                                                                                12.0,
                                                                            fontStyle:
                                                                                FontStyle.normal),
                                                                      ),
                                                                      Container(
                                                                          width:
                                                                              3),
                                                                      Container(
                                                                          width:
                                                                              5),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8.0)),
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  FullScreenVideo(
                                                                      video: document[
                                                                          'content'])),
                                                        );
                                                      },
                                                      padding:
                                                          EdgeInsets.all(0),
                                                    ),
                                                  ),
                                                  margin: EdgeInsets.only(
                                                      bottom:
                                                          isLastMessageRight(
                                                                  index)
                                                              ? 5.0
                                                              : 10.0,
                                                      right: 10.0),
                                                )
                                              : document['type'] == 5
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                          color: chatLeftColor,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          20),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          20),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 10,
                                                                bottom: 10,
                                                                left: 10),
                                                        // ignore: deprecated_member_use
                                                        child: FlatButton(
                                                          child: Material(
                                                            color:
                                                                chatLeftColor,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              10),
                                                                  child: Row(
                                                                    children: [
                                                                      ClipRRect(
                                                                          borderRadius: BorderRadius.circular(
                                                                              8.0),
                                                                          child:
                                                                              Icon(Icons.note)),
                                                                      Container(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Container(
                                                                        width:
                                                                            120,
                                                                        child:
                                                                            Text(
                                                                          "FILE_" +
                                                                              document['timestamp'].substring(document['timestamp'].length - 5).split('').reversed.join(''),
                                                                          maxLines:
                                                                              1,
                                                                          style: TextStyle(
                                                                              color: Colors.green[700],
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              5),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Text(
                                                                        DateFormat('hh:mm')
                                                                            .format(document['timestamp'].toDate()),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .grey,
                                                                            fontSize:
                                                                                12.0,
                                                                            fontStyle:
                                                                                FontStyle.normal),
                                                                      ),
                                                                      Container(
                                                                          width:
                                                                              3),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8.0)),
                                                            clipBehavior:
                                                                Clip.hardEdge,
                                                          ),
                                                          onPressed: () {
                                                            _launchURL(
                                                              document[
                                                                  'content'],
                                                            );
                                                          },
                                                          padding:
                                                              EdgeInsets.all(0),
                                                        ),
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          bottom:
                                                              isLastMessageRight(
                                                                      index)
                                                                  ? 0.0
                                                                  : 10.0,
                                                          right: 10.0),
                                                    )
                                                  : document['type'] == 6
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 0,
                                                                  bottom: 5),
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                  color:
                                                                      chatLeftColor,
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft:
                                                                          Radius.circular(
                                                                              20),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              20),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              20))),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            10),
                                                                    child: PlayerWidget(
                                                                        url: document[
                                                                            'content']),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            5,
                                                                        bottom:
                                                                            4),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Text(
                                                                          DateFormat('hh:mm')
                                                                              .format(document['timestamp'].toDate()),
                                                                          style: TextStyle(
                                                                              color: Colors.grey,
                                                                              fontSize: 12.0,
                                                                              fontStyle: FontStyle.normal),
                                                                        ),
                                                                        Container(
                                                                            width:
                                                                                3),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              )),
                                                        )
                                                      : document['type'] == 7
                                                          ? Container(
                                                              decoration: BoxDecoration(
                                                                  color:
                                                                      chatLeftColor,
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft:
                                                                          Radius.circular(
                                                                              20),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              20),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              20))),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top: 10,
                                                                        bottom:
                                                                            10,
                                                                        left:
                                                                            10),
                                                                child:
                                                                    // ignore: deprecated_member_use
                                                                    FlatButton(
                                                                  child:
                                                                      Material(
                                                                    color:
                                                                        chatLeftColor,
                                                                    child: Row(
                                                                      children: [
                                                                        CircleAvatar(
                                                                            backgroundColor:
                                                                                Colors.grey[300],
                                                                            child: Text(
                                                                              document['content'][0],
                                                                              style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
                                                                            )),
                                                                        Container(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            Container(
                                                                              width: 120,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    document['content'],
                                                                                    maxLines: 1,
                                                                                    style: TextStyle(color: Colors.green[700], fontSize: 15, fontWeight: FontWeight.w500),
                                                                                  ),
                                                                                  Container(
                                                                                    height: 3,
                                                                                  ),
                                                                                  Text(
                                                                                    document['contact'],
                                                                                    maxLines: 1,
                                                                                    style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(right: 5),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                children: [
                                                                                  Text(
                                                                                    DateFormat('hh:mm').format(document['timestamp'].toDate()),
                                                                                    style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.normal),
                                                                                  ),
                                                                                  Container(width: 3),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(8.0)),
                                                                    clipBehavior:
                                                                        Clip.hardEdge,
                                                                  ),
                                                                  onPressed:
                                                                      () {},
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0),
                                                                ),
                                                              ),
                                                              margin: EdgeInsets.only(
                                                                  bottom: isLastMessageRight(
                                                                          index)
                                                                      ? 0.0
                                                                      : 10.0,
                                                                  right: 10.0),
                                                            )
                                                          : document['type'] ==
                                                                  8
                                                              ? Container(
                                                                  decoration: BoxDecoration(
                                                                      color:
                                                                          chatLeftColor,
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              20),
                                                                          bottomRight: Radius.circular(
                                                                              20),
                                                                          topRight:
                                                                              Radius.circular(20))),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 10,
                                                                        bottom:
                                                                            10,
                                                                        left:
                                                                            10),
                                                                    child:
                                                                        // ignore: deprecated_member_use
                                                                        FlatButton(
                                                                      child:
                                                                          Material(
                                                                        color:
                                                                            chatLeftColor,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                              child: CachedNetworkImage(
                                                                                placeholder: (context, url) => Container(
                                                                                  width: 30.0,
                                                                                  height: 30.0,
                                                                                  padding: EdgeInsets.all(0),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Color(0xffE8E8E8),
                                                                                    borderRadius: BorderRadius.all(
                                                                                      Radius.circular(8.0),
                                                                                    ),
                                                                                  ),
                                                                                  child: Center(
                                                                                    child: CircularProgressIndicator(
                                                                                      valueColor: AlwaysStoppedAnimation<Color>(appColorBlue),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                errorWidget: (context, url, error) => Material(
                                                                                  child: Text("Not Avilable"),
                                                                                  borderRadius: BorderRadius.all(
                                                                                    Radius.circular(8.0),
                                                                                  ),
                                                                                  clipBehavior: Clip.hardEdge,
                                                                                ),
                                                                                imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSX2G4R17Q2SpAVqRDQNcRmHw_8y0uCk2PW4A&usqp=CAU",
                                                                                width: 70.0,
                                                                                height: 70.0,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              width: 5,
                                                                            ),
                                                                            Container(
                                                                              height: 70,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                                children: [
                                                                                  Container(height: 10),
                                                                                  Expanded(
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.only(top: 10),
                                                                                      child: Container(
                                                                                        width: 120,
                                                                                        child: Text(
                                                                                          document['content'],
                                                                                          maxLines: 2,
                                                                                          style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.w500),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    children: [
                                                                                      Text(
                                                                                        DateFormat('hh:mm').format(document['timestamp'].toDate()),
                                                                                        style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.normal),
                                                                                      ),
                                                                                      Container(width: 3),
                                                                                      Container(width: 5),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(8.0)),
                                                                        clipBehavior:
                                                                            Clip.hardEdge,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        MapsLauncher.launchCoordinates(
                                                                            double.parse(document['lat']),
                                                                            double.parse(document['long']),
                                                                            'Location');
                                                                      },
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              0),
                                                                    ),
                                                                  ),
                                                                  margin: EdgeInsets.only(
                                                                      bottom: isLastMessageRight(
                                                                              index)
                                                                          ? 0.0
                                                                          : 10.0,
                                                                      right:
                                                                          10.0),
                                                                )
                                                              : peerImageWidget(
                                                                  document[
                                                                      'content'],
                                                                  document[
                                                                      'timestamp'],
                                                                  document[
                                                                      'read'],
                                                                  index,
                                                                  document
                                                                          .data()
                                                                          .containsKey(
                                                                              'boomshot')
                                                                      ? document[
                                                                          'boomshot']
                                                                      : false,
                                                                  document.id)
                                ],
                              ),
                            ),
                          ),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    ),
                  ],
                ),
              ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  Widget myTextMessage(content, timestamp, read, index) {
    RegExp _numeric = RegExp(r'^-?[0-9]+$');

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        decoration: BoxDecoration(
            color: _showBlink == true && contentBlink == timestamp
                ? appColorBlue
                : chatRightColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                topRight: Radius.circular(20))),
        margin: EdgeInsets.only(
            bottom: isLastMessageRight(index) ? 10.0 : 10.0, right: 10.0),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.end,
                children: <Widget>[
                  _numeric.hasMatch(content) && content.length >= 10
                      ? InkWell(
                          onTap: () {
                            launch('tel:$content');
                          },
                          child: Text(
                            content,
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontFamily: normalStyle,
                                fontSize: 14),
                          ),
                        )
                      : widget.searchText != null
                          ? SubstringHighlight(
                              text: content,
                              term: widget.searchText,
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: normalStyle,
                                  fontSize: 14),
                              textStyleHighlight: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: normalStyle,
                                  fontSize: 14),
                            )
                          : Linkable(
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: normalStyle,
                                  fontSize: 14),
                              textColor: Colors.white,
                              text: content,
                            ),
                  Text(
                    timestamp.millisecondsSinceEpoch.toString(),
                    style: TextStyle(color: Colors.transparent, fontSize: 10),
                  ),
                ],
              ),
            ),
            Positioned(
              child: Row(
                children: [
                  Text(
                    DateFormat('hh:mm').format(timestamp.toDate()),
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.0,
                        fontStyle: FontStyle.normal),
                  ),
                  Container(width: 3),
                  read == true
                      ? Icon(
                          Icons.done_all,
                          size: 17,
                          color: Colors.green,
                        )
                      : Container()
                ],
              ),
              right: 8.0,
              bottom: 4.0,
            )
          ],
        ),
      ),
    );
  }

  myImageWidget(content, timeStamp, read, index, bool boomshot) {
    if (boomshot) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
              color: chatRightColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(20))),
          child: Stack(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 8,
                  ),
                  Image.asset(
                    'assets/images/boom_shot.png',
                    color: Colors.white,
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    read == true ? 'BoomShot Açıldı' : 'BoomShot Gönderildi',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: normalStyle,
                        fontSize: 14),
                  ),
                  Text(
                    timeStamp.millisecondsSinceEpoch.toString(),
                    style: TextStyle(color: Colors.transparent, fontSize: 10),
                  ),
                ],
              ),
              Positioned(
                child: Row(
                  children: [
                    Text(
                      DateFormat('hh:mm').format(timeStamp.toDate()),
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.0,
                          fontStyle: FontStyle.normal),
                    ),
                    Container(width: 3),
                    read == true
                        ? Icon(
                            Icons.done_all,
                            size: 17,
                            color: Colors.green,
                          )
                        : Container()
                  ],
                ),
                right: 8.0,
                bottom: 1.0,
              )
            ],
          ),
        ),
      );
    }
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          decoration: BoxDecoration(
              color: chatRightColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(20))),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
            child: Stack(
              children: [
                localImage.contains(content)
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewImages(
                                    images: [content], number: index)),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              width: 30.0,
                              height: 30.0,
                              padding: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      appColorBlue),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Center(child: Text("Not Avilable")),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: content,
                            width: 270.0,
                            height: 250.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: ProgressiveImage(
                          placeholder: AssetImage("assets/images/loading.gif"),
                          thumbnail: NetworkImage(content),
                          height: 250.0,
                          width: 270.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                Positioned(
                  right: 8.0,
                  bottom: 4.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('hh:mm').format(timeStamp.toDate()),
                        style: TextStyle(
                            color: appColorWhite,
                            fontSize: 12.0,
                            fontStyle: FontStyle.normal),
                      ),
                      Container(width: 3),
                      read == true
                          ? Icon(
                              Icons.done_all,
                              size: 17,
                              color: Colors.blue,
                            )
                          : Container(),
                      Container(width: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
          margin: EdgeInsets.only(
              bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
        ),
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.only(bottom: 35, left: 12),
          child: ClipOval(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: Colors.grey[100], // button color
                child: InkWell(
                  child: SizedBox(
                      width: 25,
                      height: 25,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'assets/images/boom_shot.png',
                          color: appColor,
                        ),
                      )),
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
        localImage.contains(content)
            ? Container()
            : Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey[300], shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: () {
                        download(content, 1);
                      },
                      icon: Icon(
                        Icons.arrow_downward,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  peerTextMessage(content, timestamp, read, index) {
    RegExp _numeric = RegExp(r'^-?[0-9]+$');
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
        decoration: BoxDecoration(
            color: _showBlink == true && contentBlink == timestamp
                ? appColorBlue
                : chatLeftColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20))),
        // margin: EdgeInsets.only(
        //     bottom: isLastMessageRight(index) ? 10.0 : 10.0, right: 10.0),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.end,
                children: <Widget>[
                  _numeric.hasMatch(content) && content.length >= 10
                      ? InkWell(
                          onTap: () {
                            launch('tel:$content');
                          },
                          child: Text(
                            content,
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontFamily: normalStyle,
                                fontSize: 14),
                          ),
                        )
                      : widget.searchText != null
                          ? SubstringHighlight(
                              text: content,
                              term: widget.searchText,
                              textStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: normalStyle,
                                  fontSize: 14),
                              textStyleHighlight: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: normalStyle,
                                  fontSize: 14),
                            )
                          : Linkable(
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: normalStyle,
                                  fontSize: 14),
                              text: content,
                            ),
                  Text(
                    timestamp.millisecondsSinceEpoch.toString(),
                    style: TextStyle(color: Colors.transparent, fontSize: 7),
                  ),
                ],
              ),
            ),
            Positioned(
              child: Row(
                children: [
                  Text(
                    DateFormat('hh:mm').format(timestamp.toDate()),
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                        fontStyle: FontStyle.normal),
                  ),
                ],
              ),
              right: 8.0,
              bottom: 4.0,
            )
          ],
        ),
      ),
    );
  }

  peerImageWidget(
      content, timeStamp, read, index, bool boomshot, String messageId) {
    if (boomshot) {
      return InkWell(
        onTap: () {
          if (read != true) {
            FirebaseFirestore.instance
                .collection('messages')
                .doc(groupChatId)
                .collection(groupChatId)
                .doc(messageId)
                .update({"read": true});

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ViewImages(images: [content], number: index)),
            );
          }
        },
        child: Container(
          margin: EdgeInsets.only(right: 8),
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
              color: chatLeftColor,
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20))),
          child: Stack(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 8,
                  ),
                  Image.asset(
                    'assets/images/boom_shot.png',
                    color: appColor,
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    read == true ? 'Açıldı' : 'BoomShot',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: normalStyle,
                        fontSize: 14),
                  ),
                  Text(
                    timeStamp.millisecondsSinceEpoch.toString(),
                    style: TextStyle(color: Colors.transparent, fontSize: 10),
                  ),
                ],
              ),
              Positioned(
                child: Row(
                  children: [
                    Text(
                      DateFormat('hh:mm').format(timeStamp.toDate()),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.normal),
                    ),
                  ],
                ),
                right: 8.0,
                bottom: 1.0,
              )
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              color: chatLeftColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topRight: Radius.circular(20))),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            child: Stack(
              children: [
                localImage.contains(content)
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewImages(
                                    images: [content], number: index)),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              width: 30.0,
                              height: 30.0,
                              padding: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: Color(0xffE8E8E8),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      appColorBlue),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Text("Not Avilable"),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: content,
                            width: 270.0,
                            height: 250.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: ProgressiveImage(
                          placeholder: AssetImage("assets/images/loading.gif"),
                          thumbnail: NetworkImage(content),
                          height: 250.0,
                          width: 270.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                Positioned.fill(
                  right: 8.0,
                  bottom: 4.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('hh:mm').format(timeStamp.toDate()),
                            style: TextStyle(
                                color: appColorWhite,
                                fontSize: 12.0,
                                fontStyle: FontStyle.normal),
                          ),
                          Container(width: 3),
                          Container(width: 5),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          margin: EdgeInsets.only(
              bottom: isLastMessageRight(index) ? 0.0 : 10.0, right: 10.0),
        ),
        localImage.contains(content)
            ? Container()
            : Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey[300], shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: () {
                        download(content, 1);
                      },
                      icon: Icon(
                        Icons.arrow_downward,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget imageWidget() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(widget.peerID)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          peerUrl = snapshot.data["photo"];
          return snapshot.data["photo"].length > 0
              ? Container(
                  height: 40,
                  width: 40,
                  child: CircleAvatar(
                    foregroundColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey,
                    backgroundImage: new NetworkImage(snapshot.data["photo"]),
                  ),
                )
              : Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.grey[400], shape: BoxShape.circle),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      "assets/images/user.png",
                      height: 10,
                      color: Colors.white,
                    ),
                  ));
        }
        return CupertinoActivityIndicator();
      },
    );
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage.docs[index - 1]['idFrom'] != userID) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> onSendMessage(String content, int type, String contact,
      String lat, String long, var replyTime, int contentType,
      [bool boomshot = false]) async {
    // 0 = text
    // 1 = image
    // 2 = sticker
    // 4 = video
    // 5 = file
    // 6 = audio
    // 7 = contact
    // 8 = location
    // 9 = reply
    // if (internet == true) {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (blocksId.contains(peerID)) {
      unBlockMenu(context);
    } else {
      setState(() {
        isButtonEnabled = false;

        if (type == 1) {
          localImage.add(content);
          pref.setStringList("localImage", localImage);
        }
      });
      int badgeCount = 0;

      if (content.trim() != '') {
        textEditingController.clear();

        var timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

        var documentReference = FirebaseFirestore.instance
            .collection('messages')
            .doc(groupChatId)
            .collection(groupChatId)
            .doc(timeStamp);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set(
            documentReference,
            {
              'idFrom': userID,
              'idTo': peerID,
              'fromName': globalName,
              'toName': widget.peerName,
              'timestamp': FieldValue.serverTimestamp(),
              'content': content,
              'type': type,
              "read": peerChatIn == widget.currentUserId ? true : false,
              "delete": [],
              "lat": lat,
              "long": long,
              "boomshot": boomshot,
              "replyType": replyType,
              "replyTime": replyTime,
              "contentType": contentType
            },
          );
        }).then((onValue) async {
          await FirebaseFirestore.instance
              .collection("chatList")
              .doc(userID)
              .collection(userID)
              .doc(peerID)
              .set({
            'id': peerID,
            'name': widget.peerName,
            'timestamp': widget.pin != null && widget.pin.length > 0
                ? widget.pin
                : FieldValue.serverTimestamp(),
            'pin': widget.pin != null && widget.pin.length > 0 ? timeStamp : '',
            'content': content,
            'badge': '0',
            'type': type,
            "chatType": "normal",
            'archive': widget.archive != null ? widget.archive : false,
            'mute': widget.mute != null ? widget.mute : false
          }).then((onValue) async {
            try {
              await FirebaseFirestore.instance
                  .collection("chatList")
                  .doc(peerID)
                  .collection(peerID)
                  .doc(userID)
                  .get()
                  .then((doc) async {
                if (doc["badge"] != null) {
                  badgeCount = int.parse(doc["badge"]);
                  await FirebaseFirestore.instance
                      .collection("chatList")
                      .doc(peerID)
                      .collection(peerID)
                      .doc(userID)
                      .set({
                    'id': userID,
                    'name': globalName,
                    'timestamp': widget.pin != null && widget.pin.length > 0
                        ? widget.pin
                        : FieldValue.serverTimestamp(),
                    'pin': widget.pin != null && widget.pin.length > 0
                        ? timeStamp
                        : '',
                    'content': content,
                    "chatType": "normal",
                    'badge': peerChatIn == widget.currentUserId
                        ? badgeCount.toString()
                        : '${badgeCount + 1}',
                    'type': type,
                    'archive': widget.archive != null ? widget.archive : false,
                    'mute': widget.mute != null ? widget.mute : false
                  });
                }
              });
            } catch (e) {
              await FirebaseFirestore.instance
                  .collection("chatList")
                  .doc(peerID)
                  .collection(peerID)
                  .doc(userID)
                  .set({
                'id': userID,
                'name': globalName,
                'timestamp': widget.pin != null && widget.pin.length > 0
                    ? widget.pin
                    : FieldValue.serverTimestamp(),
                'pin': widget.pin != null && widget.pin.length > 0
                    ? FieldValue.serverTimestamp()
                    : '',
                'content': content,
                'badge': '${badgeCount + 1}',
                "chatType": "normal",
                'type': type,
                'archive': widget.archive != null ? widget.archive : false,
                'mute': widget.mute != null ? widget.mute : false
              });
            }
          });
        });
        print(peerChatIn + "-" + widget.currentUserId);
        if (peerChatIn != widget.currentUserId) {
          if (type == 1) {
            sendImageNotification(peerToken, content);
          } else if (type == 4) {
            sendVideoNotification(peerToken, content);
          } else if (type == 5) {
            sendFileNotification(peerToken, content);
          } else if (type == 6) {
            sendAudioNotification(peerToken, content);
          } else {
            sendNotification(peerToken, content);
            print("bildirm");
          }
        }
      } else {}
    }
  }

  Widget buildInput() {
    SizeConfig().init(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 0, bottom: 15),
        child: Container(
          width: deviceHeight,
          decoration: BoxDecoration(
              color: replyButton == true ? Colors.grey[100] : Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                replyButton == true
                    ? Padding(
                        padding:
                            const EdgeInsets.only(left: 30, right: 30, top: 20),
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(replyName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: appColorBlue)),
                                Container(
                                  height: 5,
                                ),
                                SizedBox(
                                  width: 250,
                                  child: Text(replyMsg,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  height: 5,
                                ),
                              ],
                            ),
                            Expanded(
                              child: Text(""),
                            ),
                            Container(
                                height: 30,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(width: 1.3)),
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      replyButton = false;
                                    });
                                  },
                                ))
                          ],
                        ),
                      )
                    : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return GetCredits(
                                peerToken: peerToken,
                                userId: widget.peerID,
                                userName: widget.peerName,
                              );
                            });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 0, left: 5, top: 2, bottom: 2),
                        child: Image.asset(
                          "assets/stickers/gift.png",
                          height: 26,
                          width: 26,
                          color: appColorBlue,
                        ),
                      ),
                    ),
                    record == false
                        ? Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: IconButton(
                              padding: EdgeInsets.all(0.0),
                              onPressed: () {
                                _settingModalBottomSheet(context);
                              },
                              icon: Icon(
                                Icons.add,
                                color: appColorBlue,
                                size: 30,
                              ),
                            ),
                          )
                        : Container(),
                    record == false
                        ? Expanded(
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 0.0,
                              ),
                              // height: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                color: appColorWhite,
                              ),
                              child: TextField(
                                controller: textEditingController,
                                minLines: 1,
                                maxLines: 5,
                                keyboardType: TextInputType.multiline,
                                onChanged: (val) {
                                  _onChangeHandler(val);
                                  if ((val.length > 0)) {
                                    setState(() {
                                      isButtonEnabled = true;
                                    });
                                  } else {
                                    setState(() {
                                      isButtonEnabled = false;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20),
                                  border: InputBorder.none,
                                  hintText: 'Mesaj yaz',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.withOpacity(0.6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        textFieldFocusNode.unfocus();
                                        textFieldFocusNode.canRequestFocus =
                                            false;
                                      });

                                      GiphyGif gif = await GiphyGet.getGif(
                                        context: context,
                                        apiKey:
                                            "QUnQNPmTehyhBAwPG7WuGCz4HLLZB0zQ", //YOUR API KEY HERE
                                        lang: GiphyLanguage.spanish,
                                      );

                                      if (gif != null) {
                                        setState(() {
                                          // FocusScope.of(context).unfocus();
                                          // SystemChannels.textInput.invokeMethod('TextInput.hide');
                                          //  FocusScope.of(context).unfocus();
                                          _gif = gif;
                                          if (replyButton == true) {
                                            onSendMessage(
                                                gif.images.original.url,
                                                9,
                                                '',
                                                replyName,
                                                replyMsg,
                                                replyTime,
                                                1);
                                            setState(() {
                                              replyButton = false;
                                            });
                                          } else {
                                            onSendMessage(
                                                gif.images.original.url,
                                                1,
                                                '',
                                                '',
                                                '',
                                                '',
                                                1);
                                          }

                                          print(gif.images.original.url);
                                        });
                                      }
                                      // final gif = await GiphyPicker.pickGif(
                                      //   context: context,
                                      //   apiKey:
                                      //       'QUnQNPmTehyhBAwPG7WuGCz4HLLZB0zQ',
                                      //   fullScreenDialog: false,
                                      //   previewType: GiphyPreviewType.previewWebp,
                                      //   decorator: GiphyDecorator(
                                      //     showAppBar: false,
                                      //     searchElevation: 4,
                                      //     giphyTheme: ThemeData.dark().copyWith(
                                      //       inputDecorationTheme:
                                      //           InputDecorationTheme(
                                      //         border: InputBorder.none,
                                      //         enabledBorder: InputBorder.none,
                                      //         focusedBorder: InputBorder.none,
                                      //         contentPadding: EdgeInsets.zero,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // );
                                    },
                                    child: Container(
                                      child: FittedBox(
                                        alignment: Alignment.center,
                                        fit: BoxFit.fitHeight,
                                        child: IconTheme(
                                          data: IconThemeData(),
                                          child: Icon(
                                            Icons.gif,
                                            color: appColorBlue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: appColorGrey, width: 0.5),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: appColorGrey, width: 0.5),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: StreamBuilder<int>(
                              stream: _stopWatchTimer.rawTime,
                              initialData: _stopWatchTimer.rawTime.value,
                              builder: (context, snap) {
                                final value = snap;
                                final displayTime =
                                    StopWatchTimer.getDisplayTime(value.data,
                                        hours: false,
                                        second: true,
                                        milliSecond: false,
                                        minute: true);
                                return Text(
                                  displayTime,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                    record == false
                        ? isButtonEnabled == true
                            ? IconButton(
                                onPressed: () {
                                  if (replyButton == true) {
                                    onSendMessage(textEditingController.text, 9,
                                        '', replyName, replyMsg, replyTime, 0);
                                    setState(() {
                                      replyButton = false;
                                    });
                                  } else {
                                    onSendMessage(textEditingController.text, 0,
                                        '', '', '', '', 0);
                                  }
                                },
                                icon: Image.asset("assets/images/send.png"),
                                iconSize: 32.0,
                              )
                            : IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext bc) {
                                        return Container(
                                          child: new Wrap(
                                            children: <Widget>[
                                              new ListTile(
                                                leading: new Image.asset(
                                                  'assets/images/boom_shot.png',
                                                  color: Colors.grey,
                                                  width: 25,
                                                  height: 25,
                                                ),
                                                title: new Text('BoomShot'),
                                                onTap: () {
                                                  getImageFromCam(true).then(
                                                      (value) => Navigator.pop(
                                                          context));
                                                },
                                              ),
                                              ListTile(
                                                leading: new Icon(
                                                    Icons.video_call_outlined),
                                                title: new Text('Kamera'),
                                                onTap: () {
                                                  getImageFromCam(false).then(
                                                      (value) => Navigator.pop(
                                                          context));
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                },
                                icon: Image.asset("assets/images/camblue.png"),
                                iconSize: 32.0,
                              )
                        : Expanded(
                            child: InkWell(
                            onTap: () {
                              _cancle();
                            },
                            child: Text(
                              "Cancel",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                    button == false
                        ? isButtonEnabled == false
                            ? GestureDetector(
                                onLongPress: () {
                                  // _init();
                                  _stopWatchTimer.onExecute
                                      .add(StopWatchExecute.reset);

                                  _stopWatchTimer.onExecute
                                      .add(StopWatchExecute.start);
                                  _start();
                                },
                                onLongPressUp: () {
                                  _stop();
                                },
                                onTap: () {
                                  Toast.show("Hold to record", context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.BOTTOM);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 5, left: 3, top: 2, bottom: 2),
                                  child: Image.asset(
                                    "assets/images/mic.png",
                                    height: 26,
                                    width: 26,
                                    color: appColorBlue,
                                  ),
                                ),
                              )
                            : Container()
                        : Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: IconButton(
                              onPressed: () async {
                                setState(() {
                                  button = false;
                                  record = false;
                                  isLoading = true;
                                });

                                String imageLocation =
                                    'User Voices/${widget.currentUserId}/${DateTime.now()}.jpg';

                                await firebase_storage.FirebaseStorage.instance
                                    .ref(imageLocation)
                                    .putFile(File(recordFilePath));
                                String downloadUrl = await firebase_storage
                                    .FirebaseStorage.instance
                                    .ref(imageLocation)
                                    .getDownloadURL();

                                if (replyButton == true) {
                                  onSendMessage(downloadUrl, 9, '', replyName,
                                      replyMsg, replyTime, 6);
                                  setState(() {
                                    replyButton = false;
                                  });
                                } else {
                                  onSendMessage(
                                      downloadUrl, 6, '', '', '', '', 6);
                                }

                                setState(() {
                                  isLoading = false;
                                });
                              },
                              icon: Image.asset("assets/images/send.png"),
                              iconSize: 32.0,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDeleteInput() {
    SizeConfig().init(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: Container(
        height: 50.0,
        width: deviceHeight,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Row(
          children: <Widget>[
            Container(width: 20),
            InkWell(
              onTap: () {
                openDeleteDialog(context);
              },
              child: Icon(
                Icons.delete,
                color: Colors.red,
                size: 25,
              ),
            ),
            Expanded(
                child: Text(
              deleteMsgTime.length.toString() + " " + "Selected",
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            )),
            InkWell(
              onTap: () {
                setState(() {
                  deleteButton = false;
                });
              },
              child: Text(
                "Done",
                style:
                    TextStyle(color: appColorBlue, fontWeight: FontWeight.bold),
              ),
            ),
            Container(width: 20),
          ],
        ),
      ),
    );
  }

  Widget buildForwardInput() {
    SizeConfig().init(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: Container(
        height: 50.0,
        width: deviceHeight,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Row(
          children: <Widget>[
            Container(width: 20),
            InkWell(
                onTap: () {
                  setState(() {
                    forwardButton = false;
                  });
                  forwardMsg();
                },
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Icon(
                    Icons.reply,
                    color: Colors.black,
                    size: 25,
                  ),
                )),
            Expanded(
                child: Text(
              forwardContent.length.toString() + " " + "Selected",
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            )),
            InkWell(
              onTap: () {
                setState(() {
                  forwardButton = false;
                });
              },
              child: Text(
                "Done",
                style:
                    TextStyle(color: appColorBlue, fontWeight: FontWeight.bold),
              ),
            ),
            Container(width: 20),
          ],
        ),
      ),
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                  leading: new Icon(Icons.image),
                  title: new Text('Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    getImage();
                  },
                ),
                ListTile(
                  leading: new Icon(Icons.video_call),
                  title: new Text('video library'),
                  onTap: () {
                    _pickVideo();
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.location_on),
                  title: new Text('Location'),
                  onTap: () async {
                    String _pickedLocation = '';
                    Navigator.pop(context);
                    LocationResult result =
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PlacePicker(
                                  "AIzaSyCqQW9tN814NYD_MdsLIb35HRY65hHomco",
                                )));

                    setState(() {
                      _pickedLocation = result.formattedAddress.toString();
                    });
                    if (_pickedLocation.length > 0) {
                      onSendMessage(
                        result.formattedAddress.toString(),
                        8,
                        '',
                        result.latLng.latitude.toString(),
                        result.latLng.longitude.toString(),
                        '',
                        8,
                      ).then((value) {});
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  // imagePreview(String url) {
  //   return showDialog(
  //     context: context,
  //     builder: (_) => Stack(
  //       alignment: Alignment.topCenter,
  //       children: <Widget>[
  //         Padding(
  //           padding: const EdgeInsets.only(
  //               top: 100, left: 10, right: 10, bottom: 100),
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.circular(10),
  //             child: Container(
  //               child: PhotoView(
  //                 imageProvider: NetworkImage(url),
  //               ),
  //             ),
  //           ),
  //         ),
  //         //buildFilterCloseButton(context),
  //       ],
  //     ),
  //   );
  // }

  // Widget buildFilterCloseButton(BuildContext context) {
  //   return Align(
  //     alignment: Alignment.topLeft,
  //     child: Material(
  //       color: Colors.black.withOpacity(0.0),
  //       child: Padding(
  //         padding: const EdgeInsets.all(18.0),
  //         child: IconButton(
  //           icon: Icon(
  //             Icons.close,
  //             color: Colors.white,
  //           ),
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  openMessageBox(
    time,
    groupChatId,
    idFrom,
    content,
    idTo,
    type,
  ) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        replyButton = true;
                      });
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Reply",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: Text("")),
                          Icon(
                            Icons.reply,
                            color: Colors.black,
                            size: 25,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);

                      setState(() {
                        forwardButton = true;
                        forwardContent = [];
                        forwardTime = [];
                        forwardTypes = [];
                      });
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Forward",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: Text("")),
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: Icon(
                              Icons.reply,
                              color: Colors.black,
                              size: 25,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Clipboard.setData(new ClipboardData(text: content));
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Copy",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: Text("")),
                          Icon(
                            Icons.copy,
                            color: Colors.black,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  type == 1 || type == 4 || type == 5 || type == 7
                      ? Divider(
                          color: Colors.grey,
                          height: 4.0,
                        )
                      : Container(),
                  type == 1 || type == 4 || type == 5 || type == 7
                      ? InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            if (type == 7) {
                            } else {
                              download(content, type);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Save",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Expanded(child: Text("")),
                                Icon(
                                  Icons.file_download,
                                  color: Colors.black,
                                  size: 20,
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        deleteMsgTime.clear();
                        deleteMsgID.clear();
                        deleteMsgContent.clear();
                        deleteButton = true;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Delete",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: Text("")),
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 25,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
            ),
          );
        });
  }

  // static String avtar =
  //     "https://firebasestorage.googleapis.com/v0/b/tinfit-primocy.appspot.com/o/profile%2F1577811368705.jpg?alt=media&token=0055056b-699e-498e-a85b-9df859ea462c";
  // static String peerDeviceToken =
  //     "fW-Nc061a9E:APA91bF7zpr0F6atTXoPXcNF7euy6yKRSkgq9RlRY3kJjcIQ4LLCOeCqTkqLgHfQ8i-Sb8W4YyVJhHPXj1dNpUdhRv1JDk_LnFjr8PyxBFqxab70UjPCAqRJVZndK2GR1WljELjs9o5Y";

  Future<http.Response> createNotification(String sendNotification) async {
    final response = await http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
//          HttpHeaders.authorizationHeader:
//              "key=AAAAdlUezOQ:APA91bH9mRwxoUQujG3NGnkAmV0XFGW8zYGseKjPmLQOZqX9pcl4Zzm32qoNgBacwPvVPkRrH7auS6VGEDti558GpYAmiksVI0mPZf9N-ltZrKQQlh6TnTL5_tz3HdtRCso1hK1dqH2v"
      },
      body: sendNotification,
    );
    return response;
  }

  unBlockMenu(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Unblock",
              style: TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              unBlockCall();
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {});
  }

  unBlockCall() {
    blocksId.remove(peerID);
    var _userRef = database.reference().child('block');
    _userRef.child(userID).update({
      "id": blocksId,
    }).then((_) {
      setState(() {});
    });
  }

  getBlockId() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          blocksId = value["blocks"];
        });
      }
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(peerID)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          peerblocksId = value["blocks"];
        });
      }
    });
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/test_.mp3";
  }

  String recordFilePath;
  _start() async {
    setState(() {
      record = true;
    });
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      // startTimer();

      recordFilePath = await getFilePath();

      RecordMp3.instance.start(recordFilePath, (type) {
        statusText = "Record error--->$type";
        setState(() {
          record = true;
        });
      });
    } else {
      final snackBar =
          SnackBar(content: Text('Ses Kaydı için izin vermeniz gerekiyor!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _cancle() async {
    record = false;
    setState(() {
      button = false;
      record = false;
      record = false;
      // stopTimer();
    });
  }

  _stop() async {
    RecordMp3.instance.stop();
    setState(() {
      running = false;
      button = true;
    });

    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
  }

  // ignore: unused_element
  _resume() async {
    // await _recorder.resume();
    // setState(() {
    //   voiceRecording = null;
    // });
  }

  // ignore: unused_element
  _pause() async {
    // await _recorder.pause();
    // setState(() {});
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    chatMsgList.forEach((userDetail) {
      if (userDetail['content'].toLowerCase().contains(text.toLowerCase()))
        _searchResult.add(userDetail);
    });

    setState(() {});
  }

  // setdata() async {
  //   print(groupChatId);
  //   await FirebaseFirestore.instance
  //       .collection('messages')
  //       .doc(groupChatId)
  //       .collection(groupChatId)
  //       .orderBy('timestamp', descending: true)
  //       .get(source: Source.cache);
  // }

  // getSaved() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   if (preferences.containsKey("chat")) {
  //     List<dynamic> userMap = jsonDecode(preferences.getString("chat"));
  //     msgList.clear();
  //     msgList.addAll(userMap);
  //     print(msgList);
  //     setState(() {
  //       offline = true;
  //     });
  //   }
  // }

  openDeleteDialog(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          deleteMsgID.contains(peerID)
              ? Container()
              : CupertinoActionSheetAction(
                  child: Text(
                    "Delete For Everyone",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontFamily: "MontserratBold"),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop("Discard");
                    setState(() {
                      deleteButton = false;
                    });

                    for (var i = 0; i < deleteMsgTime.length; i++) {
                      FirebaseFirestore.instance
                          .collection('messages')
                          .doc(groupChatId)
                          .collection(groupChatId)
                          .where("timestamp", isEqualTo: deleteMsgTime[i])
                          .get()
                          .then((querySnapshot) async {
                        querySnapshot.docs.forEach((documentSnapshot) {
                          documentSnapshot.reference.update({
                            "delete": FieldValue.arrayUnion([userID, peerID])
                          });
                        });

                        await FirebaseFirestore.instance
                            .collection("chatList")
                            .doc(userID)
                            .collection(userID)
                            .doc(peerID)
                            .get()
                            .then((doc) async {
                          if (deleteMsgTime[i] == doc["timestamp"]) {
                            await FirebaseFirestore.instance
                                .collection("chatList")
                                .doc(userID)
                                .collection(userID)
                                .doc(peerID)
                                .update(
                                    {'content': "you deleted this message"});
                          }
                        }).then((value) async {
                          await FirebaseFirestore.instance
                              .collection("chatList")
                              .doc(peerID)
                              .collection(peerID)
                              .doc(userID)
                              .update({'content': "This message was deleted"});
                        });

                        // StorageReference photoRef = await FirebaseStorage
                        //     .instance
                        //     .getReferenceFromUrl(deleteMsgContent[i]);

                        // await photoRef.delete();
                      });
                    }
                  },
                ),
          CupertinoActionSheetAction(
            child: Text(
              "Delete For Me",
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontFamily: "MontserratBold"),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop("Discard");

              setState(() {
                deleteButton = false;
              });

              for (var i = 0; i <= deleteMsgTime.length; i++) {
                FirebaseFirestore.instance
                    .collection('messages')
                    .doc(groupChatId)
                    .collection(groupChatId)
                    .where("timestamp", isEqualTo: deleteMsgTime[i])
                    .get()
                    .then((querySnapshot) async {
                  querySnapshot.docs.forEach((documentSnapshot) {
                    documentSnapshot.reference.update({
                      "delete": FieldValue.arrayUnion([userID])
                    });
                  });

                  if (deleteMsgTime[i] == widget.chatListTime) {
                    await FirebaseFirestore.instance
                        .collection("chatList")
                        .doc(userID)
                        .collection(userID)
                        .doc(peerID)
                        .update({'content': "you deleted this message"});
                  }

                  // StorageReference photoRef = await FirebaseStorage.instance
                  //     .getReferenceFromUrl(deleteMsgContent[i]);

                  // await photoRef.delete();
                });
              }
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontFamily: "MontserratBold"),
          ),
          isDefaultAction: true,
          onPressed: () {
            // Navigator.pop(context, 'Cancel');
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

  forwardMsg() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState1) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  height: SizeConfig.screenHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                        ),
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Cancel",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: appColorBlue),
                                  )),
                              Text(
                                "Forward",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black),
                              ),
                              // forwardMsgId.length > 0
                              //     ?
                              InkWell(
                                  onTap: () {
                                    for (var p = 0;
                                        p < forwardTime.length;
                                        p++) {
                                      //GROUP ============================================================>
                                      print(groupMsgId);
                                      groupMsgContent = [];
                                      groupMsgType = [];
                                      groupMsgContact = [];

                                      for (var i = 0;
                                          i < groupMsgId.length;
                                          i++) {
                                        groupMsgContent.add(forwardContent[p]);
                                        groupMsgType.add(forwardTypes[p]);
                                        groupMsgContact.add("");
                                      }

                                      for (var i = 0;
                                          i < groupMsgId.length;
                                          i++) {
                                        onForwardGroup(
                                            groupMsgUserId[i],
                                            groupMsgId[i],
                                            groupMsgPeerName[i],
                                            groupMsgPeerImage[i],
                                            groupMsgContent[i],
                                            groupMsgType[i],
                                            groupMsgContact[i]);
                                      }
                                      // <======================================== GROUP

                                      forwardMsgContent = [];
                                      forwardMsgType = [];
                                      forwardMsgContact = [];

                                      for (var i = 0;
                                          i < forwardMsgId.length;
                                          i++) {
                                        forwardMsgContent
                                            .add(forwardContent[p]);
                                        forwardMsgType.add(forwardTypes[p]);
                                        forwardMsgContact.add("");
                                      }

                                      for (var i = 0;
                                          i < forwardMsgId.length;
                                          i++) {
                                        onForward(
                                            forwardMsgId[i],
                                            forwardMsgPeerName[i],
                                            forwardMsgPeerImage[i],
                                            forwardMsgContent[i],
                                            forwardMsgType[i],
                                            forwardMsgContact[i]);
                                      }
                                    }

                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      "Send",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ))
                              // : Padding(
                              //     padding: const EdgeInsets.only(right: 15),
                              //     child: Text("       "),
                              //   ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomScrollView(
                          primary: true,
                          shrinkWrap: false,
                          slivers: <Widget>[
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 10, left: 10),
                                      child: Container(
                                        decoration: new BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: new BorderRadius.all(
                                              Radius.circular(15.0),
                                            )),
                                        height: 40,
                                        child: Center(
                                          child: TextField(
                                            controller: forwardController,
                                            onChanged: (val) {
                                              setState1(() {});
                                            },
                                            style:
                                                TextStyle(color: Colors.grey),
                                            decoration: new InputDecoration(
                                              border: new OutlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.grey[200]),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(15.0),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.grey[200]),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(15.0),
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.grey[200]),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(15.0),
                                                ),
                                              ),
                                              filled: true,
                                              hintStyle: new TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14),
                                              hintText: "Search",
                                              contentPadding:
                                                  EdgeInsets.only(top: 10.0),
                                              fillColor: Colors.grey[200],
                                              prefixIcon: Icon(
                                                Icons.search,
                                                color: Colors.grey[600],
                                                size: 25.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )),
                                  forwardGroupsWidget(setState1),
                                  forwardUsersWidget(setState1),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          });
        });
  }

  forwardUsersWidget(setState1) {
    return FutureBuilder(
      future:
          firebase.FirebaseDatabase.instance.reference().child("user").once(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var lists = [];
          Map<dynamic, dynamic> values = snapshot.data;
          values.forEach((key, values) {
            lists.add(values);
          });
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: lists.length,
            itemBuilder: (BuildContext context, int index) {
              return mobileContacts.contains(lists[index]["mobile"]) &&
                      userID != lists[index]["userId"]
                  ? lists[index]["name"].contains(new RegExp(
                          forwardController.text,
                          caseSensitive: false))
                      ? Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  new Divider(
                                    height: 1,
                                  ),
                                  new ListTile(
                                    onTap: () {},
                                    leading: new Stack(
                                      children: <Widget>[
                                        (lists[index]["img"] != null &&
                                                lists[index]["img"].length > 0)
                                            ? CircleAvatar(
                                                backgroundColor: Colors.grey,
                                                backgroundImage:
                                                    new NetworkImage(
                                                        lists[index]["img"]),
                                              )
                                            : CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: Text(
                                                  "",
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                      ],
                                    ),
                                    title: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        // savedContactUserId.contains(
                                        //             lists[index]["userId"]) &&
                                        //         allcontacts != null
                                        //     ? Row(
                                        //         mainAxisAlignment:
                                        //             MainAxisAlignment.start,
                                        //         children: <Widget>[
                                        //           for (var i = 0;
                                        //               i < allcontacts.length;
                                        //               i++)
                                        //             Text(
                                        //               allcontacts[i]
                                        //                       .phones
                                        //                       .map((e) =>
                                        //                           e.value)
                                        //                       .toString()
                                        //                       .replaceAll(
                                        //                           new RegExp(
                                        //                               r"\s+\b|\b\s"),
                                        //                           "")
                                        //                       .contains(lists[
                                        //                               index]
                                        //                           ["mobile"])
                                        //                   ? allcontacts[i]
                                        //                       .displayName
                                        //                   : "",
                                        //               style: new TextStyle(
                                        //                   fontWeight:
                                        //                       FontWeight.bold),
                                        //             )
                                        //         ],
                                        //       )
                                        //     : Text(
                                        //         lists[index]["mobile"],
                                        //         style: new TextStyle(
                                        //             fontWeight:
                                        //                 FontWeight.bold),
                                        //       ),
                                        // Text(
                                        //   lists[index]["name"] ?? "",
                                        //   style: new TextStyle(
                                        //       fontWeight: FontWeight.bold),
                                        // ),
                                      ],
                                    ),
                                    subtitle: new Container(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: new Row(
                                        children: [
                                          Text(lists[index]["mobile"])
                                          // ItemsTile(c.phones),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            forwardMsgId.contains(lists[index]["userId"])
                                ? InkWell(
                                    onTap: () {},
                                    child: IconButton(
                                      onPressed: () {
                                        setState1(() {
                                          forwardMsgId
                                              .remove(lists[index]["userId"]);
                                          forwardMsgPeerName
                                              .remove(lists[index]["name"]);
                                          forwardMsgPeerImage
                                              .remove(lists[index]["img"]);
                                        });
                                      },
                                      icon: Icon(
                                        Icons.check_circle,
                                        color: appColorBlue,
                                        size: 28,
                                      ),
                                    ))
                                : IconButton(
                                    onPressed: () {
                                      setState1(() {
                                        forwardMsgId
                                            .add(lists[index]["userId"]);
                                        forwardMsgPeerName
                                            .add(lists[index]["name"]);
                                        forwardMsgPeerImage
                                            .add(lists[index]["img"]);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.radio_button_off_outlined,
                                      color: Colors.grey,
                                      size: 28,
                                    ),
                                  ),
                            Container(
                              width: 20,
                            )
                          ],
                        )
                      : forwardController.text.isEmpty
                          ? Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      new Divider(
                                        height: 1,
                                      ),
                                      new ListTile(
                                        onTap: () {},
                                        leading: new Stack(
                                          children: <Widget>[
                                            (lists[index]["img"] != null &&
                                                    lists[index]["img"].length >
                                                        0)
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey,
                                                    backgroundImage:
                                                        new NetworkImage(
                                                            lists[index]
                                                                ["img"]),
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    child: Text(
                                                      "",
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                          ],
                                        ),
                                        title: new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            // savedContactUserId.contains(
                                            //             lists[index]
                                            //                 ["userId"]) &&
                                            //         allcontacts != null
                                            //     ? Row(
                                            //         mainAxisAlignment:
                                            //             MainAxisAlignment.start,
                                            //         children: <Widget>[
                                            //           for (var i = 0;
                                            //               i <
                                            //                   allcontacts
                                            //                       .length;
                                            //               i++)
                                            //             Text(
                                            //               allcontacts[i]
                                            //                       .phones
                                            //                       .map((e) =>
                                            //                           e.value)
                                            //                       .toString()
                                            //                       .replaceAll(
                                            //                           new RegExp(
                                            //                               r"\s+\b|\b\s"),
                                            //                           "")
                                            //                       .contains(lists[
                                            //                               index]
                                            //                           [
                                            //                           "mobile"])
                                            //                   ? allcontacts[i]
                                            //                       .displayName
                                            //                   : "",
                                            //               style: new TextStyle(
                                            //                   fontWeight:
                                            //                       FontWeight
                                            //                           .bold),
                                            //             )
                                            //         ],
                                            //       )
                                            //     : Text(
                                            //         lists[index]["mobile"],
                                            //         style: new TextStyle(
                                            //             fontWeight:
                                            //                 FontWeight.bold),
                                            //       ),
                                            // Text(
                                            //   lists[index]["name"] ?? "",
                                            //   style: new TextStyle(
                                            //       fontWeight: FontWeight.bold),
                                            // ),
                                          ],
                                        ),
                                        subtitle: new Container(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: new Row(
                                            children: [
                                              Text(lists[index]["mobile"])
                                              // ItemsTile(c.phones),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                forwardMsgId.contains(lists[index]["userId"])
                                    ? InkWell(
                                        onTap: () {},
                                        child: IconButton(
                                          onPressed: () {
                                            setState1(() {
                                              forwardMsgId.remove(
                                                  lists[index]["userId"]);
                                              forwardMsgPeerName
                                                  .remove(lists[index]["name"]);
                                              forwardMsgPeerImage
                                                  .remove(lists[index]["img"]);
                                            });
                                          },
                                          icon: Icon(
                                            Icons.check_circle,
                                            color: appColorBlue,
                                            size: 28,
                                          ),
                                        ))
                                    : IconButton(
                                        onPressed: () {
                                          setState1(() {
                                            forwardMsgId
                                                .add(lists[index]["userId"]);
                                            forwardMsgPeerName
                                                .add(lists[index]["name"]);
                                            forwardMsgPeerImage
                                                .add(lists[index]["img"]);
                                          });
                                        },
                                        icon: Icon(
                                          Icons.radio_button_off_outlined,
                                          color: Colors.grey,
                                          size: 28,
                                        ),
                                      ),
                                Container(
                                  width: 20,
                                )
                              ],
                            )
                          : Container()
                  : Container();
            },
          );
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                CupertinoActivityIndicator(),
              ]),
        );
      },
    );
  }

  forwardGroupsWidget(setState1) {
    return FutureBuilder(
      future:
          firebase.FirebaseDatabase.instance.reference().child("group").once(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var lists = [];
          var groupId = [];
          Map<dynamic, dynamic> values = snapshot.data;
          values.forEach((key, values) {
            lists.add(values);
            groupId.add(key);
          });
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: lists.length,
            itemBuilder: (BuildContext context, int index) {
              return lists[index]["userId"].contains(userID)
                  ? lists[index]["castName"].contains(new RegExp(
                          forwardController.text,
                          caseSensitive: false))
                      ? Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  new Divider(
                                    height: 1,
                                  ),
                                  new ListTile(
                                    onTap: () {},
                                    leading: new Stack(
                                      children: <Widget>[
                                        (lists[index]["castImage"] != null &&
                                                lists[index]["castImage"]
                                                        .length >
                                                    0)
                                            ? CircleAvatar(
                                                backgroundColor: Colors.grey,
                                                backgroundImage:
                                                    new NetworkImage(
                                                        lists[index]
                                                            ["castImage"]),
                                              )
                                            : CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: Text(
                                                  "",
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                      ],
                                    ),
                                    title: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        new Text(
                                          lists[index]["castName"] ?? "",
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    // subtitle: new Container(
                                    //   padding: const EdgeInsets.only(top: 5.0),
                                    //   child: new Row(
                                    //     children: [
                                    //       Text(lists[index]["castDesc"])
                                    //       // ItemsTile(c.phones),
                                    //     ],
                                    //   ),
                                    // ),
                                  ),
                                ],
                              ),
                            ),
                            groupMsgId.contains(groupId[index])
                                ? InkWell(
                                    onTap: () {},
                                    child: IconButton(
                                      onPressed: () {
                                        setState1(() {
                                          groupMsgId.remove(groupId[index]);
                                          groupMsgUserId.remove(jsonEncode(
                                              lists[index]["userId"]));
                                          groupMsgPeerName
                                              .remove(lists[index]["castName"]);
                                          groupMsgPeerImage.remove(
                                              lists[index]["castImage"]);
                                          print(groupMsgUserId);
                                        });
                                      },
                                      icon: Icon(
                                        Icons.check_circle,
                                        color: appColorBlue,
                                        size: 28,
                                      ),
                                    ))
                                : IconButton(
                                    onPressed: () {
                                      setState1(() {
                                        groupMsgId.add(groupId[index]);
                                        groupMsgUserId.add(
                                            jsonEncode(lists[index]["userId"]));
                                        // groupMsgUserId
                                        //     .add(lists[index]["userId"].toString());
                                        groupMsgPeerName
                                            .add(lists[index]["castName"]);
                                        groupMsgPeerImage
                                            .add(lists[index]["castImage"]);
                                        print(groupMsgUserId);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.radio_button_off_outlined,
                                      color: Colors.grey,
                                      size: 28,
                                    ),
                                  ),
                            Container(
                              width: 20,
                            )
                          ],
                        )
                      : forwardController.text.isEmpty
                          ? Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      new Divider(
                                        height: 1,
                                      ),
                                      new ListTile(
                                        onTap: () {},
                                        leading: new Stack(
                                          children: <Widget>[
                                            (lists[index]["castImage"] !=
                                                        null &&
                                                    lists[index]["castImage"]
                                                            .length >
                                                        0)
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey,
                                                    backgroundImage:
                                                        new NetworkImage(
                                                            lists[index]
                                                                ["castImage"]),
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    child: Text(
                                                      "",
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                          ],
                                        ),
                                        title: new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new Text(
                                              lists[index]["castName"] ?? "",
                                              style: new TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        // subtitle: new Container(
                                        //   padding: const EdgeInsets.only(top: 5.0),
                                        //   child: new Row(
                                        //     children: [
                                        //       Text(lists[index]["castDesc"])
                                        //       // ItemsTile(c.phones),
                                        //     ],
                                        //   ),
                                        // ),
                                      ),
                                    ],
                                  ),
                                ),
                                groupMsgId.contains(groupId[index])
                                    ? InkWell(
                                        onTap: () {},
                                        child: IconButton(
                                          onPressed: () {
                                            setState1(() {
                                              groupMsgId.remove(groupId[index]);
                                              groupMsgUserId.remove(jsonEncode(
                                                  lists[index]["userId"]));
                                              groupMsgPeerName.remove(
                                                  lists[index]["castName"]);
                                              groupMsgPeerImage.remove(
                                                  lists[index]["castImage"]);
                                              print(groupMsgUserId);
                                            });
                                          },
                                          icon: Icon(
                                            Icons.check_circle,
                                            color: appColorBlue,
                                            size: 28,
                                          ),
                                        ))
                                    : IconButton(
                                        onPressed: () {
                                          setState1(() {
                                            groupMsgId.add(groupId[index]);
                                            groupMsgUserId.add(jsonEncode(
                                                lists[index]["userId"]));
                                            // groupMsgUserId
                                            //     .add(lists[index]["userId"].toString());
                                            groupMsgPeerName
                                                .add(lists[index]["castName"]);
                                            groupMsgPeerImage
                                                .add(lists[index]["castImage"]);
                                            print(groupMsgUserId);
                                          });
                                        },
                                        icon: Icon(
                                          Icons.radio_button_off_outlined,
                                          color: Colors.grey,
                                          size: 28,
                                        ),
                                      ),
                                Container(
                                  width: 20,
                                )
                              ],
                            )
                          : Container()
                  : Container();
            },
          );
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                CupertinoActivityIndicator(),
              ]),
        );
      },
    );
  }

  Future<void> onForward(
    peerID2,
    peerName2,
    peerUrl2,
    String content,
    int type,
    String contact,
  ) async {
    // 0 = text
    // 1 = image
    // 2 = sticker
    // 4 = video
    // 5 = file
    // 6 = audio
    // 7 = contact
    int badgeCount = 0;
    print(content);
    print(content.trim());
    if (content.trim() != '') {
      textEditingController.clear();

      if (userID.hashCode <= peerID2.hashCode) {
        groupChatId = userID + "-" + peerID2;
      } else {
        groupChatId = peerID2 + "-" + userID;
      }

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': userID,
            'idTo': peerID2,
            'timestamp': FieldValue.serverTimestamp(),
            'content': content,
            'contact': contact,
            'type': type,
            "read": false,
            "delete": []
          },
        );
      }).then((onValue) async {
        await FirebaseFirestore.instance
            .collection("chatList")
            .doc(userID)
            .collection(userID)
            .doc(peerID2)
            .update(
          {
            'id': peerID2,
            'name': peerName2,
            'timestamp': widget.pin != null && widget.pin.length > 0
                ? widget.pin
                : FieldValue.serverTimestamp(),
            'content': content,
            'badge': '0',
            'profileImage': peerUrl2,
            'type': type,
            'archive': false,
          },
        ).then((onValue) async {
          try {
            await FirebaseFirestore.instance
                .collection("chatList")
                .doc(peerID2)
                .collection(peerID2)
                .doc(userID)
                .get()
                .then((doc) async {
              debugPrint(doc["badge"]);
              if (doc["badge"] != null) {
                badgeCount = int.parse(doc["badge"]);
                await FirebaseFirestore.instance
                    .collection("chatList")
                    .doc(peerID2)
                    .collection(peerID2)
                    .doc(userID)
                    .update({
                  'id': userID,
                  'name': globalName,
                  'timestamp': widget.pin != null && widget.pin.length > 0
                      ? widget.pin
                      : FieldValue.serverTimestamp(),
                  'content': content,
                  'badge': '${badgeCount + 1}',
                  'profileImage': globalImage,
                  'type': type,
                  'archive': false,
                });
              }
            });
          } catch (e) {
            await FirebaseFirestore.instance
                .collection("chatList")
                .doc(peerID2)
                .collection(peerID2)
                .doc(userID)
                .update(
              {
                'id': userID,
                'name': globalName,
                'timestamp': widget.pin != null && widget.pin.length > 0
                    ? widget.pin
                    : FieldValue.serverTimestamp(),
                'content': content,
                'badge': '${badgeCount + 1}',
                'profileImage': globalImage,
                'type': type,
                'archive': false,
              },
            );
            print(e);
          }
        });
      });

      // String notificationPayload =
      //     "{\"to\":\"${peerToken}\",\"priority\":\"high\",\"data\":{\"type\":\"100\",\"user_id\":\"${widget.currentuser}\",\"user_name\":\"${widget.currentusername}\",\"user_pic\":\"${widget.currentuserimage}\",\"user_device_type\":\"android\",\"msg\":\"${content}\",\"time\":\"${DateTime.now().millisecondsSinceEpoch}\"},\"notification\":{\"title\":\"${widget.currentusername}\",\"body\":\"$content\",\"user_id\":\"${widget.currentuser}\",\"user_pic\":\"${widget.currentuserimage}\",\"user_device_type\":\"android\",\"sound\":\"default\"},\"priority\":\"high\"}";
      // createNotification(notificationPayload);
      // listScrollController.animateTo(0.0,
      //     duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {}
  }

  void onForwardGroup(groupMsgUserId, groupMsgId, groupMsgPeerName,
      groupMsgPeerImage, groupMsgContent, groupMsgType, groupMsgContact) {
    // 0 = text
    // 1 = image
    // 2 = sticker
    // 4 = video
    // 5 = file
    // 6 = audio
    // 7 = contact
    // 8 = location

    var timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    var documentReference = FirebaseFirestore.instance
        .collection('groupMessages')
        .doc(groupMsgId)
        .collection(groupMsgId)
        .doc(timeStamp);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        {
          'idFrom': userID,
          'fromName': globalName,
          'idTo': groupMsgId,
          'timestamp': FieldValue.serverTimestamp(),
          'content': groupMsgContent,
          'contact': groupMsgContact,
          'type': groupMsgType,
          "read": false,
          "delete": [],
          // "lat": lat,
          // "long": long,
          // "replyType": replyType
        },
      );
    }).then((onValue) async {
      var groupKey = [];
      var msg = [];
      var type = [];
      var contact = [];
      var time = [];

      var splitUserIds = jsonDecode(groupMsgUserId);

      for (var i = 0; i < splitUserIds.length; i++) {
        groupKey.add(groupMsgId);
        msg.add(groupMsgContent);
        type.add(groupMsgType);
        contact.add(groupMsgContact);
        time.add(timeStamp);
      }

      for (var i = 0; i < splitUserIds.length; i++) {
        onSendGroupMessage(
            groupKey[i], splitUserIds[i], msg[i], type[i], contact[i], time[i]);
      }
    });
  }

  Future<void> onSendGroupMessage(String groupKey, String groupIds,
      String content, int type, String contact, String time) async {
    int badgeCount = 0;

    try {
      await FirebaseFirestore.instance
          .collection("chatList")
          .doc(groupIds)
          .collection(groupIds)
          .doc(groupKey)
          .get()
          .then((doc) async {
        debugPrint(doc["badge"]);
        if (doc["badge"] != null) {
          badgeCount = int.parse(doc["badge"]);
          await FirebaseFirestore.instance
              .collection("chatList")
              .doc(groupIds)
              .collection(groupIds)
              .doc(groupKey)
              .update({
            'timestamp': FieldValue.serverTimestamp(),
            'content': content,
            'badge': '${badgeCount + 1}',
            // groupIds == widget.currentuser ? "0" : '${badgeCount + 1}',
            'type': type,
            'contact': contact,
          });
        }
      });
    } catch (e) {
      print("EEEEEEEEEE: " + e.toString());
    }
  }

  download(url, type) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      localImage.add(url);

      preferences.setStringList("localImage", localImage);
    });

    print(localImage);
    // setState(() {
    //   totalData = "0";
    //   isDownloading = true;
    // });
    String testrt = '';
    if (type == 1) {
      testrt = "jpeg";
    }
    if (type == 4) {
      testrt = "mp4";
    }
    if (type == 5) {
      testrt = "pdf";
    }

    try {
      Dio dio = Dio();

//    String path = await ExtStorage.getExternalStoragePublicDirectory(
//     ExtStorage.DIRECTORY_DOWNLOADS);
// print(path);
      var time = DateTime.now().millisecondsSinceEpoch.toString();
      await dio.download(url, "/sdcard/download/" + "$time." + "$testrt",
          onReceiveProgress: (rec, total) {
        // setState(() {
        //   int percentage = ((rec / total) * 100).floor();
        //   totalData = percentage.toString();
        //   print(percentage);
        // });
      }).then((value) {
        print("👉🏿👉🏿👉🏿👉🏿👉🏿👉🏿👉🏿👉🏿");
        // setState(() {
        //   //isDownloading = false;
        //   Toast.show("Download successfully", context,
        //       duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        // });
      });
    } catch (e) {
      setState(() {
        //isDownloading = false;
        Toast.show("Download Failed!", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      });
    }
  }

  Future<http.Response> sendNotification(
      String peerToken, String content) async {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
      },
      body: jsonEncode({
        "to": peerToken,
        "priority": "high",
        "data": {
          "type": "100",
          "user_id": userID,
          "title": content,
          "message": globalName,
          "time": DateTime.now().millisecondsSinceEpoch,
          "sound": "default",
          "vibrate": "300",
        },
        "notification": {
          "vibrate": "300",
          "priority": "high",
          "body": content,
          "title": globalName,
          "sound": "default",
        }
      }),
    );
    return response;
  }

  Future<http.Response> sendImageNotification(
      String peerToken, String content) async {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
      },
      body: jsonEncode({
        "to": peerToken,
        "priority": "high",
        "data": {
          "type": "100",
          "user_id": userID,
          "title": content,
          "message": globalName,
          "image": content,
          "time": DateTime.now().millisecondsSinceEpoch,
          "sound": "default",
          "vibrate": "300",
        },
        "notification": {
          "vibrate": "300",
          "priority": "high",
          "body": "📷 Image",
          "title": globalName,
          "sound": "default",
          "image": content,
        }
      }),
    );
    return response;
  }

  Future<http.Response> sendVideoNotification(
      String peerToken, String content) async {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
      },
      body: jsonEncode({
        "to": peerToken,
        "priority": "high",
        "data": {
          "type": "100",
          "user_id": userID,
          "title": content,
          "message": globalName,
          "time": DateTime.now().millisecondsSinceEpoch,
          "sound": "default",
          "vibrate": "300",
        },
        "notification": {
          "vibrate": "300",
          "priority": "high",
          "body": "🎥 Video",
          "title": globalName,
          "sound": "default",
        }
      }),
    );
    return response;
  }

  Future<http.Response> sendFileNotification(
      String peerToken, String content) async {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
      },
      body: jsonEncode({
        "to": peerToken,
        "priority": "high",
        "data": {
          "type": "100",
          "user_id": userID,
          "title": content,
          "message": globalName,
          "time": DateTime.now().millisecondsSinceEpoch,
          "sound": "default",
          "vibrate": "300",
        },
        "notification": {
          "vibrate": "300",
          "priority": "high",
          "body": "📄 File",
          "title": globalName,
          "sound": "default",
        }
      }),
    );
    return response;
  }

  Future<http.Response> sendAudioNotification(
      String peerToken, String content) async {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
      },
      body: jsonEncode({
        "to": peerToken,
        "priority": "high",
        "data": {
          "type": "100",
          "user_id": userID,
          "title": content,
          "message": globalName,
          "time": DateTime.now().millisecondsSinceEpoch,
          "sound": "default",
          "vibrate": "300",
        },
        "notification": {
          "vibrate": "300",
          "priority": "high",
          "body": "🔊 Voice Message",
          "title": globalName,
          "sound": "default",
        }
      }),
    );
    return response;
  }

  Future<http.Response> sendCallNotification(
      String peerToken, String content) async {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
      },
      body: jsonEncode({
        "to": peerToken,
        "priority": "high",
        "data": {
          "type": "100",
          "user_id": userID,
          "title": content,
          "user_pic": globalImage,
          "message": globalName,
          "time": DateTime.now().millisecondsSinceEpoch,
          "sound": "custom.mp3",
          "vibrate": "300",
        },
        "notification": {
          "vibrate": "300",
          "priority": "high",
          "body": content,
          "title": globalName,
          "sound": "custom.mp3",
        }
      }),
    );
    return response;
  }
}

List _searchResult = [];

List msgList = [];
